class AuthUser {
  const AuthUser({
    required this.id,
    this.firstName,
    this.lastName,
    this.displayName,
    required this.nickname,
    this.email,
    required this.needsCredentials,
    this.bankCountryCode,
    this.bankAccountHolder,
    this.bankAccountNumber,
    this.bankIban,
    this.bankBic,
    this.bankSortCode,
    this.bankRoutingNumber,
    this.revolutHandle,
    this.paypalMeLink,
    this.preferredCurrencyCode,
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
  final String? bankCountryCode;
  final String? bankAccountHolder;
  final String? bankAccountNumber;
  final String? bankIban;
  final String? bankBic;
  final String? bankSortCode;
  final String? bankRoutingNumber;
  final String? revolutHandle;
  final String? paypalMeLink;
  final String? preferredCurrencyCode;
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
    String? bankCountryCode,
    String? bankAccountHolder,
    String? bankAccountNumber,
    String? bankIban,
    String? bankBic,
    String? bankSortCode,
    String? bankRoutingNumber,
    String? revolutHandle,
    String? paypalMeLink,
    String? preferredCurrencyCode,
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
      bankCountryCode: bankCountryCode ?? this.bankCountryCode,
      bankAccountHolder: bankAccountHolder ?? this.bankAccountHolder,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIban: bankIban ?? this.bankIban,
      bankBic: bankBic ?? this.bankBic,
      bankSortCode: bankSortCode ?? this.bankSortCode,
      bankRoutingNumber: bankRoutingNumber ?? this.bankRoutingNumber,
      revolutHandle: revolutHandle ?? this.revolutHandle,
      paypalMeLink: paypalMeLink ?? this.paypalMeLink,
      preferredCurrencyCode:
          preferredCurrencyCode ?? this.preferredCurrencyCode,
      avatarBase64: clearAvatar ? null : (avatarBase64 ?? this.avatarBase64),
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
      avatarThumbUrl: clearAvatar
          ? null
          : (avatarThumbUrl ?? this.avatarThumbUrl),
    );
  }
}
