import 'dart:async';
import 'dart:convert';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';
import 'package:tripsplit/features/travel_map/presentation/travel_place_sheet.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/account_local_storage.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/features/travel_map/data/travel_location_service.dart';
import 'package:tripsplit/features/travel_map/data/travel_places_repository.dart';
import 'package:tripsplit/features/travel_map/domain/travel_place.dart';
import 'package:tripsplit/features/travel_map/presentation/travel_map_page.dart';
import 'package:tripsplit/features/travel_map/presentation/travel_map_canvas.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

const lisbon = TravelPlace(
  id: 1,
  placeKey: 'lisbon',
  visitedOn: '2026-10-05',
  city: 'Lisbon',
  region: '',
  country: 'Portugal',
  countryCode: 'PT',
  latitude: 38.72,
  longitude: -9.14,
);
const riga = TravelPlace(
  id: 2,
  placeKey: 'riga',
  visitedOn: '2026-08-14',
  city: 'Riga',
  region: '',
  country: 'Latvia',
  countryCode: 'LV',
  latitude: 56.95,
  longitude: 24.11,
);
const rome = TravelPlace(
  id: 3,
  placeKey: 'rome',
  visitedOn: '2026-09-12',
  city: 'Rome',
  region: '',
  country: 'Italy',
  countryCode: 'IT',
  latitude: 41.90,
  longitude: 12.49,
);

class FakePlaces implements TravelPlacesRepository {
  final session = AccountDataSession()..activate(7);
  List<TravelPlace> places = [lisbon, riga, rome];
  int saves = 0, deletes = 0;
  VisitDetails? lastDetails;
  String? lastDate;
  Uint8List? photoBytes;
  @override
  Future<Uint8List?> photo(TravelPlace place) async => photoBytes;
  @override
  AccountDataLease capture() => session.capture();
  @override
  Future<TravelPlacesResult> load() async => TravelPlacesResult(places);
  @override
  Future<TravelPlace> save(
    PlaceCandidate place,
    String date, {
    VisitDetails details = const VisitDetails(),
  }) async {
    saves++;
    lastDetails = details;
    lastDate = date;
    return TravelPlace.fromJson({
      ...place.toJson(),
      'id': 4,
      'place_key': 'saved',
      'visited_on': date,
    });
  }

  @override
  Future<void> delete(int id) async {
    deletes++;
  }
}

class FakeLocations implements TravelLocationService {
  int here = 0, searches = 0;
  bool denied = false;
  @override
  Future<PlaceCandidate> currentCity() async {
    here++;
    if (denied) throw const TravelLocationError('denied');
    return lisbon;
  }

  @override
  Future<List<PlaceCandidate>> search(String query) async {
    searches++;
    return [lisbon];
  }
}

class FakeApi implements ApiClient {
  Map<String, dynamic> response = {
    'places': [lisbon.toJson()],
  };
  Map<String, dynamic>? sent;
  int requests = 0;
  ApiException? error;
  Completer<Map<String, dynamic>>? pending;
  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    requests++;
    sent = body;
    if (error != null) throw error!;
    return pending?.future ?? response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget app(
  Widget page, {
  bool dark = false,
  String locale = 'en',
  double scale = 1,
}) => MaterialApp(
  theme: dark ? AppTheme.dark() : AppTheme.light(),
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: RepaintBoundary(key: const ValueKey('preview'), child: page),
);
Future<void> open(
  WidgetTester tester,
  FakePlaces repo,
  FakeLocations locations, {
  bool dark = false,
  double width = 390,
  double scale = 1,
  String locale = 'en',
  bool tripActions = false,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.runAsync(TravelCountryShape.load);
  await tester.pumpWidget(
    app(
      TravelMapPage(
        repository: repo,
        locations: locations,
        loadTrips: tripActions
            ? () async => [
                TripModel.fromLegacyMap({'id': 9, 'name': 'Latvia'}),
              ]
            : null,
      ),
      dark: dark,
      scale: scale,
      locale: locale,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'cache belongs to account and is used only for network failure',
    () async {
      final api = FakeApi(), session = AccountDataSession()..activate(1);
      final repo = ApiTravelPlacesRepository(api, AccountLocalStorage(session));
      expect((await repo.load()).places.single.city, 'Lisbon');
      api.error = const ApiException('offline', isNetworkError: true);
      expect((await repo.load()).offline, isTrue);
      session.activate(2);
      await expectLater(repo.load(), throwsA(isA<ApiException>()));
      session.activate(1);
      api.error = const ApiException('unauthorized', statusCode: 401);
      await expectLater(repo.load(), throwsA(isA<ApiException>()));
    },
  );
  test(
    'save sends city and confirmed date; delete updates offline cache',
    () async {
      final api = FakeApi(), session = AccountDataSession()..activate(1);
      final repo = ApiTravelPlacesRepository(api, AccountLocalStorage(session));
      api.response = {'place': lisbon.toJson()};
      await repo.save(lisbon, '2026-10-05');
      expect(api.sent, {
        'city': lisbon.city,
        'region': lisbon.region,
        'country': lisbon.country,
        'country_code': lisbon.countryCode,
        'latitude': lisbon.latitude,
        'longitude': lisbon.longitude,
        'visited_on': '2026-10-05',
        'title': '',
      });
      // Real candidates are not saved records, so ensure only candidate fields.
      api.response = {'ok': true};
      await repo.delete(1);
      expect(api.sent, {'id': 1});
      api.error = const ApiException('offline', isNetworkError: true);
      expect((await repo.load()).places, isEmpty);
    },
  );
  test('late response cannot populate a different account cache', () async {
    final api = FakeApi(), session = AccountDataSession()..activate(1);
    final store = AccountLocalStorage(session),
        repo = ApiTravelPlacesRepository(api, AccountLocalStorage(session));
    api.pending = Completer();
    final load = repo.load();
    final rejected = expectLater(load, throwsA(isA<ApiException>()));
    session.activate(2);
    api.pending!.complete({
      'places': [lisbon.toJson()],
    });
    await rejected;
    expect(await store.read(ApiTravelPlacesRepository.cacheKey), isNull);
  });
  test('photo cache is versioned and isolated between accounts', () async {
    final api = FakeApi(), session = AccountDataSession()..activate(1);
    final repo = ApiTravelPlacesRepository(api, AccountLocalStorage(session));
    final place = TravelPlace.fromJson({
      ...lisbon.toJson(),
      'has_photo': true,
      'photo_version': 1,
    });
    api.response = {
      'photo_base64': base64Encode([1, 2, 3]),
    };
    expect(await repo.photo(place), [1, 2, 3]);
    final count = api.requests;
    api.error = const ApiException('offline', isNetworkError: true);
    expect(await repo.photo(place), [1, 2, 3]);
    expect(api.requests, count);
    final updated = TravelPlace.fromJson({
      ...place.toJson(),
      'photo_version': 2,
    });
    await expectLater(repo.photo(updated), throwsA(isA<ApiException>()));
    session.activate(2);
    await expectLater(repo.photo(place), throwsA(isA<ApiException>()));
  });
  test(
    'save sends private visit changes and photo without modifying trip',
    () async {
      final api = FakeApi(), session = AccountDataSession()..activate(1);
      final repo = ApiTravelPlacesRepository(api, AccountLocalStorage(session));
      api.response = {'place': lisbon.toJson()};
      await repo.save(
        lisbon,
        lisbon.visitedOn,
        details: VisitDetails(
          id: 1,
          tripId: 9,
          title: 'Weekend',
          photo: Uint8List.fromList([1, 2, 3]),
        ),
      );
      expect(api.sent!['id'], 1);
      expect(api.sent!['trip_id'], 9);
      expect(api.sent!['title'], 'Weekend');
      expect(api.sent!['photo_base64'], base64Encode([1, 2, 3]));
      expect(api.sent!.containsKey('image_path'), isFalse);
    },
  );
  testWidgets(
    'trip visit requires confirmation and preserves selected trip/date',
    (tester) async {
      final repo = FakePlaces(), locations = FakeLocations();
      final trip = TripModel.fromLegacyMap({
        'id': 9,
        'name': 'Portugal weekend',
        'date_from': '2026-10-05',
        'destinations': [lisbon.toJson()],
      });
      await tester.runAsync(TravelCountryShape.load);
      await tester.pumpWidget(
        app(
          TravelMapPage(
            repository: repo,
            locations: locations,
            loadTrips: () async => [trip],
          ),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> choose() async {
        await tester.tap(find.byKey(const ValueKey('travel-map-from-trip')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Portugal weekend'));
        await tester.pumpAndSettle();
      }

      await choose();
      expect(repo.saves, 0);
      expect(locations.here, 0);
      await tester.tap(find.byTooltip('Close').last);
      await tester.pumpAndSettle();
      expect(repo.saves, 0);
      await choose();
      await tester.enterText(
        find.byKey(const ValueKey('travel-visit-title')),
        'Our weekend',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('travel-place-save')),
      );
      await tester.tap(find.byKey(const ValueKey('travel-place-save')));
      await tester.pumpAndSettle();
      expect(repo.saves, 1);
      expect(repo.lastDetails!.tripId, 9);
      expect(repo.lastDetails!.title, 'Our weekend');
      expect(repo.lastDate, '2026-10-05');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'repeated city visits share one marker and can be paged and edited',
    (tester) async {
      final repo = FakePlaces()
        ..places = [
          TravelPlace.fromJson({...lisbon.toJson(), 'title': 'First visit'}),
          TravelPlace.fromJson({
            ...lisbon.toJson(),
            'id': 5,
            'title': 'Second visit',
            'visited_on': '2026-10-06',
          }),
        ];
      await open(tester, repo, FakeLocations(), width: 320, scale: 1.6);
      await tester.tap(find.byKey(const ValueKey('travel-pin-5')));
      await tester.pumpAndSettle();
      expect(find.text('Second visit'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Next visit'));
      await tester.tap(find.byTooltip('Next visit'));
      await tester.pumpAndSettle();
      expect(find.text('First visit'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const ValueKey('travel-edit-visit')),
      );
      await tester.tap(find.byKey(const ValueKey('travel-edit-visit')));
      await tester.pumpAndSettle();
      expect(find.byType(TravelPlaceSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'gallery choice can be previewed, removed and saved without uploading cancelled photo',
    (tester) async {
      final bytes = (await rootBundle.load(
        'assets/branding/logo_full.png',
      )).buffer.asUint8List();
      VisitDetails? saved;
      await tester.pumpWidget(
        app(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<TravelPlace>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => TravelPlaceSheet(
                    locations: FakeLocations(),
                    initial: lisbon,
                    existing: lisbon,
                    isCurrent: () => true,
                    pickPhoto: () async => bytes,
                    save: (place, date, details) async {
                      saved = details;
                      return lisbon;
                    },
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('travel-visit-photo')));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(saved, isNull);
      await tester.tap(find.text('Remove photo'));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);
      await tester.ensureVisible(
        find.byKey(const ValueKey('travel-place-save')),
      );
      await tester.tap(find.byKey(const ValueKey('travel-place-save')));
      await tester.pumpAndSettle();
      expect(saved!.id, lisbon.id);
      expect(saved!.removePhoto, isTrue);
      expect(saved!.photo, isNull);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'no permanent list or location request; marker shows city and date; deletion confirms',
    (tester) async {
      final repo = FakePlaces(), locations = FakeLocations();
      await open(tester, repo, locations);
      expect(locations.here, 0);
      expect(locations.searches, 0);
      expect(find.text('Lisbon'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('travel-pin-1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('travel-place-popup')), findsOneWidget);
      expect(find.text('Lisbon'), findsOneWidget);
      expect(find.text('Portugal'), findsOneWidget);
      await tester.tap(find.byTooltip('Remove visit'));
      await tester.pumpAndSettle();
      expect(repo.deletes, 0);
      await tester.tap(find.widgetWithText(TextButton, 'Remove visit').last);
      await tester.pumpAndSettle();
      expect(repo.deletes, 1);
      expect(find.byKey(const ValueKey('travel-pin-1')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('manual search and here require separate confirmation', (
    tester,
  ) async {
    final repo = FakePlaces(), locations = FakeLocations();
    await open(tester, repo, locations);
    await tester.tap(find.byKey(const ValueKey('travel-map-here')));
    await tester.pumpAndSettle();
    expect(locations.here, 1);
    expect(repo.saves, 0);
    await tester.tap(find.byTooltip('Close').last);
    await tester.pumpAndSettle();
    expect(repo.saves, 0);
    await tester.tap(find.byKey(const ValueKey('travel-map-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('travel-place-search')),
      'Lisbon',
    );
    await tester.tap(find.byKey(const ValueKey('travel-place-search-submit')));
    await tester.pumpAndSettle();
    expect(locations.searches, 1);
    expect(repo.saves, 0);
    await tester.tap(find.text('Lisbon').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('travel-place-save')));
    await tester.tap(find.byKey(const ValueKey('travel-place-save')));
    await tester.pumpAndSettle();
    expect(repo.saves, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('permission refusal preserves manual addition', (tester) async {
    final repo = FakePlaces(), locations = FakeLocations()..denied = true;
    await open(tester, repo, locations);
    await tester.tap(find.byKey(const ValueKey('travel-map-here')));
    await tester.pumpAndSettle();
    expect(repo.saves, 0);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const ValueKey('travel-map-add')))
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });
  for (final locale in ['en', 'lv', 'es']) {
    testWidgets('small phone and larger type: $locale', (tester) async {
      await open(
        tester,
        FakePlaces(),
        FakeLocations(),
        dark: true,
        width: 320,
        scale: 1.6,
        locale: locale,
      );
      await tester.tap(find.byKey(const ValueKey('travel-pin-1')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  if (const bool.fromEnvironment('TRAVEL_MAP_PREVIEWS')) {
    for (final dark in [false, true]) {
      testWidgets('preview ${dark ? 'dark' : 'light'}', (tester) async {
        debugDisableShadows = false;
        final font = FontLoader('Inter')
          ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
        await font.load();
        await (FontLoader(
          'MaterialIcons',
        )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
        final repo = FakePlaces()
          ..places = [
            lisbon,
            rome,
            TravelPlace.fromJson({
              ...riga.toJson(),
              'has_photo': true,
              'photo_version': 1,
              'title': 'Weekend in Riga',
              'trip_id': 9,
              'trip_name': 'Latvia',
            }),
          ];
        repo.photoBytes = (await rootBundle.load(
          'assets/branding/logo_full.png',
        )).buffer.asUint8List();
        await open(
          tester,
          repo,
          FakeLocations(),
          dark: dark,
          tripActions: true,
        );
        await tester.runAsync(
          () => precacheImage(
            MemoryImage(repo.photoBytes!),
            tester.element(find.byType(TravelMapPage)),
          ),
        );
        await tester.tap(find.byKey(const ValueKey('travel-pin-2')));
        await tester.pumpAndSettle();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('preview')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 3);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final dir = Directory('../output/design/travel-map')
            ..createSync(recursive: true);
          File(
            '${dir.path}/${dark ? 'dark' : 'light'}-map.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
        debugDisableShadows = true;
      });
    }
  }
}
