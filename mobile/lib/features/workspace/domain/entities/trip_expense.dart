import 'expense_item.dart';
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
    this.items = const [],
    this.extraAmount = 0,
    this.subcategory,
    this.fromQuickSplit = false,
    this.isPersonal = false,
    this.isLocked = false,
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
  final List<ExpenseItem> items;
  final double extraAmount;

  /// Optional type within the category: a built-in key (`restaurant`) or a
  /// member's own text. Null when there is none or the server is older.
  final String? subcategory;

  /// Added to the trip from a quick split; shown with ⚡.
  final bool fromQuickSplit;

  /// One person's own spending: out of the trip total and the debts.
  final bool isPersonal;

  /// Someone else's personal expense. The server sends only its amount, date
  /// and payer, and it can't be opened.
  final bool isLocked;
}
