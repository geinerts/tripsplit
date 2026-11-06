import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/auth/presentation/pages/auth_intro_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class _Auth implements AuthController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _mount(WidgetTester tester, Size size, {double scale = 1}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: AuthIntroPage(controller: _Auth()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const logo = ValueKey('auth-intro-logo');

  testWidgets('the slide text still swipes under a logo that stays put', (
    tester,
  ) async {
    await _mount(tester, const Size(402, 874));
    final position = tester.getTopLeft(find.byKey(logo));
    expect(find.textContaining('Split smarter.'), findsOneWidget);
    for (final title in ['Plan together.', 'Settle fast.']) {
      await tester.fling(
        find.byType(PageView).last,
        const Offset(-300, 0),
        900,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining(title), findsOneWidget);
      expect(tester.getTopLeft(find.byKey(logo)), position);
    }
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('get started shows the choice and back returns', (tester) async {
    await _mount(tester, const Size(402, 874));
    final introWidth = tester.getSize(find.byKey(logo)).width;
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account.'), findsOneWidget);
    expect(tester.getSize(find.byKey(logo)).width, lessThan(introWidth));
    expect(find.text('Continue with Google'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Get started'), findsOneWidget);
    expect(tester.getSize(find.byKey(logo)).width, introWidth);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the logo stays where the launch screen left it', (tester) async {
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(tester.view.resetPadding);
    await _mount(tester, const Size(402, 874));
    final rect = tester.getRect(find.byKey(logo));
    expect(rect.width, 260);
    expect(rect.center.dx, closeTo(201, .5));
    expect(rect.center.dy, closeTo(437, .5));
    expect(find.text('Get started'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('on a small phone the logo moves up to keep the buttons', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(top: 20);
    addTearDown(tester.view.resetPadding);
    await _mount(tester, const Size(320, 568));
    expect(tester.getRect(find.byKey(logo)).center.dy, lessThan(284));
    final button = tester.getRect(find.text('Get started'));
    expect(button.bottom, lessThan(568));
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(320, 568), Size(844, 390), Size(1024, 768)]) {
    testWidgets('fits $size at 200% text', (tester) async {
      await _mount(tester, size, scale: 2);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Get started'));
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
