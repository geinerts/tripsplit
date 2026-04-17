class NotificationPreferences {
  const NotificationPreferences({
    required this.inAppBannerEnabled,
    required this.inAppExpenseAddedEnabled,
    required this.inAppFriendInvitesEnabled,
    required this.inAppTripUpdatesEnabled,
    required this.inAppSettlementUpdatesEnabled,
    required this.pushExpenseAddedEnabled,
    required this.pushFriendInvitesEnabled,
    required this.pushTripUpdatesEnabled,
    required this.pushSettlementUpdatesEnabled,
  });

  const NotificationPreferences.defaults()
    : inAppBannerEnabled = true,
      inAppExpenseAddedEnabled = true,
      inAppFriendInvitesEnabled = true,
      inAppTripUpdatesEnabled = true,
      inAppSettlementUpdatesEnabled = true,
      pushExpenseAddedEnabled = true,
      pushFriendInvitesEnabled = true,
      pushTripUpdatesEnabled = true,
      pushSettlementUpdatesEnabled = true;

  final bool inAppBannerEnabled;
  final bool inAppExpenseAddedEnabled;
  final bool inAppFriendInvitesEnabled;
  final bool inAppTripUpdatesEnabled;
  final bool inAppSettlementUpdatesEnabled;
  final bool pushExpenseAddedEnabled;
  final bool pushFriendInvitesEnabled;
  final bool pushTripUpdatesEnabled;
  final bool pushSettlementUpdatesEnabled;

  NotificationPreferences copyWith({
    bool? inAppBannerEnabled,
    bool? inAppExpenseAddedEnabled,
    bool? inAppFriendInvitesEnabled,
    bool? inAppTripUpdatesEnabled,
    bool? inAppSettlementUpdatesEnabled,
    bool? pushExpenseAddedEnabled,
    bool? pushFriendInvitesEnabled,
    bool? pushTripUpdatesEnabled,
    bool? pushSettlementUpdatesEnabled,
  }) {
    return NotificationPreferences(
      inAppBannerEnabled: inAppBannerEnabled ?? this.inAppBannerEnabled,
      inAppExpenseAddedEnabled:
          inAppExpenseAddedEnabled ?? this.inAppExpenseAddedEnabled,
      inAppFriendInvitesEnabled:
          inAppFriendInvitesEnabled ?? this.inAppFriendInvitesEnabled,
      inAppTripUpdatesEnabled:
          inAppTripUpdatesEnabled ?? this.inAppTripUpdatesEnabled,
      inAppSettlementUpdatesEnabled:
          inAppSettlementUpdatesEnabled ?? this.inAppSettlementUpdatesEnabled,
      pushExpenseAddedEnabled:
          pushExpenseAddedEnabled ?? this.pushExpenseAddedEnabled,
      pushFriendInvitesEnabled:
          pushFriendInvitesEnabled ?? this.pushFriendInvitesEnabled,
      pushTripUpdatesEnabled:
          pushTripUpdatesEnabled ?? this.pushTripUpdatesEnabled,
      pushSettlementUpdatesEnabled:
          pushSettlementUpdatesEnabled ?? this.pushSettlementUpdatesEnabled,
    );
  }
}
