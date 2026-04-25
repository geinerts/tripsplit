class WorkspaceActivityEvent {
  const WorkspaceActivityEvent({
    required this.id,
    required this.tripId,
    required this.actorUserId,
    required this.actorName,
    this.actorAvatarUrl,
    this.actorAvatarThumbUrl,
    required this.eventType,
    this.entityType,
    this.entityId,
    this.payload = const <String, dynamic>{},
    this.createdAt,
  });

  final int id;
  final int tripId;
  final int? actorUserId;
  final String actorName;
  final String? actorAvatarUrl;
  final String? actorAvatarThumbUrl;
  final String eventType;
  final String? entityType;
  final int? entityId;
  final Map<String, dynamic> payload;
  final String? createdAt;
}

class WorkspaceActivityPage {
  const WorkspaceActivityPage({
    required this.items,
    required this.hasMore,
    this.nextOffset,
  });

  final List<WorkspaceActivityEvent> items;
  final bool hasMore;
  final int? nextOffset;
}
