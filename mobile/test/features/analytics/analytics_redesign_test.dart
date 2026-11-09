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
import 'package:tripsplit/features/analytics/data/analytics_repository.dart';
import 'package:tripsplit/features/analytics/domain/analytics_report.dart';
import 'package:tripsplit/features/analytics/presentation/pages/analytics_page.dart';
import 'package:tripsplit/features/auth/domain/entities/auth_user.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/trips/domain/entities/trip.dart';
import 'package:tripsplit/features/trips/presentation/controllers/trips_controller.dart';
import 'package:tripsplit/l10n/app_localizations.dart';
import 'analytics_report_test.dart'
    show AnalyticsTestExpense, analyticsSummary, analyticsTrip;

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

class _Analytics implements AnalyticsRepository {
  Map<int, List<AnalyticsTestExpense>> byTrip = {};
  List<Trip> trips = [];
  List<AnalyticsTripSummary>? fixed;
  Object? error;
  Completer<List<AnalyticsTripSummary>>? pending;
  int calls = 0;
  List<AnalyticsTestExpense> expenses = const [
    AnalyticsTestExpense(1, amount: 24, share: 8, payer: 1, note: 'Breakfast'),
    AnalyticsTestExpense(
      2,
      amount: 42,
      share: 14,
      category: 'transport',
      note: 'Airport transfer',
    ),
    AnalyticsTestExpense(
      3,
      amount: 60,
      share: 20,
      payer: 1,
      date: '2026-10-06',
    ),
  ];
  @override
  Future<List<AnalyticsTripSummary>> loadSummary() async {
    calls++;
    if (error != null) throw error!;
    if (pending != null) return pending!.future;
    if (fixed != null) return fixed!;
    return [
      for (final trip in trips)
        analyticsSummary(
          trip.id,
          trip.currencyCode,
          byTrip[trip.id] ?? expenses,
        ),
    ];
  }
}

Future<void> _mount(
  WidgetTester tester,
  _Trips trips,
  _Analytics analytics, {
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
  analytics.trips = trips.trips;
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
        analyticsRepository: analytics,
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

const _manyCategories = [
  AnalyticsTestExpense(1, amount: 320, share: 320, category: 'accommodation'),
  AnalyticsTestExpense(2, amount: 180, share: 180, category: 'food'),
  AnalyticsTestExpense(3, amount: 95, share: 95, category: 'transport'),
  AnalyticsTestExpense(4, amount: 60, share: 60, category: 'groceries'),
  AnalyticsTestExpense(5, amount: 42, share: 42, category: 'activities'),
  AnalyticsTestExpense(6, amount: 30, share: 30, category: 'tickets'),
  AnalyticsTestExpense(7, amount: 21, share: 21, category: 'fuel'),
  AnalyticsTestExpense(8, amount: 14, share: 14, category: 'shopping'),
  AnalyticsTestExpense(9, amount: 9, share: 9, category: 'party'),
  AnalyticsTestExpense(10, amount: 6, share: 6, category: 'parking'),
  AnalyticsTestExpense(11, amount: 3, share: 3, category: 'other'),
];

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
          _Analytics(),
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
  testWidgets(
    'By trip defaults to active, allows a choice and resets on re-entry',
    (tester) async {
      final trips = _Trips()
        ..trips = [
          analyticsTrip(id: 9, name: 'Archived holiday', status: 'archived'),
          analyticsTrip(id: 2, name: 'Active holiday'),
        ];
      final commands = AnalyticsPageCommandController();
      await _mount(tester, trips, _Analytics(), commands: commands);
      await tester.tap(find.text('By trip'));
      await tester.pumpAndSettle();
      expect(find.text('Active holiday'), findsOneWidget);
      expect(find.text('Archived holiday'), findsNothing);
      await tester.tap(find.text('Active holiday'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archived holiday'));
      await tester.pumpAndSettle();
      expect(find.text('Archived holiday'), findsOneWidget);
      commands.requestRefresh();
      await tester.pumpAndSettle();
      expect(find.text('Archived holiday'), findsOneWidget);
      await tester.tap(find.text('All trips'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('By trip'));
      await tester.pumpAndSettle();
      expect(find.text('Active holiday'), findsOneWidget);
      expect(find.text('Archived holiday'), findsNothing);
    },
  );

  testWidgets(
    'without active trips the latest travel dates win over list order',
    (tester) async {
      final trips = _Trips()
        ..trips = [
          analyticsTrip(id: 9, name: 'Older holiday', status: 'archived'),
          analyticsTrip(
            id: 1,
            name: 'Latest holiday',
            status: 'settling',
            dateFrom: '2026-11-01',
            dateTo: '2026-11-08',
          ),
          analyticsTrip(
            id: 12,
            name: 'Undated holiday',
            status: 'archived',
            dateFrom: null,
            dateTo: null,
          ),
        ];
      await _mount(tester, trips, _Analytics());
      await tester.tap(find.text('By trip'));
      await tester.pumpAndSettle();
      expect(find.text('Latest holiday'), findsOneWidget);
      expect(find.text('Older holiday'), findsNothing);
      expect(find.text('Undated holiday'), findsNothing);
    },
  );

  testWidgets('all trips personal totals, trip total and share switch', (
    tester,
  ) async {
    await _mount(tester, _Trips(), _Analytics());
    expect(find.text('€42.00'), findsWidgets);
    expect(find.text('Average per trip'), findsNothing);
    expect(find.text('Active & archived trips'), findsOneWidget);
    expect(find.byKey(const ValueKey('analytics-trip-count')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('analytics-trip-count'))).dy,
      greaterThan(
        tester.getBottomLeft(find.byKey(const ValueKey('analytics-total'))).dy,
      ),
    );
    await tester.tap(find.text('By trip'));
    await tester.pumpAndSettle();
    expect(find.text('You paid'), findsOneWidget);
    final donut = find.byKey(const ValueKey('analytics-category-donut'));
    final firstCategory = find.byKey(const ValueKey('analytics-category-food'));
    expect(
      tester.getTopLeft(find.text('You paid')).dy,
      greaterThan(tester.getBottomLeft(donut).dy),
    );
    expect(
      tester.getBottomLeft(find.text('You paid')).dy,
      lessThan(tester.getTopLeft(firstCategory).dy),
    );
    expect(find.text('€84.00'), findsOneWidget);
    final summary = find.byKey(const ValueKey('analytics-chart-summary'));
    expect(
      find.descendant(of: summary, matching: find.text('Your share')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summary, matching: find.text('3 expenses')),
      findsOneWidget,
    );
    expect(find.text('3 expenses'), findsOneWidget);
    await tester.tap(find.text('Trip total').first);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('analytics-total'))).data,
      '€126.00',
    );
    expect(
      find.descendant(of: summary, matching: find.text('Trip total')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summary, matching: find.text('3 expenses')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('analytics-total')), findsOneWidget);
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
      final w = _Analytics()
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
  testWidgets('filters use the loaded summary without a new request', (
    tester,
  ) async {
    final w = _Analytics();
    await _mount(tester, _Trips(), w);
    await tester.tap(find.text('By trip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trip total').first);
    await tester.pumpAndSettle();
    expect(w.calls, 1);
  });
  testWidgets('a currency that no longer matches shows no totals', (
    tester,
  ) async {
    final w = _Analytics()..fixed = [analyticsSummary(1, 'USD', const [])];
    await _mount(tester, _Trips(), w);
    expect(find.byKey(const ValueKey('analytics-total')), findsNothing);
  });
  testWidgets('hidden analytics does not load the summary', (tester) async {
    final t = _Trips();
    final w = _Analytics();
    await _mount(tester, t, w, active: false);
    expect(t.calls, 0);
    expect(w.calls, 0);
    await _mount(tester, t, w, active: true);
    expect(w.calls, 1);
  });
  testWidgets('empty trips shows approved illustration without totals', (
    tester,
  ) async {
    await _mount(tester, _Trips()..trips = [], _Analytics());
    expect(find.byKey(const ValueKey('analytics-empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('analytics-total')), findsNothing);
  });
  testWidgets('stale refresh cannot replace a newer report', (tester) async {
    final w = _Analytics();
    final c = AnalyticsPageCommandController();
    await _mount(tester, _Trips(), w, commands: c);
    final old = Completer<List<AnalyticsTripSummary>>();
    w.pending = old;
    c.requestRefresh();
    await tester.pump();
    await tester.pump();
    w.pending = null;
    w.expenses = const [AnalyticsTestExpense(5, share: 5)];
    c.requestRefresh();
    await tester.pumpAndSettle();
    old.complete([
      analyticsSummary(1, 'EUR', const [AnalyticsTestExpense(6, share: 99)]),
    ]);
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
      final w = _Analytics()
        ..byTrip = const {
          1: [
            AnalyticsTestExpense(1, share: 20),
            AnalyticsTestExpense(2, share: 5, date: '2026-11-05'),
          ],
          2: [AnalyticsTestExpense(3, share: 15)],
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
    final w = _Analytics();
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
      final w = _Analytics();
      final trips = _Trips();
      await _mount(tester, trips, w, auth: a);
      a.id = 2;
      w.error = const ApiException('Offline', isNetworkError: true);
      await _mount(tester, trips, w, auth: a);
      expect(find.byKey(const ValueKey('analytics-total')), findsNothing);
    },
  );
  group('category donut percentages', () {
    Future<void> openTripTotal(WidgetTester tester) async {
      final t = _strings(tester);
      await tester.tap(find.text(t.analyticsByTrip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.workspaceTripTotal).first);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'legend is below the donut with visible and spoken percentages',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await _mount(tester, _Trips(), _Analytics());
        await openTripTotal(tester);
        expect(
          find.byKey(const ValueKey('analytics-category-donut')),
          findsOne,
        );
        expect(find.text('66.7%'), findsOne);
        expect(find.text('33.3%'), findsOne);
        expect(find.bySemanticsLabel('Food, €84.00, 66.7%'), findsOne);
        expect(find.bySemanticsLabel('Transport, €42.00, 33.3%'), findsOne);
        final food = find.byKey(const ValueKey('analytics-category-food'));
        expect(
          find.descendant(of: food, matching: find.byType(Text)),
          findsNWidgets(3),
        );
        expect(
          tester.getTopLeft(food).dy,
          greaterThan(
            tester
                .getBottomLeft(
                  find.byKey(const ValueKey('analytics-category-donut')),
                )
                .dy,
          ),
        );
        semantics.dispose();
      },
    );

    testWidgets('your share view uses the same chart', (tester) async {
      await _mount(tester, _Trips(), _Analytics());
      await tester.tap(find.text(_strings(tester).analyticsByTrip));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('analytics-category-donut')), findsOne);
      expect(find.text('66.7%'), findsOne);
      expect(find.text('33.3%'), findsOne);
    });

    for (final (width, scale) in [(390.0, 1.0), (320.0, 2.0)]) {
      testWidgets('many small categories fit at ${width}px ${scale}x', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final analytics = _Analytics()..expenses = _manyCategories;
        await _mount(tester, _Trips(), analytics, width: width, scale: scale);
        await openTripTotal(tester);
        expect(tester.takeException(), isNull);
        final donut = find.byKey(const ValueKey('analytics-category-donut'));
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('analytics-category-other')),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(tester.takeException(), isNull);
        final rect = tester.getRect(donut);
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(width));
        // Even the smallest category has a visible and accessible percentage.
        expect(find.text('0.4%'), findsOne);
        expect(find.bySemanticsLabel(RegExp(r'^Other, .*0\.4%$')), findsOne);
        semantics.dispose();
      });
    }

    testWidgets('a single category is one full slice', (tester) async {
      final analytics = _Analytics()
        ..expenses = const [
          AnalyticsTestExpense(
            1,
            amount: 6.5,
            share: 6.5,
            category: 'groceries',
          ),
        ];
      await _mount(tester, _Trips(), analytics);
      await openTripTotal(tester);
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('analytics-category-groceries')),
        findsOne,
      );
      expect(find.text('100.0%'), findsOne);
    });
  });
  if (const bool.fromEnvironment('ANALYTICS_PREVIEWS')) {
    for (final dark in [false, true]) {
      for (final screen in [
        'all',
        'total',
        'share',
        'empty',
        'categories',
        'many',
        'many-narrow',
        'single',
        'pair',
      ]) {
        testWidgets('preview $screen dark=$dark', (tester) async {
          final key = GlobalKey();
          final trips = _Trips();
          final analytics = _Analytics();
          if (screen == 'categories') {
            analytics.expenses = const [
              AnalyticsTestExpense(
                1,
                amount: 1000,
                share: 1000,
                category: 'tickets',
              ),
              AnalyticsTestExpense(
                2,
                amount: 25,
                share: 25,
                category: 'groceries',
              ),
            ];
          }
          if (screen.startsWith('many')) analytics.expenses = _manyCategories;
          if (screen == 'pair') {
            analytics.expenses = const [
              AnalyticsTestExpense(
                1,
                amount: 33.89,
                share: 6.5,
                category: 'groceries',
              ),
              AnalyticsTestExpense(
                2,
                amount: 8.47,
                share: 0,
                category: 'tickets',
              ),
            ];
          }
          if (screen == 'single') {
            analytics.expenses = const [
              AnalyticsTestExpense(
                1,
                amount: 6.5,
                share: 6.5,
                category: 'groceries',
              ),
            ];
          }
          if (screen == 'empty') trips.trips = [];
          if (screen == 'all') {
            trips.trips = [
              analyticsTrip(),
              analyticsTrip(id: 2, name: 'Alpine weekend', status: 'archived'),
              analyticsTrip(id: 3, name: 'Copenhagen'),
            ];
            analytics.byTrip = const {
              2: [
                AnalyticsTestExpense(
                  4,
                  amount: 240,
                  share: 120,
                  category: 'accommodation',
                ),
              ],
              3: [
                AnalyticsTestExpense(
                  5,
                  amount: 85,
                  share: 85,
                  category: 'transport',
                ),
              ],
            };
          }
          final narrow = screen == 'many-narrow';
          await _mount(
            tester,
            trips,
            analytics,
            dark: dark,
            boundary: key,
            width: narrow ? 320 : 390,
            scale: narrow ? 2 : 1,
          );
          if (screen != 'all' && screen != 'empty') {
            await tester.tap(find.text('By trip'));
            await tester.pumpAndSettle();
            if (screen != 'share') {
              await tester.tap(find.text('Trip total').first);
              await tester.pumpAndSettle();
            }
          }
          if (screen.startsWith('many') ||
              screen == 'single' ||
              screen == 'pair') {
            final donut = find.byKey(
              const ValueKey('analytics-category-donut'),
            );
            await tester.scrollUntilVisible(
              donut,
              150,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.ensureVisible(donut);
            await tester.pumpAndSettle();
            await tester.drag(
              find.byKey(const ValueKey('analytics-scroll')),
              const Offset(0, 60),
            );
            await tester.pumpAndSettle();
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
