part of 'workspace_page.dart';

extension _WorkspacePageExpensesActions on _WorkspacePageState {
  Future<void> _waitForDialogCloseTransition() async {
    // Dialog futures resolve before reverse animation fully completes.
    // Wait a little longer to avoid state updates during route teardown.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 260));
  }

  Future<void> _onAddExpensePressed() => _openExpenseForm();

  Future<void> _onEditExpensePressed(TripExpense expense) =>
      _openExpenseForm(existing: expense);

  Future<void> _openExpenseForm({TripExpense? existing}) async {
    if (_snapshot == null || _isMutating || _isAddExpenseDialogOpen) return;
    if (!_snapshot!.isActive) {
      _showSnack(context.l10n.tripClosedExpensesReadOnly, isError: true);
      return;
    }
    if (existing != null &&
        (existing.id <= 0 || existing.paidById != _currentUserId)) {
      return;
    }
    _isAddExpenseDialogOpen = true;
    var queued = false;
    _ExpenseFormResult? result;
    try {
      result = await _showExpenseDialog(
        users: _snapshot!.users,
        existing: existing,
        recentExpenses: _snapshot!.expenses,
        onSubmit: (formContext, form) async {
          if (existing != null) {
            final t = formContext.l10n;
            final confirmed = await showAppConfirmationDialog(
              context: formContext,
              title: t.editExpenseConfirmTitle,
              message: t.editExpenseConfirmText,
              confirmLabel: t.saveAction,
              cancelLabel: t.cancelAction,
              icon: Icons.edit_outlined,
            );
            if (!confirmed || !mounted) return false;
          }
          _updateState(() => _isMutating = true);
          try {
            final receipt =
                form.preuploadedReceipt ??
                await _uploadReceiptBestEffort(
                  fileName: form.receiptFileName,
                  bytes: form.receiptFileBytes,
                );
            final mutation = existing == null
                ? await widget.workspaceController.addExpense(
                    tripId: widget.trip.id,
                    amount: form.amount,
                    currencyCode: form.currencyCode,
                    category: form.category,
                    note: form.note,
                    date: form.date,
                    participants: form.participants,
                    splitMode: form.splitMode,
                    splitValues: form.splitValues,
                    receiptPath: receipt?.path,
                  )
                : await widget.workspaceController.updateExpense(
                    tripId: widget.trip.id,
                    expenseId: existing.id,
                    amount: form.amount,
                    currencyCode: form.currencyCode,
                    category: form.category,
                    note: form.note,
                    date: form.date,
                    participants: form.participants,
                    splitMode: form.splitMode,
                    splitValues: form.splitValues,
                    receiptPath: receipt?.path,
                    removeReceipt: form.removeReceipt,
                  );
            queued = mutation.queued;
            if (mounted && queued) {
              if (existing == null) {
                _applyQueuedAdd(form: form, uploadedReceipt: receipt);
              } else {
                _applyQueuedEdit(
                  expenseId: existing.id,
                  form: form,
                  uploadedReceipt: receipt,
                );
              }
            }
            return true;
          } finally {
            if (mounted) _updateState(() => _isMutating = false);
          }
        },
      );
    } finally {
      _isAddExpenseDialogOpen = false;
    }
    if (result == null || !mounted) return;
    await _waitForDialogCloseTransition();
    if (!mounted) return;
    // A successful mutation must never become a failed save due to a refresh.
    if (queued) {
      try {
        await _refreshQueueState();
      } catch (_) {
        /* Keep the saved queued row. */
      }
    } else {
      await _loadData(showLoader: false);
    }
    if (!mounted) return;
    _showSnack(
      queued
          ? (existing == null
                ? context.l10n.noInternetExpenseQueued
                : context.l10n.noInternetUpdateQueued)
          : (existing == null
                ? context.l10n.expenseAdded
                : context.l10n.expenseUpdated),
    );
  }

  Future<UploadedReceiptData?> _uploadReceiptBestEffort({
    required String? fileName,
    required Uint8List? bytes,
  }) async {
    final safeName = (fileName ?? '').trim();
    final safeBytes = bytes;
    if (safeName.isEmpty || safeBytes == null || safeBytes.isEmpty) {
      return null;
    }
    try {
      return await widget.workspaceController.uploadReceipt(
        payload: ReceiptUploadPayload(
          fileName: safeName,
          bytes: safeBytes,
          tripId: widget.trip.id,
        ),
      );
    } on ApiException catch (error) {
      if (!error.isNetworkError) {
        rethrow;
      }
      if (mounted) {
        _showSnack(_receiptSkippedOfflineMessage());
      }
      return null;
    }
  }

  String _receiptSkippedOfflineMessage() {
    return context.l10n.workspaceNoInternetExpenseSavedWithoutReceiptImage;
  }

  Future<void> _onDeleteExpensePressed(TripExpense expense) async {
    if (_isMutating) {
      return;
    }
    if (!_isTripActive) {
      _showSnack(context.l10n.tripClosedExpensesReadOnly, isError: true);
      return;
    }

    final t = context.l10n;
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: t.deleteExpenseTitle,
      message: t.deleteExpenseConfirmQuestion,
      confirmLabel: t.deleteAction,
      cancelLabel: t.cancelAction,
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );

    if (!confirmed || !mounted) {
      return;
    }
    // Avoid mutating parent state while dialog route is still deactivating.
    await _waitForDialogCloseTransition();
    if (!mounted) {
      return;
    }

    await _runMutation(
      action: () async {
        final mutation = await widget.workspaceController.deleteExpense(
          tripId: widget.trip.id,
          expenseId: expense.id,
        );

        if (mutation.queued) {
          _applyQueuedDelete(expense.id);
          await _refreshQueueState();
          if (mounted) {
            _showSnack(context.l10n.noInternetDeleteQueued);
          }
        } else {
          await _loadData(showLoader: false);
          if (mounted) {
            _showSnack(context.l10n.expenseDeleted);
          }
        }
      },
    );
  }
}
