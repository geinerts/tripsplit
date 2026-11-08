import '../../domain/entities/trip.dart';
import '../../../../core/network/media_url_resolver.dart';
import '../../../../core/currency/app_currency.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.name,
    super.budgetCents,
    super.destinations,
    super.tripMode,
    required super.currencyCode,
    required super.status,
    required super.imageUrl,
    super.imageThumbUrl,
    required super.membersCount,
    super.membersPreview,
    required super.createdAt,
    required super.createdBy,
    required super.currentUserRole,
    required super.dateFrom,
    required super.dateTo,
    required super.endedAt,
    required super.archivedAt,
    required super.settlementsTotal,
    required super.settlementsConfirmed,
    required super.settlementsPending,
    required super.allSettled,
    required super.readyToSettle,
    required super.totalAmountCents,
    required super.myPaidCents,
    super.myPaidPreferredCents,
    super.preferredCurrencyCode,
    required super.myOwedCents,
    required super.myBalanceCents,
    super.premiumFeatures,
  });

  factory TripModel.fromLegacyMap(Map<String, dynamic> map) {
    final rawStatus = (map['status'] as String? ?? '').trim().toLowerCase();
    final status = (rawStatus == 'settling' || rawStatus == 'archived')
        ? rawStatus
        : 'active';
    final rawImageUrl = map['image_url'];
    final imageUrl = rawImageUrl is String && rawImageUrl.trim().isNotEmpty
        ? MediaUrlResolver.normalize(rawImageUrl.trim())
        : null;
    final rawImageThumbUrl = map['image_thumb_url'];
    final imageThumbUrl =
        rawImageThumbUrl is String && rawImageThumbUrl.trim().isNotEmpty
        ? MediaUrlResolver.normalize(rawImageThumbUrl.trim())
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
    final currentUserRole = _normalizeTripRole(map['current_user_role']);

    return TripModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      budgetCents: (map['budget_cents'] as num?)?.toInt(),
      destinations: (map['destinations'] as List? ?? [])
          .map((d) => Map<String, dynamic>.from(d as Map))
          .toList(),
      tripMode: map['trip_mode'] == 'solo' ? 'solo' : 'group',
      currencyCode: AppCurrencyCatalog.normalize(
        map['currency_code'] as String?,
      ),
      status: status,
      imageUrl: imageUrl,
      imageThumbUrl: imageThumbUrl,
      membersCount: (map['members_count'] as num?)?.toInt() ?? 0,
      membersPreview: _parseMembersPreview(map['members_preview']),
      createdAt: map['created_at'] as String?,
      createdBy: (map['created_by'] as num?)?.toInt(),
      currentUserRole: currentUserRole,
      dateFrom: (map['date_from'] as String?)?.trim().isNotEmpty == true
          ? (map['date_from'] as String).trim()
          : null,
      dateTo: (map['date_to'] as String?)?.trim().isNotEmpty == true
          ? (map['date_to'] as String).trim()
          : null,
      endedAt: map['ended_at'] as String?,
      archivedAt: map['archived_at'] as String?,
      settlementsTotal: settlementsTotal,
      settlementsConfirmed: settlementsConfirmed,
      settlementsPending: settlementsPending,
      allSettled: allSettled,
      readyToSettle: readyToSettle,
      totalAmountCents: (map['total_amount_cents'] as num?)?.toInt() ?? 0,
      myPaidCents: (map['my_paid_cents'] as num?)?.toInt() ?? 0,
      myPaidPreferredCents: (map['my_paid_preferred_cents'] as num?)?.toInt(),
      preferredCurrencyCode:
          (map['preferred_currency_code'] as String?)?.trim().isNotEmpty == true
          ? AppCurrencyCatalog.normalizeProfilePreferred(
              (map['preferred_currency_code'] as String?)?.trim(),
            )
          : null,
      myOwedCents: (map['my_owed_cents'] as num?)?.toInt() ?? 0,
      myBalanceCents: (map['my_balance_cents'] as num?)?.toInt() ?? 0,
      premiumFeatures: _parsePremiumFeatures(map['premium_features']),
    );
  }

  static String _normalizeTripRole(Object? value) {
    final role = (value?.toString() ?? '').trim().toLowerCase();
    if (role == 'owner' || role == 'admin') {
      return role;
    }
    return 'member';
  }
}

Map<String, bool>? _parsePremiumFeatures(dynamic raw) {
  if (raw is! Map) return null;
  final features = <String, bool>{};
  raw.forEach((key, value) {
    if (key is String && value is bool) features[key] = value;
  });
  return Map.unmodifiable(features);
}

List<TripMemberPreview> _parseMembersPreview(dynamic raw) {
  if (raw is! List) return const [];
  String? url(Object? value) => value is String && value.trim().isNotEmpty
      ? MediaUrlResolver.normalize(value.trim())
      : null;
  final members = <TripMemberPreview>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final id = (item['id'] as num?)?.toInt() ?? 0;
    if (id <= 0) continue;
    final name = item['display_name'];
    members.add(
      TripMemberPreview(
        id: id,
        displayName: name is String ? name.trim() : '',
        avatarUrl: url(item['avatar_url']),
        avatarThumbUrl: url(item['avatar_thumb_url']),
      ),
    );
    if (members.length == 3) break;
  }
  return List.unmodifiable(members);
}
