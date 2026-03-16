import '../../domain/entities/expense_participant.dart';

class ExpenseShareLineMath {
  const ExpenseShareLineMath({
    required this.userId,
    required this.nickname,
    required this.paid,
    required this.owes,
    required this.isPayer,
  });

  final int userId;
  final String nickname;
  final double paid;
  final double owes;
  final bool isPayer;

  double get net => paid - owes;
}

class ExpenseTransferLineMath {
  const ExpenseTransferLineMath({
    required this.fromUserId,
    required this.fromNickname,
    required this.toUserId,
    required this.toNickname,
    required this.amount,
  });

  final int fromUserId;
  final String fromNickname;
  final int toUserId;
  final String toNickname;
  final double amount;
}

class ExpenseMath {
  const ExpenseMath._();

  static List<ExpenseShareLineMath> buildShareLines({
    required double amount,
    required int payerId,
    required String payerName,
    required List<ExpenseParticipant> participants,
    required String Function(int userId) fallbackUserName,
  }) {
    if (participants.isEmpty) {
      if (payerId <= 0) {
        return const <ExpenseShareLineMath>[];
      }
      return <ExpenseShareLineMath>[
        ExpenseShareLineMath(
          userId: payerId,
          nickname: payerName,
          paid: amount,
          owes: 0,
          isPayer: true,
        ),
      ];
    }

    final totalCents = (amount * 100).round();
    final participantIds = participants
        .map((item) => item.id)
        .where((id) => id > 0)
        .toSet();
    final hasStoredOwed = participants.every((item) => item.owedAmount != null);
    final storedOwedCents = <int, int>{};
    if (hasStoredOwed) {
      for (final participant in participants) {
        storedOwedCents[participant.id] = ((participant.owedAmount ?? 0) * 100)
            .round();
      }
      final sumStored = storedOwedCents.values.fold<int>(
        0,
        (sum, value) => sum + value,
      );
      if (sumStored != totalCents && participants.isNotEmpty) {
        final adjustUserId = participantIds.contains(payerId)
            ? payerId
            : participants.first.id;
        storedOwedCents[adjustUserId] =
            (storedOwedCents[adjustUserId] ?? 0) + (totalCents - sumStored);
      }
    }

    final lines = <ExpenseShareLineMath>[];
    for (var i = 0; i < participants.length; i++) {
      final participant = participants[i];
      final owesCents = hasStoredOwed
          ? (storedOwedCents[participant.id] ?? 0)
          : (() {
              final splitCount = participants.length;
              final baseShareCents = totalCents ~/ splitCount;
              final remainderCents = totalCents % splitCount;
              return baseShareCents + (i < remainderCents ? 1 : 0);
            })();
      final isPayer = participant.id == payerId;
      final paidCents = isPayer ? totalCents : 0;
      lines.add(
        ExpenseShareLineMath(
          userId: participant.id,
          nickname: participant.nickname.trim().isEmpty
              ? fallbackUserName(participant.id)
              : participant.nickname,
          paid: paidCents / 100,
          owes: owesCents / 100,
          isPayer: isPayer,
        ),
      );
    }

    if (payerId > 0 && !participantIds.contains(payerId)) {
      lines.insert(
        0,
        ExpenseShareLineMath(
          userId: payerId,
          nickname: payerName,
          paid: totalCents / 100,
          owes: 0,
          isPayer: true,
        ),
      );
    }

    return lines;
  }

  static List<ExpenseTransferLineMath> buildTransfers({
    required List<ExpenseShareLineMath> lines,
    required int payerId,
    required String payerName,
  }) {
    if (payerId <= 0) {
      return const <ExpenseTransferLineMath>[];
    }

    return lines
        .where((line) => line.userId != payerId && line.owes > 0.0001)
        .map(
          (line) => ExpenseTransferLineMath(
            fromUserId: line.userId,
            fromNickname: line.nickname,
            toUserId: payerId,
            toNickname: payerName,
            amount: line.owes,
          ),
        )
        .toList(growable: false);
  }
}
