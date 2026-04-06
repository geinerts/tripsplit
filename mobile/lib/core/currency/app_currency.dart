class AppCurrencyOption {
  const AppCurrencyOption({
    required this.code,
    required this.label,
    required this.symbol,
  });

  final String code;
  final String label;
  final String symbol;
}

class AppCurrencyCatalog {
  const AppCurrencyCatalog._();

  static const String defaultCode = 'EUR';

  // Europe currencies + top 5 outside Europe.
  static const List<AppCurrencyOption> supported = <AppCurrencyOption>[
    // Europe
    AppCurrencyOption(code: 'EUR', label: 'Euro', symbol: '€'),
    AppCurrencyOption(code: 'GBP', label: 'British Pound', symbol: '£'),
    AppCurrencyOption(code: 'CHF', label: 'Swiss Franc', symbol: 'CHF'),
    AppCurrencyOption(code: 'NOK', label: 'Norwegian Krone', symbol: 'kr'),
    AppCurrencyOption(code: 'SEK', label: 'Swedish Krona', symbol: 'kr'),
    AppCurrencyOption(code: 'DKK', label: 'Danish Krone', symbol: 'kr'),
    AppCurrencyOption(code: 'PLN', label: 'Polish Zloty', symbol: 'zł'),
    AppCurrencyOption(code: 'CZK', label: 'Czech Koruna', symbol: 'Kč'),
    AppCurrencyOption(code: 'HUF', label: 'Hungarian Forint', symbol: 'Ft'),
    AppCurrencyOption(code: 'RON', label: 'Romanian Leu', symbol: 'lei'),
    AppCurrencyOption(code: 'BGN', label: 'Bulgarian Lev', symbol: 'лв'),
    AppCurrencyOption(code: 'ISK', label: 'Icelandic Krona', symbol: 'kr'),
    AppCurrencyOption(code: 'ALL', label: 'Albanian Lek', symbol: 'L'),
    AppCurrencyOption(
      code: 'BAM',
      label: 'Bosnia and Herzegovina Mark',
      symbol: 'KM',
    ),
    AppCurrencyOption(code: 'BYN', label: 'Belarusian Ruble', symbol: 'Br'),
    AppCurrencyOption(code: 'MDL', label: 'Moldovan Leu', symbol: 'L'),
    AppCurrencyOption(code: 'MKD', label: 'Macedonian Denar', symbol: 'ден'),
    AppCurrencyOption(code: 'RSD', label: 'Serbian Dinar', symbol: 'дин'),
    AppCurrencyOption(code: 'UAH', label: 'Ukrainian Hryvnia', symbol: '₴'),
    AppCurrencyOption(code: 'GEL', label: 'Georgian Lari', symbol: '₾'),
    AppCurrencyOption(code: 'TRY', label: 'Turkish Lira', symbol: '₺'),
    // Outside Europe (top 5)
    AppCurrencyOption(code: 'USD', label: 'US Dollar', symbol: r'$'),
    AppCurrencyOption(code: 'JPY', label: 'Japanese Yen', symbol: '¥'),
    AppCurrencyOption(code: 'CNY', label: 'Chinese Yuan', symbol: '¥'),
    AppCurrencyOption(code: 'CAD', label: 'Canadian Dollar', symbol: r'C$'),
    AppCurrencyOption(code: 'AUD', label: 'Australian Dollar', symbol: r'A$'),
  ];

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

  static String labelForCode(String? raw) {
    final code = normalize(raw);
    for (final item in supported) {
      if (item.code == code) {
        return item.label;
      }
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
