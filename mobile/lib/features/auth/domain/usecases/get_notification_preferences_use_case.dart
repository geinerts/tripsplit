import '../entities/notification_preferences.dart';
import '../repositories/auth_repository.dart';

class GetNotificationPreferencesUseCase {
  GetNotificationPreferencesUseCase(this._repository);

  final AuthRepository _repository;

  Future<NotificationPreferences> call() {
    return _repository.getNotificationPreferences();
  }
}
