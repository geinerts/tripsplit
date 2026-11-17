import '../../../trips/domain/entities/trip.dart';
import 'expense_item.dart';
import 'uploaded_receipt.dart';

/// Values carried into a new expense form: when switching between a trip and
/// Quick split, or when a quick split is added to a trip. People are account
/// ids; anyone who isn't in the trip is left out there.
class ExpenseDraft {
  const ExpenseDraft({
    this.amount,
    this.currencyCode,
    this.note = '',
    this.category = '',
    this.subcategory,
    this.date,
    this.receipt,
    this.payerUserId,
    this.participantUserIds = const [],
    this.splitMode = 'equal',
    this.splitValues = const {},
    this.items = const [],
    this.extraAmount = 0,
    this.quickSplitId,
  });

  final double? amount;
  final String? currencyCode;
  final String note;
  final String category;
  final String? subcategory;

  /// `YYYY-MM-DD`.
  final String? date;
  final UploadedReceiptData? receipt;
  final int? payerUserId;
  final List<int> participantUserIds;
  final String splitMode;
  final Map<int, double?> splitValues;
  final List<ExpenseItem> items;
  final double extraAmount;

  /// Set when this draft adds a quick split to a trip.
  final int? quickSplitId;

  bool get hasPeople => participantUserIds.isNotEmpty || items.isNotEmpty;

  /// The same values without people, for a form with other people.
  ExpenseDraft withoutPeople() => ExpenseDraft(
    amount: amount,
    currencyCode: currencyCode,
    note: note,
    category: category,
    subcategory: subcategory,
    date: date,
    receipt: receipt,
  );
}

/// Where a new expense goes: a trip, or Quick split when [trip] is null.
class ExpenseTarget {
  const ExpenseTarget.quickSplit() : trip = null;
  const ExpenseTarget.trip(Trip this.trip);

  final Trip? trip;

  bool get isQuickSplit => trip == null;
}
