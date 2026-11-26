import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/analytics/domain/analytics_report.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';

TripModel analyticsTrip({
  int id = 1,
  String currency = 'EUR',
  String status = 'active',
  String name = 'Lisbon getaway',
  String? dateFrom = '2026-10-05',
  String? dateTo = '2026-10-09',
}) => TripModel.fromLegacyMap({
  'id': id,
  'name': name,
  'currency_code': currency,
  'status': status,
  'members_count': 3,
  'date_from': dateFrom,
  'date_to': dateTo,
  // As the server sends it: share (owed) minus paid.
  'my_balance_cents': -4200,
  'my_paid_cents': 8400,
  'my_owed_cents': 4200,
});

class AnalyticsTestExpense {
  const AnalyticsTestExpense(
    this.id, {
    this.amount = 30,
    this.share = 10,
    this.payer = 2,
    this.date = '2026-10-05',
    this.category = 'food',
    this.note = 'Dinner',
    this.subcategory,
  });
  final int id, payer;
  final double amount, share;
  final String date, category, note;
  final String? subcategory;
}

/// Adds up test expenses the way `analytics_summary` does for user 1.
AnalyticsTripSummary analyticsSummary(
  int tripId,
  String currency,
  List<AnalyticsTestExpense> expenses,
) {
  int cents(double value) => (value * 100).round();
  final buckets = <String, AnalyticsTestExpense>{};
  final grouped = <String, List<AnalyticsTestExpense>>{};
  final paid = <int, int>{1: 0};
  for (final e in expenses) {
    final key = '${e.date}|${e.category}|${e.subcategory ?? ''}';
    buckets[key] = e;
    (grouped[key] ??= []).add(e);
    paid.update(
      e.payer,
      (v) => v + cents(e.amount),
      ifAbsent: () => cents(e.amount),
    );
  }
  List<AnalyticsLargestExpense> largest(int Function(AnalyticsTestExpense) of) {
    final rows = expenses.where((e) => of(e) > 0).toList()
      ..sort((a, b) => of(b).compareTo(of(a)));
    return [
      for (final e in rows.take(5))
        AnalyticsLargestExpense(
          id: e.id,
          category: e.category,
          note: e.note,
          amountCents: of(e),
        ),
    ];
  }

  final members = paid.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return AnalyticsTripSummary(
    tripId: tripId,
    currencyCode: currency,
    buckets: [
      for (final MapEntry(:key, value: rows) in grouped.entries)
        AnalyticsBucket(
          date: buckets[key]!.date,
          category: buckets[key]!.category,
          subcategory: buckets[key]!.subcategory,
          totalCents: rows.fold(0, (s, e) => s + cents(e.amount)),
          shareCents: rows.fold(0, (s, e) => s + cents(e.share)),
          paidCents: rows
              .where((e) => e.payer == 1)
              .fold(0, (s, e) => s + cents(e.amount)),
          expenseCount: rows.length,
          sharedExpenseCount: rows.where((e) => e.share != 0).length,
        ),
    ],
    members: [
      for (final member in members)
        AnalyticsMember(
          id: member.key,
          nickname: member.key == 1 ? 'Matiss Geinerts' : 'Anna Parker',
          paidCents: member.value,
        ),
    ],
    largestByTotal: largest((e) => cents(e.amount)),
    largestByShare: largest((e) => cents(e.share)),
  );
}

void main() {
  test('reads the documented response', () {
    final summary = AnalyticsTripSummary.fromMap({
      'trip_id': 10,
      'currency_code': 'EUR',
      'buckets': [
        {
          'date': '2026-03-02',
          'category': 'food',
          'total_cents': 20000,
          'share_cents': 10000,
          'paid_cents': 20000,
          'expense_count': 1,
          'shared_expense_count': 1,
        },
      ],
      'members': [
        {'id': 4, 'nickname': 'Anna', 'paid_cents': 20000},
      ],
      'largest_by_total': [
        {
          'id': 100,
          'category': 'food',
          'note': 'Dinner',
          'amount_cents': 20000,
        },
      ],
      'largest_by_share': <Object>[],
    });
    expect(summary.tripId, 10);
    expect(summary.buckets.single.month, '2026-03');
    expect(summary.members.single.paidCents, 20000);
    expect(summary.largestByTotal.single.note, 'Dinner');
    expect(summary.largestByShare, isEmpty);
    // Servers before expense types send no subcategory.
    expect(summary.buckets.single.subcategory, isNull);
  });

  test('types within a category: own types joined, no type last', () {
    final summary = AnalyticsTripSummary.fromMap({
      'trip_id': 10,
      'currency_code': 'EUR',
      'buckets': [
        for (final (date, category, type, share) in [
          ('2026-03-02', 'food', 'restaurant', 3000),
          ('2026-03-03', 'food', 'restaurant', 1000),
          ('2026-03-02', 'food', null, 500),
          ('2026-03-02', 'food', '  ', 200),
          ('2026-03-02', 'food', 'Street food', 1500),
          ('2026-03-03', 'food', 'street  FOOD', 1000),
          ('2026-03-02', 'transport', 'taxi', 900),
          ('2026-03-04', 'food', 'cafe', 0),
        ])
          {
            'date': date,
            'category': category,
            'subcategory': type,
            'total_cents': share * 2,
            'share_cents': share,
            'paid_cents': 0,
            'expense_count': 1,
            'shared_expense_count': share == 0 ? 0 : 1,
          },
      ],
      'members': <Object>[],
      'largest_by_total': <Object>[],
      'largest_by_share': <Object>[],
    });
    final report = AnalyticsReport(source: [summary], currency: 'EUR');
    expect(
      [for (final row in report.types('food')) (row.type, row.cents)],
      [('restaurant', 4000), ('Street food', 2500), (null, 700)],
    );
    expect(report.categories['food'], 7200);
    final total = AnalyticsReport(
      source: [summary],
      currency: 'EUR',
      tripId: 10,
      personal: false,
    );
    expect(total.types('transport').single.cents, 1800);
    expect(
      () => AnalyticsBucket.fromMap({
        'date': '2026-03-02',
        'category': 'food',
        'subcategory': 5,
        'total_cents': 1,
        'share_cents': 1,
        'paid_cents': 0,
        'expense_count': 1,
        'shared_expense_count': 1,
      }),
      throwsFormatException,
    );
  });

  test('a malformed response fails instead of showing zero', () {
    expect(
      () => AnalyticsTripSummary.fromMap({
        'trip_id': 10,
        'currency_code': 'EUR',
        'buckets': null,
        'members': <Object>[],
        'largest_by_total': <Object>[],
        'largest_by_share': <Object>[],
      }),
      throwsFormatException,
    );
    expect(
      () => AnalyticsBucket.fromMap({
        'date': '2026-03-02',
        'category': 'food',
        'total_cents': '20000',
        'share_cents': 0,
        'paid_cents': 0,
        'expense_count': 1,
        'shared_expense_count': 0,
      }),
      throwsFormatException,
    );
  });

  test('currency, month, trip and nonparticipant payer are distinct', () {
    final rows = [
      analyticsSummary(1, 'EUR', const [
        AnalyticsTestExpense(1, amount: 84, share: 20),
        AnalyticsTestExpense(4, share: 0, payer: 1),
      ]),
      analyticsSummary(2, 'EUR', const [
        AnalyticsTestExpense(2, share: 5, date: '2026-11-05'),
      ]),
      analyticsSummary(3, 'USD', const [AnalyticsTestExpense(3, share: 99)]),
    ];
    expect(AnalyticsReport(source: rows, currency: 'EUR').totalCents, 2500);
    final oct = AnalyticsReport(
      source: rows,
      currency: 'EUR',
      month: '2026-10',
    );
    expect(oct.totalCents, 2000);
    expect(oct.paidCents, 3000);
    expect(oct.expenseCount, 1);
    expect(oct.shareByTrip, {1: 2000});
    expect(
      AnalyticsReport(
        source: rows,
        currency: 'EUR',
        personal: false,
        tripId: 1,
      ).totalCents,
      11400,
    );
    expect(AnalyticsReport(source: rows, currency: 'USD').totalCents, 9900);
  });

  test('categories and days skip zero and combine rows', () {
    final report = AnalyticsReport(
      source: [
        analyticsSummary(1, 'EUR', const [
          AnalyticsTestExpense(1, share: 10),
          AnalyticsTestExpense(2, share: 5, category: 'transport'),
          AnalyticsTestExpense(3, share: 0, category: 'stay'),
        ]),
        analyticsSummary(2, 'EUR', const [AnalyticsTestExpense(4, share: 1)]),
      ],
      currency: 'EUR',
    );
    expect(report.categories, {'food': 1100, 'transport': 500});
    expect(report.days, {'2026-10-05': 1600});
    expect(report.shareByTrip, {1: 1500, 2: 100});
  });

  test('members and largest belong to the selected trip and view', () {
    final rows = [
      analyticsSummary(1, 'EUR', const [
        AnalyticsTestExpense(1, amount: 90, share: 1, note: 'Big total'),
        AnalyticsTestExpense(2, amount: 20, share: 20, note: 'Big share'),
      ]),
    ];
    final all = AnalyticsReport(source: rows, currency: 'EUR');
    expect(all.members, isEmpty);
    expect(all.largest, isEmpty);
    final share = AnalyticsReport(source: rows, currency: 'EUR', tripId: 1);
    expect(share.largest.first.note, 'Big share');
    final total = AnalyticsReport(
      source: rows,
      currency: 'EUR',
      tripId: 1,
      personal: false,
    );
    expect(total.largest.first.note, 'Big total');
    expect(total.members.first.nickname, 'Anna Parker');
    expect(
      AnalyticsReport(source: rows, currency: 'EUR', tripId: 9).largest,
      isEmpty,
    );
  });

  test('summaries are matched to the loaded trips', () {
    final summaries = [
      analyticsSummary(1, 'EUR', const []),
      analyticsSummary(9, 'EUR', const []),
    ];
    final matched = matchAnalyticsToTrips([analyticsTrip()], summaries);
    expect(matched.map((s) => s.tripId), [1]);
    expect(
      () => matchAnalyticsToTrips([analyticsTrip(currency: 'USD')], summaries),
      throwsStateError,
    );
  });

  test('own personal expenses are kept apart, for all time only', () {
    final withPersonal = AnalyticsTripSummary.fromMap({
      'trip_id': 1,
      'currency_code': 'EUR',
      'buckets': [],
      'members': [],
      'largest_by_total': [],
      'largest_by_share': [],
      'personal_cents': 1500,
    });
    final older = AnalyticsTripSummary.fromMap({
      'trip_id': 2,
      'currency_code': 'EUR',
      'buckets': [],
      'members': [],
      'largest_by_total': [],
      'largest_by_share': [],
    });
    expect(older.personalCents, 0);
    final all = AnalyticsReport(source: [withPersonal, older], currency: 'EUR');
    expect(all.personalCents, 1500);
    expect(all.totalCents, 0);
    expect(
      AnalyticsReport(
        source: [withPersonal],
        currency: 'EUR',
        month: '2026-10',
      ).personalCents,
      0,
    );
    expect(
      AnalyticsReport(source: [withPersonal], currency: 'USD').personalCents,
      0,
    );
  });
}
