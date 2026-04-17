import '../entities/notification_preferences.dart';
import '../repositories/auth_repository.dart';

class UpdateNotificationPreferencesUseCase {
  UpdateNotificationPreferencesUseCase(this._repository);

  final AuthRepository _repository;

  Future<NotificationPreferences> call({
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
    return _repository.updateNotificationPreferences(
      inAppBannerEnabled: inAppBannerEnabled,
      inAppExpenseAddedEnabled: inAppExpenseAddedEnabled,
      inAppFriendInvitesEnabled: inAppFriendInvitesEnabled,
      inAppTripUpdatesEnabled: inAppTripUpdatesEnabled,
      inAppSettlementUpdatesEnabled: inAppSettlementUpdatesEnabled,
      pushExpenseAddedEnabled: pushExpenseAddedEnabled,
      pushFriendInvitesEnabled: pushFriendInvitesEnabled,
      pushTripUpdatesEnabled: pushTripUpdatesEnabled,
      pushSettlementUpdatesEnabled: pushSettlementUpdatesEnabled,
    );
  }
}
