import '../repositories/friends_repository.dart';

class SendFriendInviteUseCase {
  const SendFriendInviteUseCase(this._repository);

  final FriendsRepository _repository;

  Future<void> call({required int userId}) {
    return _repository.sendInvite(userId: userId);
  }
}
