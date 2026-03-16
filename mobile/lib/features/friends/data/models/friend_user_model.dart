import '../../domain/entities/friend_user.dart';

class FriendUserModel extends FriendUser {
  const FriendUserModel({
    required super.id,
    required super.nickname,
    super.avatarUrl,
    super.avatarThumbUrl,
  });

  factory FriendUserModel.fromLegacyMap(Map<String, dynamic> map) {
    final avatarUrl = (map['avatar_url'] as String?)?.trim();
    final avatarThumbUrl = (map['avatar_thumb_url'] as String?)?.trim();
    return FriendUserModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      nickname: (map['nickname'] as String? ?? '').trim(),
      avatarUrl: avatarUrl != null && avatarUrl.isNotEmpty ? avatarUrl : null,
      avatarThumbUrl: avatarThumbUrl != null && avatarThumbUrl.isNotEmpty
          ? avatarThumbUrl
          : null,
    );
  }
}
