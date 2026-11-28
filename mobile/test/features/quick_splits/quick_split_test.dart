import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/features/quick_splits/data/quick_splits_repository.dart';
import 'package:tripsplit/features/quick_splits/domain/quick_split.dart';
import 'package:tripsplit/features/quick_splits/presentation/quick_splits_controller.dart';

QuickSplit _split(int id, String date) => QuickSplit(
  id: id,
  note: 'Bill $id',
  category: 'food',
  date: date,
  amount: 10,
  currencyCode: 'EUR',
  peopleCount: 2,
  myAmount: 5,
  paidByMe: true,
  paidByName: 'Matiss',
  canEdit: true,
);

class _Repository implements QuickSplitsRepository {
  final pages = <String?, QuickSplitPage>{};
  ApiException? failure;
  final moved = <List<int>>[];

  @override
  Future<QuickSplitPage> list({String? cursor, int limit = 30}) async {
    if (failure != null) throw failure!;
    return pages[cursor]!;
  }

  @override
  Future<QuickSplit> add(QuickSplitInput input) async => _split(9, input.date);

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> moveToTrip({
    required int id,
    required int tripId,
    required int expenseId,
  }) async => moved.add([id, tripId, expenseId]);

  @override
  Future<QuickSplit> get(int id) async => _split(id, '2026-11-01');

  @override
  Future<QuickSplit> update(int id, QuickSplitInput input) async =>
      _split(id, input.date);
}

void main() {
  test('full quick split parses people, items and split values', () {
    final split = QuickSplit.fromJson({
      'id': 31,
      'note': 'Dinner at Lido',
      'category': 'food',
      'subcategory': 'Restaurant',
      'date': '2026-11-16',
      'amount': 20,
      'currency_code': 'EUR',
      'people_count': 3,
      'my_amount': 7.06,
      'paid_by_me': false,
      'paid_by_name': 'Andris',
      'people_preview': [
        {'name': 'Anna', 'avatar_thumb_url': null},
      ],
      'has_receipt': true,
      'can_edit': true,
      'split_mode': 'itemized',
      'created_by': 7,
      'people': [
        {
          'id': 4,
          'user_id': 7,
          'name': 'Matiss',
          'is_me': true,
          'amount': 7.06,
          'split_value': 7.06,
        },
        {
          'id': 6,
          'user_id': null,
          'name': 'Andris',
          'is_payer': true,
          'amount': 0,
          'split_value': null,
        },
      ],
      'items': [
        {
          'name': 'Pizza',
          'amount': 12,
          'person_ids': [4, 6],
        },
      ],
      'extra_amount': 3,
      'receipt_path': 'receipts/r.webp',
      'receipt_url': 'https://example.invalid/r',
      'added_to_trip': {'trip_id': 7, 'expense_id': 950},
    });
    expect(split.isFull, isTrue);
    expect(split.payer?.name, 'Andris');
    expect(split.payer?.isAccount, isFalse);
    expect(split.people.first.splitValue, 7.06);
    expect(split.people.last.splitValue, isNull);
    expect(split.items.single.personIds, [4, 6]);
    expect(split.extraAmount, 3);
    expect(split.addedToTripId, 7);
    expect(split.peoplePreview.single.name, 'Anna');
  });

  test('request uses person keys for payer, splits and items', () {
    const input = QuickSplitInput(
      amount: 90,
      currencyCode: 'EUR',
      note: 'Dinner',
      category: 'food',
      date: '2026-11-16',
      people: [
        QuickSplitPersonInput(key: 'p7', userId: 7),
        QuickSplitPersonInput(key: 'p2000000001', name: 'Andris'),
      ],
      paidByKey: 'p7',
      splitMode: 'exact',
      participantKeys: ['p7', 'p2000000001'],
      splitValues: {'p7': 50, 'p2000000001': 40},
      clientMutationId: 'qs_1',
    );
    expect(input.toJson(), {
      'amount': 90.0,
      'currency_code': 'EUR',
      'note': 'Dinner',
      'category': 'food',
      'subcategory': null,
      'date': '2026-11-16',
      'people': [
        {'key': 'p7', 'user_id': 7},
        {'key': 'p2000000001', 'name': 'Andris'},
      ],
      'paid_by': 'p7',
      'split_mode': 'exact',
      'participants': ['p7', 'p2000000001'],
      'splits': [
        {'person': 'p7', 'value': 50.0},
        {'person': 'p2000000001', 'value': 40.0},
      ],
      'client_mutation_id': 'qs_1',
    });
    const itemized = QuickSplitInput(
      amount: 20,
      currencyCode: 'EUR',
      note: '',
      category: 'food',
      date: '2026-11-16',
      people: [],
      paidByKey: 'p7',
      splitMode: 'itemized',
      participantKeys: ['p7'],
      items: [
        QuickSplitItemInput(name: 'Pizza', amount: 17, peopleKeys: ['p7']),
      ],
      extraAmount: 3,
    );
    final json = itemized.toJson();
    expect(json.containsKey('participants'), isFalse);
    expect(json['items'], [
      {
        'name': 'Pizza',
        'amount': 17.0,
        'people': ['p7'],
      },
    ]);
    expect(json['extra_amount'], 3.0);
  });

  test('controller keeps newest first, pages, and forgets on clear', () async {
    final repository = _Repository()
      ..pages[null] = QuickSplitPage(
        items: [_split(3, '2026-11-17'), _split(1, '2026-11-10')],
        nextCursor: 'next',
      )
      ..pages['next'] = QuickSplitPage(items: [_split(0, '2026-11-01')]);
    final controller = QuickSplitsController(repository);
    await controller.load();
    expect(controller.items.map((s) => s.id), [3, 1]);
    expect(controller.hasMore, isTrue);
    await controller.load(more: true);
    expect(controller.items.map((s) => s.id), [3, 1, 0]);
    expect(controller.hasMore, isFalse);

    const input = QuickSplitInput(
      amount: 10,
      currencyCode: 'EUR',
      note: '',
      category: 'food',
      date: '2026-11-12',
      people: [],
      paidByKey: 'p7',
      splitMode: 'equal',
    );
    await controller.add(input);
    expect(controller.items.map((s) => s.id), [3, 9, 1, 0]);
    await controller.moveToTrip(id: 9, tripId: 7, expenseId: 950);
    expect(repository.moved, [
      [9, 7, 950],
    ]);
    expect(controller.items.map((s) => s.id), [3, 1, 0]);
    await controller.delete(3);
    expect(controller.items.map((s) => s.id), [1, 0]);

    controller.clear();
    expect(controller.items, isEmpty);
    expect(controller.hasLoaded, isFalse);

    repository.failure = const ApiException('offline', isNetworkError: true);
    await controller.load();
    expect(controller.hasFailed, isTrue);
    expect(controller.isOffline, isTrue);
  });

  group('fitsTrip', () {
    QuickSplit split({
      bool paidByMe = true,
      bool canEdit = true,
      List<Map<String, dynamic>>? people,
    }) => QuickSplit.fromJson({
      'id': 40,
      'note': 'Lunch',
      'category': 'food',
      'date': '2026-11-20',
      'amount': 30,
      'currency_code': 'EUR',
      'can_edit': canEdit,
      'people':
          people ??
          [
            {
              'id': 1,
              'user_id': 7,
              'name': 'Me',
              'is_me': true,
              'is_payer': paidByMe,
              'amount': 10,
            },
            {
              'id': 2,
              'user_id': 8,
              'name': 'Anna',
              'is_payer': !paidByMe,
              'amount': 10,
            },
            {'id': 3, 'user_id': 9, 'name': 'Ben', 'amount': 10},
          ],
    });

    test('a trip with all of its people and more fits', () {
      expect(split().fitsTrip({7, 8, 9, 10, 11}), isTrue);
    });

    test('someone missing from the trip does not fit', () {
      expect(split().fitsTrip({7, 8}), isFalse);
    });

    test('someone without an account never fits', () {
      final withName = split(
        people: [
          {
            'id': 1,
            'user_id': 7,
            'name': 'Me',
            'is_me': true,
            'is_payer': true,
            'amount': 15,
          },
          {'id': 2, 'name': 'Mum', 'amount': 15},
        ],
      );
      expect(withName.fitsTrip({7, 8, 9}), isFalse);
    });

    test('the reason names who is in the way', () {
      expect(split().tripProblem({7, 8, 9}), isNull);
      final one = split().tripProblem({7, 8})!;
      expect(one.problem, QuickSplitTripProblem.notMembers);
      expect((one.name, one.others), ('Ben', 0));
      final two = split().tripProblem({7})!;
      expect((two.name, two.others), ('Anna', 1));
      final noAccount = split(
        people: [
          {
            'id': 1,
            'user_id': 7,
            'name': 'Me',
            'is_me': true,
            'is_payer': true,
            'amount': 15,
          },
          {'id': 2, 'name': 'Mum', 'amount': 15},
        ],
      ).tripProblem({7})!;
      expect(noAccount.problem, QuickSplitTripProblem.noAccount);
      expect(noAccount.name, 'Mum');
      final alone = split(
        people: [
          {
            'id': 1,
            'user_id': 7,
            'name': 'Me',
            'is_me': true,
            'is_payer': true,
            'amount': 15,
          },
        ],
      ).tripProblem({7})!;
      expect(alone.problem, QuickSplitTripProblem.onlyYou);
      expect(
        split(paidByMe: false).tripProblem({7, 8, 9})!.problem,
        QuickSplitTripProblem.other,
      );
    });

    test('only the creator who paid can add it', () {
      expect(split(paidByMe: false).fitsTrip({7, 8, 9}), isFalse);
      expect(split(canEdit: false).fitsTrip({7, 8, 9}), isFalse);
    });
  });
}
