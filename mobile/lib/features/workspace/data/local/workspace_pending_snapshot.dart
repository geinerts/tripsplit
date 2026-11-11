import '../../domain/entities/expense_item.dart';
import '../../domain/entities/expense_participant.dart';
import '../../domain/entities/trip_expense.dart';
import '../../domain/entities/workspace_snapshot.dart';
import '../../domain/queued_expense_math.dart';

/// Overlays pending mutations without modifying the last confirmed server copy.
WorkspaceSnapshot withPendingExpenses(
  WorkspaceSnapshot snapshot,
  List<Map<String, dynamic>> queue, {
  required int tripId,
  required int currentUserId,
}) {
  final expenses = [...snapshot.expenses];
  final users = {for (final user in snapshot.users) user.id: user};
  for (var index = 0; index < queue.length; index++) {
    final entry = queue[index];
    if (entry['trip_id'] != tripId) continue;
    final payload = entry['payload'];
    if (payload is! Map<String, dynamic>) continue;
    final type = entry['type'];
    final expenseId = (payload['expense_id'] as num?)?.toInt();
    if (type == 'delete_expense') {
      expenses.removeWhere((expense) => expense.id == expenseId);
      continue;
    }
    if (type != 'add_expense' && type != 'update_expense') continue;
    final existingIndex = expenses.indexWhere(
      (expense) => expense.id == expenseId,
    );
    if (type == 'update_expense' && existingIndex < 0) continue;
    final previous = existingIndex < 0 ? null : expenses[existingIndex];
    final amount = (payload['amount'] as num?)?.toDouble() ?? 0;
    final currency = payload['currency_code'] as String? ?? 'EUR';
    final ids = (payload['participants'] as List<dynamic>? ?? [])
        .whereType<num>()
        .map((id) => id.toInt())
        .toList();
    final participants = ids.isEmpty ? users.keys.toList() : ids;
    final splitValues = <int, double>{
      for (final split
          in (payload['splits'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>())
        (split['user_id'] as num).toInt(): (split['value'] as num).toDouble(),
    };
    final splitMode = payload['split_mode'] as String? ?? 'equal';
    final items = ExpenseItem.listFromJson(payload['items']);
    final extra = (payload['extra_amount'] as num?)?.toDouble() ?? 0;
    final owed = queuedExpenseOwedByUser(
      amount: amount,
      participantIds: participants,
      splitMode: splitMode,
      splitValuesByUser: splitValues,
      items: items,
      extraAmount: extra,
    );
    final payer =
        (payload['paid_by'] as num?)?.toInt() ??
        previous?.paidById ??
        currentUserId;
    final note = (payload['note'] as String? ?? '').trim();
    final expense = TripExpense(
      id:
          previous?.id ??
          -((entry['created_at'] as num?)?.toInt() ?? 1) * 1000 - index,
      amount: amount,
      originalAmount: amount,
      tripCurrencyCode:
          previous?.tripCurrencyCode ??
          (snapshot.expenses.isEmpty
              ? currency
              : snapshot.expenses.first.tripCurrencyCode),
      expenseCurrencyCode: currency,
      fxRateToTrip: 1,
      category: payload['category'] as String? ?? 'other',
      note: note.contains('[queued]') ? note : '$note [queued]'.trim(),
      expenseDate: payload['date'] as String? ?? '',
      splitMode: splitMode,
      paidById: payer,
      paidByNickname:
          users[payer]?.preferredName ?? previous?.paidByNickname ?? '',
      receiptUrl: payload['remove_receipt'] == true
          ? null
          : previous?.receiptUrl,
      receiptThumbUrl: payload['remove_receipt'] == true
          ? null
          : previous?.receiptThumbUrl,
      participants: [
        for (final id in participants)
          ExpenseParticipant(
            id: id,
            nickname: users[id]?.preferredName ?? '',
            owedAmount: owed[id],
            splitValue: splitValues[id],
          ),
      ],
      items: items,
      extraAmount: extra,
    );
    if (previous == null) {
      expenses.insert(0, expense);
    } else {
      expenses[existingIndex] = expense;
    }
  }
  return snapshot.copyWith(expenses: expenses);
}
