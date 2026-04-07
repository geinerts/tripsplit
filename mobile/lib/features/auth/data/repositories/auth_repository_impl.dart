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
  }) {
    return _remote.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthUser> getMe() {
    return _remote.getMe();
  }
}
