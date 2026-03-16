import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class GetMeUseCase {
  const GetMeUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call() {
    return _repository.getMe();
  }
}
