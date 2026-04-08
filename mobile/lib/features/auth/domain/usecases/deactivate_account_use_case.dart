import '../repositories/auth_repository.dart';

class DeactivateAccountUseCase {
  const DeactivateAccountUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String password}) {
    return _repository.deactivateAccount(password: password);
  }
}
