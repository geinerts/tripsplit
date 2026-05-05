import '../../domain/entities/friend_link.dart';
import 'friend_user_model.dart';

class FriendLinkModel extends FriendLink {
  const FriendLinkModel({
    required super.token,
    required super.url,
    super.expiresAt,
  });

  factory FriendLinkModel.fromLegacyMap(Map<String, dynamic> map) {
    return FriendLinkModel(
      token: (map['friend_token'] as String? ?? '').trim(),
      url: (map['friend_url'] as String? ?? '').trim(),
      expiresAt: (map['expires_at'] as String?)?.trim(),
    );
  }
}

class ResolvedFriendLinkModel extends ResolvedFriendLink {
  const ResolvedFriendLinkModel({required super.user});

  factory ResolvedFriendLinkModel.fromLegacyMap(Map<String, dynamic> map) {
    final rawUser = map['user'];
    final userMap = rawUser is Map
        ? Map<String, dynamic>.from(rawUser)
        : const <String, dynamic>{};
    return ResolvedFriendLinkModel(
      user: FriendUserModel.fromLegacyMap(userMap),
    );
  }
}
