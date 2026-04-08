import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SocialLoginUseCase {
  const SocialLoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String provider,
    required String idToken,
    String? fullName,
    String? email,
  }) {
    return _repository.loginWithSocial(
      provider: provider,
      idToken: idToken,
      fullName: fullName,
      email: email,
    );
  }
}
