class WorkspaceNotification {
  const WorkspaceNotification({
    required this.id,
    required this.tripId,
    this.tripName,
    this.inviteToken,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  WorkspaceNotification copyWith({bool? isRead}) => WorkspaceNotification(
    id: id,
    tripId: tripId,
    tripName: tripName,
    inviteToken: inviteToken,
    type: type,
    title: title,
    body: body,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );

  final int id;
  final int tripId;
  final String? tripName;
  final String? inviteToken;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final String? createdAt;
}
