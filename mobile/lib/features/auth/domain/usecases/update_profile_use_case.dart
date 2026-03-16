import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String nickname,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
  }) {
    return _repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      nickname: nickname,
      email: email,
      password: password,
    );
  }
}
