/// Where a trip opens when it is opened for a reason, e.g. a tapped push.
class WorkspaceFocus {
  const WorkspaceFocus.settle()
    : kind = WorkspaceFocusKind.settle,
      expenseId = null;
  const WorkspaceFocus.expense(int this.expenseId)
    : kind = WorkspaceFocusKind.expense;
  const WorkspaceFocus.liveMap()
    : kind = WorkspaceFocusKind.liveMap,
      expenseId = null;

  final WorkspaceFocusKind kind;

  /// The expense whose details open, for [WorkspaceFocusKind.expense].
  final int? expenseId;

  @override
  bool operator ==(Object other) =>
      other is WorkspaceFocus &&
      other.kind == kind &&
      other.expenseId == expenseId;

  @override
  int get hashCode => Object.hash(kind, expenseId);
}

enum WorkspaceFocusKind { settle, expense, liveMap }
