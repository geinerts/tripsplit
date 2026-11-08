import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/features/auth/data/models/notification_preferences_model.dart';
import 'package:tripsplit/features/auth/domain/entities/notification_preferences.dart';
import 'package:tripsplit/features/subscriptions/domain/entities/premium_access.dart';
import 'package:tripsplit/features/trip_reports/data/trip_reports_repository.dart';
import 'package:tripsplit/features/trip_reports/domain/year_summary.dart';
import 'package:tripsplit/features/trip_reports/presentation/year_summary_page.dart';
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
  }) => throw UnimplementedError();
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
  theme: AppTheme.light(),
  locale: locale ?? const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: YearSummaryPage(repository: repository),
);

void main() {
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

  testWidgets('shows the year, highlights and a partial-rate note', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _Repository((_) async {
      return YearSummary.fromMap(_summaryMap());
    });
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    expect(find.text('2026'), findsWidgets);
    expect(find.text('23'), findsOneWidget);
    expect(find.text('Italy · Latvia'), findsOneWidget);
    expect(find.text('Anna'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.textContaining('.00'), findsNothing);
    expect(find.textContaining('no exchange rate'), findsOneWidget);
    expect(find.byKey(const ValueKey('year-summary-share')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching year reloads and an empty year has no share action', (
    tester,
  ) async {
    final repository = _Repository((year) async {
      return YearSummary.fromMap(
        year == 2025 ? _summaryMap(year: 2025, trips: 0) : _summaryMap(),
      );
    });
    await tester.pumpWidget(_page(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('year-summary-year-2025')));
    await tester.pumpAndSettle();
    expect(repository.requests, [null, 2025]);
    expect(find.text('No finished trips in 2025.'), findsOneWidget);
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
    expect(find.text('Anna'), findsOneWidget);
  });

  testWidgets('long translations and large text fit a small phone', (
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
        child: _page(repository, locale: const Locale('uk')),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
