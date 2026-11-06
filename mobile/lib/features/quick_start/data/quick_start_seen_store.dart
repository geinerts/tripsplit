import 'package:shared_preferences/shared_preferences.dart';

/// Remembers on this device that the guide was shown, before any account exists.
/// Reinstalling clears it, so a new install sees the guide once.
class QuickStartSeenStore {
  static const _key = 'quick_start_seen_on_device';

  /// A storage failure counts as seen, so nobody gets stuck in front of the guide.
  Future<bool> isSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (_) {
      return true;
    }
  }

  Future<void> markSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (_) {
      // At worst the guide shows once more.
    }
  }
}
