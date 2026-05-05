import '../entities/friend_link.dart';
import '../repositories/friends_repository.dart';

class GetFriendLinkUseCase {
  const GetFriendLinkUseCase(this._repository);

  final FriendsRepository _repository;

  Future<FriendLink> call() {
    return _repository.getFriendLink();
  }
}
