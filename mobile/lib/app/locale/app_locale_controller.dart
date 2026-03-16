import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocaleMode { system, english, latvian }

class AppLocaleController extends ChangeNotifier {
  AppLocaleController();

  static const String _prefKey = 'app.locale';

  AppLocaleMode _mode = AppLocaleMode.system;
  Locale? _locale;

  AppLocaleMode get mode => _mode;

  /// `null` means follow system locale.
  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = _decodeMode(prefs.getString(_prefKey));
    _locale = _modeToLocale(_mode);
    notifyListeners();
  }

  Future<void> setMode(AppLocaleMode mode) async {
    if (_mode == mode) {
      return;
    }
    _mode = mode;
    _locale = _modeToLocale(mode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _encodeMode(mode));
  }

  static String _encodeMode(AppLocaleMode mode) {
    switch (mode) {
      case AppLocaleMode.system:
        return 'system';
      case AppLocaleMode.english:
        return 'en';
      case AppLocaleMode.latvian:
        return 'lv';
    }
  }

  static AppLocaleMode _decodeMode(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'en':
      case 'english':
        return AppLocaleMode.english;
      case 'lv':
      case 'latvian':
        return AppLocaleMode.latvian;
      default:
        return AppLocaleMode.system;
    }
  }

  static Locale? _modeToLocale(AppLocaleMode mode) {
    switch (mode) {
      case AppLocaleMode.system:
        return null;
      case AppLocaleMode.english:
        return const Locale('en');
      case AppLocaleMode.latvian:
        return const Locale('lv');
    }
  }
}
