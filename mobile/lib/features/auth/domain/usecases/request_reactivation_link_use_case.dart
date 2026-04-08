import '../repositories/auth_repository.dart';

class RequestReactivationLinkUseCase {
  const RequestReactivationLinkUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email}) {
    return _repository.requestReactivationLink(email: email);
  }
}
