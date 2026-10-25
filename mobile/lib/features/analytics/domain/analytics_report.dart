import '../../trips/domain/entities/trip.dart';
import '../../workspace/domain/entities/trip_expense.dart';
import '../../workspace/domain/entities/trip_expenses_page.dart';

typedef AnalyticsPageLoader =
    Future<TripExpensesPage> Function({
      required int tripId,
      int limit,
      String? cursor,
      int? offset,
    });

/// Complete, account-scoped input. Never substitute the capped workspace snapshot.
Future<List<AnalyticsEntry>> loadAnalyticsEntries({
  required List<Trip> trips,
  required int userId,
  required AnalyticsPageLoader loadPage,
  required bool Function() isCurrent,
}) async {
  final result = <AnalyticsEntry>[];
  for (final trip in trips) {
    final expenses = <int, TripExpense>{};
    final visited = <String>{};
    String? cursor;
    int? offset;
    while (true) {
      if (!isCurrent()) throw StateError('Analytics request superseded');
      if (!visited.add('${cursor ?? ''}:${offset ?? 0}')) {
        throw StateError('Expense pagination did not advance');
      }
      final page = await loadPage(
        tripId: trip.id,
        limit: 300,
        cursor: cursor,
        offset: offset,
      );
      if (!isCurrent()) throw StateError('Analytics request superseded');
      for (final expense in page.items) {
        expenses[expense.id] = expense;
      }
      if (!page.hasMore) break;
      if (page.items.isEmpty ||
          (page.nextCursor == null && page.nextOffset == null)) {
        throw StateError('Incomplete expense pagination');
      }
      cursor = page.nextCursor;
      offset = page.nextOffset;
    }
    result.addAll(
      expenses.values.map(
        (expense) => AnalyticsEntry.fromExpense(trip, expense, userId),
      ),
    );
  }
  return List.unmodifiable(result);
}

class AnalyticsEntry {
  const AnalyticsEntry({
    required this.trip,
    required this.expense,
    required this.totalCents,
    required this.shareCents,
    required this.paidCents,
  });
  factory AnalyticsEntry.fromExpense(
    Trip trip,
    TripExpense expense,
    int userId,
  ) {
    if (expense.tripCurrencyCode != trip.currencyCode ||
        !expense.amount.isFinite ||
        expense.amount < 0) {
      throw StateError('Invalid analytics amount or currency');
    }
    var share = 0;
    for (final participant in expense.participants.where(
      (p) => p.id == userId,
    )) {
      final owed = participant.owedAmount;
      if (owed == null || !owed.isFinite || owed < 0) {
        throw StateError('Missing participant allocation');
      }
      share += (owed * 100).round();
    }
    // The server supplies allocations for every split mode, including solo.
    // Empty allocations cannot be interpreted as either an equal share or zero.
    if (expense.participants.isEmpty && expense.amount != 0) {
      throw StateError('Missing expense allocations');
    }
    final total = (expense.amount * 100).round();
    return AnalyticsEntry(
      trip: trip,
      expense: expense,
      totalCents: total,
      shareCents: share,
      paidCents: expense.paidById == userId ? total : 0,
    );
  }
  final Trip trip;
  final TripExpense expense;
  final int totalCents;
  final int shareCents;
  final int paidCents;
  String? get month {
    final day = DateTime.tryParse(expense.expenseDate);
    return day == null
        ? null
        : '${day.year}-${day.month.toString().padLeft(2, '0')}';
  }
}

class AnalyticsReport {
  AnalyticsReport({
    required List<AnalyticsEntry> source,
    required this.currency,
    this.tripId,
    this.month,
    this.personal = true,
  }) : entries = List.unmodifiable(
         source.where(
           (e) =>
               e.trip.currencyCode == currency &&
               (tripId == null || e.trip.id == tripId) &&
               (month == null || e.month == month),
         ),
       );
  final String currency;
  final int? tripId;
  final String? month;
  final bool personal;
  final List<AnalyticsEntry> entries;
  int amount(AnalyticsEntry e) => personal ? e.shareCents : e.totalCents;
  int get totalCents => entries.fold(0, (sum, e) => sum + amount(e));
  int get paidCents => entries.fold(0, (sum, e) => sum + e.paidCents);
  int get expenseCount =>
      entries.where((e) => !personal || e.shareCents != 0).length;
  Map<String, int> get categories => _group((e) => e.expense.category);
  Map<String, int> get days =>
      _group((e) => e.expense.expenseDate.split(' ').first.split('T').first);
  Map<String, int> _group(String Function(AnalyticsEntry) key) {
    final result = <String, int>{};
    for (final entry in entries) {
      if (amount(entry) == 0) continue;
      result.update(
        key(entry),
        (n) => n + amount(entry),
        ifAbsent: () => amount(entry),
      );
    }
    return result;
  }
}
