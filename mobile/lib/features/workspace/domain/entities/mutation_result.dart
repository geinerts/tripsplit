class MutationResult {
  const MutationResult({required this.queued, this.expenseId});

  final bool queued;

  /// The new expense, when `add_expense` reached the server.
  final int? expenseId;
}
