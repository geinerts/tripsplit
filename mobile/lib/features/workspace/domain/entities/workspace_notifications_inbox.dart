import 'workspace_notification.dart';

class WorkspaceNotificationsInbox {
  const WorkspaceNotificationsInbox({
    required this.unreadCount,
    required this.notifications,
    this.hasMore = false,
    this.isCached = false,
    this.nextCursor,
    this.nextOffset,
  });

  final int unreadCount;
  final List<WorkspaceNotification> notifications;
  final bool hasMore;
  final bool isCached;
  final String? nextCursor;
  final int? nextOffset;
}
