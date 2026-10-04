import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/core/auth/auth_session_store.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/device_token_store.dart';
import 'package:tripsplit/core/auth/current_user_store.dart';
import 'package:tripsplit/core/auth/user_avatar_store.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/legacy_avatar_uploader.dart';
import 'package:tripsplit/core/network/legacy_feedback_reporter.dart';
import 'package:tripsplit/core/push/push_registration_service.dart';
import 'package:tripsplit/features/auth/domain/entities/auth_user.dart';
import 'package:tripsplit/features/auth/domain/repositories/auth_repository.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/auth/domain/usecases/login_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/logout_session_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/social_login_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/register_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/set_credentials_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/update_profile_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/get_me_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/request_email_verification_link_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/request_reactivation_link_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/request_deactivation_link_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/deactivate_account_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/request_account_deletion_link_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/get_notification_preferences_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/update_notification_preferences_use_case.dart';

class _Repository implements AuthRepository {
  bool fail = false;
  Completer<AuthUser> loginResult = Completer<AuthUser>();
  Completer<void> loginEntered = Completer<void>();
  @override
  Future<AuthUser> loginWithEmail({
    required String email,
    required String password,
  }) {
    loginEntered.complete();
    return loginResult.future;
  }

  @override
  Future<void> logoutSession() async {
    if (fail) throw const ApiException('Offline', isNetworkError: true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Push implements PushRegistrationService {
  @override
  Future<void> unregisterCurrentDevice() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final fail in [false, true]) {
    test('logout clears local data when revocation fails: $fail', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final repository = _Repository()..fail = fail;
      final session = AuthSessionStore();
      await session.saveFromAuthPayload({
        'user_id': 7,
        'access_token': 'test-access',
        'refresh_token': 'test-refresh',
        'access_expires_in_sec': 3600,
        'refresh_expires_in_sec': 7200,
      });
      final device = DeviceTokenStore();
      final oldDevice = await device.getOrCreateToken();
      final current = CurrentUserStore();
      final avatars = UserAvatarStore();
      const user = AuthUser(id: 7, nickname: 'Test', needsCredentials: false);
      await current.write(user);
      await avatars.writeAvatarBase64(userId: 7, avatarBase64: 'test-avatar');
      var clearedCaches = false;
      final account = AccountDataSession();
      final controller = AuthController(
        LoginUseCase(repository),
        LogoutSessionUseCase(repository),
        SocialLoginUseCase(repository),
        RegisterUseCase(repository),
        SetCredentialsUseCase(repository),
        UpdateProfileUseCase(repository),
        GetMeUseCase(repository),
        ForgotPasswordUseCase(repository),
        RequestEmailVerificationLinkUseCase(repository),
        RequestReactivationLinkUseCase(repository),
        RequestDeactivationLinkUseCase(repository),
        DeactivateAccountUseCase(repository),
        RequestAccountDeletionLinkUseCase(repository),
        GetNotificationPreferencesUseCase(repository),
        UpdateNotificationPreferencesUseCase(repository),
        device,
        session,
        current,
        avatars,
        LegacyAvatarUploader(
          baseUrl: 'https://example.test',
          tokenStore: device,
          authSessionStore: session,
        ),
        LegacyFeedbackReporter(
          baseUrl: 'https://example.test',
          tokenStore: device,
          authSessionStore: session,
        ),
        _Push(),
        () async {
          clearedCaches = true;
        },
        accountSession: account,
      );
      await current.write(
        const AuthUser(
          id: 8,
          nickname: 'Other account',
          needsCredentials: false,
        ),
      );
      expect(await controller.readCachedCurrentUser(), isNull);
      expect(account.userId, isNull);
      await current.write(user);
      expect((await controller.readCachedCurrentUser())!.id, 7);
      expect(account.userId, 7);
      expect(await controller.logout(), !fail);
      expect(account.userId, isNull);
      expect(controller.currentUser, isNull);
      expect(await current.read(), isNull);
      expect(await avatars.readAvatarBase64(7), isNull);
      expect(await session.readValidAccessToken(), isNull);
      expect(await session.readValidRefreshToken(), isNull);
      expect(await device.getOrCreateToken(), isNot(oldDevice));
      expect(clearedCaches, isTrue);

      final signingIn = controller.login(
        email: 'fixture@example.test',
        password: 'test',
      );
      await repository.loginEntered.future;
      expect(await controller.readCachedCurrentUser(), isNull);
      await expectLater(
        controller.login(email: 'second@example.test', password: 'test'),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'account_changed'),
        ),
      );
      repository.loginResult.complete(
        const AuthUser(id: 8, nickname: 'B', needsCredentials: false),
      );
      expect((await signingIn).id, 8);
      expect(account.userId, 8);

      repository.loginResult = Completer<AuthUser>();
      repository.loginEntered = Completer<void>();
      final interrupted = controller.login(
        email: 'third@example.test',
        password: 'test',
      );
      final rejected = expectLater(
        interrupted,
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'account_changed'),
        ),
      );
      await repository.loginEntered.future;
      await controller.logout();
      repository.loginResult.complete(
        const AuthUser(id: 9, nickname: 'C', needsCredentials: false),
      );
      await rejected;
      expect(account.userId, isNull);
      expect(controller.currentUser, isNull);
      expect(await current.read(), isNull);
    });
  }
}
