import '../../domain/entities/trip_user.dart';
import '../../../../core/network/media_url_resolver.dart';

class TripUserModel extends TripUser {
  const TripUserModel({
    required super.id,
    required super.nickname,
    super.avatarUrl,
    super.avatarThumbUrl,
  });

  factory TripUserModel.fromLegacyMap(Map<String, dynamic> map) {
    final avatarUrl = MediaUrlResolver.normalize(
      (map['avatar_url'] as String?)?.trim(),
    );
    final avatarThumbUrl = MediaUrlResolver.normalize(
      (map['avatar_thumb_url'] as String?)?.trim(),
    );
    return TripUserModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      nickname: map['nickname'] as String? ?? '',
      avatarUrl: avatarUrl,
      avatarThumbUrl: avatarThumbUrl,
    );
  }
}
