import 'friend_request.dart';
import 'friend_user.dart';

class FriendsSectionPage {
  const FriendsSectionPage({
    required this.section,
    required this.friendsCount,
    required this.pendingSentCount,
    required this.pendingReceivedCount,
    required this.friends,
    required this.requests,
    required this.hasMore,
    required this.nextCursor,
    required this.nextOffset,
  });

  final String section;
  final int friendsCount;
  final int pendingSentCount;
  final int pendingReceivedCount;
  final List<FriendUser> friends;
  final List<FriendRequest> requests;
  final bool hasMore;
  final String? nextCursor;
  final int? nextOffset;
}

