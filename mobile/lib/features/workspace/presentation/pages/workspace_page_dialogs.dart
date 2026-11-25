part of 'workspace_page.dart';

extension _WorkspacePageDialogs on _WorkspacePageState {
  Future<_ExpenseFormResult?> _showExpenseDialog({
    required List<WorkspaceUser> users,
    required Future<bool> Function(BuildContext, _ExpenseFormResult) onSubmit,
    TripExpense? existing,
    List<TripExpense> recentExpenses = const <TripExpense>[],
    _ExpenseFormSeed? draft,
  }) {
    final trip = widget.trip;
    return _showExpenseFormPage(
      context,
      initialUsers: users,
      seed: existing != null ? _ExpenseFormSeed.fromExpense(existing) : draft,
      onSubmit: onSubmit,
      setup: _ExpenseFormSetup(
        currentUserId: _currentUserId,
        isSolo: trip.isSolo,
        soloOwnerId: trip.createdBy ?? _currentUserId,
        defaultCurrencyCode: trip.currencyCode,
        subtitle: (formContext, draft) => _expenseFormTripSubtitle(
          formContext,
          draft,
          offerQuickSplit: existing == null,
        ),
        payerChoices: (users) {
          if (trip.isSolo || !_isCurrentTripOwner()) return const [];
          final guests = users.where((user) => user.isGuest).toList();
          if (guests.isEmpty) return const [];
          return [
            ...users.where((user) => user.id == _currentUserId),
            ...guests,
          ];
        },
        // Each expense once, even when it is in both lists.
        typeSources: {
          for (final expense in [...recentExpenses, ...?_snapshot?.expenses])
            expense.id: expense,
        }.values,
        uploadReceipt: (fileName, bytes) =>
            widget.workspaceController.uploadReceipt(
              payload: ReceiptUploadPayload(
                fileName: fileName,
                bytes: bytes,
                tripId: trip.id,
              ),
            ),
        loadSavedReceipt: existing == null
            ? null
            : () => widget.workspaceController.loadReceiptUri(
                tripId: trip.id,
                expenseId: existing.id,
              ),
        currentAccountId: () => widget.authController.currentUser?.id,
        // AI receipt reading in "By item", for accounts that have it.
        scanReceipt: widget.authController.currentUser?.receiptAi == true
            ? (receiptPath, requestId, rescan) =>
                  widget.workspaceController.scanReceipt(
                    receiptPath: receiptPath,
                    requestId: requestId,
                    rescan: rescan,
                  )
            : null,
      ),
    );
  }

  /// The trip name under the title; with "▾" when the expense can go to
  /// Quick split or another trip instead.
  Widget _expenseFormTripSubtitle(
    BuildContext formContext,
    ExpenseDraft Function() draft, {
    bool offerQuickSplit = false,
  }) {
    final target = _expenseFormTargetChip(formContext, draft);
    final pickQuickSplit = widget.pickQuickSplit;
    if (!offerQuickSplit ||
        pickQuickSplit == null ||
        widget.trip.isSolo ||
        widget.hasQuickSplitsToAdd?.call() != true) {
      return target;
    }
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        target,
        ActionChip(
          key: const ValueKey('expense-from-quick-split'),
          avatar: const Icon(Icons.bolt_rounded, size: 16),
          label: Text(formContext.l10n.quickSplitFromAction),
          visualDensity: VisualDensity.compact,
          onPressed: () async {
            FocusScope.of(formContext).unfocus();
            final members = {
              for (final user in _snapshot?.users ?? const <WorkspaceUser>[])
                if (user.id > 0) user.id,
            };
            final picked = await pickQuickSplit(formContext, members);
            if (picked == null || !formContext.mounted || !mounted) return;
            _quickSplitDraftToOpen = picked;
            Navigator.of(formContext).pop();
          },
        ),
      ],
    );
  }

  Widget _expenseFormTargetChip(
    BuildContext formContext,
    ExpenseDraft Function() draft,
  ) {
    final pick = widget.pickExpenseTarget;
    final onChanged = widget.onExpenseTargetChanged;
    if (pick == null || onChanged == null) {
      return Text(
        widget.trip.name,
        style: Theme.of(formContext).textTheme.bodyMedium,
      );
    }
    return _ExpenseTargetChip(
      key: const ValueKey('expense-target'),
      label: widget.trip.name,
      onTap: () async {
        FocusScope.of(formContext).unfocus();
        final target = await pick(formContext, widget.trip);
        if (target == null ||
            target.trip?.id == widget.trip.id ||
            !formContext.mounted) {
          return;
        }
        final carried = draft().withoutPeople();
        Navigator.of(formContext).pop();
        onChanged(target, carried);
      },
    );
  }
}

/// The Add expense form, for a trip or a quick split.
Future<_ExpenseFormResult?> _showExpenseFormPage(
  BuildContext context, {
  required _ExpenseFormSetup setup,
  required List<WorkspaceUser> initialUsers,
  required Future<bool> Function(BuildContext, _ExpenseFormResult) onSubmit,
  _ExpenseFormSeed? seed,
}) async {
  final hostContext = context;
  final users = [...initialUsers];
  final isSolo = setup.isSolo;
  final ownerId = setup.soloOwnerId;
  final isEdit = seed?.isEdit ?? false;
  final amountController = TextEditingController(
    text: seed?.amount != null
        ? AppCurrencyCatalog.amountInputText(
            seed!.amount!,
            seed.currencyCode ?? setup.defaultCurrencyCode,
          )
        : '',
  );
  final noteController = TextEditingController(text: seed?.note ?? '');
  final initialCategory = (seed?.category ?? '').trim().isNotEmpty
      ? ExpenseCategoryCatalog.normalizeStored(seed!.category)
      : '';
  var isCustomCategoryMode =
      initialCategory.isNotEmpty &&
      !ExpenseCategoryCatalog.isBuiltInKey(initialCategory);
  var selectedCategory = isCustomCategoryMode ? '' : initialCategory;
  var selectedType = ExpenseTypeCatalog.clean(seed?.subcategory);
  var typeWasChosen = selectedType != null;
  // The type menu opens right under the category field.
  final typeAnchorKey = GlobalKey();
  final customCategoryController = TextEditingController(
    text: isCustomCategoryMode ? initialCategory : '',
  );
  DateTime? parseExpenseDate(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed =
        DateTime.tryParse(trimmed) ??
        DateTime.tryParse(trimmed.split(' ').first);
    if (parsed == null) {
      return null;
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  String? toIsoDate(DateTime? value) {
    if (value == null) {
      return null;
    }
    final normalized = DateTime(value.year, value.month, value.day);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }

  final now = DateTime.now();
  DateTime selectedExpenseDate =
      parseExpenseDate(seed?.date) ?? DateTime(now.year, now.month, now.day);
  var selectedCurrencyCode = AppCurrencyCatalog.normalize(
    seed?.currencyCode ?? setup.defaultCurrencyCode,
  );

  final selected = isSolo
      ? <int>{ownerId}
      : (seed?.participantIds ?? const <int>[]).toSet();
  final rawSplitMode = (seed?.splitMode ?? 'equal').trim().toLowerCase();
  var selectedPayerId = seed?.payerId ?? setup.currentUserId;
  var itemDrafts = seed?.items ?? const <ExpenseItem>[];
  var extraDraft = seed?.extraAmount ?? 0.0;
  var splitMode = isSolo
      ? 'equal'
      : (_legacySplitMode(rawSplitMode) ? 'exact' : rawSplitMode);
  final splitControllers = <int, TextEditingController>{};
  if (seed != null && splitMode != 'equal' && splitMode != 'itemized') {
    for (final entry in seed.splitValues.entries) {
      final value = entry.value;
      splitControllers[entry.key] = TextEditingController(
        text: value != null ? _formatNumericInput(value) : '',
      );
    }
  }

  const customCategoryDropdownValue = '__custom_category__';

  Uint8List? selectedReceiptBytes;
  Uint8List? receiptPreviewBytes;
  UploadedReceiptData? preuploadedReceipt = seed?.receipt;
  String? selectedReceiptName = preuploadedReceipt != null
      ? context.l10n.receiptFallbackName
      : null;
  bool isReceiptUploading = false;
  bool isReceiptPicking = false;
  bool isReceiptReading = false;
  String? receiptUploadHint;
  bool removeExistingReceipt = false;
  bool isSaving = false;
  String? errorText;
  AppFormPageRoute<_ExpenseFormResult>? route;
  try {
    return await Navigator.of(context).push<_ExpenseFormResult>(
      route = AppFormPageRoute<_ExpenseFormResult>(
        builder: (sheetContext) {
          final t = sheetContext.l10n;
          String formatExpenseDate(DateTime value) {
            final dd = value.day.toString().padLeft(2, '0');
            final mm = value.month.toString().padLeft(2, '0');
            final yyyy = value.year.toString().padLeft(4, '0');
            return '$dd.$mm.$yyyy';
          }

          Future<String?> pickCurrencyCode(
            BuildContext dialogContext,
            String currentCode,
          ) => showAppCurrencyPicker(
            context: dialogContext,
            selectedCode: currentCode,
            title: context.l10n.workspaceCurrency,
            searchKey: const ValueKey('expense-currency-search'),
          );

          String splitModeLabel(String mode) {
            switch (mode) {
              case 'exact':
                return t.exactAmountsLabel;
              case 'percent':
                return t.percentagesLabel;
              case 'shares':
                return t.sharesLabel;
              case 'adjustment':
                return t.expenseAdjustmentsLabel;
              case 'itemized':
                return t.expenseItemsLabel;
              default:
                return t.equalSplitLabel;
            }
          }

          IconData splitModeIcon(String mode) {
            switch (mode) {
              case 'exact':
                return Icons.payments_outlined;
              case 'percent':
                return Icons.percent_rounded;
              case 'shares':
                return Icons.pie_chart_outline_rounded;
              case 'adjustment':
                return Icons.exposure_rounded;
              case 'itemized':
                return Icons.receipt_long_rounded;
              default:
                return Icons.balance_rounded;
            }
          }

          Future<String?> pickCategoryValue(
            BuildContext dialogContext,
            String? currentValue,
          ) {
            final current = (currentValue ?? '').trim();
            final options = [
              ...ExpenseCategoryCatalog.builtIn.map(
                (option) => (
                  value: option.key,
                  label: ExpenseCategoryCatalog.labelFor(
                    option.key,
                    Localizations.localeOf(dialogContext),
                  ),
                  icon: option.icon,
                ),
              ),
              (
                value: customCategoryDropdownValue,
                label: context.l10n.workspaceCustomCategory,
                icon: Icons.add_rounded,
              ),
            ];

            return showAppBottomSheet<String>(
              context: dialogContext,
              builder: (pickerContext) {
                return AppActionSheet(
                  key: const ValueKey('expense-category-picker'),
                  title: context.l10n.workspaceCategory,
                  children: [
                    for (final option in options) ...[
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        leading: Icon(option.icon),
                        title: Text(option.label),
                        selected: option.value == current,
                        trailing: option.value == current
                            ? Icon(
                                Icons.check,
                                color: Theme.of(
                                  pickerContext,
                                ).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(pickerContext, option.value),
                      ),
                      if (option != options.last) const Divider(height: 1),
                    ],
                  ],
                );
              },
            );
          }

          return StatefulBuilder(
            builder: (context, setDialogState) {
              AppCurrencyOption selectedCurrency =
                  AppCurrencyCatalog.supported.first;
              for (final item in AppCurrencyCatalog.supported) {
                if (item.code == selectedCurrencyCode) {
                  selectedCurrency = item;
                  break;
                }
              }
              final normalizedSelectedCategory =
                  ExpenseCategoryCatalog.normalizeStored(selectedCategory);
              String? categoryDropdownValue;
              if (isCustomCategoryMode) {
                categoryDropdownValue = customCategoryDropdownValue;
              } else if (selectedCategory.trim().isNotEmpty &&
                  ExpenseCategoryCatalog.isBuiltInKey(
                    normalizedSelectedCategory,
                  )) {
                categoryDropdownValue = normalizedSelectedCategory;
              }
              final selectedCategoryValue =
                  categoryDropdownValue ??
                  ExpenseCategoryCatalog.builtIn.last.key;
              final selectedCategoryLabel = isCustomCategoryMode
                  ? (customCategoryController.text.trim().isEmpty
                        ? context.l10n.workspaceCustomCategory
                        : customCategoryController.text.trim())
                  : ExpenseCategoryCatalog.labelFor(
                      selectedCategoryValue,
                      Localizations.localeOf(context),
                    );
              final selectedCategoryIcon = isCustomCategoryMode
                  ? Icons.add_rounded
                  : selectedCategory.isEmpty
                  ? Icons.category_outlined
                  : ExpenseCategoryCatalog.iconFor(selectedCategoryValue);
              final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
              final activeUsers = users
                  .where(
                    (user) =>
                        user.id > 0 &&
                        (selected.isEmpty || selected.contains(user.id)),
                  )
                  .toList();
              final payerId = selectedPayerId;
              final payerChoices = setup.payerChoices(users);
              final canChoosePayer = !isSolo && payerChoices.length > 1;
              Future<void> choosePayer() async {
                FocusScope.of(context).unfocus();
                final picked = await showAppBottomSheet<int>(
                  context: context,
                  builder: (sheetContext) => AppActionSheet(
                    key: const ValueKey('expense-payer-sheet'),
                    title: t.paidByLabel,
                    children: [
                      for (final user in payerChoices)
                        AppPlainActionTile(
                          key: ValueKey('expense-payer-${user.id}'),
                          icon: user.id == selectedPayerId
                              ? Icons.check_rounded
                              : Icons.person_outline_rounded,
                          title: user.preferredName,
                          onTap: () => Navigator.of(sheetContext).pop(user.id),
                        ),
                    ],
                  ),
                );
                if (picked == null || !context.mounted) return;
                setDialogState(() => selectedPayerId = picked);
              }

              final payer = users
                  .where((user) => user.id == payerId)
                  .firstOrNull;
              final payerName = payer?.preferredName ?? t.youLabel;
              Widget memberAvatar(WorkspaceUser user) => _memberAvatarFor(
                context,
                name: user.preferredName,
                avatarUrl: user.avatarThumbUrl ?? user.avatarUrl,
                size: 30,
              );

              final receiptBusy =
                  isSaving ||
                  isReceiptPicking ||
                  isReceiptUploading ||
                  isReceiptReading;
              ExpenseDraft currentDraft() {
                final amount = _parseAmount(amountController.text);
                final category = isCustomCategoryMode
                    ? customCategoryController.text.trim()
                    : selectedCategory.trim();
                return ExpenseDraft(
                  amount: amount > 0 ? amount : null,
                  currencyCode: selectedCurrencyCode,
                  note: noteController.text.trim(),
                  category: category,
                  subcategory: selectedType,
                  date: toIsoDate(selectedExpenseDate),
                  receipt: preuploadedReceipt,
                  payerUserId: payerId,
                  participantUserIds: activeUsers
                      .map((user) => user.id)
                      .toList(),
                  splitMode: splitMode,
                  splitValues: {
                    for (final entry in splitControllers.entries)
                      entry.key: entry.value.text.trim().isEmpty
                          ? null
                          : _parseAmount(entry.value.text),
                  },
                  items: splitMode == 'itemized' ? itemDrafts : const [],
                  extraAmount: splitMode == 'itemized' ? extraDraft : 0,
                );
              }

              final hasSavedReceipt =
                  (seed?.hasSavedReceipt ?? false) &&
                  setup.loadSavedReceipt != null &&
                  !removeExistingReceipt;
              Future<void> pickReceipt() async {
                FocusScope.of(context).unfocus();
                setDialogState(() => isReceiptPicking = true);
                final picked = await _pickReceiptPhoto(
                  context,
                  currentAccountId: setup.currentAccountId,
                );
                if (!context.mounted) return;
                setDialogState(() => isReceiptPicking = false);
                if (picked == null) return;
                setDialogState(() {
                  selectedReceiptBytes = picked.bytes;
                  receiptPreviewBytes = picked.bytes;
                  selectedReceiptName = picked.fileName;
                  preuploadedReceipt = null;
                  receiptUploadHint = null;
                  isReceiptUploading = true;
                  removeExistingReceipt = false;
                });
                try {
                  final uploaded = await setup.uploadReceipt(
                    picked.fileName,
                    picked.bytes,
                  );
                  if (!context.mounted) return;
                  setDialogState(() {
                    preuploadedReceipt = uploaded;
                    selectedReceiptBytes = null;
                    isReceiptUploading = false;
                  });
                } on ApiException catch (error) {
                  if (!context.mounted) return;
                  setDialogState(() {
                    isReceiptUploading = false;
                    preuploadedReceipt = null;
                    receiptUploadHint = error.isNetworkError
                        ? t.expenseReceiptUploadOnSave
                        : error.message;
                  });
                } catch (_) {
                  if (!context.mounted) return;
                  setDialogState(() {
                    isReceiptUploading = false;
                    preuploadedReceipt = null;
                    receiptUploadHint = t.expenseReceiptUploadOnSave;
                  });
                }
              }

              // AI receipt reading, asked for from "By item": takes a photo
              // first when there is none, reads it and sets currency, date
              // and note here; the editor fills its lines from the result.
              // Nothing is saved until the user saves the expense.
              Future<_ReceiptFill?> fillFromReceipt(bool rescan) async {
                final scan = setup.scanReceipt;
                final account = setup.currentAccountId();
                if (scan == null || account == null || isReceiptReading) {
                  return null;
                }
                bool stillHere() =>
                    context.mounted && setup.currentAccountId() == account;
                if (preuploadedReceipt == null) {
                  await pickReceipt();
                  if (!stillHere()) return null;
                  if (preuploadedReceipt == null) {
                    final hint = receiptUploadHint;
                    return hint == null ? null : _ReceiptFill(message: hint);
                  }
                }
                final receipt = preuploadedReceipt!;
                // The same id never starts a second AI call; asking again
                // returns the result once the server has it.
                final requestId =
                    'rs_${account}_${DateTime.now().microsecondsSinceEpoch}';
                setDialogState(() => isReceiptReading = true);
                final deadline = DateTime.now().add(
                  const Duration(seconds: 75),
                );
                ReceiptScan? result;
                String? failure;
                while (true) {
                  try {
                    result = await scan(receipt.path, requestId, rescan);
                    break;
                  } on ApiException catch (error) {
                    final again =
                        error.isNetworkError ||
                        error.code == 'scan_in_progress';
                    if (!again || DateTime.now().isAfter(deadline)) {
                      failure = error.isNetworkError
                          ? t.receiptAiFailed
                          : error.message;
                      break;
                    }
                  } catch (_) {
                    failure = t.receiptAiFailed;
                    break;
                  }
                  await Future<void>.delayed(const Duration(seconds: 3));
                  if (!stillHere()) return null;
                }
                if (!stillHere()) return null;
                setDialogState(() => isReceiptReading = false);
                final scanned = result;
                if (scanned == null) {
                  return _ReceiptFill(message: failure ?? t.receiptAiFailed);
                }
                if (!scanned.isReceipt) {
                  return _ReceiptFill(message: t.receiptAiNotReceipt);
                }
                final draft = scanned.splitDraft();
                if (draft == null) {
                  return _ReceiptFill(message: t.receiptAiNoItems);
                }
                setDialogState(() {
                  selectedCurrencyCode = AppCurrencyCatalog.normalize(
                    scanned.currencyCode,
                    fallback: selectedCurrencyCode,
                  );
                  final date = parseExpenseDate(scanned.date);
                  if (date != null) selectedExpenseDate = date;
                  final category = scanned.category?.trim() ?? '';
                  if (!isCustomCategoryMode &&
                      selectedCategory.isEmpty &&
                      category.isNotEmpty &&
                      category != 'other' &&
                      ExpenseCategoryCatalog.builtIn.any(
                        (option) => option.key == category,
                      )) {
                    selectedCategory = category;
                    selectedType = null;
                  }
                  final type = scanned.subcategory;
                  if (!isCustomCategoryMode &&
                      selectedCategory == category &&
                      selectedType == null &&
                      !typeWasChosen &&
                      type != null &&
                      ExpenseTypeCatalog.forCategory(
                        category,
                      ).any((option) => option.key == type)) {
                    selectedType = type;
                  }
                  final merchant = scanned.merchant;
                  if (noteController.text.trim().isEmpty && merchant != null) {
                    noteController.text = merchant;
                  }
                  errorText = null;
                });
                return _ReceiptFill(
                  draft: draft,
                  receiptTotalCents: scanned.totalCents,
                  currencyCode: selectedCurrencyCode,
                  message: !scanned.sumMatches
                      ? t.receiptAiTotalsMismatch
                      : scanned.hasUncertainItems
                      ? t.receiptAiCheckItems
                      : null,
                );
              }

              Future<void> editSplit([String? startMode]) async {
                final amount = _parseAmount(amountController.text);
                if (activeUsers.isEmpty) {
                  setDialogState(() {
                    errorText = t.pickAtLeastOneParticipant;
                  });
                  return;
                }
                FocusManager.instance.primaryFocus?.unfocus();
                final result = await Navigator.of(context)
                    .push<_ExpenseSplitDraft>(
                      AppFormPageRoute<_ExpenseSplitDraft>(
                        builder: (_) => _ExpenseSplitPage(
                          child: _ExpenseSplitEditor(
                            users: activeUsers,
                            amount: amount,
                            currencyCode: selectedCurrencyCode,
                            initialMode: startMode ?? splitMode,
                            initialItems: itemDrafts,
                            initialExtra: extraDraft,
                            initialValues: {
                              for (final entry in splitControllers.entries)
                                entry.key: entry.value.text,
                            },
                            avatarBuilder: memberAvatar,
                            scanReceipt: setup.scanReceipt == null
                                ? null
                                : fillFromReceipt,
                            addPerson: setup.addPerson == null
                                ? null
                                : () async {
                                    final person = await setup.addPerson!(
                                      context,
                                      users,
                                    );
                                    if (person == null || !context.mounted) {
                                      return null;
                                    }
                                    setDialogState(() {
                                      users.add(person);
                                      if (selected.isNotEmpty) {
                                        selected.add(person.id);
                                      }
                                      errorText = null;
                                    });
                                    return person;
                                  },
                          ),
                        ),
                      ),
                    );
                if (!hostContext.mounted ||
                    !context.mounted ||
                    result == null) {
                  return;
                }
                setDialogState(() {
                  splitMode = result.mode;
                  if (result.mode == 'itemized') {
                    itemDrafts = result.items;
                    extraDraft = result.extra;
                    final total = result.items.fold<double>(
                      result.extra,
                      (sum, item) => sum + item.amount,
                    );
                    amountController.text = AppCurrencyCatalog.amountInputText(
                      total,
                      selectedCurrencyCode,
                    );
                  }
                  for (final entry in result.values.entries) {
                    splitControllers
                        .putIfAbsent(entry.key, () => TextEditingController())
                        .text = entry
                        .value;
                  }
                  errorText = null;
                });
              }

              // The list of methods; Equal stays in the form, the others open
              // on their own page. Only "By item" works out the amount
              // itself, so the others need it first.
              Future<void> chooseSplitMethod() async {
                if (activeUsers.isEmpty) {
                  setDialogState(() {
                    errorText = t.pickAtLeastOneParticipant;
                  });
                  return;
                }
                // Whatever field had the keyboard (note, a name) gives it up.
                FocusManager.instance.primaryFocus?.unfocus();
                final picked = await showAppBottomSheet<String>(
                  context: context,
                  builder: (_) => _ExpenseSplitModePicker(
                    options: [
                      (
                        'equal',
                        t.equalSplitLabel,
                        t.splitHintEqual,
                        Icons.balance_rounded,
                      ),
                      ..._ExpenseSplitEditorState._modeOptions(context),
                    ],
                    selected: splitMode,
                  ),
                );
                if (picked == null || !context.mounted) return;
                if (picked == 'equal') {
                  setDialogState(() {
                    splitMode = 'equal';
                    errorText = null;
                  });
                  return;
                }
                if (picked != 'itemized' &&
                    _parseAmount(amountController.text) <= 0) {
                  setDialogState(() => errorText = t.expenseSplitAmountFirst);
                  return;
                }
                await editSplit(picked);
              }

              return PopScope(
                canPop: !isSaving,
                child: AppFormScaffold(
                  child: SizedBox.expand(
                    child: Column(
                      children: [
                        Expanded(
                          child: AbsorbPointer(
                            absorbing: isSaving,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      8,
                                      20,
                                      16,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          onPressed: isSaving
                                              ? null
                                              : () => Navigator.of(
                                                  sheetContext,
                                                ).pop(),
                                          tooltip: MaterialLocalizations.of(
                                            context,
                                          ).closeButtonTooltip,
                                          icon: const Icon(Icons.close),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                !isEdit
                                                    ? t.addExpenseTitle
                                                    : t.editExpenseTitle,
                                                style: keyboardOpen
                                                    ? Theme.of(
                                                        context,
                                                      ).textTheme.titleMedium
                                                    : Theme.of(
                                                        context,
                                                      ).textTheme.headlineSmall,
                                              ),
                                              if (!keyboardOpen) ...[
                                                const SizedBox(height: 4),
                                                setup.subtitle(
                                                  context,
                                                  currentDraft,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _ExpenseAmountRow(
                                    leading: _ExpenseReceiptButton(
                                      onPressed: receiptBusy
                                          ? null
                                          : pickReceipt,
                                      hasReceipt:
                                          selectedReceiptName != null ||
                                          hasSavedReceipt,
                                      busy:
                                          isReceiptPicking ||
                                          isReceiptUploading,
                                    ),
                                    amount: Semantics(
                                      label: t.amountLabel,
                                      child: TextField(
                                        controller: amountController,
                                        key: const ValueKey(
                                          'expense-form-amount',
                                        ),
                                        onChanged: (_) => setDialogState(() {}),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(
                                              fontSize: 48,
                                              fontWeight: FontWeight.w700,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                              decimal:
                                                  selectedCurrency
                                                      .decimalDigits >
                                                  0,
                                            ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                          hintText: '0.00',
                                          prefixText:
                                              '${selectedCurrency.symbol} ',
                                          filled: false,
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    currency: _ExpenseFormSelector(
                                      compact: true,
                                      label: context.l10n.workspaceCurrency,
                                      value: selectedCurrency.code,
                                      icon: Icons.currency_exchange,
                                      onTap: () async {
                                        FocusScope.of(context).unfocus();
                                        final picked = await pickCurrencyCode(
                                          sheetContext,
                                          selectedCurrencyCode,
                                        );
                                        if (!hostContext.mounted ||
                                            !context.mounted ||
                                            picked == null) {
                                          return;
                                        }
                                        setDialogState(() {
                                          selectedCurrencyCode =
                                              AppCurrencyCatalog.normalize(
                                                picked,
                                              );
                                        });
                                      },
                                    ),
                                  ),
                                  TextField(
                                    controller: noteController,
                                    textAlign: TextAlign.center,
                                    minLines: 1,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: t.noteHint,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                      labelText: t.noteLabel,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      filled: false,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final hasTypes =
                                          !isCustomCategoryMode &&
                                          ExpenseTypeCatalog.hasTypes(
                                            selectedCategory,
                                          );
                                      Future<void> pickType() async {
                                        FocusScope.of(context).unfocus();
                                        final box =
                                            typeAnchorKey.currentContext
                                                    ?.findRenderObject()
                                                as RenderBox?;
                                        if (box == null || !box.hasSize) {
                                          return;
                                        }
                                        final choice =
                                            await _showExpenseTypeMenu(
                                              context: sheetContext,
                                              anchor:
                                                  box.localToGlobal(
                                                    Offset.zero,
                                                  ) &
                                                  box.size,
                                              category: selectedCategory,
                                              selected: selectedType,
                                              tripTypes: _tripCustomTypes(
                                                setup.typeSources,
                                                selectedCategory,
                                              ),
                                            );
                                        if (!hostContext.mounted ||
                                            !context.mounted ||
                                            choice == null) {
                                          return;
                                        }
                                        setDialogState(() {
                                          selectedType = choice.type;
                                          typeWasChosen = true;
                                        });
                                      }

                                      final category = KeyedSubtree(
                                        key: typeAnchorKey,
                                        child: _ExpenseCompactTile(
                                          key: const ValueKey(
                                            'expense-category',
                                          ),
                                          label: t.workspaceCategory,
                                          value:
                                              selectedCategory.isEmpty &&
                                                  !isCustomCategoryMode
                                              ? t.workspaceChooseCategory
                                              : selectedCategoryLabel,
                                          type: hasTypes && selectedType != null
                                              ? _expenseTypeLabel(
                                                  context,
                                                  selectedType!,
                                                )
                                              : null,
                                          trailing: hasTypes
                                              ? _ExpenseTypeButton(
                                                  hasType: selectedType != null,
                                                  onTap: pickType,
                                                )
                                              : null,
                                          icon: selectedCategoryIcon,
                                          onTap: () async {
                                            FocusScope.of(context).unfocus();
                                            final value =
                                                await pickCategoryValue(
                                                  sheetContext,
                                                  categoryDropdownValue,
                                                );
                                            if (!hostContext.mounted ||
                                                !context.mounted ||
                                                value == null) {
                                              return;
                                            }
                                            setDialogState(() {
                                              isCustomCategoryMode =
                                                  value ==
                                                  customCategoryDropdownValue;
                                              if (value != selectedCategory) {
                                                // A type belongs to its category.
                                                selectedType = null;
                                                typeWasChosen = false;
                                              }
                                              selectedCategory =
                                                  isCustomCategoryMode
                                                  ? ''
                                                  : value;
                                              if (!isCustomCategoryMode) {
                                                customCategoryController
                                                    .clear();
                                              }
                                              errorText = null;
                                            });
                                          },
                                        ),
                                      );
                                      final date = _ExpenseCompactTile(
                                        key: const ValueKey('expense-date'),
                                        label: t.dateLabel,
                                        value: formatExpenseDate(
                                          selectedExpenseDate,
                                        ),
                                        icon: Icons.calendar_today_outlined,
                                        onTap: () async {
                                          FocusScope.of(context).unfocus();
                                          final picked = await showDatePicker(
                                            context: sheetContext,
                                            initialDate: selectedExpenseDate,
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2100),
                                          );
                                          if (!hostContext.mounted ||
                                              !context.mounted ||
                                              picked == null) {
                                            return;
                                          }
                                          setDialogState(() {
                                            selectedExpenseDate = DateTime(
                                              picked.year,
                                              picked.month,
                                              picked.day,
                                            );
                                          });
                                        },
                                      );
                                      if (constraints.maxWidth < 300 ||
                                          MediaQuery.textScalerOf(
                                                context,
                                              ).scale(16) >
                                              24) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            category,
                                            const SizedBox(height: 8),
                                            date,
                                          ],
                                        );
                                      }
                                      return Row(
                                        children: [
                                          Expanded(child: category),
                                          const SizedBox(width: 10),
                                          Expanded(child: date),
                                        ],
                                      );
                                    },
                                  ),
                                  if (isCustomCategoryMode) ...[
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: customCategoryController,
                                      decoration: InputDecoration(
                                        labelText: t.workspaceCustomCategory,
                                        hintText:
                                            t.workspaceApartmentRentParkingEtc,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 18),
                                  const Divider(height: 1),
                                  if (!isSolo) ...[
                                    InkWell(
                                      key: const ValueKey('expense-payer'),
                                      onTap: canChoosePayer
                                          ? choosePayer
                                          : null,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            _memberAvatarFor(
                                              context,
                                              name: payerName,
                                              avatarUrl:
                                                  payer?.avatarThumbUrl ??
                                                  payer?.avatarUrl,
                                              size: 36,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                t.paidByLabel,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Flexible(
                                              child: Text(
                                                payerName,
                                                textAlign: TextAlign.end,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleSmall,
                                              ),
                                            ),
                                            if (canChoosePayer) ...[
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Icons.chevron_right_rounded,
                                                size: 20,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    Padding(
                                      key: const ValueKey(
                                        'expense-participants',
                                      ),
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.expenseSplitBetween,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 10),
                                          // Everyone is in by default; a tap
                                          // takes a person out or back in.
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 10,
                                            children: [
                                              for (final user in users.where(
                                                (user) => user.id > 0,
                                              ))
                                                AppPersonToggle(
                                                  key: ValueKey(
                                                    'expense-participant-${user.id}',
                                                  ),
                                                  name: user.preferredName,
                                                  avatar: memberAvatar(user),
                                                  selected: activeUsers.any(
                                                    (active) =>
                                                        active.id == user.id,
                                                  ),
                                                  onChanged: (on) {
                                                    final next = activeUsers
                                                        .map((u) => u.id)
                                                        .toSet();
                                                    on
                                                        ? next.add(user.id)
                                                        : next.remove(user.id);
                                                    setDialogState(() {
                                                      if (next.isEmpty) {
                                                        errorText = t
                                                            .pickAtLeastOneParticipant;
                                                        return;
                                                      }
                                                      selected
                                                        ..clear()
                                                        ..addAll(next);
                                                      errorText = null;
                                                    });
                                                  },
                                                ),
                                              if (setup.addPerson != null)
                                                _ExpenseAddPersonButton(
                                                  onTap: () async {
                                                    FocusScope.of(
                                                      context,
                                                    ).unfocus();
                                                    final person =
                                                        await setup.addPerson!(
                                                          context,
                                                          users,
                                                        );
                                                    if (person == null ||
                                                        !context.mounted) {
                                                      return;
                                                    }
                                                    setDialogState(() {
                                                      users.add(person);
                                                      if (selected.isNotEmpty) {
                                                        selected.add(person.id);
                                                      }
                                                      errorText = null;
                                                    });
                                                  },
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      t.splitModeLabel,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 6),
                                    // One row: the method, then a list of
                                    // methods; anything but Equal opens on
                                    // its own page.
                                    _ExpenseCompactTile(
                                      key: const ValueKey(
                                        'expense-custom-split',
                                      ),
                                      label: t.splitModeLabel,
                                      value: splitModeLabel(splitMode),
                                      icon: splitModeIcon(splitMode),
                                      detail: splitMode == 'equal'
                                          ? t.splitHintEqual
                                          : splitMode == 'itemized'
                                          ? itemDrafts
                                                .map((item) => item.name)
                                                .join(' · ')
                                          : activeUsers
                                                .map((user) {
                                                  final raw =
                                                      splitControllers[user.id]
                                                          ?.text
                                                          .trim() ??
                                                      '';
                                                  final value = raw.isEmpty
                                                      ? '—'
                                                      : splitMode == 'exact' ||
                                                            splitMode ==
                                                                'adjustment'
                                                      ? _formatMoney(
                                                          context,
                                                          _parseAmount(raw),
                                                          currencyCode:
                                                              selectedCurrencyCode,
                                                        )
                                                      : '$raw${splitMode == 'percent' ? '%' : ' ${t.shareUnit}'}';
                                                  return '${user.preferredName} $value';
                                                })
                                                .join(' · '),
                                      onTap: chooseSplitMethod,
                                    ),
                                    const SizedBox(height: 18),
                                    const Divider(height: 1),
                                  ],
                                  if (removeExistingReceipt) ...[
                                    const SizedBox(height: 12),
                                    TextButton.icon(
                                      onPressed: receiptBusy
                                          ? null
                                          : () => setDialogState(
                                              () =>
                                                  removeExistingReceipt = false,
                                            ),
                                      icon: const Icon(Icons.undo),
                                      label: Text(t.restoreReceiptAction),
                                    ),
                                  ],
                                  if (selectedReceiptName != null) ...[
                                    const SizedBox(height: 12),
                                    ReceiptAttachmentCard(
                                      fileName: selectedReceiptName!,
                                      bytes: receiptPreviewBytes,
                                      busy: isReceiptUploading,
                                      enabled: !isReceiptPicking && !isSaving,
                                      status: receiptUploadHint,
                                      onRemove: () => setDialogState(() {
                                        selectedReceiptBytes = null;
                                        receiptPreviewBytes = null;
                                        selectedReceiptName = null;
                                        preuploadedReceipt = null;
                                        receiptUploadHint = null;
                                      }),
                                    ),
                                  ] else if (hasSavedReceipt) ...[
                                    const SizedBox(height: 12),
                                    ReceiptAttachmentCard(
                                      fileName: t.receiptFallbackName,
                                      saved: true,
                                      enabled: !isReceiptPicking && !isSaving,
                                      onRemove: () => setDialogState(
                                        () => removeExistingReceipt = true,
                                      ),
                                      openAction: ReceiptOpenAction(
                                        load: () async {
                                          final account = setup
                                              .currentAccountId();
                                          final uri =
                                              await setup.loadSavedReceipt!();
                                          if (!hostContext.mounted ||
                                              !context.mounted ||
                                              setup.currentAccountId() !=
                                                  account) {
                                            return null;
                                          }
                                          return uri;
                                        },
                                        open: (uri) => launchUrl(
                                          uri,
                                          mode: LaunchMode.inAppBrowserView,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (errorText != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 80),
                              child: SingleChildScrollView(
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    errorText!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (isSaving) const LinearProgressIndicator(),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      isSaving ||
                                          isReceiptPicking ||
                                          isReceiptUploading
                                      ? null
                                      : () async {
                                          if (isSaving ||
                                              isReceiptPicking ||
                                              isReceiptUploading) {
                                            return;
                                          }
                                          final amount = _parseAmount(
                                            amountController.text,
                                          );
                                          final date = toIsoDate(
                                            selectedExpenseDate,
                                          );
                                          final note = noteController.text
                                              .trim();
                                          final rawCategory =
                                              isCustomCategoryMode
                                              ? customCategoryController.text
                                                    .trim()
                                              : selectedCategory.trim();

                                          if (!amount.isFinite || amount <= 0) {
                                            setDialogState(() {
                                              errorText =
                                                  t.amountMustBeGreaterThanZero;
                                            });
                                            return;
                                          }

                                          if (date == null || date.isEmpty) {
                                            setDialogState(() {
                                              errorText = t.dateMustMatchFormat;
                                            });
                                            return;
                                          }

                                          if (rawCategory.isEmpty) {
                                            setDialogState(() {
                                              errorText = isCustomCategoryMode
                                                  ? context
                                                        .l10n
                                                        .workspaceEnterACustomCategory
                                                  : context
                                                        .l10n
                                                        .workspacePickAnExpenseCategory;
                                            });
                                            return;
                                          }

                                          if (isCustomCategoryMode &&
                                              rawCategory.length < 2) {
                                            setDialogState(() {
                                              errorText = context
                                                  .l10n
                                                  .workspaceCategoryMustBeAtLeast2Characters;
                                            });
                                            return;
                                          }

                                          final category =
                                              ExpenseCategoryCatalog.normalizeStored(
                                                rawCategory,
                                              );
                                          if (category.length > 64) {
                                            setDialogState(() {
                                              errorText = context
                                                  .l10n
                                                  .workspaceCategoryMustBeUpTo64Characters;
                                            });
                                            return;
                                          }

                                          if (note.length > 255) {
                                            setDialogState(() {
                                              errorText = t.noteMustBeMaxChars(
                                                255,
                                              );
                                            });
                                            return;
                                          }

                                          final participants = selected.toList(
                                            growable: false,
                                          )..sort();
                                          final resolvedParticipants =
                                              participants.isNotEmpty
                                                    ? participants
                                                    : users
                                                          .map(
                                                            (user) => user.id,
                                                          )
                                                          .where((id) => id > 0)
                                                          .toList(
                                                            growable: false,
                                                          )
                                                ..sort();
                                          final amountCents = (amount * 100)
                                              .round();
                                          final splitValues =
                                              <ExpenseSplitValue>[];

                                          if (splitMode != 'equal') {
                                            if (resolvedParticipants.isEmpty) {
                                              setDialogState(() {
                                                errorText =
                                                    t.pickAtLeastOneParticipant;
                                              });
                                              return;
                                            }

                                            if (splitMode == 'exact') {
                                              var totalCents = 0;
                                              for (final userId
                                                  in resolvedParticipants) {
                                                final controller =
                                                    splitControllers[userId];
                                                final raw =
                                                    controller?.text.trim() ??
                                                    '';
                                                final value = _parseAmount(raw);
                                                if (raw.isEmpty || value < 0) {
                                                  setDialogState(() {
                                                    errorText = t
                                                        .enterValidExactAmounts;
                                                  });
                                                  return;
                                                }
                                                totalCents += (value * 100)
                                                    .round();
                                                splitValues.add(
                                                  ExpenseSplitValue(
                                                    userId: userId,
                                                    value: value,
                                                  ),
                                                );
                                              }
                                              if (totalCents != amountCents) {
                                                setDialogState(() {
                                                  errorText = t
                                                      .exactSplitMustMatchTotal(
                                                        _formatMoney(
                                                          context,
                                                          amount,
                                                          currencyCode:
                                                              selectedCurrencyCode,
                                                        ),
                                                      );
                                                });
                                                return;
                                              }
                                            } else if (splitMode == 'percent') {
                                              var totalBasisPoints = 0;
                                              for (final userId
                                                  in resolvedParticipants) {
                                                final controller =
                                                    splitControllers[userId];
                                                final raw =
                                                    controller?.text.trim() ??
                                                    '';
                                                final value = _parseAmount(raw);
                                                if (raw.isEmpty || value < 0) {
                                                  setDialogState(() {
                                                    errorText = context
                                                        .l10n
                                                        .enterValidPercentages;
                                                  });
                                                  return;
                                                }
                                                final basisPoints =
                                                    (value * 100).round();
                                                totalBasisPoints += basisPoints;
                                                splitValues.add(
                                                  ExpenseSplitValue(
                                                    userId: userId,
                                                    value: basisPoints / 100,
                                                  ),
                                                );
                                              }
                                              if (totalBasisPoints != 10000) {
                                                setDialogState(() {
                                                  errorText = context
                                                      .l10n
                                                      .workspacePercentageSplitMustTotal100;
                                                });
                                                return;
                                              }
                                            } else if (splitMode ==
                                                'adjustment') {
                                              final adjustments = <int, int>{};
                                              for (final userId
                                                  in resolvedParticipants) {
                                                final value = _parseAmount(
                                                  splitControllers[userId]
                                                          ?.text ??
                                                      '',
                                                );
                                                adjustments[userId] =
                                                    (value * 100).round();
                                                splitValues.add(
                                                  ExpenseSplitValue(
                                                    userId: userId,
                                                    value: value,
                                                  ),
                                                );
                                              }
                                              if (adjustmentOwedCents(
                                                    amountCents,
                                                    resolvedParticipants,
                                                    adjustments,
                                                  ) ==
                                                  null) {
                                                setDialogState(() {
                                                  errorText = t
                                                      .expenseAdjustmentsMustFit;
                                                });
                                                return;
                                              }
                                            } else if (splitMode ==
                                                'itemized') {
                                              final itemsCents = itemDrafts
                                                  .fold<int>(
                                                    (extraDraft * 100).round(),
                                                    (sum, item) =>
                                                        sum +
                                                        (item.amount * 100)
                                                            .round(),
                                                  );
                                              if (itemDrafts.isEmpty ||
                                                  itemsCents != amountCents) {
                                                setDialogState(() {
                                                  errorText = t
                                                      .expenseItemsMustMatchTotal(
                                                        _formatMoney(
                                                          context,
                                                          amount,
                                                          currencyCode:
                                                              selectedCurrencyCode,
                                                        ),
                                                      );
                                                });
                                                return;
                                              }
                                            } else if (splitMode == 'shares') {
                                              for (final userId
                                                  in resolvedParticipants) {
                                                final controller =
                                                    splitControllers[userId];
                                                final raw =
                                                    controller?.text.trim() ??
                                                    '';
                                                final value = _parseAmount(raw);
                                                final rounded = value.round();
                                                if (raw.isEmpty ||
                                                    rounded <= 0) {
                                                  setDialogState(() {
                                                    errorText = context
                                                        .l10n
                                                        .workspaceSharesMustBeGreaterThan0ForAllParticipants;
                                                  });
                                                  return;
                                                }
                                                splitValues.add(
                                                  ExpenseSplitValue(
                                                    userId: userId,
                                                    value: rounded.toDouble(),
                                                  ),
                                                );
                                              }
                                            }
                                          }

                                          final form = _ExpenseFormResult(
                                            subcategory:
                                                !isCustomCategoryMode &&
                                                    ExpenseTypeCatalog.hasTypes(
                                                      category,
                                                    )
                                                ? selectedType
                                                : null,
                                            amount: amount,
                                            currencyCode: selectedCurrencyCode,
                                            date: date,
                                            category: category,
                                            note: note,
                                            // Everyone named in the items is who pays.
                                            participants:
                                                splitMode == 'itemized'
                                                ? ({
                                                    for (final item
                                                        in itemDrafts)
                                                      ...item.participantIds,
                                                  }.toList()..sort())
                                                : participants,
                                            splitMode: splitMode,
                                            splitValues: splitValues,
                                            paidBy: canChoosePayer
                                                ? selectedPayerId
                                                : null,
                                            items: splitMode == 'itemized'
                                                ? itemDrafts
                                                : const [],
                                            extraAmount: splitMode == 'itemized'
                                                ? extraDraft
                                                : 0,
                                            receiptFileBytes:
                                                selectedReceiptBytes,
                                            receiptFileName:
                                                selectedReceiptName,
                                            preuploadedReceipt:
                                                preuploadedReceipt,
                                            removeReceipt:
                                                removeExistingReceipt,
                                          );
                                          setDialogState(() {
                                            isSaving = true;
                                            errorText = null;
                                          });
                                          try {
                                            final saved = await onSubmit(
                                              context,
                                              form,
                                            );
                                            if (!context.mounted) return;
                                            if (saved) {
                                              // Rebuild PopScope before resolving the successful form.
                                              setDialogState(
                                                () => isSaving = false,
                                              );
                                              await WidgetsBinding
                                                  .instance
                                                  .endOfFrame;
                                              if (context.mounted) {
                                                Navigator.of(context).pop(form);
                                              }
                                            }
                                          } on ApiException catch (error) {
                                            if (context.mounted) {
                                              setDialogState(
                                                () => errorText = error.message,
                                              );
                                            }
                                          } catch (_) {
                                            if (context.mounted) {
                                              setDialogState(
                                                () => errorText = t
                                                    .unexpectedErrorSavingChanges,
                                              );
                                            }
                                          } finally {
                                            if (context.mounted) {
                                              setDialogState(
                                                () => isSaving = false,
                                              );
                                            }
                                          }
                                        },
                                  child: Text(
                                    isSaving
                                        ? t.savingButton
                                        : (!isEdit
                                              ? (setup.submitLabel ??
                                                    t.addAction)
                                              : t.saveAction),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  } finally {
    // A network/cache update can rebuild the closing route. Keep its
    // controllers alive until the overlay is actually removed.
    if (route != null) await route.completed;
    amountController.dispose();
    noteController.dispose();
    customCategoryController.dispose();
    for (final controller in splitControllers.values) {
      controller.dispose();
    }
  }
}

class _ExpenseFormSelector extends StatelessWidget {
  const _ExpenseFormSelector({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.compact = false,
  });
  final bool compact;
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => compact
      ? TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            backgroundColor: (AppDesign.isDark(context)
                ? AppDesign.darkSurface
                : AppDesign.lightSurfaceMuted),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          ),
          child: Semantics(
            label: label,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(value)),
                const Icon(Icons.expand_more, size: 18),
              ],
            ),
          ),
        )
      : Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 64,
              minVerticalPadding: 8,
              dense: true,
              leading: Icon(icon),
              title: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              subtitle: Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: onTap,
            ),
            const Divider(height: 1),
          ],
        );
}

class _ExpenseAmountRow extends StatelessWidget {
  const _ExpenseAmountRow({
    required this.amount,
    required this.currency,
    this.leading,
  });
  final Widget amount;
  final Widget currency;

  /// The receipt camera button, left of the amount.
  final Widget? leading;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (MediaQuery.textScalerOf(context).scale(16) > 24 ||
          constraints.maxWidth < 280) {
        return Column(
          children: [
            if (leading != null)
              Row(
                children: [
                  leading!,
                  const Spacer(),
                  SizedBox(width: 84, child: currency),
                ],
              ),
            amount,
            if (leading == null) ...[const SizedBox(height: 12), currency],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(flex: 3, child: amount),
          const SizedBox(width: 8),
          SizedBox(width: 84, child: currency),
        ],
      );
    },
  );
}

class _ExpenseCompactTile extends StatelessWidget {
  const _ExpenseCompactTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.detail,
    this.type,
    this.trailing,
  });
  final String label, value;
  final String? detail;

  /// Shown after the value, lighter: "Food · Restaurant".
  final String? type;

  /// Replaces the chevron, e.g. the "+ Type" button.
  final Widget? trailing;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    child: Material(
      color: (AppDesign.isDark(context)
          ? AppDesign.darkSurface
          : AppDesign.lightSurfaceMuted),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: value,
                        children: [
                          if (type != null)
                            TextSpan(
                              text: ' · $type',
                              style: TextStyle(
                                color: AppDesign.mutedColor(context),
                              ),
                            ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        detail!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              if (trailing != null)
                // Never more than a small corner, so the value keeps its room.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 76),
                  child: FittedBox(fit: BoxFit.scaleDown, child: trailing),
                )
              else
                const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    ),
  );
}

/// "+ Type" until a type is picked, then a small chevron that reopens it.
class _ExpenseTypeButton extends StatelessWidget {
  const _ExpenseTypeButton({required this.hasType, required this.onTap});
  final bool hasType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (hasType) {
      return IconButton(
        key: const ValueKey('expense-type-edit'),
        tooltip: context.l10n.expenseTypeButton,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: const Icon(Icons.expand_more_rounded, size: 20),
      );
    }
    return Material(
      key: const ValueKey('expense-type-add'),
      color: Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: colors.primary.withValues(alpha: .7)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Text(
            '+ ${context.l10n.expenseTypeButton}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
