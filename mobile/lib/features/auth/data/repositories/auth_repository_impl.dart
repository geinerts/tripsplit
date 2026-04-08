import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<AuthUser> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _remote.loginWithEmail(email: email, password: password);
  }

  @override
  Future<AuthUser> loginWithSocial({
    required String provider,
    required String idToken,
    String? fullName,
    String? email,
  }) {
    return _remote.loginWithSocial(
      provider: provider,
      idToken: idToken,
      fullName: fullName,
      email: email,
    );
  }

  @override
  Future<AuthUser> registerWithCredentials({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    return _remote.registerWithCredentials(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthUser> setCredentials({
    required String email,
    required String password,
  }) {
    return _remote.setCredentials(email: email, password: password);
  }

  @override
  Future<AuthUser> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    Map<String, String?>? paymentDetails,
  }) {
    return _remote.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      paymentDetails: paymentDetails,
    );
  }

  @override
  Future<AuthUser> getMe() {
    return _remote.getMe();
  }

  @override
  Future<void> requestPasswordReset({required String email}) {
    return _remote.requestPasswordReset(email: email);
  }

  @override
  Future<void> requestEmailVerificationLink({required String email}) {
    return _remote.requestEmailVerificationLink(email: email);
  }

  @override
  Future<void> requestReactivationLink({required String email}) {
    return _remote.requestReactivationLink(email: email);
  }

  @override
  Future<void> deactivateAccount({required String password}) {
    return _remote.deactivateAccount(password: password);
  }

  @override
  Future<void> requestAccountDeletionLink({required String password}) {
    return _remote.requestAccountDeletionLink(password: password);
  }
}
