class WorkspaceSharedTrip {
  const WorkspaceSharedTrip({
    required this.id,
    required this.name,
    required this.status,
    this.imageUrl,
    this.imageThumbUrl,
    required this.membersCount,
    this.createdAt,
    this.endedAt,
    this.archivedAt,
  });

  final int id;
  final String name;
  final String status;
  final String? imageUrl;
  final String? imageThumbUrl;
  final int membersCount;
  final String? createdAt;
  final String? endedAt;
  final String? archivedAt;

  bool get isActive => status == 'active';
  bool get isSettling => status == 'settling';
  bool get isArchived => status == 'archived';
}
