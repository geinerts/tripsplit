import 'expense_participant.dart';

class TripExpense {
  const TripExpense({
    required this.id,
    required this.amount,
    required this.originalAmount,
    required this.tripCurrencyCode,
    required this.expenseCurrencyCode,
    required this.fxRateToTrip,
    required this.category,
    required this.note,
    required this.expenseDate,
    required this.splitMode,
    required this.paidById,
    required this.paidByNickname,
    required this.receiptUrl,
    this.receiptThumbUrl,
    required this.participants,
  });

  final int id;
  final double amount;
  final double originalAmount;
  final String tripCurrencyCode;
  final String expenseCurrencyCode;
  final double fxRateToTrip;
  final String category;
  final String note;
  final String expenseDate;
  final String splitMode;
  final int paidById;
  final String paidByNickname;
  final String? receiptUrl;
  final String? receiptThumbUrl;
  final List<ExpenseParticipant> participants;
}
