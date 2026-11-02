import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';

enum AppLocaleMode {
  system(null, '', ''),
  english('en', 'English', '🇬🇧'),
  german('de', 'Deutsch', '🇩🇪'),
  spanish('es', 'Español', '🇪🇸'),
  french('fr', 'Français', '🇫🇷'),
  italian('it', 'Italiano', '🇮🇹'),
  portuguese('pt', 'Português', '🇵🇹'),
  polish('pl', 'Polski', '🇵🇱'),
  dutch('nl', 'Nederlands', '🇳🇱'),
  swedish('sv', 'Svenska', '🇸🇪'),
  danish('da', 'Dansk', '🇩🇰'),
  norwegian('nb', 'Norsk bokmål', '🇳🇴'),
  finnish('fi', 'Suomi', '🇫🇮'),
  czech('cs', 'Čeština', '🇨🇿'),
  ukrainian('uk', 'Українська', '🇺🇦'),
  latvian('lv', 'Latviešu', '🇱🇻');

  const AppLocaleMode(this.languageCode, this.nativeName, this.flag);
  final String? languageCode;
  final String nativeName;
  final String flag;
}

class AppLocaleController extends ChangeNotifier {
  AppLocaleController();

  static const String _prefKey = 'app.locale';

  AppLocaleMode _mode = AppLocaleMode.system;
  Locale? _locale;

  AppLocaleMode get mode => _mode;

  /// Explicit override; null lets MaterialApp follow the device.
  Locale? get locale => _locale;

  Locale get effectiveLocale =>
      _locale ??
      resolveDeviceLocale(WidgetsBinding.instance.platformDispatcher.locales);

  static Locale resolveDeviceLocale(List<Locale>? locales) {
    final deviceLanguage = locales?.firstOrNull?.languageCode.toLowerCase();
    final language = deviceLanguage == 'no' ? 'nb' : deviceLanguage;
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == language) return supported;
    }
    return const Locale('en');
  }

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

  static String _encodeMode(AppLocaleMode mode) =>
      mode.languageCode ?? 'system';

  static AppLocaleMode _decodeMode(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    final code = switch (value) {
      'english' => 'en',
      'latvian' => 'lv',
      'spanish' || 'espanol' || 'español' => 'es',
      'no' => 'nb',
      _ => value,
    };
    return AppLocaleMode.values.firstWhere(
      (mode) => mode.languageCode == code,
      orElse: () => AppLocaleMode.system,
    );
  }

  static Locale? _modeToLocale(AppLocaleMode mode) =>
      mode.languageCode == null ? null : Locale(mode.languageCode!);
}
