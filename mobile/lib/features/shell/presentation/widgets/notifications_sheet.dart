import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/ui/splyto_illustration.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/notification_localizer.dart';
import '../../../../core/ui/app_components.dart';
import '../../../workspace/domain/entities/workspace_notification.dart';
import '../../../workspace/presentation/controllers/workspace_controller.dart';

DateTime? notificationDate(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return null;
  // SQL timestamps follow the same UTC convention as the activity feed.
  final sql = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$').hasMatch(value);
  return DateTime.tryParse(
    sql ? '${value.replaceFirst(' ', 'T')}Z' : value,
  )?.toLocal();
}

List<WorkspaceNotification> sortNotifications(
  List<WorkspaceNotification> items,
) => items.toList()
  ..sort((a, b) {
    final order = (notificationDate(b.createdAt)?.millisecondsSinceEpoch ?? 0)
        .compareTo(notificationDate(a.createdAt)?.millisecondsSinceEpoch ?? 0);
    return order == 0 ? b.id.compareTo(a.id) : order;
  });

/// What can be answered from the list: a payment to confirm, a friend
/// request or a trip invitation.
enum NotificationAnswerKind { payment, settlement, friend, tripInvitation }

NotificationAnswerKind? notificationAnswerKind(WorkspaceNotification item) {
  switch (item.type.trim().toLowerCase()) {
    case 'payment_sent' when item.tripId > 0 && item.refs['payment_id'] != null:
      return NotificationAnswerKind.payment;
    case 'settlement_sent'
        when item.tripId > 0 && item.refs['settlement_id'] != null:
      return NotificationAnswerKind.settlement;
    case 'friend_invite' || 'friend_invite_received'
        when item.refs['request_id'] != null:
      return NotificationAnswerKind.friend;
    case 'trip_invitation' when (item.inviteToken ?? '').isNotEmpty:
      return NotificationAnswerKind.tripInvitation;
  }
  return null;
}

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({
    super.key,
    required this.controller,
    required this.isAccountCurrent,
    required this.onUnreadCount,
    this.onAnswer,
    this.now,
  });
  final WorkspaceController controller;
  final bool Function() isAccountCurrent;
  final ValueChanged<int> onUnreadCount;

  /// Answers [item] from the list: [accept] is ✓, otherwise ✕. Throws an
  /// [ApiException] with a message to show when it fails. Null hides ✕ | ✓.
  final Future<void> Function(WorkspaceNotification item, bool accept)?
  onAnswer;
  final DateTime Function()? now;
  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  List<WorkspaceNotification> _items = [];
  final _readIds = <int>{};
  bool _loading = false,
      _loadingMore = false,
      _marking = false,
      _loaded = false,
      _cached = false,
      _hasMore = false;
  String? _cursor, _error, _moreError;
  int? _offset;
  int _generation = 0, _unread = 0;
  int _earlierVisible = 5;

  /// Answered in this sheet: notification id → ✓ (true) or ✕ (false).
  final _answers = <int, bool>{};
  final _answering = <int>{};
  bool get _busy => _loading || _loadingMore || _marking;
  bool _current(int generation) =>
      mounted && widget.isAccountCurrent() && generation == _generation;
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    if (_marking ||
        _loading ||
        (more && (_loadingMore || !_hasMore || _cached))) {
      return;
    }
    final generation = ++_generation;
    final cursor = more ? _cursor : null;
    final offset = more && cursor == null ? _offset : null;
    var markOpenedInbox = false;
    setState(() {
      if (more) {
        _loadingMore = true;
        _moreError = null;
      } else {
        _loading = true;
        _loadingMore = false;
        _error = null;
        _moreError = null;
      }
    });
    try {
      if (more && cursor == null && offset == null) {
        throw StateError('Missing notification cursor');
      }
      final inbox = await widget.controller.loadGlobalNotifications(
        limit: 40,
        cursor: cursor,
        offset: offset,
      );
      if (!_current(generation)) return;
      if (more &&
          inbox.hasMore &&
          ((inbox.nextCursor == cursor && inbox.nextOffset == offset) ||
              inbox.notifications.isEmpty)) {
        throw StateError('Notification pagination did not advance');
      }
      final byId = <int, WorkspaceNotification>{
        if (more)
          for (final item in _items) item.id: item,
        for (final item in inbox.notifications) item.id: item,
      };
      setState(() {
        _items = sortNotifications(byId.values.toList());
        _loaded = true;
        _cached = inbox.isCached;
        _hasMore = inbox.hasMore;
        _cursor = inbox.nextCursor;
        _offset = inbox.nextOffset;
        _unread = inbox.unreadCount.clamp(0, 1 << 31);
        if (!more) {
          _earlierVisible = 5;
          if (!inbox.isCached) _readIds.clear();
        } else {
          _earlierVisible += inbox.notifications.length;
        }
      });
      widget.onUnreadCount(_unread);
      markOpenedInbox = !more && !inbox.isCached && _unread > 0;
    } catch (error) {
      if (!_current(generation)) return;
      final denied =
          error is ApiException &&
          ([401, 403, 404].contains(error.statusCode) ||
              error.code == 'account_changed');
      setState(() {
        if (denied) {
          _items = [];
          _readIds.clear();
          _loaded = false;
          _hasMore = false;
        }
        if (more && !denied) {
          _moreError = context.l10n.shellFailedToLoadNotifications;
        } else {
          _error = _loaded
              ? context.l10n.notificationsRefreshFailed
              : context.l10n.shellFailedToLoadNotifications;
        }
      });
    } finally {
      if (_current(generation)) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
    if (_current(generation) && markOpenedInbox) {
      await _markAll();
    }
  }

  Future<void> _markAll() async {
    if (_busy || _unread == 0) return;
    final generation = ++_generation;
    setState(() {
      _marking = true;
      _error = null;
    });
    try {
      final count = await widget.controller.markGlobalNotificationsRead(
        notificationIds: const [],
      );
      if (!_current(generation)) return;
      setState(() {
        _readIds.addAll(_items.map((n) => n.id));
        _unread = count.clamp(0, 1 << 31);
      });
      widget.onUnreadCount(_unread);
    } catch (error) {
      if (_current(generation)) {
        setState(() {
          if (error is ApiException &&
              ([401, 403, 404].contains(error.statusCode) ||
                  error.code == 'account_changed')) {
            _items = [];
            _readIds.clear();
            _loaded = false;
            _hasMore = false;
          }
          _error = context.l10n.shellFailedToUpdateNotifications;
        });
      }
    } finally {
      if (_current(generation)) setState(() => _marking = false);
    }
  }

  Future<void> _answer(WorkspaceNotification item, bool accept) async {
    final onAnswer = widget.onAnswer;
    final kind = notificationAnswerKind(item);
    if (onAnswer == null || kind == null || _answering.contains(item.id)) {
      return;
    }
    final t = context.l10n;
    // Joining a trip shows its preview first, like tapping the row.
    if (accept && kind == NotificationAnswerKind.tripInvitation) {
      Navigator.pop(context, item.copyWith(isRead: true));
      return;
    }
    if (!accept &&
        (kind == NotificationAnswerKind.payment ||
            kind == NotificationAnswerKind.settlement)) {
      final sure = await showAppConfirmationDialog(
        context: context,
        title: t.settlementNotReceivedConfirmTitle,
        message: t.settlementNotReceivedConfirmText,
        confirmLabel: t.settlementNotReceivedAction,
        cancelLabel: t.cancelAction,
        icon: Icons.report_gmailerrorred_rounded,
        destructive: true,
      );
      if (!sure || !mounted) return;
    }
    final generation = _generation;
    setState(() => _answering.add(item.id));
    try {
      await onAnswer(item, accept);
      if (!mounted || generation != _generation) return;
      setState(() => _answers[item.id] = accept);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            error.message.trim().isEmpty
                ? t.shellFailedToUpdateNotifications
                : error.message,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(t.shellFailedToUpdateNotifications)),
      );
    } finally {
      if (mounted) setState(() => _answering.remove(item.id));
    }
  }

  /// "Received", "Accepted"… after an answer in this sheet.
  String _answerLabel(NotificationAnswerKind kind, bool accept) {
    final t = context.l10n;
    return switch ((kind, accept)) {
      (
        NotificationAnswerKind.payment || NotificationAnswerKind.settlement,
        true,
      ) =>
        t.notificationAnswerReceived,
      (
        NotificationAnswerKind.payment || NotificationAnswerKind.settlement,
        false,
      ) =>
        t.notificationAnswerNotReceived,
      (_, true) => t.notificationAnswerAccepted,
      (_, false) => t.notificationAnswerDeclined,
    };
  }

  Widget _trailing(WorkspaceNotification item, NotificationHeadline? headline) {
    final kind = widget.onAnswer == null ? null : notificationAnswerKind(item);
    final theme = Theme.of(context);
    final answer = _answers[item.id];
    if (kind != null && answer != null) {
      return Text(
        _answerLabel(kind, answer),
        key: ValueKey('notification-answer-${item.id}'),
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: answer
              ? theme.colorScheme.primary
              : AppDesign.mutedColor(context),
        ),
      );
    }
    if (kind != null) {
      return _AnswerButtons(
        key: ValueKey('notification-actions-${item.id}'),
        busy: _answering.contains(item.id),
        declineLabel:
            kind == NotificationAnswerKind.payment ||
                kind == NotificationAnswerKind.settlement
            ? context.l10n.settlementNotReceivedAction
            : context.l10n.friendsDecline,
        acceptLabel:
            kind == NotificationAnswerKind.payment ||
                kind == NotificationAnswerKind.settlement
            ? context.l10n.notificationAnswerReceived
            : context.l10n.friendsAccept,
        onDecline: () => _answer(item, false),
        onAccept: () => _answer(item, true),
      );
    }
    final amount = headline?.amount;
    if (amount == null) return const SizedBox.shrink();
    return Text(
      amount,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  bool _today(WorkspaceNotification item) {
    final date = notificationDate(item.createdAt);
    final now = (widget.now?.call() ?? DateTime.now()).toLocal();
    return date != null &&
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _time(WorkspaceNotification item) {
    final date = notificationDate(item.createdAt);
    if (date == null) return '';
    final now = (widget.now?.call() ?? DateTime.now()).toLocal();
    final elapsed = now.difference(date);
    if (!elapsed.isNegative && _today(item)) {
      if (elapsed.inMinutes < 1) return context.l10n.notificationsJustNow;
      if (elapsed.inMinutes < 60) {
        return context.l10n.notificationsMinutesAgo(elapsed.inMinutes);
      }
      return context.l10n.notificationsHoursAgo(elapsed.inHours);
    }
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return context.l10n.shellYesterday;
    }
    return MaterialLocalizations.of(context).formatShortDate(date);
  }

  Widget _avatarFallback(WorkspaceNotification item, String? initials) =>
      initials != null && initials.isNotEmpty
      ? Text(
          initials,
          textScaler: TextScaler.noScaling,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        )
      : Icon(
          item.type.contains('friend')
              ? Icons.person_outline
              : item.type == 'expense_added'
              ? Icons.receipt_long_outlined
              : item.type == 'expense_comment_mention'
              ? Icons.alternate_email
              : item.type == 'expense_comment_added'
              ? Icons.chat_bubble_outline_rounded
              : item.type == 'live_location_started'
              ? Icons.location_on_outlined
              : item.type == 'trip_starts_tomorrow'
              ? Icons.flight_takeoff_rounded
              : Icons.notifications_none,
          size: 22,
        );

  Widget _tile(WorkspaceNotification item) {
    final localized = localizeWorkspaceNotification(context, item);
    // Who did what, instead of one title shared by every row of a type.
    final headline = notificationHeadline(context, item);
    final title =
        headline?.title ??
        (localized.title.trim().isEmpty
            ? context.l10n.notificationFallbackTitle
            : localized.title);
    final detail = headline != null ? headline.detail : localized.body;
    final actor = notificationActorName(item);
    final initials = actor
        ?.split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s.characters.first)
        .join()
        .toUpperCase();
    final avatarUrl = (item.actorAvatarThumbUrl ?? '').trim().isNotEmpty
        ? item.actorAvatarThumbUrl!.trim()
        : (item.actorAvatarUrl ?? '').trim();
    final unread = !item.isRead && !_readIds.contains(item.id);
    final meta = [
      if (item.tripId > 0 && (item.tripName ?? '').trim().isNotEmpty)
        item.tripName!.trim(),
      _time(item),
    ].where((s) => s.isNotEmpty).join(' · ');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('notification-${item.id}'),
        onTap: _marking || !widget.isAccountCurrent()
            ? null
            : () => Navigator.pop(context, item.copyWith(isRead: !unread)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                  child: avatarUrl.isEmpty
                      ? _avatarFallback(item, initials)
                      : ClipOval(
                          child: Image.network(
                            avatarUrl,
                            key: ValueKey('notification-avatar-${item.id}'),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _avatarFallback(item, initials),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (detail != null && detail.trim().isNotEmpty)
                      Text(
                        detail,
                        maxLines: headline != null ? 2 : null,
                        overflow: headline != null
                            ? TextOverflow.ellipsis
                            : null,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppDesign.mutedColor(context),
                        ),
                      ),
                    if (meta.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          meta,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _trailing(item, headline),
              const SizedBox(width: 6),
              SizedBox(
                width: 8,
                child: unread
                    ? Semantics(
                        label: context.l10n.notificationsUnread,
                        child: Container(
                          key: ValueKey('notification-unread-${item.id}'),
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading(String title) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppDesign.mutedColor(context)),
    ),
  );
  List<Widget> _rows(List<WorkspaceNotification> items) => [
    for (var i = 0; i < items.length; i++) ...[
      if (i > 0) const Divider(height: 1),
      _tile(items[i]),
    ],
  ];
  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final today = _items.where(_today).toList();
    final earlier = _items.where((n) => !_today(n)).toList();
    final hiddenEarlier = earlier.length > _earlierVisible;
    return ConstrainedBox(
      key: const ValueKey('notifications-sheet'),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .82,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.notificationsTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: t.shellMarkAllAsReadAction,
                  onPressed: _busy || !_loaded || _unread == 0
                      ? null
                      : _markAll,
                  icon: _marking
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.done_all),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          if (_loading && _loaded) const LinearProgressIndicator(),
          Flexible(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                key: const ValueKey('notifications-list'),
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  16 + MediaQuery.viewPaddingOf(context).bottom,
                ),
                children: [
                  if (_cached)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(t.notificationsCached),
                    ),
                  if (_error != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _busy ? null : _load,
                        icon: const Icon(Icons.refresh),
                        label: Text(t.retryAction),
                      ),
                    ),
                  ],
                  if (_loading && !_loaded)
                    const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_loaded && _items.isEmpty)
                    Padding(
                      key: const ValueKey('notifications-empty'),
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Column(
                        children: [
                          SplytoIllustration(
                            'assets/branding/splyto_empty_notifications.svg',
                            width: 160,
                            height: 130,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            t.noNotificationsYet,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.notificationsEmptyBody,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppDesign.mutedColor(context),
                                ),
                          ),
                        ],
                      ),
                    ),
                  if (today.isNotEmpty) ...[
                    _heading(t.notificationsToday),
                    ..._rows(today),
                  ],
                  if (earlier.isNotEmpty) ...[
                    _heading(t.shellEarlierSection),
                    ..._rows(earlier.take(_earlierVisible).toList()),
                  ],
                  if (hiddenEarlier)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => setState(() => _earlierVisible += 10),
                        child: Text(t.shellShowMoreEarlierAction),
                      ),
                    ),
                  if (_moreError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _moreError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  if (_hasMore && !hiddenEarlier && !_cached)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _busy ? null : () => _load(more: true),
                        icon: const Icon(Icons.expand_more),
                        label: Text(
                          _loadingMore
                              ? t.shellLoadingMore
                              : _moreError != null
                              ? t.retryAction
                              : t.shellLoadMoreNotificationsAction,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✕ | ✓ in one light grey group: ✕ declines, ✓ accepts or confirms.
class _AnswerButtons extends StatelessWidget {
  const _AnswerButtons({
    super.key,
    required this.busy,
    required this.declineLabel,
    required this.acceptLabel,
    required this.onDecline,
    required this.onAccept,
  });

  final bool busy;
  final String declineLabel;
  final String acceptLabel;
  final VoidCallback onDecline;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final muted = AppDesign.mutedColor(context);
    Widget button({
      required Key key,
      required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap,
      required BorderRadius radius,
    }) => Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          key: key,
          onTap: busy ? null : onTap,
          borderRadius: radius,
          child: SizedBox(
            width: 44,
            height: 36,
            child: Icon(icon, size: 20, color: busy ? muted : color),
          ),
        ),
      ),
    );
    return Material(
      color: AppDesign.isDark(context)
          ? AppDesign.darkSurfaceRaised
          : AppDesign.lightSurfaceMutedAlt,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            key: const ValueKey('notification-decline'),
            label: declineLabel,
            icon: Icons.close_rounded,
            color: muted,
            onTap: onDecline,
            radius: const BorderRadius.horizontal(left: Radius.circular(18)),
          ),
          Container(width: 1, height: 18, color: colors.outlineVariant),
          busy
              ? const SizedBox(
                  width: 44,
                  height: 36,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : button(
                  key: const ValueKey('notification-accept'),
                  label: acceptLabel,
                  icon: Icons.check_rounded,
                  color: colors.onSurface,
                  onTap: onAccept,
                  radius: const BorderRadius.horizontal(
                    right: Radius.circular(18),
                  ),
                ),
        ],
      ),
    );
  }
}
