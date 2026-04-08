import '../repositories/auth_repository.dart';

class RequestEmailVerificationLinkUseCase {
  const RequestEmailVerificationLinkUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email}) {
    return _repository.requestEmailVerificationLink(email: email);
  }
}
