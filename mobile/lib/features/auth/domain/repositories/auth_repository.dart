import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> loginWithEmail({
    required String email,
    required String password,
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
  });

  Future<AuthUser> getMe();

  Future<void> requestPasswordReset({required String email});
}
