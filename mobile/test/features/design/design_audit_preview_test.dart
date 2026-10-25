import 'package:tripsplit/core/ui/app_bottom_nav_bar.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/features/workspace/domain/entities/expense_participant.dart';
import 'package:tripsplit/features/workspace/domain/entities/trip_expenses_page.dart';
import 'package:tripsplit/app/theme/theme_mode_controller.dart';
import 'package:tripsplit/app/theme/theme_mode_scope.dart';
import 'package:tripsplit/features/workspace/domain/entities/trip_expense.dart';
import 'package:tripsplit/features/workspace/domain/entities/balance_item.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_user.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_notifications_inbox.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_notification.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_snapshot.dart';
// Opt-in renders of the pre-migration screens for the design audit.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/deeplink/invite_deep_link_controller.dart';
import 'package:tripsplit/features/auth/domain/entities/auth_user.dart';
import 'package:tripsplit/features/auth/domain/entities/notification_preferences.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/friends/domain/entities/friends_snapshot.dart';
import 'package:tripsplit/features/friends/domain/entities/friends_section_page.dart';
import 'package:tripsplit/features/friends/presentation/controllers/friends_controller.dart';
import 'package:tripsplit/features/quick_start/data/quick_start_service.dart';
import 'package:tripsplit/features/shell/presentation/pages/main_shell_page.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';
import 'package:tripsplit/features/trips/domain/entities/trip.dart';
import 'package:tripsplit/features/trips/domain/entities/trip_invite_preview.dart';
import 'package:tripsplit/features/trips/presentation/controllers/trips_controller.dart';
import 'package:tripsplit/features/workspace/presentation/controllers/workspace_controller.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class _Auth implements AuthController {
  @override
  AuthUser? get currentUser => const AuthUser(
    id: 1,
    nickname: 'Matiss',
    firstName: 'Matiss',
    lastName: 'Geinerts',
    email: 'matiss@example.com',
    needsCredentials: false,
  );
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
  Future<List<Trip>> loadTrips({bool forceRefresh = false}) async => trips;
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
  bool empty = false;
  bool notificationsError = false, notificationsCached = false;
  bool notificationsRead = false;
  final notificationMarks = <List<int>>[];
  @override
  Future<int> markGlobalNotificationsRead({
    List<int> notificationIds = const [],
  }) async {
    notificationMarks.add(notificationIds);
    notificationsRead = true;
    return 0;
  }

  @override
  Future<TripExpensesPage> loadExpensesPage({
    required int tripId,
    int limit = 300,
    String? cursor,
    int? offset,
  }) async => TripExpensesPage(
    items: (await loadSnapshot(tripId: tripId)).expenses,
    hasMore: false,
    nextCursor: null,
    nextOffset: null,
  );
  @override
  Future<WorkspaceSnapshot> loadSnapshot({required int tripId}) async =>
      WorkspaceSnapshot(
        tripStatus: 'active',
        tripEndedAt: null,
        tripArchivedAt: null,
        users: const [
          WorkspaceUser(id: 1, nickname: 'Matiss', role: 'owner'),
          WorkspaceUser(id: 2, nickname: 'Anna'),
        ],
        balances: const [
          BalanceItem(id: 1, nickname: 'Matiss', paid: 84, owed: 63, net: 21),
          BalanceItem(id: 2, nickname: 'Anna', paid: 42, owed: 63, net: -21),
        ],
        settlements: [],
        payments: [],
        settlementTotal: 0,
        settlementConfirmed: 0,
        settlementRemaining: 0,
        allSettled: false,
        unreadNotifications: 0,
        notifications: [],
        orders: [],
        expenses: [
          for (final item in [
            (1, 'Breakfast', 'food', 24.0),
            (2, 'Airport transfer', 'transport', 42.0),
            (3, 'Dinner', 'food', 60.0),
          ])
            TripExpense(
              id: item.$1,
              amount: item.$4,
              originalAmount: item.$4,
              tripCurrencyCode: 'EUR',
              expenseCurrencyCode: 'EUR',
              fxRateToTrip: 1,
              category: item.$3,
              note: item.$2,
              expenseDate: '2026-10-05',
              splitMode: 'equal',
              paidById: item.$1 == 2 ? 2 : 1,
              paidByNickname: item.$1 == 2 ? 'Anna' : 'Matiss',
              receiptUrl: null,
              participants: [
                for (final member in [
                  (1, 'Matiss Geinerts'),
                  (2, 'Anna Parker'),
                  (3, 'Daniel Reed'),
                ])
                  ExpenseParticipant(
                    id: member.$1,
                    nickname: member.$2,
                    owedAmount: item.$4 / 3,
                  ),
              ],
            ),
        ],
      );
  @override
  Future<WorkspaceNotificationsInbox> loadGlobalNotifications({
    int limit = 80,
    String? cursor,
    int? offset,
  }) async {
    if (notificationsError) {
      throw const ApiException('Offline', isNetworkError: true);
    }
    return WorkspaceNotificationsInbox(
      isCached: notificationsCached,
      unreadCount: empty || notificationsRead ? 0 : 1,
      notifications: empty
          ? []
          : [
              WorkspaceNotification(
                id: 1,
                tripId: 1,
                tripName: 'Lisbon getaway',
                type: 'expense_added',
                title: 'Expense added',
                body: 'Anna added an expense of €42.00: Airport transfer',
                isRead: notificationsRead,
                createdAt: DateTime.now()
                    .subtract(const Duration(minutes: 10))
                    .toIso8601String(),
              ),
              WorkspaceNotification(
                id: 2,
                tripId: 1,
                type: 'friend_invite_accepted',
                title: 'Invite accepted',
                body: 'Daniel accepted your friend invite.',
                isRead: true,
                createdAt: DateTime.now()
                    .subtract(const Duration(hours: 1))
                    .toIso8601String(),
              ),
              WorkspaceNotification(
                id: 3,
                tripId: 0,
                type: 'friend_invite_accepted',
                title: 'Invite accepted',
                body: 'Igors accepted your friend invite.',
                isRead: true,
                createdAt: DateTime.now()
                    .subtract(const Duration(days: 1))
                    .toIso8601String(),
              ),
            ],
    );
  }

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

void main() {
  const analyticsPreview = bool.fromEnvironment('ANALYTICS_SHELL_PREVIEWS');
  const profilePreview = bool.fromEnvironment('PROFILE_SHELL_PREVIEWS');
  const notificationsPreview = bool.fromEnvironment(
    'NOTIFICATIONS_SHELL_PREVIEWS',
  );
  if (!notificationsPreview &&
      !profilePreview &&
      !analyticsPreview &&
      !const bool.fromEnvironment('DESIGN_AUDIT_PREVIEWS')) {
    return;
  }
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final dark in [false, true]) {
    for (final screen
        in notificationsPreview
            ? [
                'notifications',
                'notifications-empty',
                'notifications-error',
                'notifications-offline',
              ]
            : profilePreview
            ? ['profile']
            : analyticsPreview
            ? [
                'analytics',
                'analytics-total',
                'analytics-share',
                'analytics-empty',
              ]
            : [
                'analytics',
                'analytics-empty',
                'profile',
                'notifications',
                'notifications-empty',
              ]) {
      testWidgets('audit ${dark ? "dark" : "light"} $screen', (tester) async {
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
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 44, bottom: 20);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);
        final themeController = ThemeModeController();
        await themeController.setThemeMode(
          dark ? ThemeMode.dark : ThemeMode.light,
        );
        addTearDown(themeController.dispose);
        final session = AccountDataSession()..activate(1);
        final trips = _Trips(session)
          ..trips = [
            if (screen != 'analytics-empty')
              TripModel.fromLegacyMap({
                'id': 1,
                'name': 'Lisbon getaway',
                'status': 'active',
                'members_count': 3,
                'currency_code': 'EUR',
                'total_amount_cents': 12600,
                'my_owed_cents': 4200,
                'my_paid_cents': 8400,
                'my_balance_cents': 4200,
                'date_from': '2026-10-05',
                'date_to': '2026-10-09',
              }),
          ];
        final service = _Service(session)..eligible = false;
        final links = _Links();
        final workspaceController = _Workspace()
          ..empty = screen.endsWith('empty')
          ..notificationsError = screen == 'notifications-error'
          ..notificationsCached = screen == 'notifications-offline';
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              builder: (context, child) =>
                  ThemeModeScope(controller: themeController, child: child!),
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: MainShellPage(
                authController: _Auth(),
                tripsController: trips,
                friendsController: _Friends(),
                workspaceController: workspaceController,
                inviteDeepLinkController: links,
                quickStartService: service,
                initialTabIndex: screen.startsWith('analytics')
                    ? 1
                    : screen == 'profile'
                    ? 4
                    : 0,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => precacheImage(
            AssetImage(
              dark
                  ? 'assets/branding/logo_full_dark.png'
                  : 'assets/branding/logo_full.png',
            ),
            key.currentContext!,
          ),
        );
        await tester.pumpAndSettle();
        if (screen == 'analytics-total' || screen == 'analytics-share') {
          await tester.tap(find.text('By trip'));
          await tester.pumpAndSettle();
          if (screen == 'analytics-total') {
            await tester.tap(find.text('Trip total').first);
            await tester.pumpAndSettle();
          }
        }
        if (screen.startsWith('notifications')) {
          await tester.tap(find.byTooltip('Notifications'));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('notifications-sheet')),
            findsOneWidget,
          );
          if (screen == 'notifications-error') {
            expect(find.text('Retry'), findsOneWidget);
            expect(
              find.byKey(const ValueKey('notifications-empty')),
              findsNothing,
            );
          }
        }
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            notificationsPreview
                ? '../output/design/notifications/${dark ? "dark" : "light"}-$screen.png'
                : profilePreview
                ? '../output/design/profile/shell-${dark ? "dark" : "light"}-profile.png'
                : analyticsPreview
                ? '../output/design/analytics/shell-${dark ? "dark" : "light"}-$screen.png'
                : '../output/design/audit-2026-10-22/${dark ? "dark" : "light"}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        if (notificationsPreview && screen == 'notifications') {
          await tester.tap(find.byTooltip('Mark all as read'));
          await tester.pumpAndSettle();
          expect(workspaceController.notificationMarks, [[]]);
          expect(
            find.byKey(const ValueKey('notification-unread-1')),
            findsNothing,
          );
          await tester.tap(find.byKey(const ValueKey('notification-2')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('notifications-sheet')),
            findsNothing,
          );
          expect(
            tester
                .widget<AppBottomNavBar>(find.byType(AppBottomNavBar))
                .selectedItem,
            AppBottomNavItem.friends,
          );
          expect(tester.takeException(), isNull);
        }
        if (profilePreview) {
          expect(find.byTooltip('Back'), findsNothing);
          await tester.tap(find.text('Matiss Geinerts'));
          await tester.pumpAndSettle();
          expect(find.byTooltip('Back'), findsOneWidget);
          await tester.tap(find.byTooltip('Back'));
          await tester.pumpAndSettle();
          expect(find.byTooltip('Back'), findsNothing);
          expect(find.text('Appearance'), findsOneWidget);
          await tester.drag(
            find.byKey(const ValueKey('profile-scroll')),
            const Offset(0, -430),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.runAsync(() async {
            final image =
                await (key.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '../output/design/profile/shell-${dark ? "dark" : "light"}-profile-bottom.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        if (analyticsPreview && !screen.endsWith('empty')) {
          await tester.drag(
            find.byKey(const ValueKey('analytics-scroll')),
            const Offset(0, -460),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.runAsync(() async {
            final image =
                await (key.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '../output/design/analytics/shell-${dark ? "dark" : "light"}-$screen-bottom.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
        await links.invites.close();
      });
    }
  }
}
