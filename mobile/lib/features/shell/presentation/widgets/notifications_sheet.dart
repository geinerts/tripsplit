import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/ui/splyto_illustration.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/notification_localizer.dart';
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

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({
    super.key,
    required this.controller,
    required this.isAccountCurrent,
    required this.onUnreadCount,
    this.now,
  });
  final WorkspaceController controller;
  final bool Function() isAccountCurrent;
  final ValueChanged<int> onUnreadCount;
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

  Widget _tile(WorkspaceNotification item) {
    final localized = localizeWorkspaceNotification(context, item);
    final actor = notificationActorName(item);
    final initials = actor
        ?.split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s.characters.first)
        .join()
        .toUpperCase();
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
                  child: initials != null && initials.isNotEmpty
                      ? Text(
                          initials,
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Icon(
                          item.type.contains('friend')
                              ? Icons.person_outline
                              : item.type == 'expense_added'
                              ? Icons.receipt_long_outlined
                              : Icons.notifications_none,
                          size: 22,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localized.title.trim().isEmpty
                          ? context.l10n.notificationFallbackTitle
                          : localized.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (localized.body.trim().isNotEmpty)
                      Text(
                        localized.body,
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
