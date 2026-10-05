import '../../domain/entities/friend_user.dart';
import '../../../../core/network/media_url_resolver.dart';

class FriendUserModel extends FriendUser {
  const FriendUserModel({
    required super.id,
    required super.nickname,
    super.displayName,
    super.avatarUrl,
    super.avatarThumbUrl,
    super.bankAccountHolder,
    super.bankIban,
    super.bankBic,
    super.revolutHandle,
    super.revolutMeLink,
    super.paypalMeLink,
    super.wisePayLink,
    super.commonTripsCount,
  });

  factory FriendUserModel.fromLegacyMap(Map<String, dynamic> map) {
    final avatarUrl = MediaUrlResolver.normalize(
      (map['avatar_url'] as String?)?.trim(),
    );
    final avatarThumbUrl = MediaUrlResolver.normalize(
      (map['avatar_thumb_url'] as String?)?.trim(),
    );
    return FriendUserModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      nickname: (map['nickname'] as String? ?? '').trim(),
      displayName: (map['display_name'] as String?)?.trim(),
      avatarUrl: avatarUrl,
      avatarThumbUrl: avatarThumbUrl,
      commonTripsCount: (map['common_trips_count'] as num?)?.toInt() ?? 0,
    );
  }
}
