class AuthUser {
  const AuthUser({
    required this.id,
    this.firstName,
    this.lastName,
    this.displayName,
    required this.nickname,
    this.email,
    required this.needsCredentials,
    this.avatarBase64,
    this.avatarUrl,
    this.avatarThumbUrl,
  });

  final int id;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String nickname;
  final String? email;
  final bool needsCredentials;
  final String? avatarBase64;
  final String? avatarUrl;
  final String? avatarThumbUrl;

  AuthUser copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? displayName,
    String? nickname,
    String? email,
    bool? needsCredentials,
    String? avatarBase64,
    String? avatarUrl,
    String? avatarThumbUrl,
    bool clearAvatar = false,
  }) {
    return AuthUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      needsCredentials: needsCredentials ?? this.needsCredentials,
      avatarBase64: clearAvatar ? null : (avatarBase64 ?? this.avatarBase64),
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
      avatarThumbUrl: clearAvatar
          ? null
          : (avatarThumbUrl ?? this.avatarThumbUrl),
    );
  }
}
