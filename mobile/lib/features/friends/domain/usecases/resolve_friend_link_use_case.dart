import '../entities/friend_link.dart';
import '../repositories/friends_repository.dart';

class ResolveFriendLinkUseCase {
  const ResolveFriendLinkUseCase(this._repository);

  final FriendsRepository _repository;

  Future<ResolvedFriendLink> call({required String token}) {
    return _repository.resolveFriendLink(token: token);
  }
}
