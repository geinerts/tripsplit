import 'dart:async';
import 'package:tripsplit/features/trips/domain/entities/received_trip_invitation.dart';
import 'package:tripsplit/features/trips/domain/entities/trip_invite_link.dart';
import 'package:tripsplit/features/trips/domain/entities/trip_invite_preview.dart';
import 'package:tripsplit/features/trips/domain/entities/trip_invite_join_result.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/app/theme/app_design.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/ui/app_bottom_nav_bar.dart';
import 'package:tripsplit/core/ui/app_skeleton.dart';
import 'package:tripsplit/features/auth/domain/entities/auth_user.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/friends/domain/entities/friends_snapshot.dart';
import 'package:tripsplit/features/friends/domain/entities/friend_user.dart';
import 'package:tripsplit/features/friends/presentation/controllers/friends_controller.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';
import 'package:tripsplit/features/trips/domain/entities/trip.dart';
import 'package:tripsplit/features/trips/presentation/controllers/trips_controller.dart';
import 'package:tripsplit/features/trips/presentation/pages/trips_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class _Auth implements AuthController {
  @override
  AuthUser? get currentUser =>
      const AuthUser(id: 7, nickname: 'Tester', needsCredentials: false);
  @override
  Uint8List? avatarBytesFor(AuthUser? user) => null;
  @override
  String? avatarUrlFor(AuthUser? user, {bool preferThumb = false}) => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Friends implements FriendsController {
  _Friends({this.friends = const []});
  final List<FriendUser> friends;
  @override
  FriendsSnapshot? peekSnapshotCache({bool allowStale = false}) =>
      FriendsSnapshot(
        friends: friends,
        pendingReceived: const [],
        pendingSent: const [],
      );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Trips implements TripsController {
  List<ReceivedTripInvitation> invitations = [];
  bool invitationsFail = false, shareFail = false;
  int accepted = 0, declined = 0, shareCalls = 0;
  @override
  Future<List<ReceivedTripInvitation>> listReceivedInvitations() async {
    if (invitationsFail) {
      throw const ApiException('Offline', isNetworkError: true);
    }
    return List.of(invitations);
  }

  @override
  Future<TripInvitePreview> previewTripInvite({
    required String inviteToken,
  }) async => TripInvitePreview(
    inviteToken: inviteToken,
    previewNonce: 'fresh-nonce',
    tripId: 77,
    tripName: 'Summer trip',
    inviterName: 'Anna',
    expiresAt: null,
    previewNonceExpiresAt: null,
    alreadyMember: false,
    isDirected: true,
  );
  @override
  Future<TripInviteJoinResult> joinTripInvite({
    required String inviteToken,
    required String previewNonce,
  }) async {
    expect(previewNonce, 'fresh-nonce');
    accepted++;
    invitations = [];
    trips = [_trip(77)];
    return TripInviteJoinResult(trip: trips.single, alreadyMember: false);
  }

  @override
  Future<void> declineTripInvite({required String inviteToken}) async {
    declined++;
    invitations = [];
  }

  @override
  Future<TripInviteLink> createTripInviteLink({required int tripId}) async {
    shareCalls++;
    if (shareFail) throw const ApiException('Failed');
    return TripInviteLink(
      tripId: tripId,
      inviteUrl: 'https://splyto.eu/invite?invite=abcdefghij',
      inviteToken: 'abcdefghij',
      expiresAt: null,
      expiresInSeconds: 3600,
    );
  }

  List<Trip>? cache;
  List<Trip> trips = [];
  Object? error;
  Completer<List<Trip>>? pending;
  @override
  List<Trip>? peekTripsCache({bool allowStale = false}) => cache;
  @override
  Future<List<Trip>?> primeTripsCacheFromDisk() async => cache;
  @override
  Future<List<Trip>> refreshTripsFromServer() async {
    if (pending != null) return pending!.future;
    if (error != null) throw error!;
    return trips;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Trip _trip(
  int id, {
  String? name,
  String status = 'active',
  String mode = 'group',
  String currency = 'EUR',
  int share = 4200,
  String role = 'member',
}) => TripModel.fromLegacyMap({
  'id': id,
  'name': name ?? 'Lisbon getaway',
  'status': status,
  'trip_mode': mode,
  'currency_code': currency,
  'my_owed_cents': share,
  'my_paid_cents': 99999,
  'members_count': mode == 'solo' ? 1 : 3,
  'current_user_role': role,
  'date_from': '2026-10-05',
  'date_to': '2026-10-09',
});

Future<void> _pump(
  WidgetTester tester,
  _Trips trips, {
  Brightness brightness = Brightness.light,
  String locale = 'en',
  double scale = 1,
  double width = 390,
  TripsPageCommandController? commands,
  TripsPageOpenTripCallback? onTripOpened,
  GlobalKey? boundary,
  FriendsController? friends,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final theme = brightness == Brightness.dark
      ? AppTheme.dark()
      : AppTheme.light();
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: RepaintBoundary(
          key: const ValueKey('home-preview'),
          child: Scaffold(
            backgroundColor: brightness == Brightness.dark
                ? AppDesign.darkCanvas
                : Colors.white,
            appBar: AppBar(
              title: Image.asset(
                brightness == Brightness.dark
                    ? 'assets/branding/logo_full_dark.png'
                    : 'assets/branding/logo_full.png',
                width: 110,
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  tooltip: 'Notifications',
                  icon: const Icon(Icons.notifications_outlined),
                ),
              ],
            ),
            body: TripsPage(
              controller: trips,
              authController: _Auth(),
              friendsController: friends ?? _Friends(),
              showInlineHeader: false,
              commandController: commands,
              onTripOpened: onTripOpened,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  const received = ReceivedTripInvitation(
    id: 9,
    tripId: 77,
    tripName: 'Summer trip',
    inviterName: 'Anna',
    inviteToken: 'abcdefghij',
  );

  for (final accept in [true, false]) {
    testWidgets(
      'home invitation badge survives opening and responds accept=$accept',
      (tester) async {
        final trips = _Trips()..invitations = [received];
        await _pump(tester, trips);
        await tester.pumpAndSettle();
        Badge badge() => tester.widget<Badge>(
          find.byKey(const ValueKey('home-trip-invitation-badge')),
        );
        expect(badge().isLabelVisible, isTrue);
        expect((badge().label! as Text).data, '1');
        await tester.tap(find.byKey(const ValueKey('home-trip-invitations')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('received-trip-invitation-9')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        // Dismissing the confirmation is not a rejection or acceptance.
        await tester.tap(find.byTooltip('Close').last);
        await tester.pumpAndSettle();
        expect(trips.accepted + trips.declined, 0);
        expect((badge().label! as Text).data, '1');
        await tester.tap(
          find.byKey(const ValueKey('received-trip-invitation-9')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.text(accept ? 'Accept' : 'Decline'));
        await tester.pumpAndSettle();
        expect(trips.accepted, accept ? 1 : 0);
        expect(trips.declined, accept ? 0 : 1);
        expect(badge().isLabelVisible, isFalse);
        // The envelope itself must not contain an unread dot after responding.
        expect((badge().child as Icon).icon, Icons.mail_outline);
        expect(find.text('No pending trip invitations'), findsOneWidget);
      },
    );
  }

  testWidgets('home invitations refresh and recover from failure', (
    tester,
  ) async {
    final commands = TripsPageCommandController();
    addTearDown(commands.dispose);
    final trips = _Trips()..invitationsFail = true;
    await _pump(tester, trips, commands: commands);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-trip-invitations')));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not load invitations. Please try again.'),
      findsOneWidget,
    );
    trips.invitationsFail = false;
    trips.invitations = [received];
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('received-trip-invitation-9')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Close').last);
    await tester.pumpAndSettle();
    trips.invitations = [];
    commands.requestInvitationsRefresh();
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Badge>(
            find.byKey(const ValueKey('home-trip-invitation-badge')),
          )
          .isLabelVisible,
      isFalse,
    );
  });

  testWidgets(
    'share opens native menu with invite URL and anchor without opening trip',
    (tester) async {
      MethodCall? shared;
      const channel = MethodChannel('dev.fluttercommunity.plus/share');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        shared = call;
        return 'com.whatsapp';
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      final trips = _Trips()..trips = [_trip(1, role: 'owner')];
      var opened = false;
      await _pump(
        tester,
        trips,
        onTripOpened: (trip, {bool openAddExpense = false}) {
          opened = true;
        },
      );
      await tester.pumpAndSettle();
      final share = find.byKey(const ValueKey('home-trip-share-1'));
      expect(
        tester.getTopLeft(share).dy,
        greaterThan(
          tester.getTopLeft(find.byKey(const ValueKey('home-trip-menu-1'))).dy,
        ),
      );
      await tester.tap(share);
      await tester.pumpAndSettle();
      expect(shared?.method, 'share');
      expect(
        shared?.arguments['text'],
        contains('https://splyto.eu/invite?invite=abcdefghij'),
      );
      expect(shared?.arguments['originWidth'], greaterThan(0));
      expect(opened, isFalse);
      expect(trips.shareCalls, 1);
      trips.shareFail = true;
      shared = null;
      await tester.tap(share);
      await tester.pumpAndSettle();
      expect(shared, isNull);
      expect(
        find.text('Could not share the trip. Please try again.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('share is restricted to active group owners and admins', (
    tester,
  ) async {
    for (final trip in [
      _trip(1, role: 'owner'),
      _trip(1, role: 'admin'),
      _trip(1),
      _trip(1, role: 'owner', mode: 'solo'),
      _trip(1, role: 'owner', status: 'archived'),
    ]) {
      await tester.pumpWidget(const SizedBox.shrink());
      await _pump(tester, _Trips()..trips = [trip]);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('home-trip-share-1')),
        trip.canCurrentUserManageTrip && trip.isActive && !trip.isSolo
            ? findsOneWidget
            : findsNothing,
      );
    }
  });

  testWidgets('home invitation and share review images', (tester) async {
    if (!const bool.fromEnvironment('HOME_ACTIONS_PREVIEWS')) return;
    for (final dark in [false, true]) {
      final key = GlobalKey();
      await tester.pumpWidget(const SizedBox.shrink());
      final trips = _Trips()
        ..trips = [_trip(1, role: 'owner')]
        ..invitations = [received];
      await _pump(
        tester,
        trips,
        boundary: key,
        brightness: dark ? Brightness.dark : Brightness.light,
      );
      await tester.pumpAndSettle();
      for (final sheet in [false, true]) {
        if (sheet) {
          await tester.tap(find.byKey(const ValueKey('home-trip-invitations')));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/home-actions/${dark ? 'dark' : 'light'}-${sheet ? 'invitations' : 'home'}.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
  });

  testWidgets('invitation review join', (tester) async {
    if (!const bool.fromEnvironment('INVITATION_PREVIEWS')) return;
    for (final dark in [false, true]) {
      final key = GlobalKey();
      await _pump(
        tester,
        _Trips(),
        brightness: dark ? Brightness.dark : Brightness.light,
        boundary: key,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Join trip via invite'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(
          '../output/design/invitations/${dark ? 'dark' : 'light'}-join.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));
  setUpAll(() async {
    await (FontLoader('packages/cupertino_icons/CupertinoIcons')..addFont(
          rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'),
        ))
        .load();
    final loader = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  testWidgets(
    'first load is not empty; genuine empty has create and join only',
    (tester) async {
      final trips = _Trips()..pending = Completer<List<Trip>>();
      await _pump(tester, trips);
      expect(find.byType(AppSkeletonBlock), findsWidgets);
      expect(find.text('Your first trip'), findsNothing);
      trips.pending!.complete([]);
      await tester.pumpAndSettle();
      expect(find.text('Your first trip'), findsOneWidget);
      expect(find.text('Your share across all trips'), findsNothing);
      expect(find.byKey(const ValueKey('home-create-trip')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('home-create-trip')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('create-trip-form')), findsOneWidget);
    },
  );

  testWidgets(
    'A4 uses shares, keeps currencies separate, includes archived and settling',
    (tester) async {
      final trips = _Trips()
        ..trips = [
          _trip(1),
          _trip(2, name: 'Archived trip', status: 'archived', share: 800),
          _trip(
            3,
            name: 'Settling trip',
            status: 'settling',
            currency: 'USD',
            share: 1200,
          ),
        ];
      int? opened;
      await _pump(
        tester,
        trips,
        onTripOpened: (trip, {openAddExpense = false}) {
          opened = trip.id;
        },
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('home-total-EUR'))).data,
        contains('50.00'),
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('home-total-USD'))).data,
        contains('12.00'),
      );
      expect(find.text('Settling trip'), findsOneWidget);
      expect(find.text('Archived trip'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('home-trip-1')));
      expect(opened, 1);
      await tester.tap(find.byKey(const ValueKey('home-archived')));
      await tester.pumpAndSettle();
      expect(find.text('Archived trip'), findsOneWidget);
      expect(find.text('Lisbon getaway'), findsNothing);
    },
  );

  testWidgets('archived-only opens archive, never first-use screen', (
    tester,
  ) async {
    await _pump(tester, _Trips()..trips = [_trip(1, status: 'archived')]);
    await tester.pumpAndSettle();
    expect(find.text('Lisbon getaway'), findsOneWidget);
    expect(find.text('Your first trip'), findsNothing);
  });

  testWidgets(
    'refresh retains content, marks offline and clears on revoked access',
    (tester) async {
      final trips = _Trips()..trips = [_trip(1)];
      final commands = TripsPageCommandController();
      addTearDown(commands.dispose);
      await _pump(tester, trips, commands: commands);
      await tester.pumpAndSettle();
      trips.pending = Completer<List<Trip>>();
      commands.requestRefresh();
      await tester.pump();
      expect(find.text('Lisbon getaway'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      trips.pending!.completeError(
        const ApiException('Offline', isNetworkError: true),
      );
      await tester.pumpAndSettle();
      expect(find.text('Offline. Showing saved trips.'), findsOneWidget);
      expect(find.text('Lisbon getaway'), findsOneWidget);
      trips.pending = null;
      trips.error = const ApiException('Forbidden', statusCode: 403);
      commands.requestRefresh();
      await tester.pumpAndSettle();
      expect(find.text('Lisbon getaway'), findsNothing);
      expect(find.text('Could not load your trips'), findsOneWidget);
      trips.cache = [_trip(1)];
      trips.pending = Completer<List<Trip>>();
      commands.requestRefresh();
      await tester.pump();
      expect(find.text('Lisbon getaway'), findsNothing);
      trips.pending!.completeError(
        const ApiException('Offline', isNetworkError: true),
      );
      await tester.pumpAndSettle();
      expect(find.text('Lisbon getaway'), findsNothing);
    },
  );

  testWidgets('offline without cache shows error and retry recovers', (
    tester,
  ) async {
    final trips = _Trips()
      ..error = const ApiException('Offline', isNetworkError: true);
    await _pump(tester, trips);
    await tester.pumpAndSettle();
    expect(find.text("You're offline"), findsOneWidget);
    expect(find.text('Your first trip'), findsNothing);
    trips.error = null;
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text('Your first trip'), findsOneWidget);
  });

  testWidgets('older refresh cannot overwrite the latest result', (
    tester,
  ) async {
    final trips = _Trips()..trips = [_trip(1)];
    final commands = TripsPageCommandController();
    addTearDown(commands.dispose);
    await _pump(tester, trips, commands: commands);
    await tester.pumpAndSettle();
    final older = Completer<List<Trip>>();
    trips.pending = older;
    commands.requestRefresh();
    await tester.pump();
    trips.pending = null;
    trips.trips = [_trip(2, name: 'Latest')];
    commands.requestRefresh();
    await tester.pumpAndSettle();
    older.complete([_trip(1, name: 'Old')]);
    await tester.pumpAndSettle();
    expect(find.text('Latest'), findsOneWidget);
    expect(find.text('Old'), findsNothing);
  });

  for (final brightness in Brightness.values) {
    for (final locale in ['en', 'lv', 'es']) {
      for (final empty in [true, false]) {
        testWidgets('320px 200% $brightness $locale empty=$empty', (
          tester,
        ) async {
          tester.view.padding = const FakeViewPadding(top: 44, bottom: 20);
          addTearDown(tester.view.resetPadding);
          await _pump(
            tester,
            _Trips()
              ..trips = empty
                  ? []
                  : [
                      _trip(
                        1,
                        name:
                            'A very long trip name with friends across several countries',
                        share: 123456789,
                      ),
                    ],
            brightness: brightness,
            locale: locale,
            width: 320,
            scale: 2,
          );
          await tester.pumpAndSettle();
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -450),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets(
    'expenses is an action and does not change selected destination',
    (tester) async {
      AppBottomNavItem? tapped;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              selectedItem: AppBottomNavItem.friends,
              avatarLetter: 'M',
              onSelected: (item) => tapped = item,
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('nav-expenses')));
      await tester.pump();
      expect(tapped, AppBottomNavItem.expenses);
      expect(
        tester
            .widget<AppBottomNavBar>(find.byType(AppBottomNavBar))
            .selectedItem,
        AppBottomNavItem.friends,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final role in ['owner', 'admin', 'member']) {
    testWidgets('trip menu preserves $role permissions', (tester) async {
      await _pump(tester, _Trips()..trips = [_trip(1, role: role)]);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('home-trip-menu-1')));
      await tester.pumpAndSettle();
      expect(
        find.byIcon(Icons.edit_outlined),
        role == 'member' ? findsNothing : findsOneWidget,
      );
      expect(
        find.byIcon(Icons.delete_outline),
        role == 'owner' ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('empty Home join action still opens invite entry', (
    tester,
  ) async {
    await _pump(tester, _Trips());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Join trip via invite'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('home controls have named 48px tap targets', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, _Trips()..trips = [_trip(1)]);
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('trip form review images', (tester) async {
    if (!const bool.fromEnvironment('TRIP_FORM_PREVIEWS')) return;
    for (final brightness in Brightness.values) {
      for (final screen in ['create', 'members', 'solo', 'currency', 'edit']) {
        tester.view.padding = const FakeViewPadding(top: 44, bottom: 20);
        addTearDown(tester.view.resetPadding);
        final boundary = GlobalKey();
        final commands = TripsPageCommandController();
        await _pump(
          tester,
          _Trips()..trips = [_trip(1, role: 'owner')],
          brightness: brightness,
          commands: commands,
          boundary: boundary,
          friends: _Friends(
            friends: const [
              FriendUser(id: 8, nickname: 'Anna Parker'),
              FriendUser(id: 9, nickname: 'Daniel Reed'),
            ],
          ),
        );
        await tester.pumpAndSettle();
        if (screen != 'edit') {
          commands.requestOpenCreateTrip();
        } else {
          await tester.tap(find.byKey(const ValueKey('home-trip-menu-1')));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Edit trip'));
        }
        await tester.pumpAndSettle();
        if (screen == 'solo') {
          await tester.tap(find.byKey(const ValueKey('trip-mode-solo')));
          await tester.pumpAndSettle();
        } else if (screen == 'currency') {
          await tester.tap(find.byKey(const ValueKey('trip-currency')));
          await tester.pumpAndSettle();
        } else if (screen == 'members') {
          await tester.ensureVisible(
            find.byKey(const ValueKey('trip-friend-9')),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('trip-friend-8')));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/trip-forms/${brightness.name}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        commands.dispose();
      }
    }
  });

  // Opt-in image generation/verification, using real production widgets and
  // fixture data only. Normal unit-test runs remain portable across platforms.
  if (const bool.fromEnvironment('HOME_GOLDENS')) {
    for (final brightness in Brightness.values) {
      for (final count in [0, 1, 3]) {
        testWidgets('preview ${brightness.name} $count trips', (tester) async {
          tester.view.padding = const FakeViewPadding(top: 44, bottom: 20);
          addTearDown(tester.view.resetPadding);
          await _pump(
            tester,
            _Trips()
              ..trips = [
                if (count > 0) _trip(1),
                if (count > 1) _trip(2, name: 'Alpine weekend', share: 12000),
                if (count > 1)
                  _trip(3, name: 'Copenhagen', mode: 'solo', share: 8500),
              ],
            brightness: brightness,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byKey(const ValueKey('home-preview')),
            matchesGoldenFile('goldens/home-${brightness.name}-$count.png'),
          );
        });
      }
    }
  }
}
