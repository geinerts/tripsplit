import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/features/auth/data/models/notification_preferences_model.dart';
import 'package:tripsplit/features/auth/domain/entities/notification_preferences.dart';
import 'package:tripsplit/features/subscriptions/domain/entities/premium_access.dart';
import 'package:tripsplit/features/trip_reports/data/trip_reports_repository.dart';
import 'package:tripsplit/features/trip_reports/domain/year_summary.dart';
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

Widget _page(TripReportsRepository repository, {Locale? locale}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  locale: locale ?? const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: YearSummaryPage(repository: repository),
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

  testWidgets('one screen shows the share card and private details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _Repository(
      (_) async => YearSummary.fromMap({
        ..._summaryMap(),
        'available_years': [2026],
      }),
    );
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    expect(find.text('Your 2026 in travel'), findsOneWidget);
    String text(String key) =>
        tester.widget<Text>(find.byKey(ValueKey(key))).data!;
    expect(text('year-summary-card-trips'), '3 trips · 23 days');
    expect(text('year-summary-card-places'), '2 countries · 2 cities');
    expect(text('year-summary-card-countries'), 'Italy · Latvia');
    expect(
      find.byKey(const ValueKey('year-summary-card-logo')),
      findsOneWidget,
    );
    // The private details are outside the shared image.
    final card = find.byKey(const ValueKey('year-summary-share-card'));
    for (final key in [
      'year-summary-spending',
      'year-summary-biggest',
      'year-summary-category',
      'year-summary-companion',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.byKey(ValueKey(key))),
        findsNothing,
      );
    }
    expect(find.text('Anna · 2'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    // A missing rate makes the spending an estimate, with a note.
    expect(find.textContaining('≈ '), findsOneWidget);
    expect(find.byKey(const ValueKey('year-summary-partial')), findsOneWidget);
    expect(find.textContaining('.00'), findsNothing);
    expect(find.byKey(const ValueKey('year-summary-share')), findsOneWidget);
    expect(find.byKey(const ValueKey('year-summary-done')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a year without places leaves out zero counts', (tester) async {
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
      tester
          .widget<Text>(find.byKey(const ValueKey('year-summary-card-trips')))
          .data,
      '3 trips',
    );
    expect(
      find.byKey(const ValueKey('year-summary-card-places')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('year-summary-card-countries')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('year-summary-companion')), findsNothing);
    expect(find.textContaining('0 '), findsNothing);
  });

  testWidgets('spending stays off the shared card until switched on', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _Repository(
      (_) async =>
          YearSummary.fromMap({..._summaryMap(), 'conversion_complete': true}),
    );
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    const spending = ValueKey('year-summary-share-spending');
    expect(find.byKey(spending), findsNothing);
    const toggle = ValueKey('year-summary-include-spending');
    await tester.ensureVisible(find.byKey(toggle));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(toggle));
    await tester.pumpAndSettle();
    expect(find.byKey(spending), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(spending)).data,
      isNot(contains('≈')),
    );
  });

  testWidgets('many countries show five on the card and count the rest', (
    tester,
  ) async {
    final repository = _Repository(
      (_) async => YearSummary.fromMap({
        ..._summaryMap(),
        'countries': [
          for (final name in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'])
            {'code': name, 'name': 'Land $name'},
        ],
      }),
    );
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('year-summary-card-countries')),
          )
          .data,
      'Land A · Land B · Land C · Land D · Land E · +3',
    );
  });

  testWidgets('one trip reads in the singular', (tester) async {
    final repository = _Repository(
      (_) async => YearSummary.fromMap(_summaryMap(trips: 1)),
    );
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 trip ·'), findsOneWidget);
  });

  testWidgets('an empty year has a message and no card', (tester) async {
    final repository = _Repository(
      (_) async => YearSummary.fromMap(_summaryMap(trips: 0)),
    );
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    expect(find.text('No finished trips in 2026.'), findsOneWidget);
    expect(find.byKey(const ValueKey('year-summary-share-card')), findsNothing);
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
    expect(
      find.byKey(const ValueKey('year-summary-share-card')),
      findsOneWidget,
    );
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

  // Opt-in review images of the screen with demo data:
  // flutter test test/features/trip_reports/trip_reports_test.dart
  //   --dart-define=YEAR_SUMMARY_PREVIEWS=true
  if (const bool.fromEnvironment('YEAR_SUMMARY_PREVIEWS')) {
    for (final locale in ['en', 'lv']) {
      testWidgets('year summary review images: $locale', (tester) async {
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
        });
        final repository = _Repository(
          (_) async => YearSummary.fromMap({
            'year': 2026,
            'available_years': [2026],
            'trip_count': 6,
            'days_away': 32,
            'countries': [
              for (final name in [
                'Italy',
                'Spain',
                'Portugal',
                'Latvia',
                'Albania',
              ])
                {'code': name, 'name': name},
            ],
            'cities': List.generate(9, (i) => 'City $i'),
            'currency_code': 'EUR',
            'total_share': 2480.0,
            'conversion_complete': true,
            'biggest_trip': {'name': 'Italy road trip', 'share': 860.0},
            'top_category': {'key': 'food', 'share': 700.0},
            'top_companion': {'nickname': 'Anna', 'trip_count': 4},
          }),
        );
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: _page(repository, locale: Locale(locale)),
          ),
        );
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/branding/logo_full.png'),
            key.currentContext!,
          ),
        );
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/branding/logo_full_dark.png'),
            key.currentContext!,
          ),
        );
        await tester.pumpAndSettle();
        for (final spending in [false, true]) {
          if (spending) {
            await tester.tap(
              find.byKey(const ValueKey('year-summary-include-spending')),
            );
            await tester.pumpAndSettle();
          }
          await tester.runAsync(() async {
            final image =
                await (key.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              '../output/design/year-summary/app-$locale'
              '${spending ? '-spending' : ''}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      });
    }
  }
}
