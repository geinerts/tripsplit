class WorkspaceNotification {
  const WorkspaceNotification({
    required this.id,
    required this.tripId,
    this.tripName,
    this.inviteToken,
    this.expenseId,
    this.refs = const {},
    this.actorUserId,
    this.actorAvatarUrl,
    this.actorAvatarThumbUrl,
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
    expenseId: expenseId,
    refs: refs,
    actorUserId: actorUserId,
    actorAvatarUrl: actorAvatarUrl,
    actorAvatarThumbUrl: actorAvatarThumbUrl,
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

  /// The expense it is about, for expense and comment notifications.
  final int? expenseId;

  /// Ids from the server payload needed to answer it from the list:
  /// `payment_id`, `settlement_id` or `request_id`.
  final Map<String, int> refs;
  final int? actorUserId;
  final String? actorAvatarUrl;
  final String? actorAvatarThumbUrl;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final String? createdAt;
}
