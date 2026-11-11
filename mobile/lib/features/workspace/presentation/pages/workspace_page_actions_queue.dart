part of 'workspace_page.dart';

extension _WorkspacePageQueueActions on _WorkspacePageState {
  void _applyQueuedAdd({
    required _ExpenseFormResult form,
    required UploadedReceiptData? uploadedReceipt,
  }) {
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }

    final usersById = <int, WorkspaceUser>{
      for (final user in snapshot.users) user.id: user,
    };
    final participantIds = form.participants.isNotEmpty
        ? form.participants
        : snapshot.users.map((user) => user.id).toList(growable: false);
    final splitValuesByUser = <int, double>{
      for (final item in form.splitValues) item.userId: item.value,
    };
    final owedByUser = queuedExpenseOwedByUser(
      amount: form.amount,
      participantIds: participantIds,
      splitMode: form.splitMode,
      splitValuesByUser: splitValuesByUser,
      items: form.items,
      extraAmount: form.extraAmount,
    );
    final participantModels = participantIds
        .where(usersById.containsKey)
        .map(
          (id) => ExpenseParticipant(
            id: id,
            nickname:
                usersById[id]?.preferredName ?? context.l10n.userWithId(id),
            owedAmount: owedByUser[id],
            splitValue: splitValuesByUser[id],
          ),
        )
        .toList(growable: false);

    final payerId = form.paidBy ?? _currentUserId;
    final payerName =
        usersById[payerId]?.preferredName ?? context.l10n.youLabel;
    final queuedExpense = TripExpense(
      id: -DateTime.now().millisecondsSinceEpoch,
      amount: form.amount,
      originalAmount: form.amount,
      tripCurrencyCode: widget.trip.currencyCode,
      expenseCurrencyCode: form.currencyCode,
      fxRateToTrip: 1.0,
      category: form.category,
      note: _tagQueuedNote(form.note),
      expenseDate: form.date,
      splitMode: form.splitMode,
      paidById: payerId,
      paidByNickname: payerName,
      receiptUrl: uploadedReceipt?.url,
      receiptThumbUrl: uploadedReceipt?.thumbUrl,
      participants: participantModels,
      items: form.items,
      extraAmount: form.extraAmount,
    );
    final nextSnapshotExpenses = [queuedExpense, ...snapshot.expenses];
    final visibleExpenses = [queuedExpense, ..._expensesFeed];

    _updateState(() {
      _expensesFeed = visibleExpenses;
      _reconcileExpenseSocialPreviewState(visibleExpenses);
      _snapshot = snapshot.copyWith(expenses: nextSnapshotExpenses);
    });
  }

  void _applyQueuedEdit({
    required int expenseId,
    required _ExpenseFormResult form,
    required UploadedReceiptData? uploadedReceipt,
  }) {
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }

    final usersById = <int, WorkspaceUser>{
      for (final user in snapshot.users) user.id: user,
    };
    final participantIds = form.participants.isNotEmpty
        ? form.participants
        : snapshot.users.map((user) => user.id).toList(growable: false);
    final splitValuesByUser = <int, double>{
      for (final item in form.splitValues) item.userId: item.value,
    };
    final owedByUser = queuedExpenseOwedByUser(
      amount: form.amount,
      participantIds: participantIds,
      splitMode: form.splitMode,
      splitValuesByUser: splitValuesByUser,
      items: form.items,
      extraAmount: form.extraAmount,
    );
    final participantModels = participantIds
        .where(usersById.containsKey)
        .map(
          (id) => ExpenseParticipant(
            id: id,
            nickname:
                usersById[id]?.preferredName ?? context.l10n.userWithId(id),
            owedAmount: owedByUser[id],
            splitValue: splitValuesByUser[id],
          ),
        )
        .toList(growable: false);

    TripExpense updateExpense(TripExpense expense) {
      if (expense.id != expenseId) {
        return expense;
      }
      return TripExpense(
        id: expense.id,
        amount: form.amount,
        originalAmount: form.amount,
        tripCurrencyCode: widget.trip.currencyCode,
        expenseCurrencyCode: form.currencyCode,
        fxRateToTrip: 1.0,
        category: form.category,
        note: _tagQueuedNote(form.note),
        expenseDate: form.date,
        splitMode: form.splitMode,
        paidById: form.paidBy ?? expense.paidById,
        paidByNickname:
            usersById[form.paidBy]?.preferredName ?? expense.paidByNickname,
        receiptUrl: form.removeReceipt
            ? null
            : (uploadedReceipt?.url ?? expense.receiptUrl),
        receiptThumbUrl: form.removeReceipt
            ? null
            : (uploadedReceipt?.thumbUrl ?? expense.receiptThumbUrl),
        participants: participantModels,
        items: form.items,
        extraAmount: form.extraAmount,
      );
    }

    final nextExpenses = snapshot.expenses
        .map(updateExpense)
        .toList(growable: false);
    final visibleExpenses = _expensesFeed
        .map(updateExpense)
        .toList(growable: false);

    _updateState(() {
      _expensesFeed = visibleExpenses;
      _reconcileExpenseSocialPreviewState(visibleExpenses);
      _snapshot = snapshot.copyWith(expenses: nextExpenses);
    });
  }

  void _applyQueuedDelete(int expenseId) {
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }

    _updateState(() {
      final nextExpenses = snapshot.expenses
          .where((expense) => expense.id != expenseId)
          .toList(growable: false);
      final visibleExpenses = _expensesFeed
          .where((expense) => expense.id != expenseId)
          .toList(growable: false);
      _expensesFeed = visibleExpenses;
      _reconcileExpenseSocialPreviewState(visibleExpenses);
      _snapshot = snapshot.copyWith(expenses: nextExpenses);
    });
  }
}
