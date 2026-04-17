import '../../domain/entities/notification_preferences.dart';

class NotificationPreferencesModel extends NotificationPreferences {
  const NotificationPreferencesModel({
    required super.inAppBannerEnabled,
    required super.inAppExpenseAddedEnabled,
    required super.inAppFriendInvitesEnabled,
    required super.inAppFriendInviteReceivedEnabled,
    required super.inAppFriendInviteAcceptedEnabled,
    required super.inAppTripUpdatesEnabled,
    required super.inAppTripAddedEnabled,
    required super.inAppTripMemberAddedEnabled,
    required super.inAppTripFinishedEnabled,
    required super.inAppMemberReadyToSettleEnabled,
    required super.inAppTripReadyToSettleEnabled,
    required super.inAppSettlementUpdatesEnabled,
    required super.inAppSettlementReminderEnabled,
    required super.inAppSettlementAutoReminderEnabled,
    required super.inAppSettlementSentEnabled,
    required super.inAppSettlementConfirmedEnabled,
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
    final inAppExpenseAddedEnabled =
        _readBool(inApp['expense_added']) ??
        _readBool(payload['in_app_expense_added_enabled']) ??
        inAppBannerEnabled;
    final inAppFriendInviteReceivedEnabled =
        _readBool(inApp['friend_invite_received']) ??
        _readBool(inApp['friend_invite']) ??
        _readBool(payload['in_app_friend_invite_received_enabled']) ??
        _readBool(payload['in_app_friend_invites_enabled']) ??
        inAppBannerEnabled;
    final inAppFriendInviteAcceptedEnabled =
        _readBool(inApp['friend_invite_accepted']) ??
        _readBool(payload['in_app_friend_invite_accepted_enabled']) ??
        _readBool(payload['in_app_friend_invites_enabled']) ??
        inAppBannerEnabled;
    final inAppTripAddedEnabled =
        _readBool(inApp['trip_added']) ??
        _readBool(payload['in_app_trip_added_enabled']) ??
        _readBool(payload['in_app_trip_updates_enabled']) ??
        inAppBannerEnabled;
    final inAppTripMemberAddedEnabled =
        _readBool(inApp['trip_member_added']) ??
        _readBool(payload['in_app_trip_member_added_enabled']) ??
        _readBool(payload['in_app_trip_updates_enabled']) ??
        inAppBannerEnabled;
    final inAppTripFinishedEnabled =
        _readBool(inApp['trip_finished']) ??
        _readBool(payload['in_app_trip_finished_enabled']) ??
        _readBool(payload['in_app_trip_updates_enabled']) ??
        inAppBannerEnabled;
    final inAppMemberReadyToSettleEnabled =
        _readBool(inApp['member_ready_to_settle']) ??
        _readBool(payload['in_app_member_ready_to_settle_enabled']) ??
        _readBool(payload['in_app_trip_updates_enabled']) ??
        inAppBannerEnabled;
    final inAppTripReadyToSettleEnabled =
        _readBool(inApp['trip_ready_to_settle']) ??
        _readBool(payload['in_app_trip_ready_to_settle_enabled']) ??
        _readBool(payload['in_app_trip_updates_enabled']) ??
        inAppBannerEnabled;
    final inAppSettlementReminderEnabled =
        _readBool(inApp['settlement_reminder']) ??
        _readBool(payload['in_app_settlement_reminder_enabled']) ??
        _readBool(payload['in_app_settlement_updates_enabled']) ??
        inAppBannerEnabled;
    final inAppSettlementAutoReminderEnabled =
        _readBool(inApp['settlement_auto_reminder']) ??
        _readBool(payload['in_app_settlement_auto_reminder_enabled']) ??
        _readBool(payload['in_app_settlement_updates_enabled']) ??
        inAppBannerEnabled;
    final inAppSettlementSentEnabled =
        _readBool(inApp['settlement_sent']) ??
        _readBool(payload['in_app_settlement_sent_enabled']) ??
        _readBool(payload['in_app_settlement_updates_enabled']) ??
        inAppBannerEnabled;
    final inAppSettlementConfirmedEnabled =
        _readBool(inApp['settlement_confirmed']) ??
        _readBool(payload['in_app_settlement_confirmed_enabled']) ??
        _readBool(payload['in_app_settlement_updates_enabled']) ??
        inAppBannerEnabled;
    final inAppFriendInvitesEnabled =
        _readBool(inApp['friend_invites']) ??
        _readBool(payload['in_app_friend_invites_enabled']) ??
        (inAppFriendInviteReceivedEnabled || inAppFriendInviteAcceptedEnabled);
    final inAppTripUpdatesEnabled =
        _readBool(inApp['trip_updates']) ??
        _readBool(payload['in_app_trip_updates_enabled']) ??
        (inAppTripAddedEnabled ||
            inAppTripMemberAddedEnabled ||
            inAppTripFinishedEnabled ||
            inAppMemberReadyToSettleEnabled ||
            inAppTripReadyToSettleEnabled);
    final inAppSettlementUpdatesEnabled =
        _readBool(inApp['settlement_updates']) ??
        _readBool(payload['in_app_settlement_updates_enabled']) ??
        (inAppSettlementReminderEnabled ||
            inAppSettlementAutoReminderEnabled ||
            inAppSettlementSentEnabled ||
            inAppSettlementConfirmedEnabled);

    return NotificationPreferencesModel(
      inAppBannerEnabled: inAppBannerEnabled,
      inAppExpenseAddedEnabled: inAppExpenseAddedEnabled,
      inAppFriendInvitesEnabled: inAppFriendInvitesEnabled,
      inAppFriendInviteReceivedEnabled: inAppFriendInviteReceivedEnabled,
      inAppFriendInviteAcceptedEnabled: inAppFriendInviteAcceptedEnabled,
      inAppTripUpdatesEnabled: inAppTripUpdatesEnabled,
      inAppTripAddedEnabled: inAppTripAddedEnabled,
      inAppTripMemberAddedEnabled: inAppTripMemberAddedEnabled,
      inAppTripFinishedEnabled: inAppTripFinishedEnabled,
      inAppMemberReadyToSettleEnabled: inAppMemberReadyToSettleEnabled,
      inAppTripReadyToSettleEnabled: inAppTripReadyToSettleEnabled,
      inAppSettlementUpdatesEnabled: inAppSettlementUpdatesEnabled,
      inAppSettlementReminderEnabled: inAppSettlementReminderEnabled,
      inAppSettlementAutoReminderEnabled: inAppSettlementAutoReminderEnabled,
      inAppSettlementSentEnabled: inAppSettlementSentEnabled,
      inAppSettlementConfirmedEnabled: inAppSettlementConfirmedEnabled,
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
