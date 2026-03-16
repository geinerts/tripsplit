import 'package:shared_preferences/shared_preferences.dart';

class UserAvatarStore {
  static const String _keyPrefix = 'trip_user_avatar_v1_';

  Future<String?> readAvatarBase64(int userId) async {
    if (userId <= 0) {
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    final value = (prefs.getString('$_keyPrefix$userId') ?? '').trim();
    return value.isEmpty ? null : value;
  }

  Future<void> writeAvatarBase64({
    required int userId,
    required String? avatarBase64,
  }) async {
    if (userId <= 0) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final value = (avatarBase64 ?? '').trim();
    final key = '$_keyPrefix$userId';
    if (value.isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, value);
  }
}
