import '../repositories/auth_repository.dart';

class RequestEmailChangeUseCase {
  const RequestEmailChangeUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String newEmail,
    required String currentPassword,
  }) {
    return _repository.requestEmailChange(
      newEmail: newEmail,
      currentPassword: currentPassword,
    );
  }
}
