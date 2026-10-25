import 'friend_trip_test_fakes.dart';
import 'package:tripsplit/features/trips/domain/entities/trip.dart';
import 'package:tripsplit/features/auth/domain/entities/auth_user.dart';
import 'package:tripsplit/features/friends/domain/entities/friend_link.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/ui/app_skeleton.dart';
import 'package:tripsplit/core/ui/app_bottom_nav_bar.dart';
import 'package:tripsplit/core/ui/user_profile_page.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/friends/domain/entities/friend_user.dart';
import 'package:tripsplit/features/friends/domain/entities/friend_request.dart';
import 'package:tripsplit/features/friends/domain/entities/friends_section_page.dart';
import 'package:tripsplit/features/friends/presentation/controllers/friends_controller.dart';
import 'package:tripsplit/features/friends/presentation/pages/friends_page.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_shared_trip.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class _Auth implements AuthController {
  @override
  AuthUser? get currentUser => const AuthUser(
    id: 7,
    nickname: 'Matiss Geinerts',
    needsCredentials: false,
  );
  @override
  Uint8List? avatarBytesFor(AuthUser? user) => null;
  @override
  String? avatarUrlFor(AuthUser? user, {bool preferThumb = false}) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const anna = FriendUser(
  id: 8,
  nickname: 'anna',
  displayName: 'Anna Bērziņa',
  commonTripsCount: 2,
);
const longFriend = FriendUser(
  id: 9,
  nickname: 'daniel',
  displayName: 'Daniel Alexander Verylongname',
  bankIban: 'LV80BANK0000435195001',
  bankAccountHolder: 'Daniel Alexander Verylongname',
  commonTripsCount: 1,
);

class _Friends implements FriendsController {
  @override
  Future<FriendLink> getFriendLink() async => const FriendLink(
    token: 'abcdefghij',
    url: 'https://splyto.app/friend/abcdefghij',
  );

  List<FriendUser> friends = [anna, longFriend];
  List<FriendRequest> received = [
    const FriendRequest(
      requestId: 20,
      user: FriendUser(id: 10, nickname: 'Laura'),
    ),
  ];
  List<FriendRequest> sent = [
    const FriendRequest(
      requestId: 21,
      user: FriendUser(id: 11, nickname: 'Sofia'),
    ),
  ];
  Object? failure;
  Object? pageFailure;
  Completer<void>? gate;
  Completer<void>? mutationGate;
  final responses = <(int, bool)>[];
  final cancels = <int>[];
  final invites = <int>[];
  final removed = <int>[];
  bool more = false;
  List<FriendUser> search = [const FriendUser(id: 12, nickname: 'Alex')];
  Future<List<FriendUser>> Function(String)? searchHandler;
  @override
  Future<FriendsSectionPage> loadSectionPage({
    required String section,
    int limit = 25,
    String? cursor,
    int? offset,
  }) async {
    final captured = List<FriendUser>.of(friends);
    final waiting = gate;
    if (waiting != null) await waiting.future;
    if (failure != null) throw failure!;
    if (cursor != null && pageFailure != null) throw pageFailure!;
    return FriendsSectionPage(
      section: section,
      friendsCount: captured.length,
      pendingSentCount: sent.length,
      pendingReceivedCount: received.length,
      friends: section == 'friends'
          ? (cursor == null
                ? captured
                : [anna, const FriendUser(id: 13, nickname: 'New friend')])
          : [],
      requests: section == 'pending_sent'
          ? sent
          : section == 'pending_received'
          ? received
          : [],
      hasMore: more && section == 'friends' && cursor == null,
      nextCursor: more && section == 'friends' && cursor == null
          ? 'next'
          : null,
      nextOffset: null,
    );
  }

  @override
  Future<void> respondInvite({
    required int requestId,
    required bool accept,
  }) async {
    responses.add((requestId, accept));
    if (mutationGate != null) await mutationGate!.future;
    received = received.where((r) => r.requestId != requestId).toList();
  }

  @override
  Future<void> cancelInvite({required int requestId}) async {
    cancels.add(requestId);
    sent = [];
  }

  @override
  Future<void> sendInvite({required int userId}) async {
    invites.add(userId);
  }

  @override
  Future<void> removeFriend({required int userId}) async {
    removed.add(userId);
    friends = friends.where((u) => u.id != userId).toList();
  }

  @override
  Future<List<FriendUser>> searchUsers({
    required String query,
    int limit = 20,
    List<int> excludeIds = const [],
  }) async => searchHandler == null ? search : searchHandler!(query);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Workspace extends FriendTestWorkspace {
  Object? failure;
  int calls = 0;
  bool empty = false;
  @override
  Future<List<WorkspaceSharedTrip>> loadSharedTripsWithUser({
    required int userId,
    int limit = 20,
  }) async {
    calls++;
    if (failure != null) throw failure!;
    if (empty) return [];
    return [
      const WorkspaceSharedTrip(
        id: 1,
        name: 'Lisbon getaway',
        status: 'active',
        membersCount: 3,
        createdAt: '2026-10-05',
      ),
    ];
  }
}

Future<void> _mount(
  WidgetTester tester,
  _Friends controller, {
  String locale = 'en',
  bool dark = false,
  double width = 390,
  double scale = 1,
  _Workspace? workspace,
  FriendTestTrips? trips,
  ValueChanged<Trip>? onOpenTrip,
  FriendsPageCommandController? commands,
  GlobalKey? boundary,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  if (boundary != null) {
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 20);
    addTearDown(tester.view.resetPadding);
  }
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
      child: child!,
    ),
    home: Scaffold(
      appBar: AppBar(
        actions: boundary == null
            ? null
            : const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.notifications_outlined),
                ),
              ],
        title: Builder(
          builder: (context) => Text(
            AppLocalizations.of(context)!.navFriends,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
      bottomNavigationBar: boundary == null
          ? null
          : AppBottomNavBar(
              selectedItem: AppBottomNavItem.friends,
              onSelected: (_) {},
              avatarLetter: 'M',
            ),
      body: FriendsPage(
        tripsController: trips ?? FriendTestTrips(),
        onOpenTrip: onOpenTrip ?? (_) {},
        controller: controller,
        authController: _Auth(),
        workspaceController: workspace ?? _Workspace(),
        commandController: commands,
      ),
    ),
  );
  await tester.pumpWidget(
    boundary == null ? app : RepaintBoundary(key: boundary, child: app),
  );
  await tester.pump();
}

AppLocalizations strings(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(FriendsPage)))!;
Future<void> show(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find
        .descendant(
          of: find.byType(UserProfilePage).evaluate().isEmpty
              ? find.byType(CustomScrollView)
              : find.byType(ListView).last,
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
}

Future<void> dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  Future<void> openProfile(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await show(tester, find.text('Anna Bērziņa'));
    await tester.tap(find.text('Anna Bērziņa'));
    await tester.pumpAndSettle();
  }

  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      testWidgets('friend trip selection 320px 200% $locale dark=$dark', (
        tester,
      ) async {
        final trips = FriendTestTrips()
          ..items = [
            testTrip(
              1,
              name: 'A long trip name that wraps across several lines',
            ),
          ];
        await _mount(
          tester,
          _Friends(),
          trips: trips,
          locale: locale,
          dark: dark,
          width: 320,
          scale: 2,
        );
        await openProfile(tester);
        await show(tester, find.byKey(const ValueKey('friend-invite-to-trip')));
        await tester.tap(find.byKey(const ValueKey('friend-invite-to-trip')));
        await tester.pumpAndSettle();
        final row = find.byKey(const ValueKey('friend-invite-trip-1'));
        await tester.ensureVisible(row);
        await tester.pumpAndSettle();
        await tester.tap(row);
        await tester.pumpAndSettle();
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
          isNotNull,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        expect(trips.invites, isEmpty);
      });
    }
  }
  testWidgets(
    'friend invitation sends once and reports success only after completion',
    (tester) async {
      final trips = FriendTestTrips()..sendGate = Completer<int>();
      await _mount(tester, _Friends(), trips: trips);
      await openProfile(tester);
      await tester.tap(find.byKey(const ValueKey('friend-invite-to-trip')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('friend-invite-trip-2')));
      await tester.pumpAndSettle();
      final submit = tester
          .widget<FilledButton>(find.byType(FilledButton).last)
          .onPressed!;
      submit();
      submit();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(trips.invites.length, 1);
      expect(trips.invites.single.$1, 2);
      expect(trips.invites.single.$2, [8]);
      expect(find.text('Invitation sent.'), findsNothing);
      expect(
        tester
            .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.close))
            .onPressed,
        isNull,
      );
      trips.sendGate!.complete(1);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('friend-invite-trip-2')), findsNothing);
      expect(find.text('Invitation sent.'), findsOneWidget);
    },
  );
  testWidgets(
    'friend trip load and send failures retry without false success',
    (tester) async {
      final trips = FriendTestTrips()
        ..failure = const ApiException('Private error');
      await _mount(tester, _Friends(), trips: trips);
      await openProfile(tester);
      await tester.tap(find.byKey(const ValueKey('friend-invite-to-trip')));
      await tester.pumpAndSettle();
      expect(find.text('Private error'), findsNothing);
      trips.failure = null;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('friend-invite-trip-1')));
      await tester.pumpAndSettle();
      trips.inviteFailure = const ApiException('Private error');
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
      expect(find.text('Invitation sent.'), findsNothing);
      expect(
        tester
            .widget<ListTile>(
              find.byKey(const ValueKey('friend-invite-trip-1')),
            )
            .selected,
        isTrue,
      );
      trips.inviteFailure = null;
      trips.result = 0;
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
      expect(find.text('Invitation sent.'), findsNothing);
      expect(find.textContaining('no longer available'), findsOneWidget);
    },
  );
  testWidgets('empty invitation list and late load stay safe after close', (
    tester,
  ) async {
    final trips = FriendTestTrips()..items = [];
    await _mount(tester, _Friends(), trips: trips);
    await openProfile(tester);
    await tester.tap(find.byKey(const ValueKey('friend-invite-to-trip')));
    await tester.pumpAndSettle();
    expect(find.textContaining('No available trips.'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
      isNull,
    );
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    trips.loadGate = Completer<List<Trip>>();
    await tester.tap(find.byKey(const ValueKey('friend-invite-to-trip')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    trips.loadGate!.complete([testTrip(1)]);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(trips.invites, isEmpty);
  });
  for (final allowed in [true, false]) {
    testWidgets('common trip open verifies access allowed=$allowed', (
      tester,
    ) async {
      final trips = FriendTestTrips();
      final workspace = _Workspace();
      final opened = <Trip>[];
      if (!allowed) {
        workspace.accessFailure = const ApiException('Denied', statusCode: 403);
      }
      await _mount(
        tester,
        _Friends(),
        trips: trips,
        workspace: workspace,
        onOpenTrip: opened.add,
      );
      await openProfile(tester);
      await show(tester, find.text('Lisbon getaway'));
      await tester.tap(find.text('Lisbon getaway'));
      await tester.pumpAndSettle();
      expect(trips.loads, 1);
      expect(workspace.reads, [1]);
      expect(opened.length, allowed ? 1 : 0);
      if (allowed) {
        expect(opened.single.id, 1);
        expect(find.byType(UserProfilePage), findsNothing);
      } else {
        expect(find.byType(UserProfilePage), findsOneWidget);
        expect(find.textContaining('Could not complete'), findsOneWidget);
      }
    });
  }

  testWidgets('friend flow review', (tester) async {
    if (!const bool.fromEnvironment('FRIEND_FLOW_PREVIEWS')) return;
    for (final dark in [false, true]) {
      for (final screen in ['profile', 'actions', 'invite']) {
        final key = GlobalKey();
        await _mount(tester, _Friends(), dark: dark, boundary: key);
        await tester.pumpAndSettle();
        await show(tester, find.text('Anna Bērziņa'));
        await tester.tap(find.text('Anna Bērziņa'));
        await tester.pumpAndSettle();
        if (screen == 'actions') {
          await tester.tap(find.byIcon(Icons.more_horiz_rounded));
          await tester.pumpAndSettle();
        }
        if (screen == 'invite') {
          await tester.tap(find.byKey(const ValueKey('friend-invite-to-trip')));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/friend-flows/${dark ? 'dark' : 'light'}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    }
  });

  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      testWidgets('friend QR 320px 200% $locale dark=$dark and exact copy', (
        tester,
      ) async {
        String? copied;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
              if (call.method == 'Clipboard.setData') {
                copied = (call.arguments as Map)['text'] as String;
              }
              return null;
            });
        addTearDown(
          () => TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, null),
        );
        await _mount(
          tester,
          _Friends(),
          locale: locale,
          dark: dark,
          width: 320,
          scale: 2,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.qr_code_2));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('friend-qr-page')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byIcon(Icons.copy_outlined));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.copy_outlined));
        await tester.pumpAndSettle();
        expect(copied, 'https://splyto.app/friend/abcdefghij');
        expect(tester.takeException(), isNull);
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('friend-qr-page')), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }

  testWidgets('invitation review qr', (tester) async {
    if (!const bool.fromEnvironment('INVITATION_PREVIEWS')) return;
    for (final dark in [false, true]) {
      final key = GlobalKey();
      await _mount(tester, _Friends(), dark: dark, boundary: key);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.qr_code_2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(
          '../output/design/invitations/${dark ? 'dark' : 'light'}-qr.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });

  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      testWidgets('friends and payment profile 320px 200% $locale dark=$dark', (
        tester,
      ) async {
        await _mount(
          tester,
          _Friends(),
          locale: locale,
          dark: dark,
          width: 320,
          scale: 2,
        );
        await tester.pumpAndSettle();
        await show(tester, find.byKey(const ValueKey('friend-row-9')));
        await tester.tap(find.byKey(const ValueKey('friend-row-9')));
        await tester.pumpAndSettle();
        expect(find.byType(UserProfilePage), findsOneWidget);
        await show(tester, find.text('IBAN: LV80BANK0000435195001'));
        expect(tester.takeException(), isNull);
        await dispose(tester);
        await _mount(
          tester,
          _Friends()
            ..friends = []
            ..received = []
            ..sent = [],
          locale: locale,
          dark: dark,
          width: 320,
          scale: 2,
        );
        await tester.pumpAndSettle();
        await show(tester, find.text(strings(tester).friendsAddFriend));
        expect(tester.takeException(), isNull);
        await dispose(tester);
      });
    }
  }
  testWidgets(
    'loading and failure never display friend empty state, retry succeeds',
    (tester) async {
      final f = _Friends()..gate = Completer<void>();
      await _mount(tester, f);
      expect(find.byType(AppSkeletonBlock), findsWidgets);
      expect(find.byKey(const ValueKey('friends-empty')), findsNothing);
      f.failure = const ApiException('Offline');
      f.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Offline'), findsOneWidget);
      expect(find.byKey(const ValueKey('friends-empty')), findsNothing);
      f.failure = null;
      f.friends = [];
      f.received = [];
      f.sent = [];
      await tester.tap(find.text(strings(tester).retryAction));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('friends-empty')), findsOneWidget);
      await dispose(tester);
    },
  );
  testWidgets(
    'requests retain correct accept, decline and cancel IDs and block duplicates',
    (tester) async {
      final f = _Friends()..mutationGate = Completer<void>();
      await _mount(tester, f);
      await tester.pumpAndSettle();
      final t = strings(tester);
      await tester.tap(find.byTooltip(t.friendsAccept));
      await tester.pump();
      await tester.tap(find.byTooltip(t.friendsAccept));
      await tester.pump();
      expect(f.responses, [(20, true)]);
      f.mutationGate!.complete();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(t.cancelAction));
      await tester.pumpAndSettle();
      expect(f.cancels, [21]);
      await dispose(tester);
    },
  );
  testWidgets('latest search query wins; invitation uses selected user', (
    tester,
  ) async {
    final old = Completer<List<FriendUser>>();
    final f = _Friends();
    f.searchHandler = (q) => q == 'old'
        ? old.future
        : Future.value([const FriendUser(id: 12, nickname: 'Alex')]);
    await _mount(tester, f);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'old');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), 'new');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    old.complete([const FriendUser(id: 99, nickname: 'Stale')]);
    await tester.pumpAndSettle();
    expect(find.text('Stale'), findsNothing);
    await tester.tap(find.text(strings(tester).friendsInviteAction));
    await tester.pumpAndSettle();
    expect(f.invites, [12]);
    await dispose(tester);
  });
  testWidgets(
    'refresh retains rows on failure, denies access and rejects older snapshot',
    (tester) async {
      final f = _Friends()
        ..received = []
        ..sent = [];
      final commands = FriendsPageCommandController();
      await _mount(tester, f, commands: commands);
      await tester.pumpAndSettle();
      f.gate = Completer<void>();
      commands.requestRefresh();
      await tester.pump();
      final stale = f.gate!;
      f.gate = null;
      f.friends = [longFriend];
      commands.requestRefresh();
      await tester.pumpAndSettle();
      stale.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('friend-row-8')), findsNothing);
      f.failure = const ApiException('Offline');
      commands.requestRefresh();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('friend-row-9')), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
      f.failure = const ApiException('No access', statusCode: 403);
      commands.requestRefresh();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('friend-row-9')), findsNothing);
      expect(find.byKey(const ValueKey('friends-empty')), findsNothing);
      await dispose(tester);
    },
  );
  testWidgets(
    'shared-trip failure is distinct from empty and has working retry',
    (tester) async {
      final w = _Workspace()..failure = const ApiException('Offline');
      final f = _Friends()
        ..received = []
        ..sent = [];
      await _mount(tester, f, workspace: w);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('friend-row-8')));
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(UserProfilePage)),
      )!;
      expect(find.text(t.workspaceNoCommonTripsFoundYet), findsNothing);
      expect(
        find.text(t.friendsCouldNotLoadCommonTripsRightNow),
        findsOneWidget,
      );
      w.failure = null;
      await tester.tap(find.text(t.retryAction));
      await tester.pumpAndSettle();
      expect(find.text('Lisbon getaway'), findsOneWidget);
      expect(w.calls, 2);
      expect(
        find.text(t.friendsThisFriendHasNotAddedPayoutDetailsYet),
        findsOneWidget,
      );
      await dispose(tester);
    },
  );
  testWidgets('friend removal requires confirmation', (tester) async {
    final f = _Friends()
      ..received = []
      ..sent = [];
    await _mount(tester, f);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('friend-row-8')));
    await tester.pumpAndSettle();
    final t = AppLocalizations.of(
      tester.element(find.byType(UserProfilePage)),
    )!;
    await tester.tap(find.byTooltip(t.friendsMoreActions));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.friendsRemoveFriend));
    await tester.pumpAndSettle();
    expect(f.removed, isEmpty);
    await tester.tap(find.text(t.friendsContinue));
    await tester.pumpAndSettle();
    expect(f.removed, [8]);
    expect(find.byType(UserProfilePage), findsNothing);
    await dispose(tester);
  });
  testWidgets('pagination retries and deduplicates friend IDs', (tester) async {
    final f = _Friends()
      ..received = []
      ..sent = []
      ..more = true
      ..pageFailure = const ApiException('Page failed');
    await _mount(tester, f);
    await tester.pumpAndSettle();
    final t = strings(tester);
    await tester.tap(find.text(t.tripsLoadMore));
    await tester.pumpAndSettle();
    expect(find.text('Page failed'), findsOneWidget);
    expect(find.byKey(const ValueKey('friend-row-8')), findsOneWidget);
    f.pageFailure = null;
    await tester.tap(find.text(t.tripsLoadMore));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('friend-row-8')), findsOneWidget);
    expect(find.byKey(const ValueKey('friend-row-13')), findsOneWidget);
    await dispose(tester);
  });
  testWidgets('decline does not accept an incoming request', (tester) async {
    final f = _Friends();
    await _mount(tester, f);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(strings(tester).friendsDeclineAction));
    await tester.pumpAndSettle();
    expect(f.responses, [(20, false)]);
    await dispose(tester);
  });
  testWidgets(
    'reference layout keeps request actions on the identity row at normal text size',
    (tester) async {
      await _mount(tester, _Friends()..sent = []);
      await tester.pumpAndSettle();
      final row = find.byKey(const ValueKey('friend-request-20'));
      final name = find.descendant(of: row, matching: find.text('Laura'));
      final accept = find.byTooltip(strings(tester).friendsAccept);
      expect(
        (tester.getCenter(name).dy - tester.getCenter(accept).dy).abs(),
        lessThan(24),
      );
      expect(tester.getSize(accept).width, greaterThanOrEqualTo(48));
      await dispose(tester);
    },
  );
  testWidgets('friend review images', (tester) async {
    if (!const bool.fromEnvironment('FRIENDS_PREVIEWS')) return;
    for (final dark in [false, true]) {
      for (final screen in [
        'list',
        'empty',
        'profile',
        'search',
        'search-large',
      ]) {
        final key = GlobalKey();
        final f = _Friends()
          ..sent = []
          ..friends = [
            const FriendUser(
              id: 8,
              nickname: 'Anna Parker',
              commonTripsCount: 2,
            ),
            const FriendUser(
              id: 9,
              nickname: 'Daniel Reed',
              commonTripsCount: 1,
            ),
            const FriendUser(
              id: 12,
              nickname: 'Emma Lewis',
              commonTripsCount: 3,
            ),
            const FriendUser(
              id: 13,
              nickname: 'James Miller',
              commonTripsCount: 1,
            ),
            const FriendUser(id: 14, nickname: 'Sofia Martin'),
          ];
        final previewWorkspace = _Workspace();
        if (screen == 'empty' || screen.startsWith('search')) {
          f.friends = [];
          f.received = [];
          f.sent = [];
        }
        if (screen == 'profile') {
          f.friends = [const FriendUser(id: 8, nickname: 'Igors Balandins')];
          previewWorkspace.empty = true;
          f.received = [];
          f.sent = [];
        }
        await _mount(
          tester,
          f,
          locale: 'en',
          dark: dark,
          boundary: key,
          width: screen == 'search-large' ? 320 : 390,
          scale: screen == 'search-large' ? 2 : 1,
          workspace: previewWorkspace,
        );
        await tester.pumpAndSettle();
        if (screen.startsWith('search')) {
          f.search = [const FriendUser(id: 12, nickname: 'Matiss Geinerts')];
          await tester.enterText(
            find.byKey(const ValueKey('friends-search')),
            'mat',
          );
          await tester.pump(const Duration(milliseconds: 350));
          await tester.pumpAndSettle();
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
        }
        if (screen == 'profile') {
          await tester.tap(find.byKey(const ValueKey('friend-row-8')));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/friends/friends-${dark ? 'dark' : 'light'}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await dispose(tester);
      }
    }
  });
}
