import '../../domain/entities/auth_user.dart';
import '../../../../core/currency/app_currency.dart';
import '../../../../core/network/media_url_resolver.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    super.firstName,
    super.lastName,
    super.displayName,
    required super.nickname,
    super.email,
    required super.needsCredentials,
    super.bankCountryCode,
    super.bankAccountHolder,
    super.bankAccountNumber,
    super.bankIban,
    super.bankBic,
    super.bankSortCode,
    super.bankRoutingNumber,
    super.revolutHandle,
    super.paypalMeLink,
    super.preferredCurrencyCode,
    super.avatarBase64,
    super.avatarUrl,
    super.avatarThumbUrl,
  });

  factory AuthUserModel.fromLegacyMap(Map<String, dynamic> map) {
    final rawAvatar = (map['avatar_base64'] ?? map['avatar']) as String?;
    final avatar = (rawAvatar ?? '').trim();
    final rawAvatarUrl = map['avatar_url'] as String?;
    final avatarUrl = MediaUrlResolver.normalize((rawAvatarUrl ?? '').trim());
    final rawAvatarThumbUrl = map['avatar_thumb_url'] as String?;
    final avatarThumbUrl = MediaUrlResolver.normalize(
      (rawAvatarThumbUrl ?? '').trim(),
    );
    final firstName = (map['first_name'] as String?)?.trim();
    final lastName = (map['last_name'] as String?)?.trim();
    final fullName = (map['full_name'] as String?)?.trim();
    final displayName = (map['display_name'] as String?)?.trim();
    final bankCountryCode = (map['bank_country_code'] as String?)?.trim();
    final bankAccountHolder = (map['bank_account_holder'] as String?)?.trim();
    final bankAccountNumber = (map['bank_account_number'] as String?)?.trim();
    final bankIban = (map['bank_iban'] as String?)?.trim();
    final bankBic = (map['bank_bic'] as String?)?.trim();
    final bankSortCode = (map['bank_sort_code'] as String?)?.trim();
    final bankRoutingNumber = (map['bank_routing_number'] as String?)?.trim();
    final revolutHandle = (map['revolut_handle'] as String?)?.trim();
    final paypalMeLink = (map['paypal_me_link'] as String?)?.trim();
    final preferredCurrencyCode = AppCurrencyCatalog.normalize(
      (map['preferred_currency_code'] as String?)?.trim(),
    );
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
      bankCountryCode: (bankCountryCode == null || bankCountryCode.isEmpty)
          ? null
          : bankCountryCode,
      bankAccountHolder:
          (bankAccountHolder == null || bankAccountHolder.isEmpty)
          ? null
          : bankAccountHolder,
      bankAccountNumber:
          (bankAccountNumber == null || bankAccountNumber.isEmpty)
          ? null
          : bankAccountNumber,
      bankIban: (bankIban == null || bankIban.isEmpty) ? null : bankIban,
      bankBic: (bankBic == null || bankBic.isEmpty) ? null : bankBic,
      bankSortCode: (bankSortCode == null || bankSortCode.isEmpty)
          ? null
          : bankSortCode,
      bankRoutingNumber:
          (bankRoutingNumber == null || bankRoutingNumber.isEmpty)
          ? null
          : bankRoutingNumber,
      revolutHandle: (revolutHandle == null || revolutHandle.isEmpty)
          ? null
          : revolutHandle,
      paypalMeLink: (paypalMeLink == null || paypalMeLink.isEmpty)
          ? null
          : paypalMeLink,
      preferredCurrencyCode: preferredCurrencyCode,
      avatarBase64: avatar.isEmpty ? null : avatar,
      avatarUrl: avatarUrl,
      avatarThumbUrl: avatarThumbUrl,
    );
  }
}
