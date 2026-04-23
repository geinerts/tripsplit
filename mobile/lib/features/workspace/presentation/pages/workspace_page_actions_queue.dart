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
    final owedByUser = _buildQueuedOwedByUser(
      amount: form.amount,
      participantIds: participantIds,
      splitMode: form.splitMode,
      splitValuesByUser: splitValuesByUser,
    );
    final participantModels = participantIds
        .where(usersById.containsKey)
        .map(
          (id) => ExpenseParticipant(
            id: id,
            nickname: usersById[id]?.nickname ?? context.l10n.userWithId(id),
            owedAmount: owedByUser[id],
            splitValue: splitValuesByUser[id],
          ),
        )
        .toList(growable: false);

    final payerName =
        usersById[_currentUserId]?.nickname ?? context.l10n.youLabel;
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
      paidById: _currentUserId,
      paidByNickname: payerName,
      receiptUrl: uploadedReceipt?.url,
      receiptThumbUrl: uploadedReceipt?.thumbUrl,
      participants: participantModels,
    );
    final nextSnapshotExpenses = [queuedExpense, ...snapshot.expenses];
    final visibleExpenses = _expensesFeed.isNotEmpty
        ? _expensesFeed
        : nextSnapshotExpenses;

    _updateState(() {
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
    final owedByUser = _buildQueuedOwedByUser(
      amount: form.amount,
      participantIds: participantIds,
      splitMode: form.splitMode,
      splitValuesByUser: splitValuesByUser,
    );
    final participantModels = participantIds
        .where(usersById.containsKey)
        .map(
          (id) => ExpenseParticipant(
            id: id,
            nickname: usersById[id]?.nickname ?? context.l10n.userWithId(id),
            owedAmount: owedByUser[id],
            splitValue: splitValuesByUser[id],
          ),
        )
        .toList(growable: false);

    final nextExpenses = snapshot.expenses
        .map((expense) {
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
            paidById: expense.paidById,
            paidByNickname: expense.paidByNickname,
            receiptUrl: form.removeReceipt
                ? null
                : (uploadedReceipt?.url ?? expense.receiptUrl),
            receiptThumbUrl: form.removeReceipt
                ? null
                : (uploadedReceipt?.thumbUrl ?? expense.receiptThumbUrl),
            participants: participantModels,
          );
        })
        .toList(growable: false);
    final visibleExpenses = _expensesFeed.isNotEmpty
        ? _expensesFeed
        : nextExpenses;

    _updateState(() {
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
      final visibleExpenses = _expensesFeed.isNotEmpty
          ? _expensesFeed
          : nextExpenses;
      _reconcileExpenseSocialPreviewState(visibleExpenses);
      _snapshot = snapshot.copyWith(expenses: nextExpenses);
    });
  }

  Map<int, double> _buildQueuedOwedByUser({
    required double amount,
    required List<int> participantIds,
    required String splitMode,
    required Map<int, double> splitValuesByUser,
  }) {
    if (participantIds.isEmpty) {
      return const <int, double>{};
    }

    final amountCents = (amount * 100).round();
    if (amountCents <= 0) {
      return const <int, double>{};
    }

    final owedCents = <int, int>{for (final id in participantIds) id: 0};
    if (splitMode == 'exact') {
      for (final id in participantIds) {
        final value = splitValuesByUser[id] ?? 0;
        owedCents[id] = (value * 100).round();
      }
    } else if (splitMode == 'percent') {
      final basisPoints = <int, int>{
        for (final id in participantIds)
          id: ((splitValuesByUser[id] ?? 0) * 100).round(),
      };
      return _distributeByWeight(
        amountCents: amountCents,
        participantIds: participantIds,
        weightsByUser: basisPoints,
      ).map((key, value) => MapEntry(key, value / 100));
    } else if (splitMode == 'shares') {
      final shares = <int, int>{
        for (final id in participantIds)
          id: (splitValuesByUser[id] ?? 0).round(),
      };
      return _distributeByWeight(
        amountCents: amountCents,
        participantIds: participantIds,
        weightsByUser: shares,
      ).map((key, value) => MapEntry(key, value / 100));
    } else {
      final base = amountCents ~/ participantIds.length;
      final remainder = amountCents % participantIds.length;
      for (var i = 0; i < participantIds.length; i++) {
        owedCents[participantIds[i]] = base + (i < remainder ? 1 : 0);
      }
    }

    return owedCents.map((key, value) => MapEntry(key, value / 100));
  }

  Map<int, int> _distributeByWeight({
    required int amountCents,
    required List<int> participantIds,
    required Map<int, int> weightsByUser,
  }) {
    final totalWeight = participantIds.fold<int>(
      0,
      (sum, id) =>
          sum + ((weightsByUser[id] ?? 0) > 0 ? (weightsByUser[id]!) : 0),
    );
    if (totalWeight <= 0) {
      return <int, int>{for (final id in participantIds) id: 0};
    }

    final out = <int, int>{for (final id in participantIds) id: 0};
    final remainders = <({int userId, int index, int remainder})>[];
    var allocated = 0;

    for (var i = 0; i < participantIds.length; i++) {
      final userId = participantIds[i];
      final rawWeight = weightsByUser[userId] ?? 0;
      final weight = rawWeight < 0
          ? 0
          : (rawWeight > (1 << 30) ? (1 << 30) : rawWeight);
      if (weight <= 0) {
        remainders.add((userId: userId, index: i, remainder: 0));
        continue;
      }
      final weighted = amountCents * weight;
      final base = weighted ~/ totalWeight;
      final remainder = weighted % totalWeight;
      out[userId] = base;
      allocated += base;
      remainders.add((userId: userId, index: i, remainder: remainder));
    }

    var left = amountCents - allocated;
    if (left <= 0) {
      return out;
    }
    remainders.sort((a, b) {
      final cmp = b.remainder.compareTo(a.remainder);
      if (cmp != 0) {
        return cmp;
      }
      return a.index.compareTo(b.index);
    });

    var idx = 0;
    while (left > 0 && remainders.isNotEmpty) {
      final row = remainders[idx % remainders.length];
      out[row.userId] = (out[row.userId] ?? 0) + 1;
      left -= 1;
      idx += 1;
    }

    return out;
  }
}
