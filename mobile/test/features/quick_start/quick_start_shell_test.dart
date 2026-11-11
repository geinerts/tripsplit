import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'dart:io';
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
import 'package:tripsplit/features/friends/presentation/pages/friend_search_page.dart';
import 'package:tripsplit/features/quick_start/data/quick_start_seen_store.dart';
import 'package:tripsplit/features/quick_start/data/quick_start_service.dart';
import 'package:tripsplit/features/quick_start/presentation/quick_start_sheet.dart';
import 'package:tripsplit/features/analytics/data/analytics_repository.dart';
import 'package:tripsplit/features/analytics/domain/analytics_report.dart';
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
  int loadCalls = 0;
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
  Future<List<Trip>> loadTrips({bool forceRefresh = false}) async {
    loadCalls++;
    return pending?.future ?? [];
  }

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
  bool seenOnDevice = false;
  bool markedSeen = false;
  @override
  QuickStartSeenStore? get seenStore => null;
  @override
  Future<bool> isSeenOnDevice() async => seenOnDevice;
  @override
  Future<void> markSeenOnDevice() async => markedSeen = true;
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
  ValueListenable<bool>? offline,
  String locale = 'en',
  bool dark = false,
  double scale = 1,
  GlobalKey? boundary,
}) async {
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
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
    home: MainShellPage(
      offlineStatus: offline,
      authController: _Auth(),
      tripsController: trips,
      friendsController: _Friends(),
      workspaceController: _Workspace(),
      analyticsRepository: _Analytics(),
      inviteDeepLinkController: links,
      quickStartService: service,
      initialTabIndex: tab,
    ),
  );
  await tester.pumpWidget(
    boundary == null ? app : RepaintBoundary(key: boundary, child: app),
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

class _Analytics implements AnalyticsRepository {
  @override
  Future<List<AnalyticsTripSummary>> loadSummary() async => const [];
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

  testWidgets(
    'Friends header opens search next to notifications and returns cleanly',
    (tester) async {
      final session = AccountDataSession()..activate(1);
      final links = _Links();
      await _mount(
        tester,
        _Trips(session),
        _Service(session)..eligible = false,
        links,
        tab: 3,
      );
      await _tick(tester);
      final search = find.byKey(const ValueKey('friends-open-search'));
      final bell = find.byIcon(Icons.notifications_none_outlined);
      expect(search, findsOneWidget);
      expect(tester.getCenter(search).dx, lessThan(tester.getCenter(bell).dx));
      expect(find.byKey(const ValueKey('friends-search')), findsNothing);
      await tester.tap(search);
      await _tick(tester);
      expect(find.byType(FriendSearchPage), findsOneWidget);
      expect(find.byKey(const ValueKey('friends-search')), findsOneWidget);
      await tester.pageBack();
      await _tick(tester);
      expect(search, findsOneWidget);
      expect(find.byKey(const ValueKey('friends-search')), findsNothing);
      await _dispose(tester, links);
    },
  );

  testWidgets(
    'Expenses chooses a cached trip without waiting for the network',
    (tester) async {
      final session = AccountDataSession()..activate(1);
      final links = _Links();
      final trips = _Trips(session)
        ..pending = Completer<List<Trip>>()
        ..cache = [
          TripModel.fromLegacyMap({
            'id': 1,
            'name': 'Offline Lisbon',
            'status': 'active',
          }),
          TripModel.fromLegacyMap({
            'id': 2,
            'name': 'Offline Riga',
            'status': 'active',
          }),
        ];
      await _mount(
        tester,
        trips,
        _Service(session)..eligible = false,
        links,
        tab: 3,
      );
      await tester.tap(find.byKey(const ValueKey('nav-expenses')));
      await _tick(tester);
      expect(find.text('Offline Lisbon'), findsOneWidget);
      expect(find.text('Offline Riga'), findsOneWidget);
      expect(trips.loadCalls, 0);
      expect(trips.pending!.isCompleted, isFalse);
      await _dispose(tester, links);
    },
  );

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

  testWidgets('seen before sign-up: the server is told, the guide stays shut', (
    tester,
  ) async {
    final session = AccountDataSession()..activate(1);
    final trips = _Trips(session);
    final service = _Service(session)..seenOnDevice = true;
    final links = _Links();
    await _mount(tester, trips, service, links);
    await _tick(tester);
    expect(service.calls, 1);
    expect(find.byType(QuickStartSheet), findsNothing);
    await _dispose(tester, links);
  });

  testWidgets('not seen, like after an invite: the guide shows and is marked', (
    tester,
  ) async {
    final session = AccountDataSession()..activate(1);
    final trips = _Trips(session);
    final service = _Service(session);
    final links = _Links();
    await _mount(tester, trips, service, links);
    await _tick(tester);
    expect(find.byType(QuickStartSheet), findsOneWidget);
    expect(service.markedSeen, isTrue);
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
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      await tester.tap(
        find.descendant(
          of: find.byType(QuickStartSheet),
          matching: find.text('Create trip'),
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

  testWidgets('create from guide replayed on a profile sub-page reaches form', (
    tester,
  ) async {
    final session = AccountDataSession()..activate(1);
    final trips = _Trips(session);
    final service = _Service(session)..eligible = false;
    final links = _Links();
    await _mount(tester, trips, service, links, tab: 4);
    final profile = tester.element(find.byType(ProfilePage));
    unawaited(
      Navigator.of(profile).push<void>(
        MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Help'))),
      ),
    );
    await tester.pumpAndSettle();
    tester
        .widget<ProfilePage>(find.byType(ProfilePage, skipOffstage: false))
        .onQuickStartRequested!();
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    await tester.tap(
      find.descendant(
        of: find.byType(QuickStartSheet),
        matching: find.text('Create trip'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Help'), findsNothing);
    expect(find.byKey(const ValueKey('create-trip-form')), findsOneWidget);
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
  testWidgets('one Offline notice sits next to the bell and retries', (
    tester,
  ) async {
    final session = AccountDataSession()..activate(1);
    final links = _Links();
    final offline = ValueNotifier<bool>(true);
    addTearDown(offline.dispose);
    final trips = _Trips(session);
    await _mount(
      tester,
      trips,
      _Service(session)..eligible = false,
      links,
      offline: offline,
    );
    await _tick(tester);
    final notice = find.byKey(const ValueKey('shell-offline'));
    expect(notice, findsOneWidget);
    expect(
      find.descendant(of: notice, matching: find.text('Offline')),
      findsOne,
    );
    expect(
      find.descendant(
        of: notice,
        matching: find.byIcon(Icons.wifi_off_rounded),
      ),
      findsOne,
    );
    final bell = find.byIcon(Icons.notifications_none_outlined);
    expect(tester.getCenter(notice).dx, lessThan(tester.getCenter(bell).dx));
    await tester.tap(find.byKey(const ValueKey('shell-offline-retry')));
    await _tick(tester);
    offline.value = false;
    await _tick(tester);
    expect(notice, findsNothing);
    expect(tester.takeException(), isNull);
    await _dispose(tester, links);
  });
  for (final locale in AppLocalizations.supportedLocales.map(
    (l) => l.languageCode,
  )) {
    testWidgets('Offline notice fits 320px at 200% in $locale', (tester) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final session = AccountDataSession()..activate(1);
      final links = _Links();
      final offline = ValueNotifier<bool>(true);
      addTearDown(offline.dispose);
      await _mount(
        tester,
        _Trips(session),
        _Service(session)..eligible = false,
        links,
        tab: 3,
        offline: offline,
        locale: locale,
        scale: 2,
      );
      await _tick(tester);
      expect(find.byKey(const ValueKey('shell-offline')), findsOneWidget);
      expect(find.byKey(const ValueKey('shell-offline-retry')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _dispose(tester, links);
    });
  }
  testWidgets('Offline notice review images', (tester) async {
    if (!const bool.fromEnvironment('OFFLINE_NOTICE_PREVIEWS')) return;
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    tester.view.physicalSize = const Size(390, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final dark in [false, true]) {
      for (final tab in [0, 1, 3, 4]) {
        final key = GlobalKey();
        final session = AccountDataSession()..activate(1);
        final links = _Links();
        final offline = ValueNotifier<bool>(true);
        await _mount(
          tester,
          _Trips(session),
          _Service(session)..eligible = false,
          links,
          tab: tab,
          offline: offline,
          locale: 'lv',
          dark: dark,
          boundary: key,
        );
        await _tick(tester);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/offline-notice/${dark ? 'dark' : 'light'}-tab$tab.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await _dispose(tester, links);
        offline.dispose();
      }
    }
  });
}
