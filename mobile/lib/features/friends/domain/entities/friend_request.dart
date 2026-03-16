import 'friend_user.dart';

class FriendRequest {
  const FriendRequest({
    required this.requestId,
    required this.user,
    this.createdAt,
  });

  final int requestId;
  final FriendUser user;
  final String? createdAt;
}
