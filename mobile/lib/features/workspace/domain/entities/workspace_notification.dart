class WorkspaceNotification {
  const WorkspaceNotification({
    required this.id,
    required this.tripId,
    this.tripName,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final int tripId;
  final String? tripName;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final String? createdAt;
}
