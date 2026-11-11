part of 'workspace_page.dart';

extension _WorkspacePageDialogs on _WorkspacePageState {
  Future<_ExpenseFormResult?> _showExpenseDialog({
    required List<WorkspaceUser> users,
    required Future<bool> Function(BuildContext, _ExpenseFormResult) onSubmit,
    TripExpense? existing,
    List<TripExpense> recentExpenses = const <TripExpense>[],
  }) async {
    final isSolo = widget.trip.isSolo;
    final ownerId = widget.trip.createdBy ?? _currentUserId;
    final amountController = TextEditingController(
      text: existing != null
          ? AppCurrencyCatalog.amountInputText(
              existing.originalAmount,
              existing.expenseCurrencyCode,
            )
          : '',
    );
    final noteController = TextEditingController(text: existing?.note ?? '');
    final initialCategory = existing != null
        ? ExpenseCategoryCatalog.normalizeStored(existing.category)
        : '';
    var isCustomCategoryMode =
        initialCategory.isNotEmpty &&
        !ExpenseCategoryCatalog.isBuiltInKey(initialCategory);
    var selectedCategory = isCustomCategoryMode ? '' : initialCategory;
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
        parseExpenseDate(existing?.expenseDate) ??
        DateTime(now.year, now.month, now.day);
    var selectedCurrencyCode = AppCurrencyCatalog.normalize(
      existing?.expenseCurrencyCode ?? widget.trip.currencyCode,
    );

    final selected = isSolo
        ? <int>{ownerId}
        : existing == null
        ? <int>{}
        : existing.participants.map((p) => p.id).toSet();
    final rawSplitMode = (existing?.splitMode ?? 'equal').trim().toLowerCase();
    final supportedSplitModes = <String>{
      'equal',
      'exact',
      'percent',
      'shares',
      'adjustment',
      'itemized',
    };
    var selectedPayerId = existing?.paidById ?? _currentUserId;
    var itemDrafts = existing?.items ?? const <ExpenseItem>[];
    var extraDraft = existing?.extraAmount ?? 0.0;
    final isLegacySplitMode = !supportedSplitModes.contains(rawSplitMode);
    var splitMode = isSolo
        ? 'equal'
        : (isLegacySplitMode ? 'exact' : rawSplitMode);
    final splitControllers = <int, TextEditingController>{};
    void seedSplitControllersFrom(
      TripExpense? expense,
      String mode, {
      bool disposeExisting = false,
    }) {
      if (disposeExisting) {
        for (final controller in splitControllers.values) {
          controller.dispose();
        }
      }
      splitControllers.clear();
      if (expense == null || mode == 'equal' || mode == 'itemized') {
        return;
      }
      final legacyMode = !supportedSplitModes.contains(
        expense.splitMode.trim().toLowerCase(),
      );
      for (final participant in expense.participants) {
        final seedValue = legacyMode
            ? participant.owedAmount
            : (participant.splitValue ?? participant.owedAmount);
        splitControllers[participant.id] = TextEditingController(
          text: seedValue != null ? _formatNumericInput(seedValue) : '',
        );
      }
    }

    seedSplitControllersFrom(existing, splitMode);

    const customCategoryDropdownValue = '__custom_category__';

    Uint8List? selectedReceiptBytes;
    Uint8List? receiptPreviewBytes;
    String? selectedReceiptName;
    UploadedReceiptData? preuploadedReceipt;
    bool isReceiptUploading = false;
    bool isReceiptPicking = false;
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
                          onTap: () =>
                              Navigator.pop(pickerContext, option.value),
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
                final keyboardOpen =
                    MediaQuery.viewInsetsOf(context).bottom > 0;
                final activeUsers = users
                    .where(
                      (user) =>
                          user.id > 0 &&
                          (selected.isEmpty || selected.contains(user.id)),
                    )
                    .toList();
                final payerId = selectedPayerId;
                final guests = users.where((user) => user.isGuest).toList();
                final canChoosePayer =
                    !isSolo && guests.isNotEmpty && _isCurrentTripOwner();
                Future<void> choosePayer() async {
                  FocusScope.of(context).unfocus();
                  final me = users
                      .where((user) => user.id == _currentUserId)
                      .toList();
                  final picked = await showAppBottomSheet<int>(
                    context: context,
                    builder: (sheetContext) => AppActionSheet(
                      key: const ValueKey('expense-payer-sheet'),
                      title: t.paidByLabel,
                      children: [
                        for (final user in [...me, ...guests])
                          AppPlainActionTile(
                            key: ValueKey('expense-payer-${user.id}'),
                            icon: user.id == selectedPayerId
                                ? Icons.check_rounded
                                : Icons.person_outline_rounded,
                            title: user.preferredName,
                            onTap: () =>
                                Navigator.of(sheetContext).pop(user.id),
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
                Widget memberAvatar(WorkspaceUser user) => _largeMemberAvatar(
                  id: user.id,
                  name: user.preferredName,
                  avatarUrl: user.avatarThumbUrl ?? user.avatarUrl,
                  size: 30,
                );
                Future<void> editSplit() async {
                  final amount = _parseAmount(amountController.text);
                  if (activeUsers.isEmpty) {
                    setDialogState(() {
                      errorText = t.pickAtLeastOneParticipant;
                    });
                    return;
                  }
                  FocusScope.of(context).unfocus();
                  final result = await showAppBottomSheet<_ExpenseSplitDraft>(
                    context: context,
                    builder: (_) => _ExpenseSplitEditor(
                      users: activeUsers,
                      amount: amount,
                      currencyCode: selectedCurrencyCode,
                      // Without an amount yet, the items are what add up to it.
                      initialMode: splitMode == 'equal' && amount <= 0
                          ? 'itemized'
                          : splitMode,
                      initialItems: itemDrafts,
                      initialExtra: extraDraft,
                      initialValues: {
                        for (final entry in splitControllers.entries)
                          entry.key: entry.value.text,
                      },
                      avatarBuilder: memberAvatar,
                    ),
                  );
                  if (!mounted || !context.mounted || result == null) return;
                  setDialogState(() {
                    splitMode = result.mode;
                    if (result.mode == 'itemized') {
                      itemDrafts = result.items;
                      extraDraft = result.extra;
                      final total = result.items.fold<double>(
                        result.extra,
                        (sum, item) => sum + item.amount,
                      );
                      amountController.text =
                          AppCurrencyCatalog.amountInputText(
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
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  20,
                                ),
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
                                                  existing == null
                                                      ? t.addExpenseTitle
                                                      : t.editExpenseTitle,
                                                  style: keyboardOpen
                                                      ? Theme.of(
                                                          context,
                                                        ).textTheme.titleMedium
                                                      : Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall,
                                                ),
                                                if (!keyboardOpen) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    widget.trip.name,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _ExpenseAmountRow(
                                      amount: Semantics(
                                        label: t.amountLabel,
                                        child: TextField(
                                          controller: amountController,
                                          key: const ValueKey(
                                            'expense-form-amount',
                                          ),
                                          onChanged: (_) =>
                                              setDialogState(() {}),
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
                                          if (!mounted ||
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
                                        final category = _ExpenseCompactTile(
                                          key: const ValueKey(
                                            'expense-category',
                                          ),
                                          label: t.workspaceCategory,
                                          value:
                                              selectedCategory.isEmpty &&
                                                  !isCustomCategoryMode
                                              ? t.workspaceChooseCategory
                                              : selectedCategoryLabel,
                                          icon: selectedCategoryIcon,
                                          onTap: () async {
                                            FocusScope.of(context).unfocus();
                                            final value =
                                                await pickCategoryValue(
                                                  sheetContext,
                                                  categoryDropdownValue,
                                                );
                                            if (!mounted ||
                                                !context.mounted ||
                                                value == null) {
                                              return;
                                            }
                                            setDialogState(() {
                                              isCustomCategoryMode =
                                                  value ==
                                                  customCategoryDropdownValue;
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
                                            if (!mounted ||
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
                                          hintText: t
                                              .workspaceApartmentRentParkingEtc,
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
                                              _largeMemberAvatar(
                                                id: payerId,
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
                                                          : next.remove(
                                                              user.id,
                                                            );
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
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: AppDesign.isDark(context)
                                              ? AppDesign.darkSurface
                                              : AppDesign.lightSurfaceMuted,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _ExpenseSplitMethodButton(
                                                label: t.equalSplitLabel,
                                                icon: Icons.balance_rounded,
                                                selected: splitMode == 'equal',
                                                onTap: () => setDialogState(() {
                                                  splitMode = 'equal';
                                                  errorText = null;
                                                }),
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: _ExpenseSplitMethodButton(
                                                key: const ValueKey(
                                                  'expense-custom-split',
                                                ),
                                                label: t.expenseCustomSplit,
                                                icon: Icons.tune,
                                                selected: splitMode != 'equal',
                                                onTap: editSplit,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      if (splitMode == 'equal')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          child: Text(
                                            t.splitHintEqual,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        )
                                      else
                                        _ExpenseCompactTile(
                                          key: const ValueKey(
                                            'expense-split-summary',
                                          ),
                                          label: t.splitModeLabel,
                                          value: splitModeLabel(splitMode),
                                          icon: splitModeIcon(splitMode),
                                          detail: splitMode == 'itemized'
                                              ? itemDrafts
                                                    .map((item) => item.name)
                                                    .join(' · ')
                                              : activeUsers
                                                    .map((user) {
                                                      final raw =
                                                          splitControllers[user
                                                                  .id]
                                                              ?.text
                                                              .trim() ??
                                                          '';
                                                      final value = raw.isEmpty
                                                          ? '—'
                                                          : splitMode ==
                                                                    'exact' ||
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
                                          onTap: editSplit,
                                        ),
                                      const SizedBox(height: 18),
                                      const Divider(height: 1),
                                    ],
                                    const SizedBox(height: 12),
                                    Text(
                                      t.receiptOptionalLabel,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 6),
                                    if (removeExistingReceipt)
                                      TextButton.icon(
                                        onPressed:
                                            isSaving ||
                                                isReceiptPicking ||
                                                isReceiptUploading
                                            ? null
                                            : () => setDialogState(
                                                () => removeExistingReceipt =
                                                    false,
                                              ),
                                        icon: const Icon(Icons.undo),
                                        label: Text(t.restoreReceiptAction),
                                      ),
                                    TextButton.icon(
                                      key: const ValueKey('receipt-add'),
                                      onPressed:
                                          isSaving ||
                                              isReceiptPicking ||
                                              isReceiptUploading
                                          ? null
                                          : () async {
                                              setDialogState(
                                                () => isReceiptPicking = true,
                                              );
                                              final picked =
                                                  await _pickReceiptAttachment(
                                                    context,
                                                  );
                                              if (mounted && context.mounted) {
                                                setDialogState(
                                                  () =>
                                                      isReceiptPicking = false,
                                                );
                                              }
                                              if (!mounted ||
                                                  !context.mounted) {
                                                return;
                                              }
                                              if (picked == null) {
                                                return;
                                              }
                                              setDialogState(() {
                                                selectedReceiptBytes =
                                                    picked.bytes;
                                                receiptPreviewBytes =
                                                    picked.bytes;
                                                selectedReceiptName =
                                                    picked.fileName;
                                                preuploadedReceipt = null;
                                                receiptUploadHint = null;
                                                isReceiptUploading = true;
                                                removeExistingReceipt = false;
                                              });
                                              try {
                                                final uploaded = await widget
                                                    .workspaceController
                                                    .uploadReceipt(
                                                      payload:
                                                          ReceiptUploadPayload(
                                                            fileName:
                                                                picked.fileName,
                                                            bytes: picked.bytes,
                                                            tripId:
                                                                widget.trip.id,
                                                          ),
                                                    );
                                                if (!mounted ||
                                                    !context.mounted) {
                                                  return;
                                                }
                                                setDialogState(() {
                                                  preuploadedReceipt = uploaded;
                                                  selectedReceiptBytes = null;
                                                  isReceiptUploading = false;
                                                });
                                              } on ApiException catch (error) {
                                                if (!mounted ||
                                                    !context.mounted) {
                                                  return;
                                                }
                                                setDialogState(() {
                                                  isReceiptUploading = false;
                                                  preuploadedReceipt = null;
                                                  receiptUploadHint =
                                                      error.isNetworkError
                                                      ? t.expenseReceiptUploadOnSave
                                                      : error.message;
                                                });
                                              } catch (_) {
                                                if (!mounted ||
                                                    !context.mounted) {
                                                  return;
                                                }
                                                setDialogState(() {
                                                  isReceiptUploading = false;
                                                  preuploadedReceipt = null;
                                                  receiptUploadHint = t
                                                      .expenseReceiptUploadOnSave;
                                                });
                                              }
                                            },
                                      icon: isReceiptPicking
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.attach_file),
                                      label: Text(
                                        selectedReceiptName != null ||
                                                (existing?.receiptUrl != null &&
                                                    !removeExistingReceipt)
                                            ? t.replaceReceiptAction
                                            : t.addReceiptAction,
                                      ),
                                    ),
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
                                    ] else if (existing != null &&
                                        existing.receiptUrl != null &&
                                        !removeExistingReceipt) ...[
                                      const SizedBox(height: 8),
                                      ReceiptAttachmentCard(
                                        fileName: t.receiptFallbackName,
                                        saved: true,
                                        enabled: !isReceiptPicking && !isSaving,
                                        onRemove: () => setDialogState(
                                          () => removeExistingReceipt = true,
                                        ),
                                        openAction: ReceiptOpenAction(
                                          load: () async {
                                            final account = widget
                                                .authController
                                                .currentUser
                                                ?.id;
                                            final uri = await widget
                                                .workspaceController
                                                .loadReceiptUri(
                                                  tripId: widget.trip.id,
                                                  expenseId: existing.id,
                                                );
                                            if (!mounted ||
                                                !context.mounted ||
                                                widget
                                                        .authController
                                                        .currentUser
                                                        ?.id !=
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
                                constraints: const BoxConstraints(
                                  maxHeight: 80,
                                ),
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

                                            if (!amount.isFinite ||
                                                amount <= 0) {
                                              setDialogState(() {
                                                errorText = t
                                                    .amountMustBeGreaterThanZero;
                                              });
                                              return;
                                            }

                                            if (date == null || date.isEmpty) {
                                              setDialogState(() {
                                                errorText =
                                                    t.dateMustMatchFormat;
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
                                                errorText = t
                                                    .noteMustBeMaxChars(255);
                                              });
                                              return;
                                            }

                                            final participants =
                                                selected.toList(growable: false)
                                                  ..sort();
                                            final resolvedParticipants =
                                                participants.isNotEmpty
                                                      ? participants
                                                      : users
                                                            .map(
                                                              (user) => user.id,
                                                            )
                                                            .where(
                                                              (id) => id > 0,
                                                            )
                                                            .toList(
                                                              growable: false,
                                                            )
                                                  ..sort();
                                            final amountCents = (amount * 100)
                                                .round();
                                            final splitValues =
                                                <ExpenseSplitValue>[];

                                            if (splitMode != 'equal') {
                                              if (resolvedParticipants
                                                  .isEmpty) {
                                                setDialogState(() {
                                                  errorText = t
                                                      .pickAtLeastOneParticipant;
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
                                                  final value = _parseAmount(
                                                    raw,
                                                  );
                                                  if (raw.isEmpty ||
                                                      value < 0) {
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
                                              } else if (splitMode ==
                                                  'percent') {
                                                var totalBasisPoints = 0;
                                                for (final userId
                                                    in resolvedParticipants) {
                                                  final controller =
                                                      splitControllers[userId];
                                                  final raw =
                                                      controller?.text.trim() ??
                                                      '';
                                                  final value = _parseAmount(
                                                    raw,
                                                  );
                                                  if (raw.isEmpty ||
                                                      value < 0) {
                                                    setDialogState(() {
                                                      errorText = context
                                                          .l10n
                                                          .enterValidPercentages;
                                                    });
                                                    return;
                                                  }
                                                  final basisPoints =
                                                      (value * 100).round();
                                                  totalBasisPoints +=
                                                      basisPoints;
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
                                                final adjustments =
                                                    <int, int>{};
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
                                                      (extraDraft * 100)
                                                          .round(),
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
                                              } else if (splitMode ==
                                                  'shares') {
                                                for (final userId
                                                    in resolvedParticipants) {
                                                  final controller =
                                                      splitControllers[userId];
                                                  final raw =
                                                      controller?.text.trim() ??
                                                      '';
                                                  final value = _parseAmount(
                                                    raw,
                                                  );
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
                                              amount: amount,
                                              currencyCode:
                                                  selectedCurrencyCode,
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
                                              extraAmount:
                                                  splitMode == 'itemized'
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
                                                  Navigator.of(
                                                    context,
                                                  ).pop(form);
                                                }
                                              }
                                            } on ApiException catch (error) {
                                              if (context.mounted) {
                                                setDialogState(
                                                  () =>
                                                      errorText = error.message,
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
                                          : (existing == null
                                                ? t.addAction
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
  const _ExpenseAmountRow({required this.amount, required this.currency});
  final Widget amount;
  final Widget currency;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (MediaQuery.textScalerOf(context).scale(16) > 24 ||
          constraints.maxWidth < 280) {
        return Column(children: [amount, const SizedBox(height: 12), currency]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
  });
  final String label, value;
  final String? detail;
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
                    Text(value, style: Theme.of(context).textTheme.bodyMedium),
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
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ExpenseSplitMethodButton extends StatelessWidget {
  const _ExpenseSplitMethodButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        foregroundColor: selected
            ? Theme.of(context).colorScheme.primary
            : AppDesign.mutedColor(context),
        backgroundColor: selected
            ? AppDesign.pageSurface(context)
            : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 5),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    ),
  );
}
