part of 'analytics_page.dart';

extension _AnalyticsPageCalculations on _AnalyticsPageState {
  String _formatMoney(double amount) {
    final currencyCode =
        _selectedTrip?.currencyCode ?? AppCurrencyCatalog.defaultCode;
    return AppFormatters.currency(context, amount, currencyCode: currencyCode);
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
    return AppFormatters.shortDayMonth(context, day);
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

  List<DateTime> _allTripDays(WorkspaceSnapshot snapshot) {
    if (snapshot.expenses.isEmpty) {
      return [];
    }

    DateTime? minDay;
    DateTime? maxDay;
    for (final expense in snapshot.expenses) {
      final day = _parseExpenseDay(expense.expenseDate);
      if (day == null) {
        continue;
      }
      if (minDay == null || day.isBefore(minDay)) {
        minDay = day;
      }
      if (maxDay == null || day.isAfter(maxDay)) {
        maxDay = day;
      }
    }

    if (minDay == null || maxDay == null) {
      return [];
    }

    // Cap at 90 contiguous days ending on the latest expense date.
    const maxDays = 90;
    final span = maxDay.difference(minDay).inDays + 1;
    final effectiveMin = span > maxDays
        ? maxDay.subtract(const Duration(days: maxDays - 1))
        : minDay;

    final days = <DateTime>[];
    var current = effectiveMin;
    while (!current.isAfter(maxDay)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
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
    final palette = AppDesign.memberPalette;
    final map = <int, Color>{};
    for (var i = 0; i < members.length; i++) {
      map[members[i].id] = palette[i % palette.length];
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
          color: AppDesign.analyticsCategoryColor(entry.key),
        ),
      );
    }

    rows.sort((a, b) => b.total.compareTo(a.total));
    if (rows.length <= 4) {
      return rows;
    }

    final topRows = rows.take(4).toList(growable: true);
    final otherTotal = rows
        .skip(4)
        .fold<double>(0, (sum, row) => sum + row.total);

    if (otherTotal > 0) {
      topRows.add(
        _CategoryTotalRow(
          key: 'other_aggregate',
          label: context.l10n.analyticsOther,
          icon: Icons.more_horiz_rounded,
          total: otherTotal,
          color: AppDesign.analyticsCategoryColor('other'),
        ),
      );
    }

    return topRows;
  }

  String _tripName(BuildContext context, Trip trip) {
    final name = trip.name.trim();
    if (name.isNotEmpty) {
      return name;
    }
    return context.l10n.tripWithId(trip.id);
  }
}
