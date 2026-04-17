part of 'workspace_page.dart';

extension _WorkspacePageExpensesActions on _WorkspacePageState {
  Future<void> _waitForDialogCloseTransition() async {
    // Dialog futures resolve before reverse animation fully completes.
    // Wait a little longer to avoid state updates during route teardown.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 260));
  }

  Future<void> _onAddExpensePressed() async {
    if (_snapshot == null || _isMutating) {
      return;
    }
    if (!_snapshot!.isActive) {
      _showSnack(context.l10n.tripClosedExpensesReadOnly, isError: true);
      return;
    }

    final result = await _showExpenseDialog(users: _snapshot!.users);
    if (result == null || !mounted) {
      return;
    }
    // Avoid mutating parent state while dialog route is still deactivating.
    await _waitForDialogCloseTransition();
    if (!mounted) {
      return;
    }

    await _runMutation(
      action: () async {
        final receipt = await _uploadReceiptBestEffort(
          fileName: result.receiptFileName,
          bytes: result.receiptFileBytes,
        );

        final mutation = await widget.workspaceController.addExpense(
          tripId: widget.trip.id,
          amount: result.amount,
          currencyCode: result.currencyCode,
          category: result.category,
          note: result.note,
          date: result.date,
          participants: result.participants,
          splitMode: result.splitMode,
          splitValues: result.splitValues,
          receiptPath: receipt?.path,
        );

        if (mutation.queued) {
          _applyQueuedAdd(form: result, uploadedReceipt: receipt);
          await _refreshQueueState();
          if (mounted) {
            _showSnack(context.l10n.noInternetExpenseQueued);
          }
        } else {
          await _loadData(showLoader: false);
          if (mounted) {
            _showSnack(context.l10n.expenseAdded);
          }
        }
      },
    );
  }

  Future<void> _onEditExpensePressed(TripExpense expense) async {
    if (_snapshot == null || _isMutating) {
      return;
    }
    if (!_snapshot!.isActive) {
      _showSnack(context.l10n.tripClosedExpensesReadOnly, isError: true);
      return;
    }

    final result = await _showExpenseDialog(
      users: _snapshot!.users,
      existing: expense,
    );
    if (result == null || !mounted) {
      return;
    }
    // Avoid mutating parent state while dialog route is still deactivating.
    await _waitForDialogCloseTransition();
    if (!mounted) {
      return;
    }

    await _runMutation(
      action: () async {
        final receipt = await _uploadReceiptBestEffort(
          fileName: result.receiptFileName,
          bytes: result.receiptFileBytes,
        );

        final mutation = await widget.workspaceController.updateExpense(
          tripId: widget.trip.id,
          expenseId: expense.id,
          amount: result.amount,
          currencyCode: result.currencyCode,
          category: result.category,
          note: result.note,
          date: result.date,
          participants: result.participants,
          splitMode: result.splitMode,
          splitValues: result.splitValues,
          receiptPath: receipt?.path,
          removeReceipt: result.removeReceipt,
        );

        if (mutation.queued) {
          _applyQueuedEdit(
            expenseId: expense.id,
            form: result,
            uploadedReceipt: receipt,
          );
          await _refreshQueueState();
          if (mounted) {
            _showSnack(context.l10n.noInternetUpdateQueued);
          }
        } else {
          await _loadData(showLoader: false);
          if (mounted) {
            _showSnack(context.l10n.expenseUpdated);
          }
        }
      },
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

  Future<void> _deleteExpenseAfterSwipe(TripExpense expense) async {
    if (!mounted || _isMutating) {
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

  Future<void> _onDeleteExpensePressed(TripExpense expense) async {
    if (_isMutating) {
      return;
    }
    if (!_isTripActive) {
      _showSnack(context.l10n.tripClosedExpensesReadOnly, isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final t = context.l10n;
        return AlertDialog(
          title: Text(t.deleteExpenseTitle),
          content: Text(t.deleteExpenseConfirmQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.deleteAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
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
