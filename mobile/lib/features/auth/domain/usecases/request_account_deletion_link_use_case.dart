import '../repositories/auth_repository.dart';

class RequestAccountDeletionLinkUseCase {
  const RequestAccountDeletionLinkUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String password}) {
    return _repository.requestAccountDeletionLink(password: password);
  }
}
