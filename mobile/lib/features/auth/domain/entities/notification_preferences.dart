class NotificationPreferences {
  const NotificationPreferences({
    required this.inAppBannerEnabled,
    required this.inAppExpenseAddedEnabled,
    required this.inAppFriendInvitesEnabled,
    required this.inAppFriendInviteReceivedEnabled,
    required this.inAppFriendInviteAcceptedEnabled,
    required this.inAppTripUpdatesEnabled,
    required this.inAppTripAddedEnabled,
    required this.inAppTripMemberAddedEnabled,
    required this.inAppTripFinishedEnabled,
    required this.inAppMemberReadyToSettleEnabled,
    required this.inAppTripReadyToSettleEnabled,
    required this.inAppSettlementUpdatesEnabled,
    required this.inAppSettlementReminderEnabled,
    required this.inAppSettlementAutoReminderEnabled,
    required this.inAppSettlementSentEnabled,
    required this.inAppSettlementConfirmedEnabled,
    required this.pushExpenseAddedEnabled,
    required this.pushFriendInvitesEnabled,
    required this.pushTripUpdatesEnabled,
    required this.pushSettlementUpdatesEnabled,
  });

  const NotificationPreferences.defaults()
    : inAppBannerEnabled = true,
      inAppExpenseAddedEnabled = true,
      inAppFriendInvitesEnabled = true,
      inAppFriendInviteReceivedEnabled = true,
      inAppFriendInviteAcceptedEnabled = true,
      inAppTripUpdatesEnabled = true,
      inAppTripAddedEnabled = true,
      inAppTripMemberAddedEnabled = true,
      inAppTripFinishedEnabled = true,
      inAppMemberReadyToSettleEnabled = true,
      inAppTripReadyToSettleEnabled = true,
      inAppSettlementUpdatesEnabled = true,
      inAppSettlementReminderEnabled = true,
      inAppSettlementAutoReminderEnabled = true,
      inAppSettlementSentEnabled = true,
      inAppSettlementConfirmedEnabled = true,
      pushExpenseAddedEnabled = true,
      pushFriendInvitesEnabled = true,
      pushTripUpdatesEnabled = true,
      pushSettlementUpdatesEnabled = true;

  final bool inAppBannerEnabled;
  final bool inAppExpenseAddedEnabled;
  final bool inAppFriendInvitesEnabled;
  final bool inAppFriendInviteReceivedEnabled;
  final bool inAppFriendInviteAcceptedEnabled;
  final bool inAppTripUpdatesEnabled;
  final bool inAppTripAddedEnabled;
  final bool inAppTripMemberAddedEnabled;
  final bool inAppTripFinishedEnabled;
  final bool inAppMemberReadyToSettleEnabled;
  final bool inAppTripReadyToSettleEnabled;
  final bool inAppSettlementUpdatesEnabled;
  final bool inAppSettlementReminderEnabled;
  final bool inAppSettlementAutoReminderEnabled;
  final bool inAppSettlementSentEnabled;
  final bool inAppSettlementConfirmedEnabled;
  final bool pushExpenseAddedEnabled;
  final bool pushFriendInvitesEnabled;
  final bool pushTripUpdatesEnabled;
  final bool pushSettlementUpdatesEnabled;

  NotificationPreferences copyWith({
    bool? inAppBannerEnabled,
    bool? inAppExpenseAddedEnabled,
    bool? inAppFriendInvitesEnabled,
    bool? inAppFriendInviteReceivedEnabled,
    bool? inAppFriendInviteAcceptedEnabled,
    bool? inAppTripUpdatesEnabled,
    bool? inAppTripAddedEnabled,
    bool? inAppTripMemberAddedEnabled,
    bool? inAppTripFinishedEnabled,
    bool? inAppMemberReadyToSettleEnabled,
    bool? inAppTripReadyToSettleEnabled,
    bool? inAppSettlementUpdatesEnabled,
    bool? inAppSettlementReminderEnabled,
    bool? inAppSettlementAutoReminderEnabled,
    bool? inAppSettlementSentEnabled,
    bool? inAppSettlementConfirmedEnabled,
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
      inAppFriendInviteReceivedEnabled:
          inAppFriendInviteReceivedEnabled ??
          this.inAppFriendInviteReceivedEnabled,
      inAppFriendInviteAcceptedEnabled:
          inAppFriendInviteAcceptedEnabled ??
          this.inAppFriendInviteAcceptedEnabled,
      inAppTripUpdatesEnabled:
          inAppTripUpdatesEnabled ?? this.inAppTripUpdatesEnabled,
      inAppTripAddedEnabled:
          inAppTripAddedEnabled ?? this.inAppTripAddedEnabled,
      inAppTripMemberAddedEnabled:
          inAppTripMemberAddedEnabled ?? this.inAppTripMemberAddedEnabled,
      inAppTripFinishedEnabled:
          inAppTripFinishedEnabled ?? this.inAppTripFinishedEnabled,
      inAppMemberReadyToSettleEnabled:
          inAppMemberReadyToSettleEnabled ??
          this.inAppMemberReadyToSettleEnabled,
      inAppTripReadyToSettleEnabled:
          inAppTripReadyToSettleEnabled ?? this.inAppTripReadyToSettleEnabled,
      inAppSettlementUpdatesEnabled:
          inAppSettlementUpdatesEnabled ?? this.inAppSettlementUpdatesEnabled,
      inAppSettlementReminderEnabled:
          inAppSettlementReminderEnabled ?? this.inAppSettlementReminderEnabled,
      inAppSettlementAutoReminderEnabled:
          inAppSettlementAutoReminderEnabled ??
          this.inAppSettlementAutoReminderEnabled,
      inAppSettlementSentEnabled:
          inAppSettlementSentEnabled ?? this.inAppSettlementSentEnabled,
      inAppSettlementConfirmedEnabled:
          inAppSettlementConfirmedEnabled ??
          this.inAppSettlementConfirmedEnabled,
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
