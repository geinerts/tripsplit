import '../repositories/friends_repository.dart';

class RespondFriendInviteUseCase {
  const RespondFriendInviteUseCase(this._repository);

  final FriendsRepository _repository;

  Future<void> call({required int requestId, required bool accept}) {
    return _repository.respondInvite(requestId: requestId, accept: accept);
  }
}
