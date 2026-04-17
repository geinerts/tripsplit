import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeController extends ChangeNotifier {
  ThemeModeController();

  static const String _prefKey = 'app.theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _decodeThemeMode(prefs.getString(_prefKey));
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final normalized = _normalizeMode(mode);
    if (_themeMode == normalized) {
      return;
    }
    _themeMode = normalized;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _encodeThemeMode(normalized));
  }

  static String _encodeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        // Legacy mode is persisted as dark.
        return 'dark';
    }
  }

  static ThemeMode _decodeThemeMode(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        // Legacy "system" falls back to explicit dark default.
        return ThemeMode.dark;
    }
  }

  static ThemeMode _normalizeMode(ThemeMode mode) {
    if (mode == ThemeMode.system) {
      return ThemeMode.dark;
    }
    return mode;
  }
}
