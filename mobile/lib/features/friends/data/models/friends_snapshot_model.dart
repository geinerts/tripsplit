import '../../domain/entities/friends_snapshot.dart';
import 'friend_request_model.dart';
import 'friend_user_model.dart';

class FriendsSnapshotModel extends FriendsSnapshot {
  const FriendsSnapshotModel({
    required super.friends,
    required super.pendingSent,
    required super.pendingReceived,
  });

  factory FriendsSnapshotModel.fromLegacyMap(Map<String, dynamic> map) {
    final friendsList = map['friends'] as List<dynamic>? ?? const <dynamic>[];
    final pendingSentList =
        map['pending_sent'] as List<dynamic>? ?? const <dynamic>[];
    final pendingReceivedList =
        map['pending_received'] as List<dynamic>? ?? const <dynamic>[];

    return FriendsSnapshotModel(
      friends: friendsList
          .whereType<Map<String, dynamic>>()
          .map(FriendUserModel.fromLegacyMap)
          .toList(growable: false),
      pendingSent: pendingSentList
          .whereType<Map<String, dynamic>>()
          .map((item) =>
              FriendRequestModel.fromLegacyMap(item, userKey: 'to'))
          .toList(growable: false),
      pendingReceived: pendingReceivedList
          .whereType<Map<String, dynamic>>()
          .map((item) =>
              FriendRequestModel.fromLegacyMap(item, userKey: 'from'))
          .toList(growable: false),
    );
  }
}
