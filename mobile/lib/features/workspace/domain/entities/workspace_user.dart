class WorkspaceUser {
  const WorkspaceUser({
    required this.id,
    required this.nickname,
    this.displayName,
    this.avatarUrl,
    this.avatarThumbUrl,
    this.isReadyToSettle = false,
    this.readyToSettleAt,
  });

  final int id;
  final String nickname;
  final String? displayName;
  final String? avatarUrl;
  final String? avatarThumbUrl;
  final bool isReadyToSettle;
  final String? readyToSettleAt;

  String get preferredName {
    final fullName = (displayName ?? '').trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return nickname;
  }
}
