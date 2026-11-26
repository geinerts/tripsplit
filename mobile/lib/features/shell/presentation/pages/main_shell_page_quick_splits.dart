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
        _workspaceFocus = null;
      });
    }
    _tripsCommandController.requestShowQuickSplits();
    if (refresh) unawaited(_quickSplits!.load());
  }

  /// An active trip's currency, else the profile currency, else the newest
  /// trip's.
  String _quickSplitCurrency(List<Trip> trips) {
    for (final trip in trips) {
      if (trip.isActive) return trip.currencyCode;
    }
    final preferred =
        widget.authController.currentUser?.preferredCurrencyCode?.trim() ?? '';
    if (preferred.isNotEmpty) return AppCurrencyCatalog.normalize(preferred);
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
    final fitting = await _tripsFittingQuickSplit(full);
    if (!mounted || widget.authController.currentUser?.id != account) return;
    final hasReceipt = full.hasReceipt || full.receiptUrl != null;
    final action = await showQuickSplitSheet(
      context,
      split: full,
      canAddToTrip: fitting.isNotEmpty,
      receiptAction: hasReceipt
          ? ReceiptOpenAction(
              key: ValueKey('quick-receipt-$account-${full.id}'),
              compactLabel: context.l10n.expenseReceiptChip,
              isCurrentAccount: () =>
                  mounted &&
                  account != null &&
                  widget.authController.currentUser?.id == account,
              loadPreview: () =>
                  controller.loadReceiptUri(full.id, thumbnail: true),
              load: () async {
                final uri = await controller.loadReceiptUri(full.id);
                if (!mounted ||
                    widget.authController.currentUser?.id != account) {
                  return null;
                }
                return uri;
              },
              open: (uri) async {
                if (!mounted ||
                    widget.authController.currentUser?.id != account) {
                  return false;
                }
                await Navigator.of(context).push<void>(
                  AppFormPageRoute(
                    builder: (_) => ReceiptViewerPage(
                      initialUri: uri,
                      isCurrentAccount: () =>
                          mounted &&
                          widget.authController.currentUser?.id == account,
                      reload: () => controller.loadReceiptUri(full.id),
                    ),
                  ),
                );
                return true;
              },
            )
          : null,
    );
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
        await _addQuickSplitToTrip(full, fitting);
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
  /// it there takes the quick split off the list. Only trips that fit are
  /// offered ([QuickSplit.fitsTrip]).
  Future<void> _addQuickSplitToTrip(
    QuickSplit split,
    List<Trip> fitting,
  ) async {
    if (fitting.isEmpty) return;
    final trip = fitting.length == 1
        ? fitting.single
        : (await _pickExpenseTarget(
            context,
            includeQuickSplit: false,
            trips: fitting,
          ))?.trip;
    if (trip == null || !mounted) return;
    _openWorkspaceInShell(
      trip,
      openAddExpense: true,
      draft: _draftFromQuickSplit(split),
    );
  }

  /// Members of a trip, from its cached snapshot or else from the server.
  /// Null when they can't be read.
  Future<Set<int>?> _tripMemberIds(int tripId) async {
    try {
      final snapshot =
          await widget.workspaceController.readCachedSnapshot(tripId: tripId) ??
          await widget.workspaceController.loadSnapshot(tripId: tripId);
      return {
        for (final user in snapshot.users)
          if (user.id > 0) user.id,
      };
    } catch (_) {
      return null;
    }
  }

  /// Active trips that have every person of this quick split.
  Future<List<Trip>> _tripsFittingQuickSplit(QuickSplit split) async {
    if (!split.mayFitATrip || split.payer?.isMe != true) return const [];
    var trips = widget.tripsController.peekTripsCache();
    if (trips == null) {
      try {
        trips = await widget.tripsController.loadTrips();
      } catch (_) {
        return const [];
      }
    }
    final fitting = <Trip>[];
    for (final trip in trips) {
      if (!trip.isActive || trip.isSolo) continue;
      final members = await _tripMemberIds(trip.id);
      if (members != null && split.fitsTrip(members)) fitting.add(trip);
    }
    return fitting;
  }

  /// "From a quick split" inside a trip: the user's quick splits whose people
  /// are all in this trip. Null when closed or none fits.
  Future<ExpenseDraft?> _pickQuickSplitForTrip(
    BuildContext formContext,
    Set<int> memberIds,
  ) async {
    final controller = _quickSplits;
    if (controller == null) return null;
    final account = widget.authController.currentUser?.id;
    final t = formContext.l10n;
    if (!controller.hasLoaded) await controller.load();
    final candidates = controller.items
        .where((split) => split.mayFitATrip)
        .take(30)
        .toList();
    final loaded = await Future.wait([
      for (final split in candidates)
        (split.isFull ? Future.value(split) : controller.get(split.id))
            .then<QuickSplit?>((full) => full)
            .catchError((Object _) => null),
    ]);
    if (!formContext.mounted ||
        widget.authController.currentUser?.id != account) {
      return null;
    }
    final fitting = [
      for (final split in loaded)
        if (split != null && split.fitsTrip(memberIds)) split,
    ];
    if (fitting.isEmpty) {
      ScaffoldMessenger.maybeOf(
        formContext,
      )?.showSnackBar(SnackBar(content: Text(t.quickSplitNoneForTrip)));
      return null;
    }
    final picked = await showAppBottomSheet<QuickSplit>(
      context: formContext,
      builder: (pickerContext) => AppActionSheet(
        key: const ValueKey('quick-split-for-trip-sheet'),
        title: t.quickSplitFromTitle,
        children: [
          for (final split in fitting)
            AppActionSheetTile(
              key: ValueKey('quick-split-for-trip-${split.id}'),
              icon: Icons.bolt_rounded,
              title: quickSplitTitle(pickerContext, split),
              subtitle:
                  '${AppFormatters.currency(pickerContext, split.amount, currencyCode: split.currencyCode)} · ${t.homePeople(split.people.length)}',
              onTap: () => Navigator.of(pickerContext).pop(split),
            ),
        ],
      ),
    );
    if (picked == null || widget.authController.currentUser?.id != account) {
      return null;
    }
    return _draftFromQuickSplit(picked);
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
