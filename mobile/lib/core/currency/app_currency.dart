import 'package:tripsplit/l10n/app_localizations.dart';

part 'app_currency_data.g.dart';

class AppCurrencyOption {
  const AppCurrencyOption({
    required this.code,
    required this.symbol,
    this.decimalDigits = 2,
  });

  final String code;
  final String symbol;

  /// Digits shown after the decimal point. Amounts are always stored in hundredths.
  final int decimalDigits;
}

class AppCurrencyCatalog {
  const AppCurrencyCatalog._();

  static const String defaultCode = 'EUR';

  static const List<AppCurrencyOption> supported = _catalog;

  // The server has rates for every supported currency.
  static const List<AppCurrencyOption> profilePreferredSupported = _catalog;

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
  }) => normalize(raw, fallback: fallback);

  static String labelForCode(String? raw, AppLocalizations l10n) {
    final code = normalize(raw);
    return _generatedLabel(code, l10n) ?? code;
  }

  static String symbolForCode(String? raw) =>
      _option(raw)?.symbol ?? normalize(raw);

  static int decimalDigitsForCode(String? raw) =>
      _option(raw)?.decimalDigits ?? 2;

  /// Text for an amount field. A value that isn't whole keeps its hundredths, so an
  /// exact share in a currency without decimals is never silently changed.
  static String amountInputText(double amount, String? code) {
    final whole = amount.roundToDouble();
    if (decimalDigitsForCode(code) == 0 && (amount - whole).abs() < 0.000001) {
      return whole.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  static AppCurrencyOption? _option(String? raw) {
    final code = normalize(raw);
    for (final item in supported) {
      if (item.code == code) {
        return item;
      }
    }
    return null;
  }
}
