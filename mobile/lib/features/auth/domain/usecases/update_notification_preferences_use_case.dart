import '../entities/notification_preferences.dart';
import '../repositories/auth_repository.dart';

class UpdateNotificationPreferencesUseCase {
  UpdateNotificationPreferencesUseCase(this._repository);

  final AuthRepository _repository;

  Future<NotificationPreferences> call({
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
    return _repository.updateNotificationPreferences(
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
      pushExpenseAddedEnabled: pushExpenseAddedEnabled,
      pushFriendInvitesEnabled: pushFriendInvitesEnabled,
      pushTripUpdatesEnabled: pushTripUpdatesEnabled,
      pushSettlementUpdatesEnabled: pushSettlementUpdatesEnabled,
    );
  }
}
