import '../entities/friends_section_page.dart';
import '../entities/friend_link.dart';
import '../entities/friends_snapshot.dart';

abstract class FriendsRepository {
  Future<FriendsSnapshot> loadFriends();
  Future<FriendsSectionPage> loadSectionPage({
    required String section,
    int limit,
    String? cursor,
    int? offset,
  });

  Future<void> sendInvite({required int userId});

  Future<FriendLink> getFriendLink();

  Future<ResolvedFriendLink> resolveFriendLink({required String token});

  Future<void> respondInvite({required int requestId, required bool accept});

  Future<void> cancelInvite({required int requestId});

  Future<void> removeFriend({required int userId});
}
