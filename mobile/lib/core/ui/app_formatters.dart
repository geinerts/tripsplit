import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AppFormatters {
  const AppFormatters._();

  static NumberFormat _currencyFormatter(BuildContext context) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    try {
      return NumberFormat.currency(
        locale: localeTag,
        symbol: '€',
        decimalDigits: 2,
      );
    } catch (_) {
      return NumberFormat.currency(
        locale: 'en_US',
        symbol: '€',
        decimalDigits: 2,
      );
    }
  }

  static String euro(
    BuildContext context,
    double amount, {
    bool signed = false,
  }) {
    final formatted = _currencyFormatter(context).format(amount.abs());
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

  static String euroFromCents(
    BuildContext context,
    int cents, {
    bool signed = false,
  }) {
    return euro(context, cents / 100, signed: signed);
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
