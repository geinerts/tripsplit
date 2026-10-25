import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/analytics/domain/analytics_report.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';
import 'package:tripsplit/features/workspace/domain/entities/expense_participant.dart';
import 'package:tripsplit/features/workspace/domain/entities/trip_expense.dart';
import 'package:tripsplit/features/workspace/domain/entities/trip_expenses_page.dart';

TripModel analyticsTrip({
  int id = 1,
  String currency = 'EUR',
  String status = 'active',
  String name = 'Lisbon getaway',
}) => TripModel.fromLegacyMap({
  'id': id,
  'name': name,
  'currency_code': currency,
  'status': status,
  'members_count': 3,
  'date_from': '2026-10-05',
  'date_to': '2026-10-09',
  'my_balance_cents': 4200,
  'my_paid_cents': 8400,
  'my_owed_cents': 4200,
});
TripExpense analyticsExpense(
  int id, {
  double amount = 30,
  double? share = 10,
  int payer = 2,
  String currency = 'EUR',
  String date = '2026-10-05',
  bool participant = true,
  String category = 'food',
  String note = 'Dinner',
}) => TripExpense(
  id: id,
  amount: amount,
  originalAmount: amount,
  tripCurrencyCode: currency,
  expenseCurrencyCode: currency,
  fxRateToTrip: 1,
  category: category,
  note: note,
  expenseDate: date,
  splitMode: 'exact',
  paidById: payer,
  paidByNickname: payer == 1 ? 'Matiss Geinerts' : 'Anna Parker',
  receiptUrl: null,
  participants: [
    ExpenseParticipant(
      id: participant ? 1 : 2,
      nickname: participant ? 'Matiss Geinerts' : 'Anna Parker',
      owedAmount: share,
    ),
  ],
);
TripExpensesPage page(
  List<TripExpense> items, {
  bool more = false,
  String? cursor,
  int? offset,
}) => TripExpensesPage(
  items: items,
  hasMore: more,
  nextCursor: cursor,
  nextOffset: offset,
);
void main() {
  test(
    'loads beyond 300, deduplicates page overlap and uses allocated share',
    () async {
      final calls = <String?>[];
      final rows = await loadAnalyticsEntries(
        trips: [analyticsTrip()],
        userId: 1,
        isCurrent: () => true,
        loadPage:
            ({
              required tripId,
              int limit = 300,
              String? cursor,
              int? offset,
            }) async {
              calls.add(cursor);
              return cursor == null
                  ? page(
                      List.generate(300, (i) => analyticsExpense(i + 1)),
                      more: true,
                      cursor: 'next',
                    )
                  : page([analyticsExpense(300), analyticsExpense(301)]);
            },
      );
      expect(calls, [null, 'next']);
      expect(rows.length, 301);
      final report = AnalyticsReport(source: rows, currency: 'EUR');
      expect(report.totalCents, 301000);
      expect(report.paidCents, 0);
      expect(report.categories['food'], 301000);
    },
  );
  test(
    'currency, month, archived trips and nonparticipant payer are distinct',
    () {
      final rows = [
        AnalyticsEntry.fromExpense(
          analyticsTrip(),
          analyticsExpense(1, amount: 84, share: 20),
          1,
        ),
        AnalyticsEntry.fromExpense(
          analyticsTrip(id: 2, status: 'archived'),
          analyticsExpense(2, share: 5, date: '2026-11-05'),
          1,
        ),
        AnalyticsEntry.fromExpense(
          analyticsTrip(id: 3, currency: 'USD'),
          analyticsExpense(3, currency: 'USD', share: 99),
          1,
        ),
        AnalyticsEntry.fromExpense(
          analyticsTrip(),
          analyticsExpense(4, participant: false, payer: 1),
          1,
        ),
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
    },
  );
  test('missing allocation cannot become a guessed equal share', () {
    expect(
      () => AnalyticsEntry.fromExpense(
        analyticsTrip(),
        analyticsExpense(1, share: null),
        1,
      ),
      throwsStateError,
    );
  });
  test(
    'nonadvancing pagination fails instead of returning partial totals',
    () async {
      await expectLater(
        loadAnalyticsEntries(
          trips: [analyticsTrip()],
          userId: 1,
          isCurrent: () => true,
          loadPage:
              ({
                required tripId,
                int limit = 300,
                String? cursor,
                int? offset,
              }) async =>
                  page([analyticsExpense(1)], more: true, cursor: 'repeat'),
        ),
        throwsStateError,
      );
    },
  );
  test('account cancellation stops paging before the next request', () async {
    var active = true;
    var calls = 0;
    await expectLater(
      loadAnalyticsEntries(
        trips: [analyticsTrip()],
        userId: 1,
        isCurrent: () => active,
        loadPage:
            ({
              required tripId,
              int limit = 300,
              String? cursor,
              int? offset,
            }) async {
              calls++;
              active = false;
              return page([analyticsExpense(1)], more: true, cursor: 'next');
            },
      ),
      throwsStateError,
    );
    expect(calls, 1);
  });
}
