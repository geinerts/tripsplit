import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/workspace/domain/entities/expense_participant.dart';
import 'package:tripsplit/features/workspace/presentation/utils/expense_math.dart';

void main() {
  group('ExpenseMath.buildShareLines', () {
    test('equal split keeps cents balanced and payer net is correct', () {
      final lines = ExpenseMath.buildShareLines(
        amount: 10,
        payerId: 1,
        payerName: 'Alice',
        participants: const <ExpenseParticipant>[
          ExpenseParticipant(id: 1, nickname: 'Alice'),
          ExpenseParticipant(id: 2, nickname: 'Bob'),
          ExpenseParticipant(id: 3, nickname: 'Carol'),
        ],
        fallbackUserName: (id) => 'User$id',
      );

      expect(lines, hasLength(3));
      final payer = lines.firstWhere((line) => line.userId == 1);
      final bob = lines.firstWhere((line) => line.userId == 2);
      final carol = lines.firstWhere((line) => line.userId == 3);

      expect(payer.paid, closeTo(10.0, 0.000001));
      expect(payer.owes, closeTo(3.34, 0.000001));
      expect(payer.net, closeTo(6.66, 0.000001));
      expect(bob.owes, closeTo(3.33, 0.000001));
      expect(carol.owes, closeTo(3.33, 0.000001));

      final owedTotal = lines.fold<double>(0, (sum, line) => sum + line.owes);
      final paidTotal = lines.fold<double>(0, (sum, line) => sum + line.paid);
      expect(owedTotal, closeTo(10.0, 0.000001));
      expect(paidTotal, closeTo(10.0, 0.000001));
    });

    test('exact split with legacy mismatch is adjusted to payer', () {
      final lines = ExpenseMath.buildShareLines(
        amount: 5,
        payerId: 1,
        payerName: 'Alice',
        participants: const <ExpenseParticipant>[
          ExpenseParticipant(id: 1, nickname: 'Alice', owedAmount: 2),
          ExpenseParticipant(id: 2, nickname: 'Bob', owedAmount: 2),
        ],
        fallbackUserName: (id) => 'User$id',
      );

      expect(lines, hasLength(2));
      final payer = lines.firstWhere((line) => line.userId == 1);
      final bob = lines.firstWhere((line) => line.userId == 2);

      expect(payer.owes, closeTo(3.0, 0.000001));
      expect(bob.owes, closeTo(2.0, 0.000001));
      expect(payer.net, closeTo(2.0, 0.000001));

      final owedTotal = lines.fold<double>(0, (sum, line) => sum + line.owes);
      expect(owedTotal, closeTo(5.0, 0.000001));
    });

    test('payer is inserted when not present in participants', () {
      final lines = ExpenseMath.buildShareLines(
        amount: 4,
        payerId: 1,
        payerName: 'Alice',
        participants: const <ExpenseParticipant>[
          ExpenseParticipant(id: 2, nickname: 'Bob'),
          ExpenseParticipant(id: 3, nickname: 'Carol'),
        ],
        fallbackUserName: (id) => 'User$id',
      );

      expect(lines, hasLength(3));
      final payer = lines.firstWhere((line) => line.userId == 1);
      expect(payer.isPayer, isTrue);
      expect(payer.paid, closeTo(4.0, 0.000001));
      expect(payer.owes, closeTo(0.0, 0.000001));
    });

    test('returns empty lines when payer invalid and no participants', () {
      final lines = ExpenseMath.buildShareLines(
        amount: 12.5,
        payerId: 0,
        payerName: 'N/A',
        participants: const <ExpenseParticipant>[],
        fallbackUserName: (id) => 'User$id',
      );
      expect(lines, isEmpty);
    });
  });

  group('ExpenseMath.buildTransfers', () {
    test('builds transfers from debtors to payer', () {
      final lines = ExpenseMath.buildShareLines(
        amount: 4,
        payerId: 1,
        payerName: 'Alice',
        participants: const <ExpenseParticipant>[
          ExpenseParticipant(id: 2, nickname: 'Bob'),
          ExpenseParticipant(id: 3, nickname: 'Carol'),
        ],
        fallbackUserName: (id) => 'User$id',
      );
      final transfers = ExpenseMath.buildTransfers(
        lines: lines,
        payerId: 1,
        payerName: 'Alice',
      );

      expect(transfers, hasLength(2));
      expect(
        transfers.map((item) => item.fromUserId).toSet(),
        equals(<int>{2, 3}),
      );
      expect(
        transfers.every(
          (item) =>
              item.toUserId == 1 &&
              item.toNickname == 'Alice' &&
              item.amount == 2,
        ),
        isTrue,
      );
    });
  });
}
