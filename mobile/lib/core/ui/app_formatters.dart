import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../currency/app_currency.dart';

class AppFormatters {
  const AppFormatters._();

  static NumberFormat _currencyFormatter(
    BuildContext context, {
    required String currencyCode,
  }) {
    final normalizedCode = AppCurrencyCatalog.normalize(currencyCode);
    final symbol = AppCurrencyCatalog.symbolForCode(normalizedCode);
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    try {
      return NumberFormat.currency(
        locale: localeTag,
        name: normalizedCode,
        symbol: symbol,
        decimalDigits: 2,
      );
    } catch (_) {
      return NumberFormat.currency(
        locale: 'en_US',
        name: normalizedCode,
        symbol: symbol,
        decimalDigits: 2,
      );
    }
  }

  static String currency(
    BuildContext context,
    double amount, {
    String currencyCode = AppCurrencyCatalog.defaultCode,
    bool signed = false,
  }) {
    final normalizedCode = AppCurrencyCatalog.normalize(currencyCode);
    final formatted = _currencyFormatter(
      context,
      currencyCode: normalizedCode,
    ).format(amount.abs());
    if (!signed) {
      return formatted;
    }
    if (amount > 0) {
      return '+$formatted';
    }
    if (amount < 0) {
      return '-$formatted';
    }
    return formatted;
  }

  static String currencyFromCents(
    BuildContext context,
    int cents, {
    String currencyCode = AppCurrencyCatalog.defaultCode,
    bool signed = false,
  }) {
    return currency(
      context,
      cents / 100,
      currencyCode: currencyCode,
      signed: signed,
    );
  }

  static String euro(
    BuildContext context,
    double amount, {
    bool signed = false,
  }) {
    return currency(context, amount, signed: signed);
  }

  static String euroFromCents(
    BuildContext context,
    int cents, {
    bool signed = false,
  }) {
    return currencyFromCents(context, cents, signed: signed);
  }

  static DateTime? parseIsoDate(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static String shortDayMonth(BuildContext context, DateTime date) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    return DateFormat('MMM d', localeTag).format(date);
  }

  static String tripDateRange(
    BuildContext context, {
    String? startRaw,
    String? endRaw,
    required String unknownLabel,
  }) {
    final start = parseIsoDate(startRaw);
    final end = parseIsoDate(endRaw);
    if (start == null && end == null) {
      return unknownLabel;
    }
    if (start != null && end != null) {
      final localeTag = Localizations.localeOf(context).toLanguageTag();
      final month = DateFormat('MMM', localeTag);
      if (start.year == end.year && start.month == end.month) {
        return '${start.day}-${end.day} ${month.format(end)}';
      }
      return '${start.day} ${month.format(start)} - ${end.day} ${month.format(end)}';
    }
    return shortDayMonth(context, start ?? end!);
  }
}
