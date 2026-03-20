import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.name,
    required super.status,
    required super.imageUrl,
    super.imageThumbUrl,
    required super.membersCount,
    required super.createdAt,
    required super.createdBy,
    required super.endedAt,
    required super.archivedAt,
    required super.settlementsTotal,
    required super.settlementsConfirmed,
    required super.settlementsPending,
    required super.allSettled,
    required super.readyToSettle,
    required super.totalAmountCents,
    required super.myPaidCents,
    required super.myOwedCents,
    required super.myBalanceCents,
  });

  factory TripModel.fromLegacyMap(Map<String, dynamic> map) {
    final rawStatus = (map['status'] as String? ?? '').trim().toLowerCase();
    final status = (rawStatus == 'settling' || rawStatus == 'archived')
        ? rawStatus
        : 'active';
    final rawImageUrl = map['image_url'];
    final imageUrl = rawImageUrl is String && rawImageUrl.trim().isNotEmpty
        ? rawImageUrl.trim()
        : null;
    final rawImageThumbUrl = map['image_thumb_url'];
    final imageThumbUrl =
        rawImageThumbUrl is String && rawImageThumbUrl.trim().isNotEmpty
        ? rawImageThumbUrl.trim()
        : null;
    final settlementsTotal = (map['settlements_total'] as num?)?.toInt() ?? 0;
    final settlementsConfirmed =
        (map['settlements_confirmed'] as num?)?.toInt() ?? 0;
    final settlementsPendingRaw =
        (map['settlements_pending'] as num?)?.toInt() ??
        (settlementsTotal - settlementsConfirmed);
    final settlementsPending = settlementsPendingRaw < 0
        ? 0
        : settlementsPendingRaw;
    final allSettled =
        map['all_settled'] == true ||
        (status == 'archived' && settlementsTotal <= settlementsConfirmed);
    final readyToSettle =
        map['ready_to_settle'] == true ||
        (status == 'settling' && settlementsPending > 0);

    return TripModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      status: status,
      imageUrl: imageUrl,
      imageThumbUrl: imageThumbUrl,
      membersCount: (map['members_count'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] as String?,
      createdBy: (map['created_by'] as num?)?.toInt(),
      endedAt: map['ended_at'] as String?,
      archivedAt: map['archived_at'] as String?,
      settlementsTotal: settlementsTotal,
      settlementsConfirmed: settlementsConfirmed,
      settlementsPending: settlementsPending,
      allSettled: allSettled,
      readyToSettle: readyToSettle,
      totalAmountCents: (map['total_amount_cents'] as num?)?.toInt() ?? 0,
      myPaidCents: (map['my_paid_cents'] as num?)?.toInt() ?? 0,
      myOwedCents: (map['my_owed_cents'] as num?)?.toInt() ?? 0,
      myBalanceCents: (map['my_balance_cents'] as num?)?.toInt() ?? 0,
    );
  }
}
