import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../../../core/auth/auth_session_store.dart';
import '../../../../core/auth/account_data_session.dart';
import '../../../../core/auth/current_user_store.dart';
import '../../../../core/auth/device_token_store.dart';
import '../../../../core/auth/user_avatar_store.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/legacy_avatar_uploader.dart';
import '../../../../core/network/legacy_feedback_reporter.dart';
import '../../../../core/push/push_registration_service.dart';
import '../../data/models/auth_user_model.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/usecases/deactivate_account_use_case.dart';
import '../../domain/usecases/forgot_password_use_case.dart';
import '../../domain/usecases/get_me_use_case.dart';
import '../../domain/usecases/get_notification_preferences_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_session_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/request_account_deletion_link_use_case.dart';
import '../../domain/usecases/request_deactivation_link_use_case.dart';
import '../../domain/usecases/request_email_verification_link_use_case.dart';
import '../../domain/usecases/request_reactivation_link_use_case.dart';
import '../../domain/usecases/set_credentials_use_case.dart';
import '../../domain/usecases/social_login_use_case.dart';
import '../../domain/usecases/update_notification_preferences_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';

class AuthController {
  AuthController(
    this._loginUseCase,
    this._logoutSessionUseCase,
    this._socialLoginUseCase,
    this._registerUseCase,
    this._setCredentialsUseCase,
    this._updateProfileUseCase,
    this._getMeUseCase,
    this._forgotPasswordUseCase,
    this._requestEmailVerificationLinkUseCase,
    this._requestReactivationLinkUseCase,
    this._requestDeactivationLinkUseCase,
    this._deactivateAccountUseCase,
    this._requestAccountDeletionLinkUseCase,
    this._getNotificationPreferencesUseCase,
    this._updateNotificationPreferencesUseCase,
    this._tokenStore,
    this._authSessionStore,
    this._currentUserStore,
    this._avatarStore,
    this._avatarUploader,
    this._feedbackReporter,
    this._pushRegistrationService,
    this._onLoggedOut, {
    AccountDataSession? accountSession,
  }) : _accountSession = accountSession ?? AccountDataSession();

  final LoginUseCase _loginUseCase;
  final LogoutSessionUseCase _logoutSessionUseCase;
  final SocialLoginUseCase _socialLoginUseCase;
  final RegisterUseCase _registerUseCase;
  final SetCredentialsUseCase _setCredentialsUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetMeUseCase _getMeUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final RequestEmailVerificationLinkUseCase
  _requestEmailVerificationLinkUseCase;
  final RequestReactivationLinkUseCase _requestReactivationLinkUseCase;
  final RequestDeactivationLinkUseCase _requestDeactivationLinkUseCase;
  final DeactivateAccountUseCase _deactivateAccountUseCase;
  final RequestAccountDeletionLinkUseCase _requestAccountDeletionLinkUseCase;
  final GetNotificationPreferencesUseCase _getNotificationPreferencesUseCase;
  final UpdateNotificationPreferencesUseCase
  _updateNotificationPreferencesUseCase;
  final DeviceTokenStore _tokenStore;
  final AuthSessionStore _authSessionStore;
  final CurrentUserStore _currentUserStore;
  final UserAvatarStore _avatarStore;
  final LegacyAvatarUploader _avatarUploader;
  final LegacyFeedbackReporter _feedbackReporter;
  final PushRegistrationService _pushRegistrationService;
  final Future<void> Function() _onLoggedOut;
  final AccountDataSession _accountSession;
  Future<bool>? _logoutInFlight;
  bool _signingIn = false;

  AuthUser? currentUser;
  NotificationPreferences _notificationPreferences =
      const NotificationPreferences.defaults();

  NotificationPreferences get notificationPreferences =>
      _notificationPreferences;

  Future<AuthUser> login({required String email, required String password}) =>
      _signIn(() => _loginUseCase.call(email: email, password: password));

  Future<AuthUser> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) => _signIn(
    () => _registerUseCase.call(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    ),
  );

  Future<AuthUser> loginWithSocial({
    required String provider,
    required String idToken,
    String? fullName,
    String? email,
  }) => _signIn(
    () => _socialLoginUseCase.call(
      provider: provider,
      idToken: idToken,
      fullName: fullName,
      email: email,
    ),
  );

  Future<AuthUser> setCredentials({
    required String email,
    required String password,
  }) async {
    final generation = _accountSession.generation;
    late final AuthUser user;
    try {
      user = await _withStoredAvatar(
        await _setCredentialsUseCase.call(email: email, password: password),
      );
    } on ApiException catch (error) {
      if (error.code == 'EMAIL_VERIFICATION_REQUIRED') {
        _accountSession.checkGeneration(generation);
        await logout();
      }
      rethrow;
    }
    await _setCurrentUser(user, generation);
    unawaited(_syncPushRegistration());
    return user;
  }

  Future<AuthUser> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? currentPassword,
    String? preferredCurrencyCode,
    Map<String, String?>? paymentDetails,
  }) async {
    final generation = _accountSession.generation;
    final user = await _withStoredAvatar(
      await _updateProfileUseCase.call(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        currentPassword: currentPassword,
        preferredCurrencyCode: preferredCurrencyCode,
        paymentDetails: paymentDetails,
      ),
    );
    await _setCurrentUser(user, generation);
    unawaited(_syncPushRegistration());
    return user;
  }

  Future<AuthUser> loadCurrentUser() async {
    final generation = _accountSession.generation;
    final user = await _withStoredAvatar(await _getMeUseCase.call());
    await _setCurrentUser(user, generation);
    unawaited(_syncPushRegistration());
    return user;
  }

  Future<void> requestPasswordReset({required String email}) {
    return _forgotPasswordUseCase.call(email: email);
  }

  Future<void> requestEmailVerificationLink({required String email}) {
    return _requestEmailVerificationLinkUseCase.call(email: email);
  }

  Future<void> requestReactivationLink({required String email}) {
    return _requestReactivationLinkUseCase.call(email: email);
  }

  Future<void> requestDeactivationLink() {
    return _requestDeactivationLinkUseCase.call();
  }

  Future<void> deactivateAccount({required String password}) {
    return _deactivateAccountUseCase.call(password: password);
  }

  Future<void> requestAccountDeletionLink({required String password}) {
    return _requestAccountDeletionLinkUseCase.call(password: password);
  }

  Future<NotificationPreferences> loadNotificationPreferences() async {
    final prefs = await _getNotificationPreferencesUseCase.call();
    _notificationPreferences = prefs;
    return prefs;
  }

  Future<NotificationPreferences> updateNotificationPreferences({
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
    final prefs = await _updateNotificationPreferencesUseCase.call(
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
    _notificationPreferences = prefs;
    return prefs;
  }

  Future<AuthUser?> readCachedCurrentUser() async {
    if (_signingIn || _logoutInFlight != null) return null;
    final generation = _accountSession.generation;
    final inMemory = currentUser;
    if (inMemory != null && inMemory.id > 0) {
      return inMemory;
    }
    if (!await hasRecoverableSession()) return null;
    final stored = await _currentUserStore.read();
    if (stored == null || stored.id <= 0) {
      return null;
    }
    if (await _authSessionStore.readAccountOwner() != stored.id) return null;
    final merged = await _withStoredAvatar(stored);
    await _setCurrentUser(merged, generation);
    return merged;
  }

  Future<bool> hasRecoverableSession() async {
    final accessToken = await _authSessionStore.readValidAccessToken();
    if ((accessToken ?? '').trim().isNotEmpty) {
      return true;
    }
    final refreshToken = await _authSessionStore.readValidRefreshToken();
    return (refreshToken ?? '').trim().isNotEmpty;
  }

  Uint8List? avatarBytesFor(AuthUser? user) {
    final encoded = user?.avatarBase64;
    if (encoded == null || encoded.trim().isEmpty) {
      return null;
    }
    try {
      return base64Decode(encoded);
    } catch (_) {
      return null;
    }
  }

  String? avatarUrlFor(AuthUser? user, {bool preferThumb = false}) {
    final candidates = preferThumb
        ? <String?>[user?.avatarThumbUrl, user?.avatarUrl]
        : <String?>[user?.avatarUrl, user?.avatarThumbUrl];
    for (final candidate in candidates) {
      final raw = candidate?.trim();
      if (raw != null && raw.isNotEmpty) {
        return raw;
      }
    }
    return null;
  }

  Future<AuthUser?> updateLocalAvatar(Uint8List? bytes) async {
    final generation = _accountSession.generation;
    final user = currentUser;
    if (user == null || user.id <= 0) {
      return null;
    }
    final encoded = bytes == null || bytes.isEmpty ? null : base64Encode(bytes);
    await _avatarStore.writeAvatarBase64(
      userId: user.id,
      avatarBase64: encoded,
    );
    final next = encoded == null
        ? user.copyWith(clearAvatar: true)
        : user.copyWith(avatarBase64: encoded);
    await _setCurrentUser(next, generation);
    return next;
  }

  Future<AuthUser?> uploadAvatar({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final generation = _accountSession.generation;
    final user = currentUser;
    if (user == null || user.id <= 0 || bytes.isEmpty) {
      return null;
    }

    final uploaded = await _avatarUploader.uploadAvatar(
      fileName: fileName,
      bytes: bytes,
    );
    final encoded = base64Encode(bytes);
    final merged = _mergeRemoteMe(user, uploaded.mePayload).copyWith(
      avatarBase64: encoded,
      avatarUrl: uploaded.avatarUrl,
      avatarThumbUrl: uploaded.avatarThumbUrl,
    );

    await _avatarStore.writeAvatarBase64(
      userId: merged.id,
      avatarBase64: encoded,
    );
    await _setCurrentUser(merged, generation);
    return merged;
  }

  Future<AuthUser?> removeAvatar() async {
    final generation = _accountSession.generation;
    final user = currentUser;
    if (user == null || user.id <= 0) {
      return null;
    }

    final removed = await _avatarUploader.removeAvatar();
    final merged = _mergeRemoteMe(
      user,
      removed.mePayload,
    ).copyWith(clearAvatar: true);

    await _avatarStore.writeAvatarBase64(userId: merged.id, avatarBase64: null);
    await _setCurrentUser(merged, generation);
    return merged;
  }

  Future<void> submitFeedback({
    required String type,
    required String note,
    int? tripId,
    String? localeCode,
    Map<String, Object?>? contextData,
    String? screenshotFileName,
    Uint8List? screenshotBytes,
  }) {
    return _feedbackReporter.submitFeedback(
      type: type,
      note: note,
      tripId: tripId,
      localeCode: localeCode,
      contextData: contextData,
      screenshotFileName: screenshotFileName,
      screenshotBytes: screenshotBytes,
    );
  }

  Future<bool> logout() =>
      _logoutInFlight ??= _performLogout().whenComplete(() {
        _logoutInFlight = null;
      });

  Future<bool> _performLogout() async {
    _accountSession.invalidate();
    final userId = currentUser?.id ?? 0;
    try {
      await _pushRegistrationService.unregisterCurrentDevice();
    } catch (_) {
      // Ignore push unregister errors during logout.
    }
    var revocationConfirmed = false;
    try {
      await _logoutSessionUseCase.call();
      revocationConfirmed = true;
    } catch (_) {
      // Offline logout must still remove access on this device.
    }
    await _authSessionStore.clear();
    await _tokenStore.resetToken();
    if (userId > 0) {
      await _avatarStore.writeAvatarBase64(userId: userId, avatarBase64: null);
    }
    currentUser = null;
    _notificationPreferences = const NotificationPreferences.defaults();
    await _currentUserStore.clear();
    await _onLoggedOut();
    return revocationConfirmed;
  }

  Future<void> syncPushRegistration() {
    return _syncPushRegistration();
  }

  Future<void> _syncPushRegistration() async {
    try {
      await _pushRegistrationService.syncRegistration();
    } catch (_) {
      // Push setup is best-effort and must not block auth flow.
    }
  }

  Future<AuthUser> _withStoredAvatar(AuthUser user) async {
    final stored = await _avatarStore.readAvatarBase64(user.id);
    if (stored == null || stored == user.avatarBase64) {
      return user;
    }
    return user.copyWith(avatarBase64: stored);
  }

  Future<int> _beginSignIn() async {
    // Also drain a restored session's refresh when no profile is loaded yet.
    await logout();
    return _accountSession.generation;
  }

  Future<AuthUser> _signIn(Future<AuthUser> Function() authenticate) async {
    if (_signingIn) throw AccountDataSession.changed;
    _signingIn = true;
    try {
      final generation = await _beginSignIn();
      final user = await _withStoredAvatar(await authenticate());
      await _setCurrentUser(user, generation, signingIn: true);
      unawaited(_syncPushRegistration());
      return user;
    } finally {
      _signingIn = false;
    }
  }

  Future<void> _setCurrentUser(
    AuthUser user,
    int generation, {
    bool signingIn = false,
  }) async {
    if (_logoutInFlight != null || (_signingIn && !signingIn)) {
      throw AccountDataSession.changed;
    }
    _accountSession.checkGeneration(generation);
    final previous = currentUser ?? await _currentUserStore.read();
    _accountSession.checkGeneration(generation);
    if (previous != null && previous.id != user.id) {
      await _onLoggedOut();
      _notificationPreferences = const NotificationPreferences.defaults();
    }
    _accountSession.checkGeneration(generation);
    currentUser = user;
    await _currentUserStore.write(user);
    _accountSession.checkGeneration(generation);
    _accountSession.activate(user.id);
  }

  AuthUser _mergeRemoteMe(AuthUser fallback, Map<String, dynamic>? mePayload) {
    if (mePayload == null) {
      return fallback;
    }
    return AuthUserModel.fromLegacyMap(mePayload);
  }
}
