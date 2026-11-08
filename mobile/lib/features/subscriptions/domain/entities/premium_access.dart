/// Feature names from the server's Premium feature list.
abstract final class PremiumFeatures {
  static const tripExport = 'trip_export';
  static const yearSummary = 'year_summary';
}

/// Display-only server projection. Never persisted or used to authorize actions.
///
/// Parsing tolerates values that later servers may send, such as new sources or
/// billing being enabled, so builds released now keep working.
class PremiumAccess {
  PremiumAccess._({
    required this.plan,
    required this.source,
    required this.expiresAt,
    required this.billingEnabled,
    required Map<String, bool>? features,
    required Duration validFor,
  }) : _features = features,
       _validFor = validFor,
       _age = Stopwatch()..start();

  static final _sourcePattern = RegExp(r'^[a-z][a-z0-9_]{0,39}$');

  final String plan;

  /// Where Premium comes from, such as `admin_grant` or `launch`. Null unless
  /// the plan is Premium.
  final String? source;

  /// Null for Premium without an end date.
  final DateTime? expiresAt;
  final bool billingEnabled;
  final Map<String, bool>? _features;
  final Duration _validFor;
  final Stopwatch _age;

  bool get isFresh => _age.elapsed < _validFor;
  bool get isPremium => isFresh && plan == 'premium';

  bool get _notExpired =>
      expiresAt == null || DateTime.now().toUtc().isBefore(expiresAt!);

  /// Whether to show Premium features. It stays true once the 5-minute display
  /// freshness passes, since the server checks access on every request.
  bool get offersPremiumFeatures => plan == 'premium' && _notExpired;

  /// Whether to offer [feature]. Uses the server's feature list when it sends
  /// one, so a feature made free on the server shows without an app update.
  bool allows(String feature) {
    final features = _features;
    if (features == null) return offersPremiumFeatures;
    if (features[feature] != true) return false;
    return plan != 'premium' || _notExpired;
  }

  /// The profile shows the plan only when buying is possible or the account
  /// has its own Premium. Premium for everyone (`launch`) shows nothing.
  bool get showsPlanStatus =>
      billingEnabled || (plan == 'premium' && source != 'launch');

  Duration get remainingFreshness {
    final remaining = _validFor - _age.elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static DateTime? _utcDate(dynamic value) {
    if (value is! String || value.length != 20 || !value.endsWith('Z')) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    return parsed?.toIso8601String() == value.replaceFirst('Z', '.000Z')
        ? parsed
        : null;
  }

  static Map<String, bool>? _parseFeatures(dynamic raw) {
    if (raw is! Map) return null;
    final features = <String, bool>{};
    raw.forEach((key, value) {
      if (key is String && value is bool) features[key] = value;
    });
    return features;
  }

  static PremiumAccess? fromMap(dynamic raw, {required int accountId}) {
    if (raw is! Map ||
        accountId <= 0 ||
        raw['account_id'] is! int ||
        raw['schema_version'] is! int ||
        raw['account_id'] != accountId ||
        (raw['schema_version'] as int) < 1 ||
        raw['billing_enabled'] is! bool ||
        raw['limits_enforced'] is! bool) {
      return null;
    }
    final plan = raw['plan'];
    if (plan != 'free' && plan != 'premium' && plan != 'unknown') return null;
    final checked = raw['checked_at'];
    final seconds = raw['refresh_after_seconds'];
    if (checked is! String ||
        !checked.endsWith('Z') ||
        seconds is! int ||
        seconds <= 0 ||
        seconds > 300) {
      return null;
    }
    final serverTime = _utcDate(checked);
    if (serverTime == null) return null;
    String? source;
    DateTime? end;
    var validFor = Duration(seconds: seconds);
    if (plan == 'premium') {
      final rawSource = raw['source'];
      if (rawSource is! String || !_sourcePattern.hasMatch(rawSource)) {
        return null;
      }
      source = rawSource;
      final expires = raw['expires_at'];
      if (expires != null) {
        end = _utcDate(expires);
        if (end == null || !end.isAfter(serverTime)) return null;
        final remaining = end.difference(serverTime);
        if (remaining < validFor) validFor = remaining;
      }
    }
    return PremiumAccess._(
      plan: plan as String,
      source: source,
      expiresAt: end,
      billingEnabled: raw['billing_enabled'] as bool,
      features: _parseFeatures(raw['features']),
      validFor: validFor,
    );
  }
}
