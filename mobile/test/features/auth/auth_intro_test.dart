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

Future<void> _mount(
  WidgetTester tester,
  Size size, {
  double scale = 1,
  bool fromLaunch = false,
  bool settle = true,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: AuthIntroPage(controller: _Auth(), fromLaunch: fromLaunch),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

void main() {
  const logo = ValueKey('auth-intro-logo');

  testWidgets('the page offers every way in, and no carousel', (tester) async {
    await _mount(tester, const Size(402, 874));
    expect(find.text('Create your account.'), findsOneWidget);
    expect(find.text('Choose how you want to sign up.'), findsNothing);
    expect(find.text('Sign up with email'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    expect(find.text('Get started'), findsNothing);
  });

  testWidgets('the logo moves up from the launch screen, above the text', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(tester.view.resetPadding);
    await _mount(tester, const Size(402, 874), fromLaunch: true, settle: false);
    await tester.pump();
    final start = tester.getRect(find.byKey(logo));
    expect(start.width, 260);
    expect(start.center.dx, closeTo(201, .5));
    expect(start.center.dy, closeTo(437, .5));
    await tester.pumpAndSettle();
    final end = tester.getRect(find.byKey(logo));
    expect(end.width, 260);
    final heading = tester.getRect(find.text('Create your account.'));
    // Below the middle of the space above the text, and clear of it.
    expect(end.center.dy, greaterThan(heading.top / 2));
    expect(end.bottom, lessThan(heading.top));
    final firstButton = tester.getRect(find.byType(InkWell).first);
    expect(firstButton.top - heading.bottom, closeTo(30, 1));
    final google = tester.getRect(find.text('Continue with Google'));
    final email = tester.getRect(find.text('Sign up with email'));
    final signIn = tester.getRect(find.text('Sign in'));
    expect(google.top, greaterThan(heading.bottom));
    expect(email.top, greaterThan(google.bottom));
    expect(signIn.top, greaterThan(email.bottom));
    expect(signIn.bottom, lessThan(874 - 34));
    expect(find.text('Sign in').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a small phone keeps the logo clear of the text', (tester) async {
    tester.view.padding = const FakeViewPadding(top: 20);
    addTearDown(tester.view.resetPadding);
    await _mount(tester, const Size(320, 568));
    final heading = tester.getRect(find.text('Create your account.'));
    expect(tester.getRect(find.byKey(logo)).bottom, lessThan(heading.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets('it follows the phone language', (tester) async {
    await _mount(tester, const Size(402, 874), locale: const Locale('lv'));
    expect(find.text('Sign up with email'), findsNothing);
    expect(find.text('Continue with Google'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('fits a small phone at 200% text, ${locale.languageCode}', (
      tester,
    ) async {
      await _mount(tester, const Size(320, 568), scale: 2, locale: locale);
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in const [Size(844, 390), Size(1024, 768)]) {
    testWidgets('fits $size at 200% text', (tester) async {
      await _mount(tester, size, scale: 2);
      expect(tester.takeException(), isNull);
    });
  }
}
