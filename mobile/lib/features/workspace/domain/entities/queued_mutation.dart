enum QueuedMutationType { addExpense, updateExpense, deleteExpense, unknown }

class QueuedMutation {
  const QueuedMutation({
    required this.id,
    required this.tripId,
    required this.createdAtMillis,
    required this.type,
    this.amount,
    this.note,
    this.expenseId,
    this.date,
  });

  final String id;
  final int tripId;
  final int createdAtMillis;
  final QueuedMutationType type;
  final double? amount;
  final String? note;
  final int? expenseId;
  final String? date;
}
