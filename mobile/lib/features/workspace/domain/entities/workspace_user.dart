class WorkspaceUser {
  const WorkspaceUser({
    required this.id,
    required this.nickname,
    this.role = 'member',
    this.displayName,
    this.avatarUrl,
    this.avatarThumbUrl,
    this.bankAccountHolder,
    this.bankIban,
    this.bankBic,
    this.revolutHandle,
    this.revolutMeLink,
    this.paypalMeLink,
    this.wisePayLink,
    this.isReadyToSettle = false,
    this.readyToSettleAt,
  });

  final int id;
  final String nickname;
  final String role;
  final String? displayName;
  final String? avatarUrl;
  final String? avatarThumbUrl;
  final String? bankAccountHolder;
  final String? bankIban;
  final String? bankBic;
  final String? revolutHandle;
  final String? revolutMeLink;
  final String? paypalMeLink;
  final String? wisePayLink;
  final bool isReadyToSettle;
  final String? readyToSettleAt;

  String get preferredName {
    final fullName = (displayName ?? '').trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return nickname;
  }

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';
  bool get canManageTrip => isOwner || isAdmin;
}
