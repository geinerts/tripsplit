import '../../trips/domain/entities/trip.dart';

int _intValue(Object? value) {
  if (value is num && value.isFinite) return value.toInt();
  throw const FormatException('Invalid analytics number');
}

String _textValue(Object? value) {
  if (value is String) return value;
  throw const FormatException('Invalid analytics text');
}

List<T> _listValue<T>(Object? value, T Function(Map<String, dynamic>) parse) {
  if (value is! List) throw const FormatException('Invalid analytics list');
  return List.unmodifiable(
    value.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid analytics row');
      }
      return parse(item);
    }),
  );
}

class AnalyticsBucket {
  const AnalyticsBucket({
    required this.date,
    required this.category,
    required this.totalCents,
    required this.shareCents,
    required this.paidCents,
    required this.expenseCount,
    required this.sharedExpenseCount,
  });
  factory AnalyticsBucket.fromMap(Map<String, dynamic> map) => AnalyticsBucket(
    date: _textValue(map['date']),
    category: _textValue(map['category']),
    totalCents: _intValue(map['total_cents']),
    shareCents: _intValue(map['share_cents']),
    paidCents: _intValue(map['paid_cents']),
    expenseCount: _intValue(map['expense_count']),
    sharedExpenseCount: _intValue(map['shared_expense_count']),
  );
  final String date, category;
  final int totalCents, shareCents, paidCents, expenseCount, sharedExpenseCount;
  String? get month {
    final day = DateTime.tryParse(date);
    return day == null
        ? null
        : '${day.year}-${day.month.toString().padLeft(2, '0')}';
  }
}

class AnalyticsMember {
  const AnalyticsMember({
    required this.id,
    required this.nickname,
    required this.paidCents,
  });
  factory AnalyticsMember.fromMap(Map<String, dynamic> map) => AnalyticsMember(
    id: _intValue(map['id']),
    nickname: _textValue(map['nickname']),
    paidCents: _intValue(map['paid_cents']),
  );
  final int id, paidCents;
  final String nickname;
}

class AnalyticsLargestExpense {
  const AnalyticsLargestExpense({
    required this.id,
    required this.category,
    required this.note,
    required this.amountCents,
  });
  factory AnalyticsLargestExpense.fromMap(Map<String, dynamic> map) =>
      AnalyticsLargestExpense(
        id: _intValue(map['id']),
        category: _textValue(map['category']),
        note: _textValue(map['note']),
        amountCents: _intValue(map['amount_cents']),
      );
  final int id, amountCents;
  final String category, note;
}

class AnalyticsTripSummary {
  const AnalyticsTripSummary({
    required this.tripId,
    required this.currencyCode,
    this.buckets = const [],
    this.members = const [],
    this.largestByTotal = const [],
    this.largestByShare = const [],
  });
  factory AnalyticsTripSummary.fromMap(Map<String, dynamic> map) =>
      AnalyticsTripSummary(
        tripId: _intValue(map['trip_id']),
        currencyCode: _textValue(map['currency_code']),
        buckets: _listValue(map['buckets'], AnalyticsBucket.fromMap),
        members: _listValue(map['members'], AnalyticsMember.fromMap),
        largestByTotal: _listValue(
          map['largest_by_total'],
          AnalyticsLargestExpense.fromMap,
        ),
        largestByShare: _listValue(
          map['largest_by_share'],
          AnalyticsLargestExpense.fromMap,
        ),
      );
  final int tripId;
  final String currencyCode;
  final List<AnalyticsBucket> buckets;
  final List<AnalyticsMember> members;
  final List<AnalyticsLargestExpense> largestByTotal, largestByShare;
}

/// Keeps summaries for [trips] only. A currency that differs means the two
/// responses no longer describe the same trip, so no totals are shown.
List<AnalyticsTripSummary> matchAnalyticsToTrips(
  List<Trip> trips,
  List<AnalyticsTripSummary> summaries,
) {
  final currencies = {for (final trip in trips) trip.id: trip.currencyCode};
  final known = summaries.where((s) => currencies.containsKey(s.tripId));
  for (final summary in known) {
    if (currencies[summary.tripId] != summary.currencyCode) {
      throw StateError('Analytics currency does not match the trip');
    }
  }
  return List.unmodifiable(known);
}

class AnalyticsReport {
  AnalyticsReport({
    required List<AnalyticsTripSummary> source,
    required this.currency,
    this.tripId,
    this.month,
    this.personal = true,
  }) : _trips = source
           .where(
             (s) =>
                 s.currencyCode == currency &&
                 (tripId == null || s.tripId == tripId),
           )
           .toList(growable: false);
  final String currency;
  final int? tripId;
  final String? month;
  final bool personal;
  final List<AnalyticsTripSummary> _trips;
  Iterable<AnalyticsBucket> _rows(AnalyticsTripSummary trip) =>
      trip.buckets.where((b) => month == null || b.month == month);
  Iterable<AnalyticsBucket> get _allRows => _trips.expand(_rows);
  int _amount(AnalyticsBucket b) => personal ? b.shareCents : b.totalCents;
  int get totalCents => _allRows.fold(0, (sum, b) => sum + _amount(b));
  int get paidCents => _allRows.fold(0, (sum, b) => sum + b.paidCents);
  int get expenseCount => _allRows.fold(
    0,
    (sum, b) => sum + (personal ? b.sharedExpenseCount : b.expenseCount),
  );
  Map<String, int> get categories => _group((b) => b.category);
  Map<String, int> get days => _group((b) => b.date);

  /// Own share per trip, for every trip with an expense in this period.
  Map<int, int> get shareByTrip => {
    for (final trip in _trips)
      if (_rows(trip).isNotEmpty)
        trip.tripId: _rows(trip).fold(0, (sum, b) => sum + b.shareCents),
  };
  List<AnalyticsMember> get members =>
      tripId == null ? const [] : _trips.firstOrNull?.members ?? const [];
  List<AnalyticsLargestExpense> get largest {
    if (tripId == null) return const [];
    final trip = _trips.firstOrNull;
    if (trip == null) return const [];
    return personal ? trip.largestByShare : trip.largestByTotal;
  }

  Map<String, int> _group(String Function(AnalyticsBucket) key) {
    final result = <String, int>{};
    for (final bucket in _allRows) {
      if (_amount(bucket) == 0) continue;
      result.update(
        key(bucket),
        (n) => n + _amount(bucket),
        ifAbsent: () => _amount(bucket),
      );
    }
    return result;
  }
}
