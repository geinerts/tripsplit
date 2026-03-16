import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    super.firstName,
    super.lastName,
    super.displayName,
    required super.nickname,
    super.email,
    required super.needsCredentials,
    super.avatarBase64,
    super.avatarUrl,
    super.avatarThumbUrl,
  });

  factory AuthUserModel.fromLegacyMap(Map<String, dynamic> map) {
    final rawAvatar = (map['avatar_base64'] ?? map['avatar']) as String?;
    final avatar = (rawAvatar ?? '').trim();
    final rawAvatarUrl = map['avatar_url'] as String?;
    final avatarUrl = (rawAvatarUrl ?? '').trim();
    final rawAvatarThumbUrl = map['avatar_thumb_url'] as String?;
    final avatarThumbUrl = (rawAvatarThumbUrl ?? '').trim();
    final firstName = (map['first_name'] as String?)?.trim();
    final lastName = (map['last_name'] as String?)?.trim();
    final fullName = (map['full_name'] as String?)?.trim();
    final displayName = (map['display_name'] as String?)?.trim();
    return AuthUserModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      firstName: (firstName == null || firstName.isEmpty) ? null : firstName,
      lastName: (lastName == null || lastName.isEmpty) ? null : lastName,
      displayName: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : ((fullName != null && fullName.isNotEmpty) ? fullName : null),
      nickname: map['nickname'] as String? ?? '',
      email: map['email'] as String?,
      needsCredentials: map['needs_credentials'] as bool? ?? false,
      avatarBase64: avatar.isEmpty ? null : avatar,
      avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
      avatarThumbUrl: avatarThumbUrl.isEmpty ? null : avatarThumbUrl,
    );
  }
}
