class Trip {
  const Trip({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.status,
    required this.imageUrl,
    this.imageThumbUrl,
    required this.membersCount,
    required this.createdAt,
    required this.createdBy,
    required this.dateFrom,
    required this.dateTo,
    required this.endedAt,
    required this.archivedAt,
    required this.settlementsTotal,
    required this.settlementsConfirmed,
    required this.settlementsPending,
    required this.allSettled,
    required this.readyToSettle,
    required this.totalAmountCents,
    required this.myPaidCents,
    this.myPaidPreferredCents,
    this.preferredCurrencyCode,
    required this.myOwedCents,
    required this.myBalanceCents,
  });

  final int id;
  final String name;
  final String currencyCode;
  final String status;
  final String? imageUrl;
  final String? imageThumbUrl;
  final int membersCount;
  final String? createdAt;
  final int? createdBy;
  final String? dateFrom;
  final String? dateTo;
  final String? endedAt;
  final String? archivedAt;
  final int settlementsTotal;
  final int settlementsConfirmed;
  final int settlementsPending;
  final bool allSettled;
  final bool readyToSettle;
  final int totalAmountCents;
  final int myPaidCents;
  final int? myPaidPreferredCents;
  final String? preferredCurrencyCode;
  final int myOwedCents;
  final int myBalanceCents;

  bool get isActive => status == 'active';
  bool get isSettling => status == 'settling';
  bool get isArchived => status == 'archived';
}
