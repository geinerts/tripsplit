import '../entities/auth_user.dart';
import '../entities/notification_preferences.dart';

abstract class AuthRepository {
  Future<AuthUser> loginWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> loginWithSocial({
    required String provider,
    required String idToken,
    String? fullName,
    String? email,
  });

  Future<AuthUser> registerWithCredentials({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  Future<AuthUser> setCredentials({
    required String email,
    required String password,
  });

  Future<AuthUser> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? preferredCurrencyCode,
    Map<String, String?>? paymentDetails,
  });

  Future<AuthUser> getMe();

  Future<void> requestPasswordReset({required String email});

  Future<void> requestEmailVerificationLink({required String email});

  Future<void> requestReactivationLink({required String email});

  Future<void> requestEmailChange({
    required String newEmail,
    required String currentPassword,
  });

  Future<void> deactivateAccount({required String password});

  Future<void> requestAccountDeletionLink({required String password});

  Future<NotificationPreferences> getNotificationPreferences();

  Future<NotificationPreferences> updateNotificationPreferences({
    bool? inAppBannerEnabled,
    bool? pushExpenseAddedEnabled,
    bool? pushFriendInvitesEnabled,
    bool? pushTripUpdatesEnabled,
    bool? pushSettlementUpdatesEnabled,
  });
}
