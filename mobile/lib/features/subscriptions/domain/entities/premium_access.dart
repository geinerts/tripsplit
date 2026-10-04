/// Display-only server projection. Never persisted or used to authorize actions.
class PremiumAccess {
  PremiumAccess._(this.plan, this.expiresAt, this._validFor)
    : _age = Stopwatch()..start();

  final String plan;
  final DateTime? expiresAt;
  final Duration _validFor;
  final Stopwatch _age;

  bool get isFresh => _age.elapsed < _validFor;
  bool get isPremium => isFresh && plan == 'premium';
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

  static PremiumAccess? fromMap(dynamic raw, {required int accountId}) {
    if (raw is! Map ||
        accountId <= 0 ||
        raw['account_id'] is! int ||
        raw['schema_version'] is! int ||
        raw['account_id'] != accountId ||
        raw['schema_version'] != 1 ||
        raw['billing_enabled'] != false ||
        raw['limits_enforced'] != false) {
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
    DateTime? end;
    var validFor = Duration(seconds: seconds);
    if (plan == 'premium') {
      final expires = raw['expires_at'];
      if (raw['source'] != 'admin_grant' ||
          expires is! String ||
          !expires.endsWith('Z')) {
        return null;
      }
      end = _utcDate(expires);
      if (end == null || !end.isAfter(serverTime)) return null;
      final remaining = end.difference(serverTime);
      if (remaining < validFor) validFor = remaining;
    } else if (raw['source'] != null || raw['expires_at'] != null) {
      return null;
    }
    return PremiumAccess._(plan, end, validFor);
  }
}
