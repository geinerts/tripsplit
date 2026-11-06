import '../../../subscriptions/domain/entities/subscription_preview.dart';
import '../../../subscriptions/domain/entities/premium_access.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    this.firstName,
    this.lastName,
    this.displayName,
    required this.nickname,
    this.email,
    this.emailVerified,
    required this.needsCredentials,
    this.hasPassword,
    this.bankCountryCode,
    this.bankAccountHolder,
    this.bankAccountNumber,
    this.bankIban,
    this.bankBic,
    this.bankSortCode,
    this.bankRoutingNumber,
    this.revolutHandle,
    this.revolutMeLink,
    this.paypalMeLink,
    this.wisePayLink,
    this.sharePaymentDetailsWithTrips = false,
    this.preferredCurrencyCode,
    this.avatarBase64,
    this.avatarUrl,
    this.avatarThumbUrl,
    this.subscriptionPreview,
    this.premiumAccess,
  });

  final int id;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String nickname;
  final String? email;

  /// Null when unknown, such as a profile saved by an older version.
  final bool? emailVerified;
  final bool needsCredentials;

  /// Whether a chosen password is known; null for legacy or unknown state.
  /// Presentation only: the server still requires password or email proof.
  final bool? hasPassword;
  final String? bankCountryCode;
  final String? bankAccountHolder;
  final String? bankAccountNumber;
  final String? bankIban;
  final String? bankBic;
  final String? bankSortCode;
  final String? bankRoutingNumber;
  final String? revolutHandle;
  final String? revolutMeLink;
  final String? paypalMeLink;
  final String? wisePayLink;
  final bool sharePaymentDetailsWithTrips;
  final String? preferredCurrencyCode;
  final String? avatarBase64;
  final String? avatarUrl;
  final String? avatarThumbUrl;
  final SubscriptionPreview? subscriptionPreview;
  final PremiumAccess? premiumAccess;

  AuthUser copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? displayName,
    String? nickname,
    String? email,
    bool? emailVerified,
    bool? needsCredentials,
    bool? hasPassword,
    bool clearPasswordStatus = false,
    String? bankCountryCode,
    String? bankAccountHolder,
    String? bankAccountNumber,
    String? bankIban,
    String? bankBic,
    String? bankSortCode,
    String? bankRoutingNumber,
    String? revolutHandle,
    String? revolutMeLink,
    String? paypalMeLink,
    String? wisePayLink,
    bool? sharePaymentDetailsWithTrips,
    String? preferredCurrencyCode,
    String? avatarBase64,
    String? avatarUrl,
    String? avatarThumbUrl,
    bool clearAvatar = false,
  }) {
    return AuthUser(
      id: id ?? this.id,
      premiumAccess: id == null || id == this.id ? premiumAccess : null,
      subscriptionPreview: id == null || id == this.id
          ? subscriptionPreview
          : null,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      emailVerified: id != null && id != this.id
          ? emailVerified
          : (emailVerified ?? this.emailVerified),
      needsCredentials: needsCredentials ?? this.needsCredentials,
      hasPassword: clearPasswordStatus || (id != null && id != this.id)
          ? null
          : (hasPassword ?? this.hasPassword),
      bankCountryCode: bankCountryCode ?? this.bankCountryCode,
      bankAccountHolder: bankAccountHolder ?? this.bankAccountHolder,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIban: bankIban ?? this.bankIban,
      bankBic: bankBic ?? this.bankBic,
      bankSortCode: bankSortCode ?? this.bankSortCode,
      bankRoutingNumber: bankRoutingNumber ?? this.bankRoutingNumber,
      revolutHandle: revolutHandle ?? this.revolutHandle,
      revolutMeLink: revolutMeLink ?? this.revolutMeLink,
      paypalMeLink: paypalMeLink ?? this.paypalMeLink,
      wisePayLink: wisePayLink ?? this.wisePayLink,
      sharePaymentDetailsWithTrips:
          sharePaymentDetailsWithTrips ?? this.sharePaymentDetailsWithTrips,
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
