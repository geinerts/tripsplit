import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:tripsplit/features/trips/presentation/widgets/trip_invitation_dialog.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/features/trips/presentation/widgets/trip_invite_members_page.dart';
import 'package:tripsplit/features/trips/domain/entities/trip_user.dart';
import 'package:tripsplit/features/trips/domain/entities/pending_trip_invitation.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class _Harness {
  Object? result;
  bool closed = false, failFriends = false;
  Completer<List<TripUser>>? pendingFriends;
  int friendCalls = 0;
  Future<void> mount(
    WidgetTester tester, {
    String locale = 'en',
    bool dark = false,
    double scale = 1,
    bool settle = true,
  }) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              child: const Text('Open'),
              onPressed: () async {
                result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TripInviteMembersPage(
                      tripName: 'A long trip name with several destinations',
                      loadFriends: () async {
                        friendCalls++;
                        if (pendingFriends != null)
                          return pendingFriends!.future;
                        if (failFriends) throw Exception('Offline');
                        return const [
                          TripUser(
                            id: 8,
                            nickname: 'Anna with a very long family name',
                          ),
                        ];
                      },
                      loadPending: () async => [
                        const PendingTripInvitation(
                          id: 5,
                          userId: 9,
                          name: 'Daniel with a long family name',
                        ),
                      ],
                      revoke: (_) async {},
                    ),
                  ),
                );
                closed = true;
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }
}

Future<void> visible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      180,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('invite-members-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('invitation confirmation review images', (tester) async {
    if (!const bool.fromEnvironment('INVITATION_PREVIEWS')) return;
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final dark in [false, true]) {
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    child: const Text('Open'),
                    onPressed: () => showDialog<bool>(
                      context: context,
                      builder: (_) => const TripInvitationDialog(
                        message:
                            'Anna invited you to Lisbon getaway. Would you like to join?',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(
          '../output/design/invitations/${dark ? 'dark' : 'light'}-confirmation.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });

  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      testWidgets('friend invitation 320px 200% $locale dark=$dark', (
        tester,
      ) async {
        final h = _Harness();
        await h.mount(tester, locale: locale, dark: dark, scale: 2);
        expect(tester.takeException(), isNull);
        await visible(tester, find.byKey(const ValueKey('invite-friend-8')));
        await tester.tap(find.byKey(const ValueKey('invite-friend-8')));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<CheckboxListTile>(
                find.byKey(const ValueKey('invite-friend-8')),
              )
              .value,
          isTrue,
        );
        expect(find.byType(SelectableText), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.tap(
          find
              .byTooltip(
                MaterialLocalizations.of(
                  tester.element(find.byType(Scaffold).last),
                ).closeButtonTooltip,
              )
              .first,
        );
        await tester.pumpAndSettle();
        expect(h.closed, isTrue);
        expect(h.result, isNull);
      });
    }
  }
  testWidgets(
    'friends retry and selected friends submit once without link controls',
    (tester) async {
      final h = _Harness()..failFriends = true;
      await h.mount(tester);
      expect(find.byKey(const ValueKey('invite-link-copy')), findsNothing);
      expect(find.byKey(const ValueKey('invite-link-retry')), findsNothing);
      expect(
        tester
            .widget<ElevatedButton>(
              find.byKey(const ValueKey('invite-members-submit')),
            )
            .onPressed,
        isNull,
      );
      h.failFriends = false;
      await visible(tester, find.byKey(const ValueKey('invite-friends-retry')));
      await tester.tap(find.byKey(const ValueKey('invite-friends-retry')));
      await tester.pumpAndSettle();
      expect(h.friendCalls, 2);
      await visible(tester, find.byKey(const ValueKey('invite-friend-8')));
      await tester.tap(find.byKey(const ValueKey('invite-friend-8')));
      await tester.pumpAndSettle();
      final submit = tester
          .widget<ElevatedButton>(
            find.byKey(const ValueKey('invite-members-submit')),
          )
          .onPressed!;
      submit();
      submit();
      await tester.pumpAndSettle();
      expect(h.result, {8});
      expect(find.text('Open'), findsOneWidget);
    },
  );
  testWidgets('closing before friends response ignores late completion', (
    tester,
  ) async {
    final pending = Completer<List<TripUser>>();
    final h = _Harness()..pendingFriends = pending;
    await h.mount(tester, settle: false);
    await tester.tap(find.byTooltip('Close').first);
    await tester.pumpAndSettle();
    pending.complete(const [TripUser(id: 8, nickname: 'Anna')]);
    await tester.pumpAndSettle();
    expect(h.closed, isTrue);
    expect(h.result, isNull);
    expect(tester.takeException(), isNull);
  });
}
