import 'package:shared_preferences/shared_preferences.dart';

class PushRegistrationStore {
  static const String _registeredTokenKey = 'trip_push_registered_token_v1';

  String? _cachedToken;

  Future<String?> readRegisteredToken() async {
    if (_cachedToken != null) {
      return _cachedToken;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = (prefs.getString(_registeredTokenKey) ?? '').trim();
    if (token.isEmpty) {
      return null;
    }
    _cachedToken = token;
    return token;
  }

  Future<void> writeRegisteredToken(String? token) async {
    final next = (token ?? '').trim();
    final prefs = await SharedPreferences.getInstance();
    if (next.isEmpty) {
      await prefs.remove(_registeredTokenKey);
      _cachedToken = null;
      return;
    }
    await prefs.setString(_registeredTokenKey, next);
    _cachedToken = next;
  }
}
