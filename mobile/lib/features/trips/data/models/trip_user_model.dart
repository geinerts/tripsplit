import '../../domain/entities/trip_user.dart';

class TripUserModel extends TripUser {
  const TripUserModel({
    required super.id,
    required super.nickname,
    super.avatarUrl,
    super.avatarThumbUrl,
  });

  factory TripUserModel.fromLegacyMap(Map<String, dynamic> map) {
    final avatarUrl = (map['avatar_url'] as String?)?.trim();
    final avatarThumbUrl = (map['avatar_thumb_url'] as String?)?.trim();
    return TripUserModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      nickname: map['nickname'] as String? ?? '',
      avatarUrl: avatarUrl != null && avatarUrl.isNotEmpty ? avatarUrl : null,
      avatarThumbUrl: avatarThumbUrl != null && avatarThumbUrl.isNotEmpty
          ? avatarThumbUrl
          : null,
    );
  }
}
