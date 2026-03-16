class Trip {
  const Trip({
    required this.id,
    required this.name,
    required this.status,
    required this.imageUrl,
    this.imageThumbUrl,
    required this.membersCount,
    required this.createdAt,
    required this.createdBy,
    required this.endedAt,
    required this.archivedAt,
    required this.settlementsTotal,
    required this.settlementsConfirmed,
    required this.allSettled,
    required this.totalAmountCents,
    required this.myPaidCents,
    required this.myOwedCents,
    required this.myBalanceCents,
  });

  final int id;
  final String name;
  final String status;
  final String? imageUrl;
  final String? imageThumbUrl;
  final int membersCount;
  final String? createdAt;
  final int? createdBy;
  final String? endedAt;
  final String? archivedAt;
  final int settlementsTotal;
  final int settlementsConfirmed;
  final bool allSettled;
  final int totalAmountCents;
  final int myPaidCents;
  final int myOwedCents;
  final int myBalanceCents;

  bool get isActive => status == 'active';
  bool get isSettling => status == 'settling';
  bool get isArchived => status == 'archived';
}
