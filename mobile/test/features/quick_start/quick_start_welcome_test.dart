import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/app/router/app_router.dart';
import 'package:tripsplit/core/deeplink/invite_deep_link_controller.dart';
import 'package:tripsplit/features/quick_start/data/quick_start_seen_store.dart';
import 'package:tripsplit/features/quick_start/presentation/quick_start_welcome_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

const _signInPage = Text('sign-in page');

Future<(QuickStartSeenStore, InviteDeepLinkController)> _open(
  WidgetTester tester, {
  void Function(InviteDeepLinkController)? before,
}) async {
  tester.view.physicalSize = const Size(402, 874);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final store = QuickStartSeenStore();
  final links = InviteDeepLinkController();
  before?.call(links);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {AppRouter.authIntro: (_) => const Scaffold(body: _signInPage)},
      home: QuickStartWelcomePage(seenStore: store, deepLinks: links),
    ),
  );
  await tester.pumpAndSettle();
  return (store, links);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('opening it marks the guide as seen on this device', (
    tester,
  ) async {
    final (store, _) = await _open(tester);
    expect(find.text('Next'), findsOneWidget);
    expect(await store.isSeen(), isTrue);
  });

  testWidgets('swiping works both ways and the last button is Sign up', (
    tester,
  ) async {
    await _open(tester);
    final pages = find.byKey(const ValueKey('quick-start-pages'));
    await tester.fling(pages, const Offset(-300, 0), 900);
    await tester.pumpAndSettle();
    await tester.fling(pages, const Offset(300, 0), 900);
    await tester.pumpAndSettle();
    expect(find.text('Sign up'), findsNothing);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Create trip'), findsNothing);
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    expect(find.byWidget(_signInPage), findsOneWidget);
  });

  testWidgets('skip leads to the sign-in page', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byWidget(_signInPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a link opened during the guide leaves it and stays pending', (
    tester,
  ) async {
    final (_, links) = await _open(tester);
    links.handleIncomingUri(Uri.parse('https://splyto.eu/?invite=abcde12345'));
    await tester.pumpAndSettle();
    expect(find.byWidget(_signInPage), findsOneWidget);
    expect(links.hasPendingLink, isTrue);
    expect(links.consumePendingInviteCode(), isNotNull);
  });

  testWidgets('a link that was already waiting skips the guide', (
    tester,
  ) async {
    await _open(
      tester,
      before: (links) => links.handleIncomingUri(
        Uri.parse('https://splyto.eu/?invite=abcde12345'),
      ),
    );
    expect(find.byWidget(_signInPage), findsOneWidget);
  });

  test('a new device has not seen the guide', () async {
    expect(await QuickStartSeenStore().isSeen(), isFalse);
  });
}
