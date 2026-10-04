/// A server-supplied draft for future billing. Never authorizes paid features.
class SubscriptionPreview {
  const SubscriptionPreview._({
    required this.accountId,
    required this.catalogVersion,
    required this.freeLimits,
    required this.proLimits,
  });

  final int accountId;
  final String catalogVersion;
  final SubscriptionPlanLimits freeLimits;
  final SubscriptionPlanLimits proLimits;

  static SubscriptionPreview? fromMap(Object? value, {required int accountId}) {
    if (value is! Map<String, dynamic> ||
        accountId <= 0 ||
        value['account_id'] is! int ||
        value['account_id'] != accountId ||
        value['schema_version'] != 1 ||
        value['mode'] != 'preview' ||
        value['plan'] != 'free' ||
        value['billing_enabled'] != false ||
        value['limits_enforced'] != false) {
      return null;
    }
    final version = value['catalog_version'];
    final plans = value['proposed_plans'];
    final effective = SubscriptionPlanLimits.fromMap(value['effective_limits']);
    if (version is! String ||
        version.trim().isEmpty ||
        plans is! Map<String, dynamic> ||
        effective == null ||
        effective.activeOwnedTrips != null ||
        effective.currenciesPerTrip != null) {
      return null;
    }
    final free = SubscriptionPlanLimits.fromMap(plans['free']);
    final pro = SubscriptionPlanLimits.fromMap(plans['pro']);
    if (free == null || pro == null) return null;
    return SubscriptionPreview._(
      accountId: accountId,
      catalogVersion: version,
      freeLimits: free,
      proLimits: pro,
    );
  }
}

class SubscriptionPlanLimits {
  const SubscriptionPlanLimits._({
    required this.activeOwnedTrips,
    required this.currenciesPerTrip,
  });

  /// Null explicitly means no commercial count limit, not missing data.
  final int? activeOwnedTrips;
  final int? currenciesPerTrip;

  static SubscriptionPlanLimits? fromMap(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    for (final key in ['active_owned_trips', 'currencies_per_trip']) {
      if (!value.containsKey(key)) return null;
      final limit = value[key];
      if (limit != null && (limit is! int || limit <= 0)) return null;
    }
    return SubscriptionPlanLimits._(
      activeOwnedTrips: value['active_owned_trips'] as int?,
      currenciesPerTrip: value['currencies_per_trip'] as int?,
    );
  }
}
