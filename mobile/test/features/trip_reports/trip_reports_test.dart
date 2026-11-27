import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/maps/world_countries.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/features/auth/data/models/notification_preferences_model.dart';
import 'package:tripsplit/features/auth/domain/entities/notification_preferences.dart';
import 'package:tripsplit/features/subscriptions/domain/entities/premium_access.dart';
import 'package:tripsplit/features/trip_reports/data/trip_reports_repository.dart';
import 'package:tripsplit/features/trip_reports/domain/year_summary.dart';
import 'package:tripsplit/features/trip_reports/presentation/year_summary_home_banner.dart';
import 'package:tripsplit/features/trip_reports/presentation/year_summary_page.dart';
import 'package:tripsplit/features/trip_reports/presentation/trip_export_flow.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class _Api implements ApiClient {
  _Api(this.response);

  final Map<String, dynamic> response;
  String? path;
  Map<String, dynamic>? query;
  Map<String, String>? headers;

  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    this.path = path;
    this.query = query;
    this.headers = headers;
    return response;
  }

  @override
  Future<void> revokeCurrentSession() async {}
}

class _Repository implements TripReportsRepository {
  _Repository(this.load);

  final Future<YearSummary> Function(int? year) load;
  final List<int?> requests = [];
  final List<TripExportFormat> exports = [];
  Object exportFailure = StateError('Export unavailable in test');

  @override
  Future<YearSummary> loadYearSummary({int? year}) {
    requests.add(year);
    return load(year);
  }

  @override
  Future<TripExportFile> exportTrip({
    required int tripId,
    required TripExportFormat format,
    required String locale,
  }) async {
    exports.add(format);
    throw exportFailure;
  }
}

Map<String, dynamic> _summaryMap({int year = 2026, int trips = 3}) => {
  'year': year,
  'available_years': [2026, 2025],
  'trip_count': trips,
  'days_away': 23,
  'expense_count': 40,
  'countries': [
    {'code': 'IT', 'name': 'Italy'},
    {'code': 'LV', 'name': 'Latvia'},
  ],
  'cities': ['Rome', 'Riga'],
  'currency_code': 'JPY',
  'total_share': 123456.0,
  'conversion_complete': false,
  'biggest_trip': {'name': 'Summer', 'share': 80000.0},
  'top_category': {'key': 'food', 'share': 3000.0},
  'top_companion': {'nickname': 'Anna', 'trip_count': 2},
};

Widget _page(
  TripReportsRepository repository, {
  Locale? locale,
  DateTime? today,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  locale: locale ?? const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: YearSummaryPage(
    repository: repository,
    clock: () => today ?? DateTime(2027, 3, 1),
  ),
);

void main() {
  for (final pdfAllowed in [false, true]) {
    testWidgets('export formats respect finished status: $pdfAllowed', (
      tester,
    ) async {
      final repository = _Repository(
        (_) async => YearSummary.fromMap(_summaryMap()),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => unawaited(
                  runTripExport(
                    context,
                    repository,
                    tripId: 7,
                    pdfAllowed: pdfAllowed,
                  ),
                ),
                child: const Text('Export'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Export'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('trip-export-pdf')),
        pdfAllowed ? findsOneWidget : findsNothing,
      );
      expect(find.byKey(const ValueKey('trip-export-csv')), findsOneWidget);
      expect(
        find.text('PDF export is available after you finish the trip.'),
        pdfAllowed ? findsNothing : findsOneWidget,
      );
      if (pdfAllowed) {
        repository.exportFailure = const ApiException(
          'Server trip status changed',
          code: 'trip_not_finished',
          statusCode: 409,
        );
      }
      await tester.tap(
        find.byKey(
          ValueKey(pdfAllowed ? 'trip-export-pdf' : 'trip-export-csv'),
        ),
      );
      await tester.pumpAndSettle();
      expect(repository.exports, [
        pdfAllowed ? TripExportFormat.pdf : TripExportFormat.csv,
      ]);
      if (pdfAllowed) {
        expect(
          find.text('PDF export is available after you finish the trip.'),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'closed year season shows an explanation without retry or sharing',
    (tester) async {
      final repository = _Repository(
        (_) async => throw const ApiException(
          'Out of season',
          code: 'year_summary_unavailable',
          statusCode: 403,
        ),
      );
      await tester.pumpWidget(_page(repository));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Your previous year’s summary is available from 1 January to 31 March.',
        ),
        findsOneWidget,
      );
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byKey(const ValueKey('year-summary-share')), findsNothing);
      expect(repository.requests, [null]);
    },
  );

  test('summary parses all fields and tolerates nulls', () {
    final full = YearSummary.fromMap(_summaryMap());
    expect(full.countries, ['Italy', 'Latvia']);
    expect(full.biggestTripName, 'Summer');
    expect(full.topCompanionTrips, 2);
    expect(full.conversionComplete, isFalse);
    final empty = YearSummary.fromMap({
      'year': 2020,
      'biggest_trip': null,
      'top_category': null,
      'top_companion': null,
    });
    expect(empty.tripCount, 0);
    expect(empty.biggestTripName, isNull);
    expect(empty.topCategoryKey, isNull);
    expect(empty.conversionComplete, isTrue);
  });

  test(
    'export sends the trip, format and language, and decodes the file',
    () async {
      final api = _Api({
        'ok': true,
        'filename': 'splyto-rome-2026.csv',
        'mime_type': 'text/csv',
        'content_base64': base64Encode(utf8.encode('a;b')),
      });
      final file = await ApiTripReportsRepository(
        api,
      ).exportTrip(tripId: 7, format: TripExportFormat.csv, locale: 'lv');
      expect(api.path, contains('trip_export'));
      expect(api.query, {'format': 'csv', 'locale': 'lv'});
      expect(api.headers, {'X-Trip-Id': '7'});
      expect(file.name, 'splyto-rome-2026.csv');
      expect(utf8.decode(file.bytes), 'a;b');
    },
  );

  test('email report preference reads, defaults and copies', () {
    NotificationPreferences parse(Map<String, dynamic> preferences) =>
        NotificationPreferencesModel.fromApiMap({'preferences': preferences});
    expect(parse({}).emailTripReportEnabled, isTrue);
    final off = parse({'email_trip_report_enabled': false});
    expect(off.emailTripReportEnabled, isFalse);
    expect(off.copyWith().emailTripReportEnabled, isFalse);
    expect(
      off.copyWith(emailTripReportEnabled: true).emailTripReportEnabled,
      isTrue,
    );
  });

  test('push categories read their own keys or fall back to old ones', () {
    NotificationPreferences parse(Map<String, dynamic> preferences) =>
        NotificationPreferencesModel.fromApiMap({'preferences': preferences});
    final split = parse({
      'push': {
        'trip_updates': true,
        'settlement_updates': true,
        'comments': false,
        'reminders': false,
      },
    });
    expect(split.pushCommentsEnabled, isFalse);
    expect(split.pushTripInvitesEnabled, isTrue);
    expect(split.pushRemindersEnabled, isFalse);
    expect(split.pushPaymentsEnabled, isTrue);
    final older = parse({
      'push': {'trip_updates': false, 'settlement_updates': true},
    });
    expect(older.pushCommentsEnabled, isFalse);
    expect(older.pushTripStatusEnabled, isFalse);
    expect(older.pushPaymentRequestsEnabled, isTrue);
    expect(parse({}).pushRemindersEnabled, isTrue);
    expect(older.pushLocationEnabled, isTrue);
    expect(
      parse({
        'push': {'location': false},
      }).pushLocationEnabled,
      isFalse,
    );
    expect(
      older.copyWith(pushCommentsEnabled: true).pushCommentsEnabled,
      isTrue,
    );
  });

  test(
    'Premium features stay offered after display freshness, until expiry',
    () {
      final now = DateTime.now().toUtc();
      String stamp(DateTime value) =>
          '${value.toIso8601String().split('.').first}Z';
      PremiumAccess? access(String plan, DateTime? end) =>
          PremiumAccess.fromMap({
            'schema_version': 1,
            'account_id': 1,
            'plan': plan,
            'source': plan == 'premium' ? 'admin_grant' : null,
            'expires_at': end == null ? null : stamp(end),
            'checked_at': stamp(now),
            'refresh_after_seconds': 1,
            'billing_enabled': false,
            'limits_enforced': false,
          }, accountId: 1);
      expect(
        access(
          'premium',
          now.add(const Duration(days: 2)),
        )?.offersPremiumFeatures,
        isTrue,
      );
      expect(access('free', null)?.offersPremiumFeatures, isFalse);
      expect(access('unknown', null)?.offersPremiumFeatures, isFalse);
    },
  );

  testWidgets('one screen shows the story and private details', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(WorldCountry.load);
    final repository = _Repository(
      (_) async => YearSummary.fromMap({
        ..._summaryMap(),
        'available_years': [2026],
      }),
    );
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    final story = find.byKey(const ValueKey('year-summary-story'));
    Finder inStory(Finder finder) =>
        find.descendant(of: story, matching: finder);
    expect(inStory(find.text('2026')), findsOneWidget);
    expect(inStory(find.text('YOUR YEAR IN TRAVEL')), findsOneWidget);
    for (final label in ['TRIPS', 'DAYS', 'COUNTRIES', 'CITIES']) {
      expect(inStory(find.text(label)), findsOneWidget);
    }
    expect(inStory(find.text('23')), findsOneWidget);
    expect(inStory(find.text('Italy\u00A0· Latvia')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('year-summary-story-map')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('year-summary-story-logo')),
      findsOneWidget,
    );
    // The private details are outside the shared image.
    for (final key in [
      'year-summary-spending',
      'year-summary-biggest',
      'year-summary-category',
      'year-summary-companion',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget);
      expect(inStory(find.byKey(ValueKey(key))), findsNothing);
    }
    expect(find.text('Anna · 2'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    // A missing rate makes the spending an estimate, with a note.
    expect(find.textContaining('≈ '), findsOneWidget);
    expect(find.byKey(const ValueKey('year-summary-partial')), findsOneWidget);
    expect(find.textContaining('.00'), findsNothing);
    expect(find.byKey(const ValueKey('year-summary-share')), findsOneWidget);
    expect(find.byKey(const ValueKey('year-summary-close')), findsOneWidget);
    // More detail than the card, for the user only.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('year-summary-all-cities')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('40'), findsOneWidget);
    expect(find.text('Italy, Latvia'), findsOneWidget);
    expect(find.text('Rome, Riga'), findsOneWidget);
    expect(
      inStory(find.byKey(const ValueKey('year-summary-all-cities'))),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  test('the summary keeps country codes next to their names', () {
    final summary = YearSummary.fromMap({
      ..._summaryMap(),
      'countries': [
        {'code': 'it', 'name': 'Italy'},
        {'code': '', 'name': 'Nowhere'},
        {'code': 'LV', 'name': ''},
      ],
    });
    expect(summary.countries, ['Italy', 'Nowhere']);
    expect(summary.countryCodes, ['IT']);
  });

  testWidgets('the Home card opens the summary as a pop-up that closes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _Repository(
      (_) async => YearSummary.fromMap(_summaryMap()),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: YearSummaryHomeBanner(
                year: 2026,
                onOpen: () => showYearSummary(context, repository),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Your 2026 in travel'), findsOneWidget);
    expect(find.text('NEW'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('year-summary-home-banner')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('year-summary-story')), findsOneWidget);
    // The app stays underneath, dimmed.
    expect(find.text('Your 2026 in travel'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('year-summary-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('year-summary-story')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('year-summary-home-banner')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 300));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('year-summary-story')), findsNothing);
  });

  testWidgets('December and January get the New Year look', (tester) async {
    final repository = _Repository(
      (_) async => YearSummary.fromMap(_summaryMap()),
    );
    await tester.pumpWidget(_page(repository, today: DateTime(2027, 1, 2)));
    await tester.pumpAndSettle();
    expect(find.text('HAPPY NEW YEAR · SPLYTO.EU'), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);
    await tester.pumpWidget(_page(repository, today: DateTime(2027, 2, 1)));
    await tester.pumpAndSettle();
    expect(find.textContaining('HAPPY NEW YEAR'), findsNothing);
    expect(find.text('SPLYTO.EU'), findsOneWidget);
    expect(yearSummaryHolidaySeason(DateTime(2026, 12, 31)), isTrue);
    expect(yearSummaryHolidaySeason(DateTime(2027, 2, 1)), isFalse);
  });

  testWidgets('a year without places shows a globe and no zero counts', (
    tester,
  ) async {
    await tester.runAsync(WorldCountry.load);
    final repository = _Repository(
      (_) async => YearSummary.fromMap({
        ..._summaryMap(),
        'countries': <Object>[],
        'cities': <Object>[],
        'days_away': 0,
        'top_companion': null,
      }),
    );
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('year-summary-story-globe')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('year-summary-story-map')), findsNothing);
    expect(find.text('TRIPS'), findsOneWidget);
    for (final label in ['DAYS', 'COUNTRIES', 'CITIES']) {
      expect(find.text(label), findsNothing);
    }
    expect(
      find.byKey(const ValueKey('year-summary-story-countries')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('year-summary-companion')), findsNothing);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('the shared story never carries amounts', (tester) async {
    final repository = _Repository(
      (_) async =>
          YearSummary.fromMap({..._summaryMap(), 'conversion_complete': true}),
    );
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    final story = find.byKey(const ValueKey('year-summary-story'));
    expect(
      find.descendant(of: story, matching: find.textContaining('¥')),
      findsNothing,
    );
    expect(find.byType(Switch), findsNothing);
  });

  testWidgets('many countries show eight names and count the rest', (
    tester,
  ) async {
    final repository = _Repository(
      (_) async => YearSummary.fromMap({
        ..._summaryMap(),
        'countries': [
          for (final name in 'ABCDEFGHIJ'.split(''))
            {'code': name, 'name': name},
        ],
      }),
    );
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('year-summary-story-countries')),
          )
          .data,
      'A · B · C · D · E · F · G · H · +2'.replaceAll(' ·', '\u00A0·'),
    );
  });

  testWidgets('one trip reads in the singular', (tester) async {
    final repository = _Repository(
      (_) async => YearSummary.fromMap(_summaryMap(trips: 1)),
    );
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    expect(find.text('TRIP'), findsOneWidget);
  });

  testWidgets('an empty year has a message and no card', (tester) async {
    final repository = _Repository(
      (_) async => YearSummary.fromMap(_summaryMap(trips: 0)),
    );
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    expect(find.text('No finished trips in 2026.'), findsOneWidget);
    expect(find.byKey(const ValueKey('year-summary-story')), findsNothing);
    expect(find.byKey(const ValueKey('year-summary-share')), findsNothing);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    var fail = true;
    final repository = _Repository((_) async {
      if (fail) throw StateError('offline');
      return YearSummary.fromMap(_summaryMap());
    });
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load your year in travel."), findsOneWidget);
    fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('year-summary-story')), findsOneWidget);
    expect(repository.requests, [null, null]);
  });

  test('the year summary stays hidden in the app by default', () {
    expect(yearSummaryOfferedInApp, isFalse);
  });

  for (final locale in ['uk', 'lv', 'de']) {
    testWidgets('long translations and large text fit a small phone: $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = _Repository((_) async {
        return YearSummary.fromMap(_summaryMap());
      });
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(1.6),
          ),
          child: _page(repository, locale: Locale(locale)),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byKey(const ValueKey('year-summary-scroll')),
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  // Opt-in review images with demo data: the screen, the shared 1080 × 1350
  // card for 5, 12, 1 and no countries, and the card arriving in a chat.
  // flutter test test/features/trip_reports/trip_reports_test.dart
  //   --dart-define=YEAR_SUMMARY_PREVIEWS=true
  if (const bool.fromEnvironment('YEAR_SUMMARY_PREVIEWS')) {
    Map<String, dynamic> demo(List<(String, String)> countries, int cities) => {
      'year': 2026,
      'available_years': [2026],
      'trip_count': countries.isEmpty ? 3 : 6 + countries.length,
      'days_away': countries.isEmpty ? 11 : 20 + countries.length * 6,
      'countries': [
        for (final (code, name) in countries) {'code': code, 'name': name},
      ],
      'cities': List.generate(cities, (i) => 'City $i'),
      'currency_code': 'EUR',
      'total_share': 2480.0,
      'conversion_complete': true,
      'biggest_trip': {'name': 'Italy road trip', 'share': 860.0},
      'top_category': {'key': 'food', 'share': 700.0},
      'top_companion': {'nickname': 'Anna', 'trip_count': 4},
    };
    final cases = {
      'five': demo([
        ('IT', 'Italy'),
        ('ES', 'Spain'),
        ('PT', 'Portugal'),
        ('LV', 'Latvia'),
        ('AL', 'Albania'),
      ], 9),
      'twelve': demo([
        ('LV', 'Latvia'),
        ('GB', 'United Kingdom'),
        ('IS', 'Iceland'),
        ('US', 'United States'),
        ('MX', 'Mexico'),
        ('PT', 'Portugal'),
        ('ES', 'Spain'),
        ('MA', 'Morocco'),
        ('IT', 'Italy'),
        ('TH', 'Thailand'),
        ('JP', 'Japan'),
        ('AU', 'Australia'),
      ], 23),
      'one': demo([('IT', 'Italy')], 4),
      'none': demo([], 0),
    };
    for (final locale in ['en', 'lv']) {
      testWidgets('year summary pop-up review images: $locale', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.runAsync(() async {
          await (FontLoader(
            'Inter',
          )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
          await (FontLoader('MaterialIcons')
                ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
              .load();
          await WorldCountry.load();
        });
        final repository = _Repository(
          (_) async => YearSummary.fromMap(cases['five']!),
        );
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) => Scaffold(
                  body: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      children: [
                        const Text(
                          'Your share across all trips',
                          style: TextStyle(color: Color(0xFF697182)),
                        ),
                        const Text(
                          '€463.74',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        YearSummaryHomeBanner(
                          year: 2026,
                          onOpen: () => showYearSummary(
                            context,
                            repository,
                            clock: () => DateTime(2027, 1, 1),
                          ),
                        ),
                        const SizedBox(height: 24),
                        for (final colour in const [
                          Color(0xFFCFE9E4),
                          Color(0xFFE3EEF7),
                          Color(0xFFF3E7D6),
                        ])
                          Container(
                            height: 130,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: colour,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        Future<void> save(String name) async {
          await tester.runAsync(() async {
            final image =
                await (key.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File('../output/design/year-summary/$name.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        await save('home-$locale');
        await tester.tap(
          find.byKey(const ValueKey('year-summary-home-banner')),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/branding/logo_full_dark.png'),
            key.currentContext!,
          ),
        );
        await tester.pumpAndSettle();
        await save('app-$locale');
        await tester.drag(
          find.byKey(const ValueKey('year-summary-scroll')),
          const Offset(0, -600),
        );
        await tester.pumpAndSettle();
        await save('app-$locale-details');
      });
    }
    for (final locale in ['en', 'lv']) {
      for (final entry in cases.entries) {
        testWidgets('year summary review images: $locale ${entry.key}', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.runAsync(() async {
            await (FontLoader(
              'Inter',
            )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
            await (FontLoader('MaterialIcons')
                  ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
                .load();
            await WorldCountry.load();
          });
          final repository = _Repository(
            (_) async => YearSummary.fromMap(entry.value),
          );
          final key = GlobalKey();
          await tester.pumpWidget(
            RepaintBoundary(
              key: key,
              child: _page(
                repository,
                locale: Locale(locale),
                today: DateTime(2027, 1, 1),
              ),
            ),
          );
          await tester.runAsync(
            () => precacheImage(
              const AssetImage('assets/branding/logo_full.png'),
              key.currentContext!,
            ),
          );
          await tester.pumpAndSettle();
          Future<void> save(ui.Image image, String name) async {
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File('../output/design/year-summary/$name.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
          }

          late Uint8List shared;
          await tester.runAsync(() async {
            final image =
                await (find
                        .byKey(const ValueKey('year-summary-story'))
                        .evaluate()
                        .single
                        .findAncestorRenderObjectOfType<
                          RenderRepaintBoundary
                        >()!)
                    .toImage(pixelRatio: 3);
            await save(image, 'story-$locale-${entry.key}');
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            shared = bytes!.buffer.asUint8List();
            image.dispose();
          });
          if (entry.key != 'five') return;

          // The shared story as it arrives in a chat, in light and dark mode.
          for (final dark in [false, true]) {
            final chatKey = GlobalKey();
            await tester.pumpWidget(
              RepaintBoundary(
                key: chatKey,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: ColoredBox(
                    color: dark
                        ? const Color(0xFF0B141A)
                        : const Color(0xFFEFE7DE),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width: 230,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: dark
                                ? const Color(0xFF005C4B)
                                : const Color(0xFFD9FDD3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.memory(shared),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.runAsync(() async {
              await precacheImage(MemoryImage(shared), chatKey.currentContext!);
            });
            await tester.pumpAndSettle();
            await tester.runAsync(() async {
              final image =
                  await (chatKey.currentContext!.findRenderObject()
                          as RenderRepaintBoundary)
                      .toImage(pixelRatio: 2);
              await save(image, 'chat-$locale-${dark ? 'dark' : 'light'}');
              image.dispose();
            });
          }
        });
      }
    }
  }
}
