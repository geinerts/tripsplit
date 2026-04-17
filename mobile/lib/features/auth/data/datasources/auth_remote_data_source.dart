import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_method.dart';
import '../../../../core/errors/api_exception.dart';
import '../models/auth_user_model.dart';
import '../models/notification_preferences_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUserModel> loginWithSocial({
    required String provider,
    required String idToken,
    String? fullName,
    String? email,
  });

  Future<AuthUserModel> registerWithCredentials({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  Future<AuthUserModel> setCredentials({
    required String email,
    required String password,
  });

  Future<AuthUserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? preferredCurrencyCode,
    Map<String, String?>? paymentDetails,
  });

  Future<AuthUserModel> getMe();

  Future<void> requestPasswordReset({required String email});

  Future<void> requestEmailVerificationLink({required String email});

  Future<void> requestReactivationLink({required String email});

  Future<void> requestEmailChange({
    required String newEmail,
    required String currentPassword,
  });

  Future<void> deactivateAccount({required String password});

  Future<void> requestAccountDeletionLink({required String password});

  Future<NotificationPreferencesModel> getNotificationPreferences();

  Future<NotificationPreferencesModel> updateNotificationPreferences({
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
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthUserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('login'),
      method: HttpMethod.post,
      body: <String, dynamic>{'email': email, 'password': password},
    );

    final me = response['me'] as Map<String, dynamic>?;
    if (me == null) {
      throw StateError('Missing me payload in login response.');
    }

    return AuthUserModel.fromLegacyMap(me);
  }

  @override
  Future<AuthUserModel> loginWithSocial({
    required String provider,
    required String idToken,
    String? fullName,
    String? email,
  }) async {
    final payload = <String, dynamic>{
      'provider': provider,
      'id_token': idToken,
    };
    final normalizedFullName = (fullName ?? '').trim();
    if (normalizedFullName.isNotEmpty) {
      payload['full_name'] = normalizedFullName;
    }
    final normalizedEmail = (email ?? '').trim().toLowerCase();
    if (normalizedEmail.isNotEmpty) {
      payload['email'] = normalizedEmail;
    }

    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('social_auth'),
      method: HttpMethod.post,
      body: payload,
    );

    final me = response['me'] as Map<String, dynamic>?;
    if (me == null) {
      throw StateError('Missing me payload in social_auth response.');
    }
    return AuthUserModel.fromLegacyMap(me);
  }

  @override
  Future<AuthUserModel> registerWithCredentials({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final proofResponse = await _apiClient.request(
      path: ApiEndpoints.legacyAction('register_proof'),
      method: HttpMethod.get,
    );
    final registerProof =
        (proofResponse['register_proof'] as String?)?.trim() ?? '';
    if (registerProof.isEmpty) {
      throw StateError('Missing register_proof payload.');
    }

    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('register'),
      method: HttpMethod.post,
      body: <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'register_proof': registerProof,
        // Honeypot: must stay empty, backend rejects non-empty.
        'website': '',
      },
    );
    final requiresVerification =
        response['email_verification_required'] == true;
    if (requiresVerification) {
      final backendMessage = (response['message'] as String? ?? '').trim();
      throw ApiException(
        backendMessage.isNotEmpty
            ? backendMessage
            : 'Verification email sent. Please verify your email before logging in.',
        code: 'EMAIL_VERIFICATION_REQUIRED',
      );
    }

    final me = response['me'] as Map<String, dynamic>?;
    if (me == null) {
      throw StateError('Missing me payload in register response.');
    }
    return AuthUserModel.fromLegacyMap(me);
  }

  @override
  Future<AuthUserModel> setCredentials({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('set_credentials'),
      method: HttpMethod.post,
      body: <String, dynamic>{'email': email, 'password': password},
    );

    final me = response['me'] as Map<String, dynamic>?;
    if (me == null) {
      throw StateError('Missing me payload in set_credentials response.');
    }
    return AuthUserModel.fromLegacyMap(me);
  }

  @override
  Future<AuthUserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? preferredCurrencyCode,
    Map<String, String?>? paymentDetails,
  }) async {
    final payload = <String, dynamic>{};
    if (firstName != null && lastName != null) {
      payload['first_name'] = firstName;
      payload['last_name'] = lastName;
    }
    if (email != null && password != null) {
      payload['email'] = email;
      payload['password'] = password;
    }
    if (preferredCurrencyCode != null &&
        preferredCurrencyCode.trim().isNotEmpty) {
      payload['preferred_currency_code'] = preferredCurrencyCode.trim();
    }
    if (paymentDetails != null && paymentDetails.isNotEmpty) {
      for (final entry in paymentDetails.entries) {
        payload[entry.key] = entry.value ?? '';
      }
    }

    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('update_profile'),
      method: HttpMethod.post,
      body: payload,
    );

    final me = response['me'] as Map<String, dynamic>?;
    if (me == null) {
      throw StateError('Missing me payload in update_profile response.');
    }
    return AuthUserModel.fromLegacyMap(me);
  }

  @override
  Future<AuthUserModel> getMe() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('me'),
      method: HttpMethod.get,
    );
    final me = response['me'] as Map<String, dynamic>?;
    if (me == null) {
      throw StateError('Missing me payload in me response.');
    }
    return AuthUserModel.fromLegacyMap(me);
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('forgot_password'),
      method: HttpMethod.post,
      body: <String, dynamic>{'email': email},
    );
  }

  @override
  Future<void> requestEmailVerificationLink({required String email}) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('request_email_verification_link'),
      method: HttpMethod.post,
      body: <String, dynamic>{'email': email},
    );
  }

  @override
  Future<void> requestReactivationLink({required String email}) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('request_reactivation_link'),
      method: HttpMethod.post,
      body: <String, dynamic>{'email': email},
    );
  }

  @override
  Future<void> requestEmailChange({
    required String newEmail,
    required String currentPassword,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('request_email_change'),
      method: HttpMethod.post,
      body: <String, dynamic>{
        'new_email': newEmail,
        'current_password': currentPassword,
      },
    );
  }

  @override
  Future<void> deactivateAccount({required String password}) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('deactivate_account'),
      method: HttpMethod.post,
      body: <String, dynamic>{'password': password},
    );
  }

  @override
  Future<void> requestAccountDeletionLink({required String password}) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('request_account_deletion_link'),
      method: HttpMethod.post,
      body: <String, dynamic>{'password': password},
    );
  }

  @override
  Future<NotificationPreferencesModel> getNotificationPreferences() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('get_notification_preferences'),
      method: HttpMethod.get,
    );
    return NotificationPreferencesModel.fromApiMap(response);
  }

  @override
  Future<NotificationPreferencesModel> updateNotificationPreferences({
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
  }) async {
    final inAppPayload = <String, dynamic>{};
    if (inAppExpenseAddedEnabled != null) {
      inAppPayload['expense_added'] = inAppExpenseAddedEnabled;
    }
    if (inAppFriendInvitesEnabled != null) {
      inAppPayload['friend_invites'] = inAppFriendInvitesEnabled;
    }
    if (inAppFriendInviteReceivedEnabled != null) {
      inAppPayload['friend_invite_received'] = inAppFriendInviteReceivedEnabled;
    }
    if (inAppFriendInviteAcceptedEnabled != null) {
      inAppPayload['friend_invite_accepted'] = inAppFriendInviteAcceptedEnabled;
    }
    if (inAppTripUpdatesEnabled != null) {
      inAppPayload['trip_updates'] = inAppTripUpdatesEnabled;
    }
    if (inAppTripAddedEnabled != null) {
      inAppPayload['trip_added'] = inAppTripAddedEnabled;
    }
    if (inAppTripMemberAddedEnabled != null) {
      inAppPayload['trip_member_added'] = inAppTripMemberAddedEnabled;
    }
    if (inAppTripFinishedEnabled != null) {
      inAppPayload['trip_finished'] = inAppTripFinishedEnabled;
    }
    if (inAppMemberReadyToSettleEnabled != null) {
      inAppPayload['member_ready_to_settle'] = inAppMemberReadyToSettleEnabled;
    }
    if (inAppTripReadyToSettleEnabled != null) {
      inAppPayload['trip_ready_to_settle'] = inAppTripReadyToSettleEnabled;
    }
    if (inAppSettlementUpdatesEnabled != null) {
      inAppPayload['settlement_updates'] = inAppSettlementUpdatesEnabled;
    }
    if (inAppSettlementReminderEnabled != null) {
      inAppPayload['settlement_reminder'] = inAppSettlementReminderEnabled;
    }
    if (inAppSettlementAutoReminderEnabled != null) {
      inAppPayload['settlement_auto_reminder'] =
          inAppSettlementAutoReminderEnabled;
    }
    if (inAppSettlementSentEnabled != null) {
      inAppPayload['settlement_sent'] = inAppSettlementSentEnabled;
    }
    if (inAppSettlementConfirmedEnabled != null) {
      inAppPayload['settlement_confirmed'] = inAppSettlementConfirmedEnabled;
    }

    final pushPayload = <String, dynamic>{};
    if (pushExpenseAddedEnabled != null) {
      pushPayload['expense_added'] = pushExpenseAddedEnabled;
    }
    if (pushFriendInvitesEnabled != null) {
      pushPayload['friend_invites'] = pushFriendInvitesEnabled;
    }
    if (pushTripUpdatesEnabled != null) {
      pushPayload['trip_updates'] = pushTripUpdatesEnabled;
    }
    if (pushSettlementUpdatesEnabled != null) {
      pushPayload['settlement_updates'] = pushSettlementUpdatesEnabled;
    }

    final payload = <String, dynamic>{};
    if (inAppBannerEnabled != null) {
      payload['in_app_banner_enabled'] = inAppBannerEnabled;
    }
    if (inAppPayload.isNotEmpty) {
      payload['in_app'] = inAppPayload;
    }
    if (pushPayload.isNotEmpty) {
      payload['push'] = pushPayload;
    }

    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('update_notification_preferences'),
      method: HttpMethod.post,
      body: payload,
    );
    return NotificationPreferencesModel.fromApiMap(response);
  }
}
