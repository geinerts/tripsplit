class NotificationPreferences {
  const NotificationPreferences({
    required this.inAppBannerEnabled,
    required this.pushExpenseAddedEnabled,
    required this.pushFriendInvitesEnabled,
    required this.pushTripUpdatesEnabled,
    required this.pushSettlementUpdatesEnabled,
  });

  const NotificationPreferences.defaults()
    : inAppBannerEnabled = true,
      pushExpenseAddedEnabled = true,
      pushFriendInvitesEnabled = true,
      pushTripUpdatesEnabled = true,
      pushSettlementUpdatesEnabled = true;

  final bool inAppBannerEnabled;
  final bool pushExpenseAddedEnabled;
  final bool pushFriendInvitesEnabled;
  final bool pushTripUpdatesEnabled;
  final bool pushSettlementUpdatesEnabled;

  NotificationPreferences copyWith({
    bool? inAppBannerEnabled,
    bool? pushExpenseAddedEnabled,
    bool? pushFriendInvitesEnabled,
    bool? pushTripUpdatesEnabled,
    bool? pushSettlementUpdatesEnabled,
  }) {
    return NotificationPreferences(
      inAppBannerEnabled: inAppBannerEnabled ?? this.inAppBannerEnabled,
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
