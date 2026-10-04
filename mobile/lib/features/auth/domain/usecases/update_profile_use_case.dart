import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? currentPassword,
    String? preferredCurrencyCode,
    Map<String, String?>? paymentDetails,
  }) {
    return _repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      currentPassword: currentPassword,
      preferredCurrencyCode: preferredCurrencyCode,
      paymentDetails: paymentDetails,
    );
  }
}
