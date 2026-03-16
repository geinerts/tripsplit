import '../repositories/friends_repository.dart';

class CancelFriendInviteUseCase {
  const CancelFriendInviteUseCase(this._repository);

  final FriendsRepository _repository;

  Future<void> call({required int requestId}) {
    return _repository.cancelInvite(requestId: requestId);
  }
}
