import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/account_local_storage.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/core/network/legacy_trip_image_uploader.dart';
import 'package:tripsplit/core/ui/trip_budget_card.dart';
import 'package:tripsplit/features/trips/data/datasources/trips_remote_data_source.dart';
import 'package:tripsplit/features/trips/data/local/trips_local_store.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';
import 'package:tripsplit/features/trips/presentation/widgets/trip_form_page.dart';
import 'package:tripsplit/features/workspace/data/local/workspace_snapshot_codec.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class _Api implements ApiClient {
  Map<String, dynamic>? body;
  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    this.body = body;
    return {
      'ok': true,
      'trip': {'id': 1, 'name': 'Budget trip', ...?body},
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Uploader implements LegacyTripImageUploader {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(
  Widget home, {
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
  home: home,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'API distinguishes omitted, set and removed budgets; cache retains cents',
    () async {
      final api = _Api();
      final remote = TripsRemoteDataSourceImpl(api, _Uploader());
      await remote.createTrip(name: 'Trip', currencyCode: 'EUR', memberIds: []);
      expect(api.body!.containsKey('budget_cents'), isFalse);
      final trip = await remote.createTrip(
        name: 'Trip',
        currencyCode: 'EUR',
        memberIds: [],
        tripMode: 'solo',
        budgetCents: 125050,
      );
      expect(api.body!['budget_cents'], 125050);
      expect(trip.budgetCents, 125050);
      final store = TripsLocalStore(
        AccountLocalStorage(AccountDataSession()..activate(7)),
      );
      await store.writeTrips([trip]);
      expect((await store.readTrips()).single.budgetCents, 125050);
      await remote.updateTrip(tripId: 1, name: 'Renamed');
      expect(api.body!.containsKey('budget_cents'), isFalse);
      await remote.updateTrip(tripId: 1, name: 'Trip', budgetCents: 30000);
      expect(api.body!['budget_cents'], 30000);
      final cleared = await remote.updateTrip(
        tripId: 1,
        name: 'Trip',
        clearBudget: true,
      );
      expect(api.body!.containsKey('budget_cents'), isTrue);
      expect(api.body!['budget_cents'], isNull);
      await store.writeTrips([cleared]);
      expect((await store.readTrips()).single.budgetCents, isNull);
    },
  );
  test(
    'workspace cache distinguishes unknown from explicitly removed budget',
    () {
      final old = WorkspaceSnapshotCodec.fromMap({});
      expect(old.budgetLoaded, isFalse);
      final withBudget = old.copyWith(budgetCents: 23456, budgetLoaded: true);
      final restored = WorkspaceSnapshotCodec.fromMap(
        WorkspaceSnapshotCodec.toMap(withBudget),
      );
      expect(restored.budgetCents, 23456);
      final cleared = WorkspaceSnapshotCodec.fromMap(
        WorkspaceSnapshotCodec.toMap(restored.copyWith(clearBudget: true)),
      );
      expect(cleared.budgetLoaded, isTrue);
      expect(cleared.budgetCents, isNull);
    },
  );
  testWidgets('creation defaults to no budget', (tester) async {
    await tester.pumpWidget(_app(TripFormPage(pickImage: (_) async => null)));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('trip-budget-toggle')),
          )
          .value,
      isFalse,
    );
    expect(find.byKey(const ValueKey('trip-budget-amount')), findsNothing);
  });
  for (final remove in [false, true]) {
    testWidgets(
      'edit validates amount and returns ${remove ? 'removed' : 'exact decimal'} budget',
      (tester) async {
        TripFormDraft? result;
        await tester.pumpWidget(
          _app(
            Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await Navigator.of(context).push<TripFormDraft>(
                      MaterialPageRoute(
                        builder: (_) => TripFormPage(
                          trip: TripModel.fromLegacyMap({
                            'id': 1,
                            'name': 'Trip',
                            'currency_code': 'EUR',
                            'budget_cents': 10000,
                          }),
                          pickImage: (_) async => null,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final field = find.byKey(const ValueKey('trip-budget-amount'));
        expect(tester.widget<TextField>(field).controller!.text, '100.00');
        await tester.ensureVisible(field);
        await tester.enterText(field, '0');
        await tester.tap(find.byKey(const ValueKey('trip-form-submit')));
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(
          tester.widget<TextField>(field).decoration!.errorText,
          isNotNull,
        );
        if (remove) {
          await tester.ensureVisible(
            find.byKey(const ValueKey('trip-budget-toggle')),
          );
          await tester.tap(find.byKey(const ValueKey('trip-budget-toggle')));
        } else {
          await tester.enterText(field, '1250,50');
        }
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('trip-form-submit')));
        await tester.pumpAndSettle();
        expect(result, isNotNull);
        expect(result!.budgetCents, remove ? null : 125050);
      },
    );
  }
  for (final dark in [false, true]) {
    for (final locale in ['en', 'lv', 'es']) {
      testWidgets(
        'budget overflow remains readable at 320px 200% $locale dark=$dark',
        (tester) async {
          tester.view.physicalSize = const Size(320, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            _app(
              const Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: TripBudgetCard(
                      budgetCents: 10000,
                      spentCents: 125050,
                      currencyCode: 'EUR',
                      isSolo: false,
                    ),
                  ),
                ),
              ),
              dark: dark,
              locale: locale,
              scale: 2,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(
            tester
                .widget<LinearProgressIndicator>(
                  find.byType(LinearProgressIndicator),
                )
                .value,
            1,
          );
          final context = tester.element(find.byType(TripBudgetCard));
          expect(
            find.text(AppLocalizations.of(context)!.tripBudgetOver),
            findsOneWidget,
          );
        },
      );
    }
  }
}
