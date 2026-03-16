import '../repositories/friends_repository.dart';

class RemoveFriendUseCase {
  const RemoveFriendUseCase(this._repository);

  final FriendsRepository _repository;

  Future<void> call({required int userId}) {
    return _repository.removeFriend(userId: userId);
  }
}
