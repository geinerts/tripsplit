import '../repositories/auth_repository.dart';

class RequestDeactivationLinkUseCase {
  const RequestDeactivationLinkUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.requestDeactivationLink();
}
