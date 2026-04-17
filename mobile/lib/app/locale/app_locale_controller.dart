import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocaleMode { english, latvian, spanish }

class AppLocaleController extends ChangeNotifier {
  AppLocaleController();

  static const String _prefKey = 'app.locale';

  AppLocaleMode _mode = AppLocaleMode.english;
  Locale? _locale;

  AppLocaleMode get mode => _mode;

  /// Active locale used by the app.
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
      case AppLocaleMode.english:
        return 'en';
      case AppLocaleMode.latvian:
        return 'lv';
      case AppLocaleMode.spanish:
        return 'es';
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
      case 'es':
      case 'spanish':
      case 'espanol':
      case 'español':
        return AppLocaleMode.spanish;
      default:
        // Legacy "system" falls back to explicit English default.
        return AppLocaleMode.english;
    }
  }

  static Locale? _modeToLocale(AppLocaleMode mode) {
    switch (mode) {
      case AppLocaleMode.english:
        return const Locale('en');
      case AppLocaleMode.latvian:
        return const Locale('lv');
      case AppLocaleMode.spanish:
        return const Locale('es');
    }
  }
}
