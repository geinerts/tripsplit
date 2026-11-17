import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
  String? avatar,
  String? thumbnail,
  Map<String, int> refs = const {},
}) => WorkspaceNotification(
  refs: refs,
  id: id,
  tripId: tripId,
  inviteToken: token,
  actorAvatarUrl: avatar,
  actorAvatarThumbUrl: thumbnail,
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
  Future<void> Function(WorkspaceNotification, bool)? onAnswer,
  GlobalKey? boundary,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 44, bottom: 20);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
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
                onAnswer: onAnswer,
                now: () => _now,
              ),
            );
            onSelected?.call(result);
          },
          child: const Text('Open'),
        ),
      ),
    ),
  );
  await tester.pumpWidget(
    boundary == null ? app : RepaintBoundary(key: boundary, child: app),
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
  testWidgets('notification photos prefer thumbnails and fall back to initials', (
    tester,
  ) async {
    final controller = _Workspace()
      ..inbox = _page([
        _item(
          1,
          avatar: 'https://example.test/full.jpg',
          thumbnail: 'https://example.test/thumb.jpg',
        ),
        _item(2, avatar: 'https://example.test/full-only.jpg'),
        _item(3),
        _item(4, type: 'trip_ready_to_settle', body: 'All members are ready.'),
      ]);
    await _mount(tester, controller);
    final thumb = tester.widget<Image>(
      find.byKey(const ValueKey('notification-avatar-1')),
    );
    final full = tester.widget<Image>(
      find.byKey(const ValueKey('notification-avatar-2')),
    );
    expect((thumb.image as NetworkImage).url, 'https://example.test/thumb.jpg');
    expect(
      (full.image as NetworkImage).url,
      'https://example.test/full-only.jpg',
    );
    expect(thumb.fit, BoxFit.cover);
    expect(thumb.width, 40);
    expect(find.byKey(const ValueKey('notification-avatar-3')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('notification-3')),
        matching: find.text('AP'),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    // Flutter's test HTTP client rejects image loads; the fallback remains usable.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('notification-1')),
        matching: find.text('AP'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

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
        (
          'expense_comment_mention',
          'Anna mentioned you in a comment on "Taxi".',
        ),
        ('expense_comment_mention', 'Anna mentioned you in a comment.'),
        ('expense_comment_added', 'Anna commented on "Taxi".'),
        ('expense_comment_added', 'Anna commented on your expense.'),
        (
          'live_location_started',
          'Anna started sharing their live location in "Lisbon".',
        ),
        ('settlement_reminder', 'Anna reminded Daniel to mark €42.00 as sent.'),
        (
          'settlement_reminder',
          'Anna reminded Daniel to confirm receiving €42.00.',
        ),
        ('settlement_sent', 'Anna marked €42.00 as sent to you.'),
        ('settlement_confirmed', 'Anna confirmed receiving €42.00 from you.'),
        ('trip_starts_tomorrow', '"Lisbon" starts tomorrow.'),
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

  List<WorkspaceNotification> answerable() => [
    _item(
      1,
      type: 'payment_sent',
      tripId: 7,
      refs: const {'payment_id': 5},
      body: 'Valērija marked EUR 322.60 as paid to you.',
    ),
    _item(
      2,
      type: 'friend_invite_received',
      refs: const {'request_id': 9},
      body: 'Kate Moss sent you a friend invite.',
    ),
    _item(
      3,
      days: 1,
      read: true,
      type: 'expense_added',
      tripId: 7,
      body: 'Marta Kalnīte added an expense of EUR 41.65 in "Albania".',
    ),
    _item(
      4,
      days: 1,
      read: true,
      type: 'expense_added',
      tripId: 7,
      body: 'Marta Kalnīte added an expense of EUR 58.00: Taxi to Theth',
    ),
    _item(
      5,
      days: 2,
      read: true,
      type: 'expense_comment_mention',
      tripId: 7,
      body: 'Andris Ozols mentioned you in a comment on "Fuel".',
    ),
  ];

  testWidgets('rows say who did what, with the amount on the right', (
    tester,
  ) async {
    await _mount(tester, _Workspace()..inbox = _page(answerable()));
    final t = _t(tester);
    expect(find.text('Invite accepted'), findsNothing);
    expect(
      find.text(t.notificationHeadlineSentYou('Valērija', '€322.60')),
      findsOneWidget,
    );
    expect(
      find.text(t.notificationHeadlineFriendRequest('Kate Moss')),
      findsOneWidget,
    );
    expect(
      find.text(t.notificationHeadlineExpense('Marta Kalnīte')),
      findsOneWidget,
    );
    expect(find.text('€41.65'), findsOneWidget);
    expect(find.text('Marta Kalnīte · Taxi to Theth'), findsOneWidget);
    expect(find.text('€58.00'), findsOneWidget);
    expect(
      find.text(t.notificationHeadlineMentioned('Andris Ozols')),
      findsOneWidget,
    );
    expect(find.text('Fuel'), findsOneWidget);
    // Without an answer callback there are no buttons.
    expect(find.byKey(const ValueKey('notification-actions-1')), findsNothing);
  });

  testWidgets('✕ and ✓ answer from the list and show the result', (
    tester,
  ) async {
    final answers = <(int, bool)>[];
    var fail = false;
    await _mount(
      tester,
      _Workspace()..inbox = _page(answerable()),
      onAnswer: (item, accept) async {
        if (fail) throw const ApiException('Already confirmed.');
        answers.add((item.id, accept));
      },
    );
    final t = _t(tester);
    for (final id in [1, 2]) {
      expect(find.byKey(ValueKey('notification-actions-$id')), findsOneWidget);
    }
    // Expenses have no buttons.
    expect(find.byKey(const ValueKey('notification-actions-3')), findsNothing);

    // A failure keeps the buttons and says why.
    fail = true;
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('notification-actions-2')),
        matching: find.byKey(const ValueKey('notification-accept')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Already confirmed.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('notification-actions-2')),
      findsOneWidget,
    );
    fail = false;

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('notification-actions-2')),
        matching: find.byKey(const ValueKey('notification-decline')),
      ),
    );
    await tester.pumpAndSettle();
    expect(answers, [(2, false)]);
    expect(find.text(t.notificationAnswerDeclined), findsOneWidget);

    // "Not received" asks first; cancelling sends nothing.
    final payment = find.byKey(const ValueKey('notification-actions-1'));
    await tester.tap(
      find.descendant(
        of: payment,
        matching: find.byKey(const ValueKey('notification-decline')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(t.settlementNotReceivedConfirmTitle), findsOneWidget);
    await tester.tap(find.text(t.cancelAction).last);
    await tester.pumpAndSettle();
    expect(answers, [(2, false)]);

    await tester.tap(
      find.descendant(
        of: payment,
        matching: find.byKey(const ValueKey('notification-accept')),
      ),
    );
    await tester.pumpAndSettle();
    expect(answers, [(2, false), (1, true)]);
    expect(find.text(t.notificationAnswerReceived), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-actions-1')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('answer buttons fit at 320px and 200% text', (tester) async {
    for (final locale in ['en', 'lv', 'de']) {
      await _mount(
        tester,
        _Workspace()..inbox = _page(answerable()),
        locale: locale,
        width: 320,
        scale: 2,
        onAnswer: (_, _) async {},
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('notification list review images', (tester) async {
    if (!const bool.fromEnvironment('NOTIFICATIONS_PREVIEWS')) return;
    await tester.runAsync(() async {
      await (FontLoader(
        'Inter',
      )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    for (final dark in [false, true]) {
      final key = GlobalKey();
      await _mount(
        tester,
        _Workspace()..inbox = _page(answerable()),
        dark: dark,
        boundary: key,
        onAnswer: (_, _) async {},
      );
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(
          '../output/design/notifications/app-${dark ? 'dark' : 'light'}.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
