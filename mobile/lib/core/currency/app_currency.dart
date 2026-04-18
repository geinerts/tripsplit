import 'package:tripsplit/l10n/app_localizations.dart';

class AppCurrencyOption {
  const AppCurrencyOption({required this.code, required this.symbol});

  final String code;
  final String symbol;
}

class AppCurrencyCatalog {
  const AppCurrencyCatalog._();

  static const String defaultCode = 'EUR';

  // Europe currencies + top 5 outside Europe.
  static const List<AppCurrencyOption> supported = <AppCurrencyOption>[
    // Europe
    AppCurrencyOption(code: 'EUR', symbol: '€'),
    AppCurrencyOption(code: 'GBP', symbol: '£'),
    AppCurrencyOption(code: 'CHF', symbol: 'CHF'),
    AppCurrencyOption(code: 'NOK', symbol: 'kr'),
    AppCurrencyOption(code: 'SEK', symbol: 'kr'),
    AppCurrencyOption(code: 'DKK', symbol: 'kr'),
    AppCurrencyOption(code: 'PLN', symbol: 'zł'),
    AppCurrencyOption(code: 'CZK', symbol: 'Kč'),
    AppCurrencyOption(code: 'HUF', symbol: 'Ft'),
    AppCurrencyOption(code: 'RON', symbol: 'lei'),
    AppCurrencyOption(code: 'BGN', symbol: 'лв'),
    AppCurrencyOption(code: 'ISK', symbol: 'kr'),
    AppCurrencyOption(code: 'ALL', symbol: 'L'),
    AppCurrencyOption(code: 'BAM', symbol: 'KM'),
    AppCurrencyOption(code: 'BYN', symbol: 'Br'),
    AppCurrencyOption(code: 'MDL', symbol: 'L'),
    AppCurrencyOption(code: 'MKD', symbol: 'ден'),
    AppCurrencyOption(code: 'RSD', symbol: 'дин'),
    AppCurrencyOption(code: 'UAH', symbol: '₴'),
    AppCurrencyOption(code: 'GEL', symbol: '₾'),
    AppCurrencyOption(code: 'TRY', symbol: '₺'),
    // Outside Europe (top 5)
    AppCurrencyOption(code: 'USD', symbol: r'$'),
    AppCurrencyOption(code: 'JPY', symbol: '¥'),
    AppCurrencyOption(code: 'CNY', symbol: '¥'),
    AppCurrencyOption(code: 'CAD', symbol: r'C$'),
    AppCurrencyOption(code: 'AUD', symbol: r'A$'),
  ];

  // Subset that backend can convert reliably via FX provider.
  static const Set<String> profilePreferredSupportedCodes = <String>{
    'AUD',
    'BGN',
    'CAD',
    'CHF',
    'CNY',
    'CZK',
    'DKK',
    'EUR',
    'GBP',
    'HUF',
    'ISK',
    'JPY',
    'NOK',
    'PLN',
    'RON',
    'SEK',
    'TRY',
    'USD',
  };

  static final List<AppCurrencyOption> profilePreferredSupported = supported
      .where((item) => profilePreferredSupportedCodes.contains(item.code))
      .toList(growable: false);

  static String normalize(String? raw, {String fallback = defaultCode}) {
    final code = (raw ?? '').trim().toUpperCase();
    if (code.length != 3) {
      return fallback;
    }
    for (final item in supported) {
      if (item.code == code) {
        return code;
      }
    }
    return fallback;
  }

  static String normalizeProfilePreferred(
    String? raw, {
    String fallback = defaultCode,
  }) {
    final code = normalize(raw, fallback: fallback);
    if (profilePreferredSupportedCodes.contains(code)) {
      return code;
    }
    return fallback;
  }

  static String labelForCode(String? raw, AppLocalizations l10n) {
    final code = normalize(raw);
    switch (code) {
      case 'EUR':
        return l10n.currencyNameEur;
      case 'GBP':
        return l10n.currencyNameGbp;
      case 'CHF':
        return l10n.currencyNameChf;
      case 'NOK':
        return l10n.currencyNameNok;
      case 'SEK':
        return l10n.currencyNameSek;
      case 'DKK':
        return l10n.currencyNameDkk;
      case 'PLN':
        return l10n.currencyNamePln;
      case 'CZK':
        return l10n.currencyNameCzk;
      case 'HUF':
        return l10n.currencyNameHuf;
      case 'RON':
        return l10n.currencyNameRon;
      case 'BGN':
        return l10n.currencyNameBgn;
      case 'ISK':
        return l10n.currencyNameIsk;
      case 'ALL':
        return l10n.currencyNameAll;
      case 'BAM':
        return l10n.currencyNameBam;
      case 'BYN':
        return l10n.currencyNameByn;
      case 'MDL':
        return l10n.currencyNameMdl;
      case 'MKD':
        return l10n.currencyNameMkd;
      case 'RSD':
        return l10n.currencyNameRsd;
      case 'UAH':
        return l10n.currencyNameUah;
      case 'GEL':
        return l10n.currencyNameGel;
      case 'TRY':
        return l10n.currencyNameTry;
      case 'USD':
        return l10n.currencyNameUsd;
      case 'JPY':
        return l10n.currencyNameJpy;
      case 'CNY':
        return l10n.currencyNameCny;
      case 'CAD':
        return l10n.currencyNameCad;
      case 'AUD':
        return l10n.currencyNameAud;
    }
    return code;
  }

  static String symbolForCode(String? raw) {
    final code = normalize(raw);
    for (final item in supported) {
      if (item.code == code) {
        return item.symbol;
      }
    }
    return code;
  }
}
