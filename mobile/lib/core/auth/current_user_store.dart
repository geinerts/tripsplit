import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/models/auth_user_model.dart';
import '../../features/auth/domain/entities/auth_user.dart';

class CurrentUserStore {
  static const String _key = 'trip_current_user_v1';

  Future<AuthUser?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = (prefs.getString(_key) ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return AuthUserModel.fromLegacyMap(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(AuthUser user) async {
    if (user.id <= 0) {
      await clear();
      return;
    }
    final payload = <String, dynamic>{
      'id': user.id,
      'first_name': user.firstName,
      'last_name': user.lastName,
      'display_name': user.displayName,
      'nickname': user.nickname,
      'email': user.email,
      'needs_credentials': user.needsCredentials,
      'bank_country_code': user.bankCountryCode,
      'bank_account_holder': user.bankAccountHolder,
      'bank_account_number': user.bankAccountNumber,
      'bank_iban': user.bankIban,
      'bank_bic': user.bankBic,
      'bank_sort_code': user.bankSortCode,
      'bank_routing_number': user.bankRoutingNumber,
      'revolut_handle': user.revolutHandle,
      'paypal_me_link': user.paypalMeLink,
      'preferred_currency_code': user.preferredCurrencyCode,
      'avatar_base64': user.avatarBase64,
      'avatar_url': user.avatarUrl,
      'avatar_thumb_url': user.avatarThumbUrl,
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(payload));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
