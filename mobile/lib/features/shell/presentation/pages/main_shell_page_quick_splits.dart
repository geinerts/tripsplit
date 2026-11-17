part of 'main_shell_page.dart';

/// Quick split: the home list, its form and sheet, and "Add to a trip".
extension _MainShellPageQuickSplits on _MainShellPageState {
  QuickSplitsController? get _quickSplits => widget.quickSplitsController;

  Widget _buildQuickSplitsTab(BuildContext context) => QuickSplitsList(
    controller: _quickSplits!,
    onOpen: (split) => unawaited(_openQuickSplitSheet(split)),
  );

  void _onQuickSplitsShown(bool shown) {
    _quickSplitsShown = shown;
    final controller = _quickSplits;
    if (shown && controller != null && !controller.isLoading) {
      unawaited(controller.load());
    }
  }

  /// Home with the Quick splits list on show.
  void _showHomeQuickSplits({bool refresh = false}) {
    if (_quickSplits == null) return;
    if (_selectedTabIndex != _MainShellPageState._tabHome || _isWorkspaceOpen) {
      _updateState(() {
        _selectedTabIndex = _MainShellPageState._tabHome;
        _openedTrip = null;
        _openAddExpenseOnWorkspaceStart = false;
        _workspaceExpenseDraft = null;
      });
    }
    _tripsCommandController.requestShowQuickSplits();
    if (refresh) unawaited(_quickSplits!.load());
  }

  String _quickSplitCurrency(List<Trip> trips) {
    for (final trip in trips) {
      if (trip.isActive) return trip.currencyCode;
    }
    return trips.isNotEmpty
        ? trips.first.currencyCode
        : AppCurrencyCatalog.defaultCode;
  }

  Future<void> _openQuickSplitForm({
    QuickSplit? existing,
    ExpenseDraft? draft,
  }) async {
    final controller = _quickSplits;
    if (controller == null || !mounted) return;
    final account = widget.authController.currentUser?.id;
    final trips = widget.tripsController.peekTripsCache() ?? const <Trip>[];
    final saved = await showQuickSplitForm(
      context,
      authController: widget.authController,
      friendsController: widget.friendsController,
      workspaceController: widget.workspaceController,
      save: controller.add,
      update: controller.update,
      existing: existing,
      draft: draft,
      defaultCurrencyCode: _quickSplitCurrency(trips),
      pickTarget: existing == null
          ? (formContext) => _pickExpenseTarget(formContext)
          : null,
      onTargetChanged: _onExpenseTargetChanged,
    );
    if (saved == null ||
        !mounted ||
        widget.authController.currentUser?.id != account) {
      return;
    }
    _showHomeQuickSplits();
    await _openQuickSplitSheet(saved);
  }

  Future<void> _openQuickSplitSheet(QuickSplit split) async {
    final controller = _quickSplits;
    if (controller == null || !mounted) return;
    final account = widget.authController.currentUser?.id;
    var full = split;
    if (!split.isFull) {
      try {
        full = await controller.get(split.id);
      } on ApiException catch (error) {
        if (mounted) _showSnack(error.message, isError: true);
        return;
      } catch (_) {
        if (mounted) {
          _showSnack(context.l10n.quickSplitsLoadFailed, isError: true);
        }
        return;
      }
    }
    if (!mounted || widget.authController.currentUser?.id != account) return;
    final action = await showQuickSplitSheet(context, split: full);
    if (!mounted ||
        action == null ||
        widget.authController.currentUser?.id != account) {
      return;
    }
    switch (action) {
      case QuickSplitSheetAction.edit:
        await _openQuickSplitForm(existing: full);
      case QuickSplitSheetAction.delete:
        await _deleteQuickSplit(full);
      case QuickSplitSheetAction.addToTrip:
        await _addQuickSplitToTrip(full);
    }
  }

  Future<void> _deleteQuickSplit(QuickSplit split) async {
    final t = context.l10n;
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: t.quickSplitDeleteTitle,
      message: t.quickSplitDeleteMessage,
      confirmLabel: t.deleteAction,
      cancelLabel: t.cancelAction,
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await _quickSplits!.delete(split.id);
      if (mounted) _showSnack(t.quickSplitDeleted, isError: false);
    } on ApiException catch (error) {
      if (mounted) _showSnack(error.message, isError: true);
    } catch (_) {
      if (mounted) _showSnack(t.unexpectedErrorSavingChanges, isError: true);
    }
  }

  /// Opens Add expense in the chosen trip, filled from the quick split. Saving
  /// it there takes the quick split off the list.
  Future<void> _addQuickSplitToTrip(QuickSplit split) async {
    final t = context.l10n;
    // Trip expenses are entered by whoever paid.
    if (split.payer?.isMe != true) {
      _showSnack(t.quickSplitAddToTripOnlyPayer, isError: true);
      return;
    }
    List<Trip> trips;
    try {
      trips =
          widget.tripsController.peekTripsCache() ??
          await widget.tripsController.loadTrips(forceRefresh: true);
    } catch (_) {
      if (mounted) _showSnack(t.unexpectedErrorLoadingTrips, isError: true);
      return;
    }
    if (!mounted) return;
    final active = trips.where((trip) => trip.isActive).toList();
    if (active.isEmpty) {
      _showSnack(t.quickSplitNoActiveTrip, isError: true);
      return;
    }
    final trip = active.length == 1
        ? active.single
        : (await _pickExpenseTarget(context, includeQuickSplit: false))?.trip;
    if (trip == null || !mounted) return;
    _openWorkspaceInShell(
      trip,
      openAddExpense: true,
      draft: _draftFromQuickSplit(split),
    );
  }

  ExpenseDraft _draftFromQuickSplit(QuickSplit split) {
    final itemized = split.splitMode == 'itemized';
    final shareHolders = split.people
        .where(
          (person) =>
              itemized ||
              split.splitMode == 'equal' && person.amount > 0 ||
              person.splitValue != null,
        )
        .where(
          (person) =>
              !itemized ||
              split.items.any((item) => item.personIds.contains(person.id)),
        )
        .toList();
    // Someone without an account can't be in a trip expense; the split then
    // starts again as equal among the others.
    final everyoneHasAccount = shareHolders.every((p) => p.isAccount);
    final userIdByPerson = {
      for (final person in split.people)
        if (person.userId != null) person.id: person.userId!,
    };
    final receipt = split.receiptPath;
    return ExpenseDraft(
      quickSplitId: split.id,
      amount: split.amount,
      currencyCode: split.currencyCode,
      note: split.note,
      category: split.category,
      subcategory: split.subcategory,
      date: split.date,
      receipt: receipt == null
          ? null
          : UploadedReceiptData(
              path: receipt,
              url: split.receiptUrl,
              thumbUrl: split.receiptThumbUrl,
            ),
      payerUserId: split.payer?.userId,
      participantUserIds: [
        for (final person in shareHolders)
          if (person.userId != null) person.userId!,
      ],
      splitMode: everyoneHasAccount ? split.splitMode : 'equal',
      splitValues: everyoneHasAccount
          ? {
              for (final person in shareHolders)
                if (person.userId != null) person.userId!: person.splitValue,
            }
          : const {},
      items: everyoneHasAccount && itemized
          ? [
              for (final item in split.items)
                ExpenseItem(
                  name: item.name,
                  amount: item.amount,
                  participantIds: [
                    for (final id in item.personIds)
                      if (userIdByPerson[id] != null) userIdByPerson[id]!,
                  ],
                ),
            ]
          : const [],
      extraAmount: everyoneHasAccount && itemized ? split.extraAmount : 0,
    );
  }

  /// "⚡ Quick split" and the active trips. Null when closed.
  Future<ExpenseTarget?> _pickExpenseTarget(
    BuildContext sheetContext, {
    Trip? current,
    bool includeQuickSplit = true,
    List<Trip>? trips,
  }) async {
    final t = sheetContext.l10n;
    var all = trips ?? widget.tripsController.peekTripsCache();
    if (all == null) {
      try {
        await widget.tripsController.primeTripsCacheFromDisk();
        all = widget.tripsController.peekTripsCache() ?? const <Trip>[];
      } catch (_) {
        all = const <Trip>[];
      }
    }
    if (!sheetContext.mounted) return null;
    final active = all.where((trip) => trip.isActive).toList();
    return showAppBottomSheet<ExpenseTarget>(
      context: sheetContext,
      builder: (pickerContext) => AppActionSheet(
        key: const ValueKey('expense-target-sheet'),
        title: t.expenseTargetTitle,
        children: [
          if (includeQuickSplit)
            AppActionSheetTile(
              key: const ValueKey('expense-target-quick-split'),
              icon: Icons.bolt_rounded,
              title: t.quickSplitLabel,
              subtitle: t.quickSplitTargetHint,
              trailing: current == null && includeQuickSplit
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => Navigator.of(
                pickerContext,
              ).pop(const ExpenseTarget.quickSplit()),
            ),
          for (final trip in active)
            AppActionSheetTile(
              key: ValueKey('expense-target-trip-${trip.id}'),
              icon: Icons.luggage_outlined,
              title: trip.name,
              trailing: current?.id == trip.id
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () =>
                  Navigator.of(pickerContext).pop(ExpenseTarget.trip(trip)),
            ),
        ],
      ),
    );
  }

  /// Continues the same expense in Quick split or another trip.
  void _onExpenseTargetChanged(ExpenseTarget target, ExpenseDraft draft) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final trip = target.trip;
      if (trip == null) {
        unawaited(_openQuickSplitForm(draft: draft));
      } else {
        _openWorkspaceInShell(trip, openAddExpense: true, draft: draft);
      }
    });
  }

  Future<void> _onQuickSplitAddedToTrip(
    int quickSplitId,
    int tripId,
    int expenseId,
  ) async {
    await _quickSplits?.moveToTrip(
      id: quickSplitId,
      tripId: tripId,
      expenseId: expenseId,
    );
  }
}
