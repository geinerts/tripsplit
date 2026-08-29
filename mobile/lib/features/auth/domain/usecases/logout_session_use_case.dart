import '../repositories/auth_repository.dart';

class LogoutSessionUseCase {
  const LogoutSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.logoutSession();
  }
}
