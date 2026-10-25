import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/deeplink/invite_deep_link_controller.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/features/auth/domain/entities/auth_user.dart';
import 'package:tripsplit/features/auth/domain/entities/notification_preferences.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/auth/presentation/pages/profile_page.dart';
import 'package:tripsplit/features/friends/domain/entities/friends_snapshot.dart';
import 'package:tripsplit/features/friends/domain/entities/friends_section_page.dart';
import 'package:tripsplit/features/friends/presentation/controllers/friends_controller.dart';
import 'package:tripsplit/features/quick_start/data/quick_start_service.dart';
import 'package:tripsplit/features/quick_start/presentation/quick_start_sheet.dart';
import 'package:tripsplit/features/shell/presentation/pages/main_shell_page.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';
import 'package:tripsplit/features/trips/domain/entities/trip.dart';
import 'package:tripsplit/features/trips/domain/entities/trip_invite_preview.dart';
import 'package:tripsplit/features/trips/presentation/controllers/trips_controller.dart';
import 'package:tripsplit/features/trips/presentation/pages/trips_page.dart';
import 'package:tripsplit/features/workspace/presentation/controllers/workspace_controller.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class _Auth implements AuthController {
  @override
  AuthUser? get currentUser =>
      const AuthUser(id: 1, nickname: 'Test', needsCredentials: false);
  @override
  Future<AuthUser> loadCurrentUser() async => currentUser!;
  @override
  NotificationPreferences get notificationPreferences =>
      const NotificationPreferences.defaults();
  @override
  Future<NotificationPreferences> loadNotificationPreferences() async =>
      notificationPreferences;
  @override
  Uint8List? avatarBytesFor(AuthUser? user) => null;
  @override
  String? avatarUrlFor(AuthUser? user, {bool preferThumb = false}) => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Trips implements TripsController {
  _Trips(this.accountSession);
  @override
  final AccountDataSession accountSession;
  List<Trip> trips = [];
  List<Trip>? cache;
  Object? error;
  Completer<List<Trip>>? pending;
  Completer<TripInvitePreview>? invite;
  @override
  List<Trip>? peekTripsCache({bool allowStale = true}) => cache;
  @override
  Future<List<Trip>?> primeTripsCacheFromDisk() async => cache;
  @override
  Future<List<Trip>> refreshTripsFromServer() async {
    if (pending != null) return pending!.future;
    if (error != null) throw error!;
    return trips;
  }

  @override
  Future<List<Trip>> loadTrips({bool forceRefresh = false}) async => [];
  @override
  Future<TripInvitePreview> previewTripInvite({required String inviteToken}) =>
      invite!.future;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Friends implements FriendsController {
  @override
  Future<FriendsSectionPage> loadSectionPage({
    required String section,
    int limit = 25,
    String? cursor,
    int? offset,
  }) async => FriendsSectionPage(
    section: section,
    friendsCount: 0,
    pendingSentCount: 0,
    pendingReceivedCount: 0,
    friends: [],
    requests: [],
    hasMore: false,
    nextCursor: null,
    nextOffset: null,
  );
  @override
  FriendsSnapshot? peekSnapshotCache({bool allowStale = true}) =>
      const FriendsSnapshot(friends: [], pendingReceived: [], pendingSent: []);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Workspace implements WorkspaceController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Links implements InviteDeepLinkController {
  final invites = StreamController<String>.broadcast();
  String? initial;
  @override
  String? consumePendingInviteCode() {
    final value = initial;
    initial = null;
    return value;
  }

  @override
  FriendDeepLinkTarget? consumePendingFriendTarget() => null;
  @override
  String? consumePendingFriendLinkToken() => null;
  @override
  Stream<String> get inviteCodeStream => invites.stream;
  @override
  Stream<String> get friendLinkTokenStream => const Stream.empty();
  @override
  Stream<FriendDeepLinkTarget> get friendTargetStream => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Service implements QuickStartService {
  _Service(this.accountSession);
  @override
  final AccountDataSession accountSession;
  int calls = 0;
  bool eligible = true;
  Completer<bool>? pending;
  @override
  Future<bool> claimAutomaticPresentation() async {
    calls++;
    return pending?.future ?? eligible;
  }
}

Future<void> _mount(
  WidgetTester tester,
  _Trips trips,
  _Service service,
  _Links links, {
  int tab = 0,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MainShellPage(
        authController: _Auth(),
        tripsController: trips,
        friendsController: _Friends(),
        workspaceController: _Workspace(),
        inviteDeepLinkController: links,
        quickStartService: service,
        initialTabIndex: tab,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _tick(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _dispose(WidgetTester tester, _Links links) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
  await links.invites.close();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (_) async => ['none'],
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity_status'),
      (_) async => null,
    );
  });

  testWidgets('loading and failures never claim; successful retry can show', (
    tester,
  ) async {
    final session = AccountDataSession()..activate(1);
    final trips = _Trips(session)..pending = Completer();
    final service = _Service(session);
    final links = _Links();
    await _mount(tester, trips, service, links);
    await _tick(tester);
    expect(service.calls, 0);
    trips.pending!.completeError(
      const ApiException('Offline', isNetworkError: true),
    );
    await _tick(tester);
    expect(service.calls, 0);
    trips.pending = null;
    tester
        .widget<TripsPage>(find.byType(TripsPage))
        .commandController!
        .requestRefresh();
    await tester.pump();
    await _tick(tester);
    expect(service.calls, 1);
    expect(find.byType(QuickStartSheet), findsOneWidget);
    await _dispose(tester, links);
  });

  for (final status in ['active', 'archived']) {
    testWidgets('$status trips are never first use', (tester) async {
      final session = AccountDataSession()..activate(1);
      final trips = _Trips(session)
        ..trips = [
          TripModel.fromLegacyMap({'id': 1, 'name': 'Trip', 'status': status}),
        ];
      final service = _Service(session);
      final links = _Links();
      await _mount(tester, trips, service, links);
      await _tick(tester);
      expect(service.calls, 0);
      expect(find.byType(QuickStartSheet), findsNothing);
      await _dispose(tester, links);
    });
  }

  testWidgets('claim response cannot overlay a newly opened dialog', (
    tester,
  ) async {
    final session = AccountDataSession()..activate(1);
    final trips = _Trips(session);
    final service = _Service(session)..pending = Completer();
    final links = _Links();
    await _mount(tester, trips, service, links);
    await _tick(tester);
    expect(service.calls, 1);
    final context = tester.element(find.byType(MainShellPage));
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(title: Text('Busy')),
      ),
    );
    await tester.pumpAndSettle();
    service.pending!.complete(true);
    await _tick(tester);
    expect(find.byType(QuickStartSheet), findsNothing);
    Navigator.of(context).pop();
    await _tick(tester);
    await _tick(tester);
    expect(find.byType(QuickStartSheet), findsOneWidget);
    expect(service.calls, 1);
    await _dispose(tester, links);
  });

  testWidgets(
    'initial invitation has priority; after failure eligibility is rechecked',
    (tester) async {
      final session = AccountDataSession()..activate(1);
      final trips = _Trips(session)..invite = Completer();
      final service = _Service(session);
      final links = _Links()..initial = 'abcdefghij';
      await _mount(tester, trips, service, links);
      await _tick(tester);
      expect(service.calls, 0);
      trips.invite!.completeError(const ApiException('Expired invitation'));
      await _tick(tester);
      await _tick(tester);
      expect(find.byType(QuickStartSheet), findsOneWidget);
      await _dispose(tester, links);
    },
  );

  testWidgets(
    'completion opens actual creation form; cancellation never replays',
    (tester) async {
      final session = AccountDataSession()..activate(1);
      final trips = _Trips(session);
      final service = _Service(session);
      final links = _Links();
      await _mount(tester, trips, service, links);
      await _tick(tester);
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      await tester.tap(
        find.descendant(
          of: find.byType(QuickStartSheet),
          matching: find.text('Create'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('create-trip-form')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      tester
          .widget<TripsPage>(find.byType(TripsPage))
          .commandController!
          .requestRefresh();
      await _tick(tester);
      expect(find.byType(QuickStartSheet), findsNothing);
      expect(service.calls, 1);
      await _dispose(tester, links);
    },
  );

  testWidgets('profile replay works without automatic claim or network', (
    tester,
  ) async {
    final session = AccountDataSession()..activate(1);
    final trips = _Trips(session)
      ..error = const ApiException('Offline', isNetworkError: true);
    final service = _Service(session)..eligible = false;
    final links = _Links();
    await _mount(tester, trips, service, links, tab: 4);
    tester
        .widget<ProfilePage>(find.byType(ProfilePage))
        .onQuickStartRequested!();
    await tester.pumpAndSettle();
    expect(find.byType(QuickStartSheet), findsOneWidget);
    expect(service.calls, 0);
    await _dispose(tester, links);
  });

  testWidgets('manual join stays ahead of guide while preview is loading', (
    tester,
  ) async {
    final session = AccountDataSession()..activate(1);
    final trips = _Trips(session)..invite = Completer();
    final service = _Service(session);
    final links = _Links();
    await _mount(tester, trips, service, links);
    await tester.tap(find.text('Join trip via invite'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'abcdefghij');
    await tester.tap(find.text('Join'));
    await _tick(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(service.calls, 0);
    trips.invite!.completeError(const ApiException('Expired invitation'));
    await _tick(tester);
    await _tick(tester);
    expect(find.byType(QuickStartSheet), findsOneWidget);
    await _dispose(tester, links);
  });

  testWidgets(
    'incoming invitation dismisses a visible guide without reopening it',
    (tester) async {
      final session = AccountDataSession()..activate(1);
      final trips = _Trips(session)..invite = Completer();
      final service = _Service(session);
      final links = _Links();
      await _mount(tester, trips, service, links);
      await _tick(tester);
      expect(find.byType(QuickStartSheet), findsOneWidget);
      links.invites.add('abcdefghij');
      await _tick(tester);
      expect(find.byType(QuickStartSheet), findsNothing);
      trips.invite!.completeError(const ApiException('Expired invitation'));
      await _tick(tester);
      expect(find.byType(QuickStartSheet), findsNothing);
      expect(service.calls, 1);
      await _dispose(tester, links);
    },
  );
}
