import 'friend_request.dart';
import 'friend_user.dart';

class FriendsSnapshot {
  const FriendsSnapshot({
    required this.friends,
    required this.pendingSent,
    required this.pendingReceived,
  });

  final List<FriendUser> friends;
  final List<FriendRequest> pendingSent;
  final List<FriendRequest> pendingReceived;
}
