import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    return _repository.registerWithCredentials(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
  }
}
