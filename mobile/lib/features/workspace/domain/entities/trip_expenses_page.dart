import 'trip_expense.dart';

class TripExpensesPage {
  const TripExpensesPage({
    required this.items,
    required this.hasMore,
    required this.nextCursor,
    required this.nextOffset,
  });

  final List<TripExpense> items;
  final bool hasMore;
  final String? nextCursor;
  final int? nextOffset;
}

