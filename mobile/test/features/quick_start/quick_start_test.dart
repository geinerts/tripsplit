import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/features/quick_start/data/quick_start_service.dart';
import 'package:tripsplit/features/quick_start/presentation/quick_start_background.dart';
import 'package:tripsplit/features/quick_start/presentation/quick_start_sheet.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class _Client implements ApiClient {
  Completer<Map<String, dynamic>>? pending;
  Map<String, dynamic> response = {'show_quick_start': true};
  int requests = 0;

  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    expect(method, HttpMethod.post);
    expect(path, endsWith('action=claim_quick_start'));
    expect(body, isNull); // Identity comes only from the authenticated session.
    requests++;
    return pending?.future ?? response;
  }

  @override
  Future<void> revokeCurrentSession() async {}
}

Widget _app({
  required Widget home,
  String locale = 'en',
  bool dark = false,
  double scale = 1,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: dark ? AppTheme.dark() : AppTheme.light(),
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: home,
);

void main() {
  setUpAll(() async {
    final font = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  test(
    'server state is authoritative; missing/false response fails closed',
    () async {
      final session = AccountDataSession()..activate(1);
      final client = _Client();
      final service = QuickStartService(client, session);
      expect(await service.claimAutomaticPresentation(), isTrue);
      client.response = {'show_quick_start': false};
      expect(await service.claimAutomaticPresentation(), isFalse);
      client.response = {};
      expect(await service.claimAutomaticPresentation(), isFalse);
      session.invalidate();
      await expectLater(
        service.claimAutomaticPresentation(),
        throwsA(isA<ApiException>()),
      );
      expect(client.requests, 3);
    },
  );

  test('late response from another account or login is discarded', () async {
    for (final switchAccount in [true, false]) {
      final session = AccountDataSession()..activate(1);
      final client = _Client()..pending = Completer();
      final request = QuickStartService(
        client,
        session,
      ).claimAutomaticPresentation();
      final expectation = expectLater(
        request,
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'account_changed'),
        ),
      );
      if (switchAccount) {
        session.activate(2);
      } else {
        session.invalidate();
        session.activate(1);
      }
      client.pending!.complete({'show_quick_start': true});
      await expectation;
    }
  });

  for (final dark in [false, true]) {
    for (final locale in ['en', 'lv', 'es']) {
      testWidgets('six steps at 320px / 200%, $locale, dark=$dark', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        bool? result;
        final presenter = QuickStartPresenter();
        await tester.pumpWidget(
          _app(
            locale: locale,
            dark: dark,
            scale: 2,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await presenter.show(context);
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(QuickStartSheet)),
        )!;
        expect(find.text(t.quickStartBack), findsNothing);
        expect(find.byIcon(Icons.close), findsNothing);
        expect(find.byKey(const ValueKey('quick-start-logo')), findsOneWidget);
        final next = find.widgetWithText(FilledButton, t.quickStartNext);
        final dots = find.byKey(const ValueKey('quick-start-dots'));
        final skip = find.widgetWithText(TextButton, t.quickStartSkip);
        expect(tester.getCenter(skip).dx, greaterThan(160));
        expect(
          tester.getBottomLeft(skip).dy,
          lessThan(tester.getTopLeft(dots).dy),
        );
        expect(
          tester.getBottomLeft(dots).dy,
          lessThan(tester.getTopLeft(next).dy),
        );
        for (var step = 0; step < 6; step++) {
          final action = find.widgetWithText(
            FilledButton,
            step == 5 ? t.quickStartCreateAction : t.quickStartNext,
          );
          final indicators = tester
              .widgetList<Container>(
                find.descendant(of: dots, matching: find.byType(Container)),
              )
              .toList();
          expect(indicators, hasLength(6));
          for (var index = 0; index < indicators.length; index++) {
            final decoration = indicators[index].decoration! as BoxDecoration;
            expect(decoration.shape, BoxShape.circle);
            expect(decoration.color == quickStartInk, index == step);
          }
          expect(
            find.text(
              [
                t.quickStartCreateTitle,
                t.quickStartExpenseTitle,
                t.quickStartSettleTitle,
                t.quickStartAnalyticsTitle,
                t.quickStartMapTitle,
                t.quickStartLiveTitle,
              ][step],
            ),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('quick-start-logo')),
            findsOneWidget,
          );
          expect(find.byType(FilledButton), findsOneWidget);
          await tester.tap(action);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(result, isTrue);
        expect(find.byType(QuickStartSheet), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final dismissal in ['skip', 'back', 'invitation']) {
    testWidgets(
      '$dismissal dismisses without requesting creation; replay starts at step 1',
      (tester) async {
        bool? result;
        final presenter = QuickStartPresenter();
        await tester.pumpWidget(
          _app(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await presenter.show(context);
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        switch (dismissal) {
          case 'skip':
            await tester.tap(find.text('Skip'));
          case 'back':
            await tester.binding.handlePopRoute();
          case 'invitation':
            presenter.dismiss();
        }
        await tester.pumpAndSettle();
        expect(result, isNot(true));
        expect(find.byType(QuickStartSheet), findsNothing);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Solo or with friends'), findsOneWidget);
        presenter.dismiss();
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets('swiping moves both ways and never finishes the guide', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      _app(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await QuickStartPresenter().show(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final t = AppLocalizations.of(
      tester.element(find.byType(QuickStartSheet)),
    )!;
    final pages = find.byKey(const ValueKey('quick-start-pages'));
    Future<void> swipe(double dx) async {
      await tester.fling(pages, Offset(dx, 0), 1200);
      await tester.pumpAndSettle();
    }

    await swipe(300);
    expect(find.text(t.quickStartCreateTitle), findsOneWidget);
    await swipe(-300);
    expect(find.text(t.quickStartExpenseTitle), findsOneWidget);
    await swipe(300);
    expect(find.text(t.quickStartCreateTitle), findsOneWidget);
    for (var i = 0; i < 7; i++) {
      await swipe(-300);
    }
    expect(find.text(t.quickStartLiveTitle), findsOneWidget);
    expect(find.byType(QuickStartSheet), findsOneWidget);
    expect(result, isNull);
    expect(
      find.widgetWithText(FilledButton, t.quickStartCreateAction),
      findsOneWidget,
    );
    await swipe(300);
    expect(find.text(t.quickStartMapTitle), findsOneWidget);
    expect(find.widgetWithText(FilledButton, t.quickStartNext), findsOneWidget);
    await tester.tap(find.text(t.quickStartNext));
    await tester.pumpAndSettle();
    expect(find.text(t.quickStartLiveTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone stays still and shows a screenshot on every step', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(home: const QuickStartSheet()));
    await tester.pumpAndSettle();
    final t = AppLocalizations.of(
      tester.element(find.byType(QuickStartSheet)),
    )!;
    final phone = find.byKey(const ValueKey('quick-start-phone'));
    final position = tester.getTopLeft(phone);
    // Its lower edge stays hidden behind the opaque area around the dots.
    expect(
      tester.getBottomLeft(phone).dy,
      greaterThan(
        tester.getBottomLeft(find.byKey(const ValueKey('quick-start-dots'))).dy,
      ),
    );
    final assets = [
      'create_trip',
      'add_expense',
      'settle_up',
      'analytics',
      'travel_map',
      'live_map',
    ];
    bool showsScreenshot(String name) => tester
        .widgetList<Image>(find.byType(Image))
        .any(
          (image) =>
              image.image is AssetImage &&
              (image.image as AssetImage).assetName ==
                  'assets/quick_start/$name.webp',
        );
    expect(showsScreenshot(assets.first), isTrue);
    for (var step = 0; step < 5; step++) {
      await tester.tap(find.text(t.quickStartNext));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(phone), position);
      expect(showsScreenshot(assets[step + 1]), isTrue);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('invitation dismissal removes only the guide route', (
    tester,
  ) async {
    final presenter = QuickStartPresenter();
    late BuildContext host;
    await tester.pumpWidget(
      _app(
        home: Builder(
          builder: (context) {
            host = context;
            return const Scaffold();
          },
        ),
      ),
    );
    unawaited(presenter.show(host));
    await tester.pumpAndSettle();
    unawaited(
      showDialog<void>(
        context: host,
        builder: (_) => const AlertDialog(title: Text('Invitation')),
      ),
    );
    await tester.pumpAndSettle();
    presenter.dismiss();
    await tester.pumpAndSettle();
    expect(find.text('Invitation'), findsOneWidget);
    Navigator.of(host).pop();
    await tester.pumpAndSettle();
    expect(find.byType(QuickStartSheet), findsNothing);
  });

  testWidgets('save light/dark visual review images', (tester) async {
    if (!const bool.fromEnvironment('QUICK_START_PREVIEWS')) return;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final dark in [false, true]) {
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: _app(
            dark: dark,
            locale: 'lv',
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => QuickStartPresenter().show(context),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      for (var step = 1; step <= 6; step++) {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/quick-start/quick-start-${dark ? 'dark' : 'light'}-$step.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        if (step < 6) {
          await tester.tap(find.text('Tālāk'));
          await tester.pumpAndSettle();
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
}
