import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/workspace/domain/entities/expense_item.dart';
import 'package:tripsplit/features/workspace/domain/services/expense_split_math.dart';

void main() {
  group('adjustments', () {
    test('share what remains equally', () {
      expect(adjustmentOwedCents(10000, [1, 2, 3], {1: 1000}), {
        1: 4000,
        2: 3000,
        3: 3000,
      });
    });

    test('a discount moves cost to the others', () {
      expect(adjustmentOwedCents(10000, [1, 2, 3], {1: -1000, 3: 500}), {
        1: 2500,
        2: 3500,
        3: 4000,
      });
    });

    test('leftover cents go to the first people', () {
      expect(adjustmentOwedCents(1000, [1, 2, 3], const {}), {
        1: 334,
        2: 333,
        3: 333,
      });
    });

    test('what does not fit is refused', () {
      expect(adjustmentOwedCents(1000, [1, 2], {1: 1500}), isNull);
      expect(adjustmentOwedCents(1000, [1, 2], {1: -2000}), isNull);
      expect(adjustmentOwedCents(1000, const [], const {}), isNull);
    });
  });

  group('items', () {
    const items = [
      ExpenseItem(name: 'Pizza', amount: 12, participantIds: [1, 2]),
      ExpenseItem(name: 'Beer', amount: 5, participantIds: [2]),
    ];

    test('are shared among their people', () {
      expect(itemizedOwedCents(items, 0), {1: 600, 2: 1100});
    });

    test('the extra follows what each person had', () {
      expect(itemizedOwedCents(items, 300), {1: 706, 2: 1294});
    });

    test('totals stay exact with awkward numbers', () {
      for (final extra in [1, 7, 100, 333, 9999]) {
        final owed = itemizedOwedCents(const [
          ExpenseItem(name: 'A', amount: 10.01, participantIds: [1, 2, 3]),
          ExpenseItem(name: 'B', amount: 0.07, participantIds: [3, 4]),
        ], extra);
        expect(owed.values.reduce((a, b) => a + b), 1008 + extra);
      }
    });

    test('survive the offline queue and the local cache', () {
      final decoded = ExpenseItem.listFromJson(
        jsonDecode(jsonEncode(items.map((item) => item.toJson()).toList())),
      );
      expect(decoded.map((item) => item.name), ['Pizza', 'Beer']);
      expect(decoded.last.amount, 5);
      expect(decoded.first.participantIds, [1, 2]);
      expect(ExpenseItem.listFromJson(null), isEmpty);
    });
  });
}
