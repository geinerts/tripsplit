part of 'analytics_page.dart';

extension _AnalyticsPageCalculations on _AnalyticsPageState {
  String _txt({required String en, required String lv}) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode.toLowerCase() == 'lv' ? lv : en;
  }

  String _formatMoney(double amount) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final positiveValue = amount.abs();
    try {
      final formatter = NumberFormat.currency(
        locale: localeTag,
        symbol: '€',
        decimalDigits: 2,
      );
      return formatter.format(positiveValue);
    } catch (_) {
      final fallback = NumberFormat.currency(
        locale: 'en_US',
        symbol: '€',
        decimalDigits: 2,
      );
      return fallback.format(positiveValue);
    }
  }

  DateTime _dayOnly(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  DateTime? _parseExpenseDay(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    DateTime? parsed = DateTime.tryParse(trimmed);
    parsed ??= DateTime.tryParse(trimmed.split(' ').first);
    if (parsed == null) {
      return null;
    }
    return _dayOnly(parsed);
  }

  String _dayKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  String _dayShortLabel(DateTime day) {
    final dd = day.day.toString().padLeft(2, '0');
    final mm = day.month.toString().padLeft(2, '0');
    return '$dd.$mm';
  }

  List<DateTime> _lastFiveDays(WorkspaceSnapshot snapshot) {
    DateTime anchor = _dayOnly(DateTime.now());
    for (final expense in snapshot.expenses) {
      final day = _parseExpenseDay(expense.expenseDate);
      if (day == null) {
        continue;
      }
      if (day.isAfter(anchor)) {
        anchor = day;
      }
    }

    final days = <DateTime>[];
    for (var i = 4; i >= 0; i--) {
      days.add(anchor.subtract(Duration(days: i)));
    }
    return days;
  }

  List<_MemberMeta> _membersForSnapshot(WorkspaceSnapshot snapshot) {
    final byId = <int, _MemberMeta>{
      for (final user in snapshot.users)
        user.id: _MemberMeta(id: user.id, name: user.nickname),
    };

    for (final expense in snapshot.expenses) {
      byId.putIfAbsent(
        expense.paidById,
        () => _MemberMeta(
          id: expense.paidById,
          name: expense.paidByNickname.trim().isEmpty
              ? '#${expense.paidById}'
              : expense.paidByNickname,
        ),
      );
    }

    final members = byId.values.toList(growable: false)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return members;
  }

  Map<int, Color> _memberColors(
    List<_MemberMeta> members,
    BuildContext context,
  ) {
    final base = Theme.of(context).colorScheme.primary;
    final hsv = HSVColor.fromColor(base);
    final map = <int, Color>{};
    for (var i = 0; i < members.length; i++) {
      final hue = (hsv.hue + (i * 41)) % 360;
      map[members[i].id] = hsv
          .withHue(hue)
          .withSaturation(0.72)
          .withValue(0.86)
          .toColor();
    }
    return map;
  }

  Map<String, Map<int, double>> _memberSpentByDay(
    WorkspaceSnapshot snapshot,
    List<DateTime> days,
    List<_MemberMeta> members,
  ) {
    final result = <String, Map<int, double>>{};
    for (final day in days) {
      result[_dayKey(day)] = {for (final member in members) member.id: 0};
    }

    for (final expense in snapshot.expenses) {
      final day = _parseExpenseDay(expense.expenseDate);
      if (day == null) {
        continue;
      }
      final key = _dayKey(day);
      final dayMap = result[key];
      if (dayMap == null) {
        continue;
      }
      dayMap[expense.paidById] =
          (dayMap[expense.paidById] ?? 0) + expense.amount;
    }
    return result;
  }

  Map<int, double> _memberTotals(WorkspaceSnapshot snapshot) {
    final totals = <int, double>{};
    for (final expense in snapshot.expenses) {
      totals[expense.paidById] =
          (totals[expense.paidById] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<_CategoryTotalRow> _categoryTotals(
    WorkspaceSnapshot snapshot,
    BuildContext context,
  ) {
    final totals = <String, double>{};
    final rawByGroupKey = <String, String>{};
    for (final expense in snapshot.expenses) {
      final normalized = ExpenseCategoryCatalog.normalizeStored(
        expense.category,
      );
      final groupKey = ExpenseCategoryCatalog.groupingKey(normalized);
      totals[groupKey] = (totals[groupKey] ?? 0) + expense.amount;
      rawByGroupKey.putIfAbsent(groupKey, () => normalized);
    }

    final rows = <_CategoryTotalRow>[];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = Theme.of(context).colorScheme.tertiary;
    final hsv = HSVColor.fromColor(base);
    var idx = 0;
    for (final entry in totals.entries) {
      final rawCategory = rawByGroupKey[entry.key] ?? 'other';
      rows.add(
        _CategoryTotalRow(
          key: entry.key,
          label: ExpenseCategoryCatalog.labelFor(
            rawCategory,
            Localizations.localeOf(context),
          ),
          icon: ExpenseCategoryCatalog.iconFor(rawCategory),
          total: entry.value,
          color: hsv
              .withHue((hsv.hue + (idx * 29)) % 360)
              .withSaturation(isDark ? 0.56 : 0.62)
              .withValue(isDark ? 0.98 : 0.84)
              .toColor(),
        ),
      );
      idx += 1;
    }

    rows.sort((a, b) => b.total.compareTo(a.total));
    return rows;
  }

  String _tripName(BuildContext context, Trip trip) {
    final name = trip.name.trim();
    if (name.isNotEmpty) {
      return name;
    }
    return context.l10n.tripWithId(trip.id);
  }
}
