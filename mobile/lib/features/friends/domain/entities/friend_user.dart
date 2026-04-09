class FriendUser {
  const FriendUser({
    required this.id,
    required this.nickname,
    this.displayName,
    this.avatarUrl,
    this.avatarThumbUrl,
    this.bankAccountHolder,
    this.bankIban,
    this.bankBic,
    this.revolutHandle,
    this.revolutMeLink,
    this.paypalMeLink,
  });

  final int id;
  final String nickname;
  final String? displayName;
  final String? avatarUrl;
  final String? avatarThumbUrl;
  final String? bankAccountHolder;
  final String? bankIban;
  final String? bankBic;
  final String? revolutHandle;
  final String? revolutMeLink;
  final String? paypalMeLink;

  String get preferredName {
    final fullName = (displayName ?? '').trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return nickname;
  }

  bool get hasPaymentDetails {
    return (bankIban ?? '').trim().isNotEmpty ||
        (bankBic ?? '').trim().isNotEmpty ||
        (revolutHandle ?? '').trim().isNotEmpty ||
        (revolutMeLink ?? '').trim().isNotEmpty ||
        (paypalMeLink ?? '').trim().isNotEmpty;
  }
}
