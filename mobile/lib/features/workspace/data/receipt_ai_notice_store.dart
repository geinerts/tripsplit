import 'package:shared_preferences/shared_preferences.dart';

/// Remembers, per account on this device, that the user was told receipt
/// photos go to OpenAI (privacy policy, "Receipt reading").
class ReceiptAiNoticeStore {
  const ReceiptAiNoticeStore();

  static String _key(int accountId) => 'receipt_ai_notice_seen_$accountId';

  /// A storage failure counts as not seen, so the notice shows again.
  Future<bool> isSeen(int accountId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key(accountId)) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> markSeen(int accountId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key(accountId), true);
    } catch (_) {
      // At worst the notice shows once more.
    }
  }
}
