class TripUser {
  const TripUser({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    this.avatarThumbUrl,
  });

  final int id;
  final String nickname;
  final String? avatarUrl;
  final String? avatarThumbUrl;
}
