import '../../domain/entities/friends_section_page.dart';
import '../../domain/entities/friend_link.dart';
import '../../domain/entities/friends_snapshot.dart';
import '../../domain/repositories/friends_repository.dart';
import '../datasources/friends_remote_data_source.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  FriendsRepositoryImpl(this._remote);

  final FriendsRemoteDataSource _remote;

  @override
  Future<FriendsSnapshot> loadFriends() {
    return _remote.loadFriends();
  }

  @override
  Future<FriendsSectionPage> loadSectionPage({
    required String section,
    int limit = 25,
    String? cursor,
    int? offset,
  }) {
    return _remote.loadSectionPage(
      section: section,
      limit: limit,
      cursor: cursor,
      offset: offset,
    );
  }

  @override
  Future<void> sendInvite({required int userId}) {
    return _remote.sendInvite(userId: userId);
  }

  @override
  Future<FriendLink> getFriendLink() {
    return _remote.getFriendLink();
  }

  @override
  Future<ResolvedFriendLink> resolveFriendLink({required String token}) {
    return _remote.resolveFriendLink(token: token);
  }

  @override
  Future<void> respondInvite({required int requestId, required bool accept}) {
    return _remote.respondInvite(requestId: requestId, accept: accept);
  }

  @override
  Future<void> cancelInvite({required int requestId}) {
    return _remote.cancelInvite(requestId: requestId);
  }

  @override
  Future<void> removeFriend({required int userId}) {
    return _remote.removeFriend(userId: userId);
  }
}
