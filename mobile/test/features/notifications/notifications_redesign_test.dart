import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/l10n/notification_localizer.dart';
import 'package:tripsplit/core/ui/app_sheet.dart';
import 'package:tripsplit/features/shell/presentation/widgets/notifications_sheet.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_notification.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_notifications_inbox.dart';
import 'package:tripsplit/features/workspace/presentation/controllers/workspace_controller.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

final _now = DateTime(2026, 10, 22, 12);
WorkspaceNotification _item(
  int id, {
  bool read = false,
  int days = 0,
  String type = 'friend_invite_accepted',
  int tripId = 0,
  String? token,
  String? body,
}) => WorkspaceNotification(
  id: id,
  tripId: tripId,
  inviteToken: token,
  tripName: tripId > 0 ? 'Lisbon getaway' : null,
  type: type,
  title: 'Invite accepted',
  body: body ?? 'Anna Parker accepted your friend invite.',
  isRead: read,
  createdAt: _now.subtract(Duration(days: days, minutes: id)).toIso8601String(),
);
WorkspaceNotificationsInbox _page(
  List<WorkspaceNotification> items, {
  bool more = false,
  String? cursor,
  bool cached = false,
}) => WorkspaceNotificationsInbox(
  unreadCount: items.where((n) => !n.isRead).length,
  notifications: items,
  hasMore: more,
  nextCursor: cursor,
  isCached: cached,
);

class _Workspace implements WorkspaceController {
  WorkspaceNotificationsInbox inbox = _page([
    _item(1),
    _item(2, read: true),
    _item(3, days: 1),
  ]);
  WorkspaceNotificationsInbox? next;
  Object? error, markError;
  Completer<WorkspaceNotificationsInbox>? pending;
  Completer<int>? pendingMark;
  final cursors = <String?>[];
  final marks = <List<int>>[];
  @override
  Future<WorkspaceNotificationsInbox> loadGlobalNotifications({
    int limit = 80,
    String? cursor,
    int? offset,
  }) async {
    cursors.add(cursor);
    if (error != null) throw error!;
    if (pending != null) return pending!.future;
    return cursor == null ? inbox : next!;
  }

  @override
  Future<int> markGlobalNotificationsRead({
    List<int> notificationIds = const [],
  }) async {
    marks.add(notificationIds);
    if (markError != null) throw markError!;
    if (pendingMark != null) return pendingMark!.future;
    return 0;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Future<void> _mount(
  WidgetTester tester,
  _Workspace controller, {
  String locale = 'en',
  bool dark = false,
  double width = 390,
  double scale = 1,
  bool Function()? current,
  ValueChanged<int>? onUnread,
  ValueChanged<WorkspaceNotification?>? onSelected,
  bool settle = true,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 44, bottom: 20);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
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
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final result = await showAppBottomSheet<WorkspaceNotification>(
                context: context,
                useSafeArea: false,
                builder: (_) => NotificationsSheet(
                  controller: controller,
                  isAccountCurrent: current ?? () => true,
                  onUnreadCount: onUnread ?? (_) {},
                  now: () => _now,
                ),
              );
              onSelected?.call(result);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }
}

AppLocalizations _t(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(NotificationsSheet)))!;
Future<void> _tap(WidgetTester tester, String text) async {
  final target = find.text(text);
  await tester.scrollUntilVisible(
    target,
    180,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  test('known server actor only and timestamp parsing', () {
    expect(notificationActorName(_item(1)), 'Anna Parker');
    expect(
      notificationActorName(
        _item(
          1,
          type: 'friend_invite_received',
          body: 'Anna Parker sent you a friend invite.',
        ),
      ),
      'Anna Parker',
    );
    expect(
      notificationActorName(_item(1, type: 'info', body: 'Anna Parker')),
      isNull,
    );
    expect(
      notificationActorName(_item(1, body: 'An unrecognized sentence')),
      isNull,
    );
    expect(
      notificationDate('2026-10-22 12:00:00')!.toUtc(),
      DateTime.utc(2026, 10, 22, 12),
    );
    expect(notificationDate('invalid'), isNull);
  });
  for (final dark in [false, true]) {
    for (final locale in ['en', 'lv', 'es']) {
      testWidgets('notifications 320px 200% $locale dark=$dark', (
        tester,
      ) async {
        final w = _Workspace()
          ..inbox = _page([
            _item(
              1,
              body: 'Aleksandrs Ļoti Garš Uzvārds accepted your friend invite.',
            ),
            _item(2, days: 1),
          ]);
        await _mount(
          tester,
          w,
          locale: locale,
          dark: dark,
          width: 320,
          scale: 2,
        );
        final t = _t(tester);
        expect(find.text(t.notificationsToday), findsOneWidget);
        await tester.drag(
          find.byKey(const ValueKey('notifications-list')),
          const Offset(0, -250),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(
          find.byTooltip(
            MaterialLocalizations.of(
              tester.element(find.byType(NotificationsSheet)),
            ).closeButtonTooltip,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsSheet), findsNothing);
      });
    }
  }
  testWidgets('date grouping includes read today and unread earlier', (
    tester,
  ) async {
    await _mount(tester, _Workspace());
    final todayY = tester.getTopLeft(find.text('Today')).dy;
    final earlierY = tester.getTopLeft(find.text('Earlier')).dy;
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('notification-2'))).dy,
      greaterThan(todayY),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('notification-2'))).dy,
      lessThan(earlierY),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('notification-3'))).dy,
      greaterThan(earlierY),
    );
    expect(find.byKey(const ValueKey('notification-unread-3')), findsNothing);
    expect(find.text('AP'), findsNWidgets(3));
  });
  testWidgets(
    'empty and failed load both keep header and close; retry recovers',
    (tester) async {
      final w = _Workspace()
        ..error = const ApiException('Offline', isNetworkError: true);
      await _mount(tester, w);
      expect(find.byKey(const ValueKey('notifications-empty')), findsNothing);
      expect(find.text(_t(tester).notificationsTitle), findsOneWidget);
      w.error = null;
      w.inbox = _page([]);
      await _tap(tester, _t(tester).retryAction);
      expect(find.byKey(const ValueKey('notifications-empty')), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.ancestor(
                of: find.byIcon(Icons.done_all),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNull,
      );
    },
  );
  testWidgets('cached data is labelled including cached empty', (tester) async {
    await _mount(tester, _Workspace()..inbox = _page([], cached: true));
    expect(find.text(_t(tester).notificationsCached), findsOneWidget);
    expect(find.byKey(const ValueKey('notifications-empty')), findsOneWidget);
  });
  testWidgets(
    'opening automatically marks all, blocks duplicates and updates badge',
    (tester) async {
      final w = _Workspace()..pendingMark = Completer<int>();
      final counts = <int>[];
      await _mount(tester, w, onUnread: counts.add, settle: false);
      final title = _t(tester).shellMarkAllAsReadAction;
      await tester.tap(find.byTooltip(title));
      await tester.pump();
      expect(w.marks, [[]]);
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (w) => w is IconButton && w.tooltip == title,
              ),
            )
            .onPressed,
        isNull,
      );
      w.pendingMark!.complete(0);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('notification-unread-1')), findsNothing);
      expect(find.byKey(const ValueKey('notification-unread-3')), findsNothing);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Earlier'), findsOneWidget);
      expect(counts.last, 0);
    },
  );
  testWidgets('mark failure leaves unread state and allows retry', (
    tester,
  ) async {
    final w = _Workspace()..markError = const ApiException('Failed');
    await _mount(tester, w);
    await tester.tap(find.byTooltip(_t(tester).shellMarkAllAsReadAction));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('notification-unread-1')), findsOneWidget);
    expect(
      find.text(_t(tester).shellFailedToUpdateNotifications),
      findsOneWidget,
    );
    w.markError = null;
    await tester.tap(find.byTooltip(_t(tester).shellMarkAllAsReadAction));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('notification-unread-1')), findsNothing);
  });
  testWidgets('pagination failure retry and overlap deduplication', (
    tester,
  ) async {
    final w = _Workspace()
      ..inbox = _page([_item(1)], more: true, cursor: 'page2')
      ..next = _page([_item(1), _item(2, days: 1)]);
    await _mount(tester, w);
    w.error = const ApiException('Offline', isNetworkError: true);
    await _tap(tester, _t(tester).shellLoadMoreNotificationsAction);
    expect(
      find.text(_t(tester).shellFailedToLoadNotifications),
      findsOneWidget,
    );
    w.error = null;
    await _tap(tester, _t(tester).retryAction);
    expect(w.cursors, [null, 'page2', 'page2']);
    expect(find.byKey(const ValueKey('notification-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-2')), findsOneWidget);
  });
  testWidgets(
    'old response after close/account change cannot update unread count',
    (tester) async {
      final w = _Workspace()
        ..pending = Completer<WorkspaceNotificationsInbox>();
      var current = true;
      final counts = <int>[];
      await _mount(
        tester,
        w,
        current: () => current,
        onUnread: counts.add,
        settle: false,
      );
      current = false;
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      w.pending!.complete(_page([_item(1)]));
      await tester.pumpAndSettle();
      expect(counts, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'English notification parameters preserve actor, amount and recipient',
    (tester) async {
      await _mount(tester, _Workspace());
      final context = tester.element(find.byType(NotificationsSheet));
      for (final example in [
        ('expense_added', 'Anna added an expense of €42.00: Airport transfer'),
        ('expense_added', 'Anna added an expense of €42.00 in "Lisbon".'),
        ('settlement_reminder', 'Anna reminded Daniel to mark €42.00 as sent.'),
        (
          'settlement_reminder',
          'Anna reminded Daniel to confirm receiving €42.00.',
        ),
        ('settlement_sent', 'Anna marked €42.00 as sent to you.'),
        ('settlement_confirmed', 'Anna confirmed receiving €42.00 from you.'),
      ]) {
        expect(
          localizeWorkspaceNotification(
            context,
            _item(1, type: example.$1, body: example.$2),
          ).body,
          example.$2,
        );
      }
    },
  );
  testWidgets(
    'refresh failure retains rows, denial clears them and retry remains available',
    (tester) async {
      final w = _Workspace();
      await _mount(tester, w);
      Future<void> refresh() async {
        tester
            .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
            .show();
        await tester.pumpAndSettle();
      }

      w.error = const ApiException('Offline', isNetworkError: true);
      await refresh();
      expect(find.byKey(const ValueKey('notification-1')), findsOneWidget);
      expect(find.text(_t(tester).notificationsRefreshFailed), findsOneWidget);
      w.error = const ApiException('Forbidden', statusCode: 403);
      await _tap(tester, _t(tester).retryAction);
      expect(find.byKey(const ValueKey('notification-1')), findsNothing);
      expect(find.byKey(const ValueKey('notifications-empty')), findsNothing);
      expect(find.text(_t(tester).retryAction), findsOneWidget);
    },
  );
  testWidgets(
    'nonadvancing next page fails without appending partial results',
    (tester) async {
      final w = _Workspace()
        ..inbox = _page([_item(1)], more: true, cursor: 'same')
        ..next = _page([_item(2)], more: true, cursor: 'same');
      await _mount(tester, w);
      await _tap(tester, _t(tester).shellLoadMoreNotificationsAction);
      expect(find.byKey(const ValueKey('notification-2')), findsNothing);
      expect(find.text(_t(tester).retryAction), findsOneWidget);
    },
  );
  for (final type in [
    'friend_invite_accepted',
    'expense_added',
    'trip_invitation',
  ]) {
    testWidgets('opening $type preserves exact destination fields', (
      tester,
    ) async {
      WorkspaceNotification? result;
      final item = _item(7, type: type, tripId: 12, token: 'invite-token');
      await _mount(
        tester,
        _Workspace()..inbox = _page([item]),
        onSelected: (v) => result = v,
      );
      await tester.tap(find.byKey(const ValueKey('notification-7')));
      await tester.pumpAndSettle();
      expect(result!.id, 7);
      expect(result!.tripId, 12);
      expect(result!.inviteToken, 'invite-token');
      expect(result!.isRead, true);
    });
  }
}
