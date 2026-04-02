part of 'workspace_page.dart';

String _localizedText(
  BuildContext context, {
  required String en,
  required String lv,
}) {
  final languageCode = Localizations.localeOf(context).languageCode;
  return languageCode.toLowerCase() == 'lv' ? lv : en;
}

String _tagQueuedNote(String note) {
  final trimmed = note.trim();
  if (trimmed.isEmpty) {
    return '[queued]';
  }
  if (trimmed.contains('[queued]')) {
    return trimmed;
  }
  return '$trimmed [queued]';
}

String _todayIsoDate() {
  final now = DateTime.now();
  final year = now.year.toString().padLeft(4, '0');
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

double _parseAmount(String raw) {
  final normalized = raw.trim().replaceAll(',', '.');
  return double.tryParse(normalized) ?? 0;
}

String _formatMoney(BuildContext context, double value) {
  final rounded = value.abs() < 0.005 ? 0.0 : value;
  return AppFormatters.euro(context, rounded);
}

String _signedMoney(BuildContext context, double value) {
  final rounded = value.abs() < 0.005 ? 0.0 : value;
  return AppFormatters.euro(context, rounded, signed: true);
}

String _splitModeShortLabel(BuildContext context, String splitMode) {
  final t = context.l10n;
  switch (splitMode.trim().toLowerCase()) {
    case 'exact':
      return t.exactAmountsLabel;
    case 'percent':
      return t.percentagesLabel;
    case 'shares':
      return t.sharesLabel;
    default:
      return t.equalSplitLabel;
  }
}

String _formatDisplayDate(BuildContext context, String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    return '';
  }
  final parsed =
      AppFormatters.parseIsoDate(value) ??
      DateTime.tryParse(value.split(' ').first);
  if (parsed == null) {
    return value;
  }
  return AppFormatters.shortDayMonth(context, parsed);
}

String _formatCompactNumber(double value) {
  final rounded = value.abs() < 0.000001 ? 0.0 : value;
  final whole = rounded.roundToDouble();
  if ((rounded - whole).abs() < 0.000001) {
    return whole.toInt().toString();
  }
  return rounded.toStringAsFixed(2);
}
