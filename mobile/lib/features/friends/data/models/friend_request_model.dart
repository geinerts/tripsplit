import '../../domain/entities/friend_request.dart';
import 'friend_user_model.dart';

class FriendRequestModel extends FriendRequest {
  const FriendRequestModel({
    required super.requestId,
    required super.user,
    super.createdAt,
  });

  factory FriendRequestModel.fromLegacyMap(
    Map<String, dynamic> map, {
    required String userKey,
  }) {
    final userMap = map[userKey] as Map<String, dynamic>?;
    return FriendRequestModel(
      requestId: (map['request_id'] as num?)?.toInt() ?? 0,
      user: FriendUserModel.fromLegacyMap(userMap ?? const <String, dynamic>{}),
      createdAt: (map['created_at'] as String?)?.trim(),
    );
  }
}
