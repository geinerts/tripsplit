import 'friend_user.dart';

class FriendLink {
  const FriendLink({required this.token, required this.url, this.expiresAt});

  final String token;
  final String url;
  final String? expiresAt;
}

class ResolvedFriendLink {
  const ResolvedFriendLink({required this.user});

  final FriendUser user;
}
