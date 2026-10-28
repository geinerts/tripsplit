import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/ui/app_bottom_nav_bar.dart';
import 'package:tripsplit/features/analytics/presentation/pages/analytics_page.dart';
import 'package:tripsplit/features/auth/domain/entities/auth_user.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/trips/domain/entities/trip.dart';
import 'package:tripsplit/features/trips/presentation/controllers/trips_controller.dart';
import 'package:tripsplit/features/workspace/domain/entities/trip_expense.dart';
import 'package:tripsplit/features/workspace/domain/entities/trip_expenses_page.dart';
import 'package:tripsplit/features/workspace/presentation/controllers/workspace_controller.dart';
import 'package:tripsplit/l10n/app_localizations.dart';
import 'analytics_report_test.dart' show analyticsTrip, analyticsExpense, page;

class _Auth implements AuthController {
  int id = 1;
  @override
  AuthUser? get currentUser =>
      AuthUser(id: id, nickname: 'Matiss', needsCredentials: false);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Trips implements TripsController {
  List<Trip> trips = [analyticsTrip()];
  int calls = 0;
  @override
  Future<List<Trip>> loadTrips({bool forceRefresh = false}) async {
    calls++;
    return trips;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Workspace implements WorkspaceController {
  Map<int, List<TripExpense>> byTrip = {};
  Object? error;
  Completer<TripExpensesPage>? pending;
  int calls = 0;
  List<TripExpense> expenses = [
    analyticsExpense(1, amount: 24, share: 8, payer: 1, note: 'Breakfast'),
    analyticsExpense(
      2,
      amount: 42,
      share: 14,
      category: 'transport',
      note: 'Airport transfer',
    ),
    analyticsExpense(3, amount: 60, share: 20, payer: 1, date: '2026-10-06'),
  ];
  @override
  Future<TripExpensesPage> loadExpensesPage({
    required int tripId,
    int limit = 50,
    String? cursor,
    int? offset,
  }) async {
    calls++;
    if (error != null) throw error!;
    if (pending != null) return pending!.future;
    return page(byTrip[tripId] ?? expenses);
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Future<void> _mount(
  WidgetTester tester,
  _Trips trips,
  _Workspace workspace, {
  _Auth? auth,
  bool dark = false,
  String locale = 'en',
  double scale = 1,
  double width = 390,
  AnalyticsPageCommandController? commands,
  GlobalKey? boundary,
  bool active = true,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 44, bottom: 20);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) => Text(
            AppLocalizations.of(context)!.navActivities,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedItem: AppBottomNavItem.analytics,
        onSelected: (_) {},
        avatarLetter: 'M',
      ),
      body: AnalyticsPage(
        tripsController: trips,
        workspaceController: workspace,
        authController: auth ?? _Auth(),
        commandController: commands,
        active: active,
        onOpenTrip: (_) {},
      ),
    ),
  );
  await tester.pumpWidget(
    boundary == null ? app : RepaintBoundary(key: boundary, child: app),
  );
  await tester.pumpAndSettle();
}

AppLocalizations _strings(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(AnalyticsPage)))!;
void main() {
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final dark in [false, true]) {
    for (final locale in ['en', 'lv', 'es']) {
      testWidgets('analytics 320px 200% $locale dark=$dark', (tester) async {
        await _mount(
          tester,
          _Trips(),
          _Workspace(),
          dark: dark,
          locale: locale,
          scale: 2,
          width: 320,
        );
        final t = _strings(tester);
        await tester.tap(find.text(t.analyticsByTrip));
        await tester.pumpAndSettle();
        await tester.drag(
          find.byKey(const ValueKey('analytics-scroll')),
          const Offset(0, -1600),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(
          find.byKey(const ValueKey('analytics-scroll')),
          const Offset(0, 2500),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(t.workspaceTripTotal).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('all trips personal totals, trip total and share switch', (
    tester,
  ) async {
    await _mount(tester, _Trips(), _Workspace());
    expect(find.text('€42.00'), findsWidgets);
    await tester.tap(find.text('By trip'));
    await tester.pumpAndSettle();
    expect(find.text('You paid'), findsOneWidget);
    expect(find.text('€84.00'), findsOneWidget);
    await tester.tap(find.text('Trip total').first);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('analytics-total'))).data,
      '€126.00',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('analytics-member-2')),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Paid by member'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('analytics-member-2')),
        matching: find.text('€42.00'),
      ),
      findsOneWidget,
    );
  });
  testWidgets(
    'failed load has no zero total; retry recovers; denial clears old data',
    (tester) async {
      final w = _Workspace()
        ..error = const ApiException('Offline', isNetworkError: true);
      final c = AnalyticsPageCommandController();
      await _mount(tester, _Trips(), w, commands: c);
      expect(find.byKey(const ValueKey('analytics-total')), findsNothing);
      expect(find.byKey(const ValueKey('analytics-empty')), findsNothing);
      w.error = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('analytics-total')), findsOneWidget);
      w.error = const ApiException('Denied', statusCode: 403);
      c.requestRefresh();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('analytics-total')), findsNothing);
    },
  );
  testWidgets('hidden analytics does not load all expense histories', (
    tester,
  ) async {
    final t = _Trips();
    final w = _Workspace();
    await _mount(tester, t, w, active: false);
    expect(t.calls, 0);
    expect(w.calls, 0);
    await _mount(tester, t, w, active: true);
    expect(w.calls, 1);
  });
  testWidgets('empty trips shows approved illustration without totals', (
    tester,
  ) async {
    await _mount(tester, _Trips()..trips = [], _Workspace());
    expect(find.byKey(const ValueKey('analytics-empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('analytics-total')), findsNothing);
  });
  testWidgets('stale refresh cannot replace a newer report', (tester) async {
    final w = _Workspace();
    final c = AnalyticsPageCommandController();
    await _mount(tester, _Trips(), w, commands: c);
    final old = Completer<TripExpensesPage>();
    w.pending = old;
    c.requestRefresh();
    await tester.pump();
    await tester.pump();
    w.pending = null;
    w.expenses = [analyticsExpense(5, share: 5)];
    c.requestRefresh();
    await tester.pumpAndSettle();
    old.complete(page([analyticsExpense(6, share: 99)]));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('analytics-total'))).data,
      '€5.00',
    );
  });
  testWidgets(
    'month and currency filters change the complete personal report',
    (tester) async {
      final trips = _Trips()
        ..trips = [analyticsTrip(), analyticsTrip(id: 2, currency: 'USD')];
      final w = _Workspace()
        ..byTrip = {
          1: [
            analyticsExpense(1, share: 20),
            analyticsExpense(2, share: 5, date: '2026-11-05'),
          ],
          2: [analyticsExpense(3, currency: 'USD', share: 15)],
        };
      await _mount(tester, trips, w);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('analytics-total'))).data,
        '€25.00',
      );
      await tester.tap(find.text('All time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('October 2026'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('analytics-total'))).data,
        '€20.00',
      );
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('USD').last);
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('analytics-total'))).data,
        contains('15.00'),
      );
      expect(find.text('All time'), findsOneWidget);
    },
  );
  testWidgets('ordinary refresh failure retains an explicitly stale report', (
    tester,
  ) async {
    final w = _Workspace();
    final c = AnalyticsPageCommandController();
    await _mount(tester, _Trips(), w, commands: c);
    w.error = const ApiException('Offline', isNetworkError: true);
    c.requestRefresh();
    await tester.pumpAndSettle();
    expect(
      find.text('Showing the last successfully loaded report.'),
      findsOneWidget,
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('analytics-total'))).data,
      '€42.00',
    );
  });
  testWidgets(
    'account change clears the previous report before a failed load',
    (tester) async {
      final a = _Auth();
      final w = _Workspace();
      final trips = _Trips();
      await _mount(tester, trips, w, auth: a);
      a.id = 2;
      w.error = const ApiException('Offline', isNetworkError: true);
      await _mount(tester, trips, w, auth: a);
      expect(find.byKey(const ValueKey('analytics-total')), findsNothing);
    },
  );
  if (const bool.fromEnvironment('ANALYTICS_PREVIEWS')) {
    for (final dark in [false, true]) {
      for (final screen in ['all', 'total', 'share', 'empty', 'categories']) {
        testWidgets('preview $screen dark=$dark', (tester) async {
          final key = GlobalKey();
          final trips = _Trips();
          final workspace = _Workspace();
          if (screen == 'categories') {
            workspace.expenses = [
              analyticsExpense(
                1,
                amount: 1000,
                share: 1000,
                category: 'tickets',
              ),
              analyticsExpense(2, amount: 25, share: 25, category: 'groceries'),
            ];
          }
          if (screen == 'empty') trips.trips = [];
          if (screen == 'all') {
            trips.trips = [
              analyticsTrip(),
              analyticsTrip(id: 2, name: 'Alpine weekend', status: 'archived'),
              analyticsTrip(id: 3, name: 'Copenhagen'),
            ];
            workspace.byTrip = {
              2: [
                analyticsExpense(
                  4,
                  amount: 240,
                  share: 120,
                  category: 'accommodation',
                ),
              ],
              3: [
                analyticsExpense(
                  5,
                  amount: 85,
                  share: 85,
                  category: 'transport',
                ),
              ],
            };
          }
          await _mount(tester, trips, workspace, dark: dark, boundary: key);
          if (screen == 'total' ||
              screen == 'share' ||
              screen == 'categories') {
            await tester.tap(find.text('By trip'));
            await tester.pumpAndSettle();
            if (screen == 'total' || screen == 'categories') {
              await tester.tap(find.text('Trip total').first);
              await tester.pumpAndSettle();
            }
          }
          expect(tester.takeException(), isNull);
          await tester.runAsync(() async {
            final image =
                await (key.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              '../output/design/analytics/analytics-${dark ? 'dark' : 'light'}-$screen.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        });
      }
    }
  }
}
