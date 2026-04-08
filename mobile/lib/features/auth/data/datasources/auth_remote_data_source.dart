import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_method.dart';
import '../../../../core/errors/api_exception.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserModel> loginWithEmail({
    required String email,
    required String password,
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
  });

  Future<AuthUserModel> getMe();

  Future<void> requestPasswordReset({required String email});

  Future<void> requestEmailVerificationLink({required String email});

  Future<void> requestReactivationLink({required String email});

  Future<void> deactivateAccount({required String password});

  Future<void> requestAccountDeletionLink({required String password});
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
}
