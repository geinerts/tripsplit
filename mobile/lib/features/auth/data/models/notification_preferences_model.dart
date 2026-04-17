import '../../domain/entities/notification_preferences.dart';

class NotificationPreferencesModel extends NotificationPreferences {
  const NotificationPreferencesModel({
    required super.inAppBannerEnabled,
    required super.inAppExpenseAddedEnabled,
    required super.inAppFriendInvitesEnabled,
    required super.inAppTripUpdatesEnabled,
    required super.inAppSettlementUpdatesEnabled,
    required super.pushExpenseAddedEnabled,
    required super.pushFriendInvitesEnabled,
    required super.pushTripUpdatesEnabled,
    required super.pushSettlementUpdatesEnabled,
  });

  factory NotificationPreferencesModel.fromApiMap(Map<String, dynamic> map) {
    final prefsRaw = map['preferences'];
    final payload = prefsRaw is Map<String, dynamic> ? prefsRaw : map;
    final inAppRaw = payload['in_app'];
    final inApp = inAppRaw is Map<String, dynamic>
        ? inAppRaw
        : <String, dynamic>{};
    final pushRaw = payload['push'];
    final push = pushRaw is Map<String, dynamic>
        ? pushRaw
        : <String, dynamic>{};
    final inAppBannerEnabled =
        _readBool(payload['in_app_banner_enabled']) ??
        _readBool(map['in_app_banner_enabled']) ??
        true;

    return NotificationPreferencesModel(
      inAppBannerEnabled: inAppBannerEnabled,
      inAppExpenseAddedEnabled:
          _readBool(inApp['expense_added']) ??
          _readBool(payload['in_app_expense_added_enabled']) ??
          inAppBannerEnabled,
      inAppFriendInvitesEnabled:
          _readBool(inApp['friend_invites']) ??
          _readBool(payload['in_app_friend_invites_enabled']) ??
          inAppBannerEnabled,
      inAppTripUpdatesEnabled:
          _readBool(inApp['trip_updates']) ??
          _readBool(payload['in_app_trip_updates_enabled']) ??
          inAppBannerEnabled,
      inAppSettlementUpdatesEnabled:
          _readBool(inApp['settlement_updates']) ??
          _readBool(payload['in_app_settlement_updates_enabled']) ??
          inAppBannerEnabled,
      pushExpenseAddedEnabled:
          _readBool(push['expense_added']) ??
          _readBool(payload['push_expense_added_enabled']) ??
          true,
      pushFriendInvitesEnabled:
          _readBool(push['friend_invites']) ??
          _readBool(payload['push_friend_invites_enabled']) ??
          true,
      pushTripUpdatesEnabled:
          _readBool(push['trip_updates']) ??
          _readBool(payload['push_trip_updates_enabled']) ??
          true,
      pushSettlementUpdatesEnabled:
          _readBool(push['settlement_updates']) ??
          _readBool(payload['push_settlement_updates_enabled']) ??
          true,
    );
  }

  static bool? _readBool(Object? raw) {
    if (raw is bool) {
      return raw;
    }
    if (raw is num) {
      if (raw == 0) return false;
      if (raw == 1) return true;
      return null;
    }
    if (raw is String) {
      final value = raw.trim().toLowerCase();
      if (value == '1' || value == 'true' || value == 'yes' || value == 'on') {
        return true;
      }
      if (value == '0' || value == 'false' || value == 'no' || value == 'off') {
        return false;
      }
    }
    return null;
  }
}
