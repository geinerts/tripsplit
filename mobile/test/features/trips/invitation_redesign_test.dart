import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:tripsplit/features/trips/presentation/widgets/trip_invitation_dialog.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/features/trips/presentation/widgets/join_trip_invite_page.dart';
import 'package:tripsplit/features/trips/presentation/widgets/trip_invite_members_page.dart';
import 'package:tripsplit/features/trips/domain/entities/trip_user.dart';
import 'package:tripsplit/features/trips/domain/entities/trip_invite_link.dart';
import 'package:tripsplit/features/trips/domain/entities/pending_trip_invitation.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

const link = TripInviteLink(
  tripId: 1,
  inviteUrl: 'https://splyto.app/?invite=lisbon-abcdefghij',
  inviteToken: 'abcdefghij',
  expiresAt: '2026-11-01 12:00:00',
  expiresInSeconds: 86400,
);

class _Harness {
  Object? result;
  bool closed = false, failFriends = false, failLink = false;
  Completer<TripInviteLink>? pendingLink;
  int linkCalls = 0, friendCalls = 0;
  Future<void> mount(
    WidgetTester tester, {
    bool join = false,
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
                    builder: (_) => join
                        ? const JoinTripInvitePage()
                        : TripInviteMembersPage(
                            tripName:
                                'A long trip name with several destinations',
                            loadFriends: () async {
                              friendCalls++;
                              if (failFriends) throw Exception('Offline');
                              return const [
                                TripUser(
                                  id: 8,
                                  nickname: 'Anna with a very long family name',
                                ),
                              ];
                            },
                            loadLink: () async {
                              linkCalls++;
                              if (pendingLink != null) {
                                return pendingLink!.future;
                              }
                              if (failLink) throw Exception('Offline');
                              return link;
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

  String clipboard = '';
  String? copied;
  setUp(() {
    clipboard = '';
    copied = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') return {'text': clipboard};
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null),
  );
  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      for (final join in [false, true]) {
        testWidgets('invitation 320px 200% $locale dark=$dark join=$join', (
          tester,
        ) async {
          final h = _Harness();
          await h.mount(
            tester,
            join: join,
            locale: locale,
            dark: dark,
            scale: 2,
          );
          expect(tester.takeException(), isNull);
          if (join) {
            await tester.ensureVisible(
              find.byKey(const ValueKey('join-trip-input')),
            );
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const ValueKey('join-trip-input')));
            tester.view.viewInsets = const FakeViewPadding(bottom: 300);
            addTearDown(tester.view.resetViewInsets);
            await tester.pumpAndSettle();
            expect(
              tester
                  .getRect(find.byKey(const ValueKey('join-trip-submit')))
                  .bottom,
              lessThanOrEqualTo(544),
            );
          } else {
            await visible(
              tester,
              find.byKey(const ValueKey('invite-friend-8')),
            );
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
          }
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
  }
  testWidgets('join validates and paste submits the exact parsed token once', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester, join: true);
    await tester.tap(find.byKey(const ValueKey('join-trip-submit')));
    await tester.pumpAndSettle();
    expect(h.closed, isFalse);
    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();
    expect(find.text('Clipboard is empty.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('join-trip-input')),
      'https://splyto.app/?invite=%',
    );
    await tester.tap(find.byKey(const ValueKey('join-trip-submit')));
    await tester.pumpAndSettle();
    expect(h.closed, isFalse);
    expect(tester.takeException(), isNull);
    clipboard = 'https://splyto.app/?invite=abcdefghij';
    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();
    final save = tester
        .widget<FilledButton>(find.byKey(const ValueKey('join-trip-submit')))
        .onPressed!;
    save();
    save();
    await tester.pumpAndSettle();
    expect(h.result, 'abcdefghij');
    expect(find.text('Open'), findsOneWidget);
  });
  testWidgets(
    'link and friends retry independently; copy and selection preserve exact values',
    (tester) async {
      final h = _Harness()
        ..failLink = true
        ..failFriends = true;
      await h.mount(tester);
      expect(find.byKey(const ValueKey('invite-link-copy')), findsNothing);
      h.failLink = false;
      await tester.tap(find.byKey(const ValueKey('invite-link-retry')));
      await tester.pumpAndSettle();
      expect(h.linkCalls, 2);
      expect(h.friendCalls, 1);
      await tester.tap(find.byKey(const ValueKey('invite-link-copy')));
      await tester.pumpAndSettle();
      expect(copied, link.inviteUrl);
      h.failFriends = false;
      await visible(tester, find.byKey(const ValueKey('invite-friends-retry')));
      await tester.tap(find.byKey(const ValueKey('invite-friends-retry')));
      await tester.pumpAndSettle();
      expect(h.linkCalls, 2);
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
  testWidgets('closing before invite link response ignores late completion', (
    tester,
  ) async {
    final pending = Completer<TripInviteLink>();
    final h = _Harness()..pendingLink = pending;
    await h.mount(tester, settle: false);
    await tester.tap(find.byTooltip('Close').first);
    await tester.pumpAndSettle();
    pending.complete(link);
    await tester.pumpAndSettle();
    expect(h.closed, isTrue);
    expect(h.result, isNull);
    expect(tester.takeException(), isNull);
  });
}
