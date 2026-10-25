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
      text: existing != null ? existing.originalAmount.toStringAsFixed(2) : '',
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
    final supportedSplitModes = <String>{'equal', 'exact', 'percent', 'shares'};
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
      if (expense == null || mode == 'equal') {
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

    List<String> recentCategoryKeys() {
      final keys = <String>[];
      for (final expense in recentExpenses) {
        final key = ExpenseCategoryCatalog.normalizeStored(expense.category);
        if (key.isEmpty || keys.contains(key)) {
          continue;
        }
        keys.add(key);
        if (keys.length >= 4) {
          break;
        }
      }
      return keys;
    }

    const customCategoryDropdownValue = '__custom_category__';

    Uint8List? selectedReceiptBytes;
    Uint8List? receiptPreviewBytes;
    String? selectedReceiptName;
    UploadedReceiptData? preuploadedReceipt;
    bool isReceiptScanning = false;
    bool isReceiptPicking = false;
    String? receiptOcrHint;
    bool removeExistingReceipt = false;
    bool isSaving = false;
    String? errorText;
    try {
      return await Navigator.of(context).push<_ExpenseFormResult>(
        AppFormPageRoute<_ExpenseFormResult>(
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

            Future<String?> pickSplitMode(
              BuildContext dialogContext,
              String currentMode,
            ) {
              const modes = <String>['equal', 'exact', 'percent', 'shares'];
              return showAppBottomSheet<String>(
                context: dialogContext,
                builder: (pickerContext) {
                  return AppActionSheet(
                    key: const ValueKey('split-mode-picker'),
                    title: t.splitModeLabel,
                    children: [
                      for (final mode in modes) ...[
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          leading: Icon(
                            splitModeIcon(mode),
                            color: Theme.of(
                              pickerContext,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          title: Text(splitModeLabel(mode)),
                          subtitle: Text(_splitModeHint(mode)),
                          selected: mode == currentMode,
                          trailing: mode == currentMode
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(
                                    pickerContext,
                                  ).colorScheme.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(pickerContext).pop(mode),
                        ),
                        if (mode != modes.last) const Divider(height: 1),
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
                final quickCategoryKeys = <String>{
                  'food',
                  'transport',
                  'activities',
                  ...recentCategoryKeys(),
                }.toList();
                final normalizedSelectedCategory =
                    ExpenseCategoryCatalog.normalizeStored(selectedCategory);
                String? categoryDropdownValue;
                if (isCustomCategoryMode) {
                  categoryDropdownValue = customCategoryDropdownValue;
                } else if (ExpenseCategoryCatalog.isBuiltInKey(
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
                    : ExpenseCategoryCatalog.iconFor(selectedCategoryValue);
                final keyboardOpen =
                    MediaQuery.viewInsetsOf(context).bottom > 0;
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
                                      amount: TextField(
                                        controller: amountController,
                                        key: const ValueKey(
                                          'expense-form-amount',
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w700,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: InputDecoration(
                                          labelText: t.amountLabel,
                                          filled: false,
                                          border: const UnderlineInputBorder(),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: AppDesign.cardStroke(
                                                context,
                                              ),
                                            ),
                                          ),
                                          hintText: t.amountHint,
                                        ),
                                      ),
                                      currency: _ExpenseFormSelector(
                                        compact: true,
                                        label: context.l10n.workspaceCurrency,
                                        value: selectedCurrency.code,
                                        icon: Icons.currency_exchange,
                                        onTap: () async {
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
                                    const SizedBox(height: 4),
                                    InkWell(
                                      borderRadius: AppDesign.cardRadius,
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: sheetContext,
                                          initialDate: selectedExpenseDate,
                                          firstDate: DateTime(2020, 1, 1),
                                          lastDate: DateTime(2100, 12, 31),
                                        );
                                        if (!mounted || picked == null) {
                                          return;
                                        }
                                        setDialogState(() {
                                          selectedExpenseDate = DateTime(
                                            picked.year,
                                            picked.month,
                                            picked.day,
                                          );
                                          errorText = null;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            minTileHeight: 64,
                                            minVerticalPadding: 8,
                                            dense: true,
                                            leading: const Icon(
                                              Icons.calendar_today_outlined,
                                            ),
                                            title: Text(
                                              t.dateLabel,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: AppDesign.mutedColor(
                                                      context,
                                                    ),
                                                  ),
                                            ),
                                            subtitle: Text(
                                              formatExpenseDate(
                                                selectedExpenseDate,
                                              ),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge,
                                            ),
                                            trailing: const Icon(
                                              Icons.chevron_right,
                                            ),
                                          ),
                                          const Divider(height: 1),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (!isSolo) ...[
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        minTileHeight: 64,
                                        minVerticalPadding: 8,
                                        dense: true,
                                        leading: _largeMemberAvatar(
                                          id:
                                              existing?.paidById ??
                                              _currentUserId,
                                          name:
                                              users
                                                  .where(
                                                    (user) =>
                                                        user.id ==
                                                        (existing?.paidById ??
                                                            _currentUserId),
                                                  )
                                                  .map(
                                                    (user) =>
                                                        user.preferredName,
                                                  )
                                                  .firstOrNull ??
                                              t.youLabel,
                                          avatarUrl: users
                                              .where(
                                                (user) =>
                                                    user.id ==
                                                    (existing?.paidById ??
                                                        _currentUserId),
                                              )
                                              .firstOrNull
                                              ?.avatarThumbUrl,
                                          size: 40,
                                        ),
                                        title: Text(
                                          t.paidByLabel,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppDesign.mutedColor(
                                                  context,
                                                ),
                                              ),
                                        ),
                                        subtitle: Text(
                                          users
                                                  .where(
                                                    (user) =>
                                                        user.id ==
                                                        (existing?.paidById ??
                                                            _currentUserId),
                                                  )
                                                  .map(
                                                    (user) =>
                                                        user.preferredName,
                                                  )
                                                  .firstOrNull ??
                                              t.youLabel,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                        ),
                                      ),
                                      const Divider(height: 1),
                                      const SizedBox(height: 16),
                                    ],
                                    if (quickCategoryKeys.isNotEmpty) ...[
                                      Text(
                                        t.expenseQuickCategories,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppDesign.mutedColor(
                                                context,
                                              ),
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          for (final categoryKey
                                              in quickCategoryKeys)
                                            _ExpenseQuickCategory(
                                              labelStyle: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize.padded,
                                              label: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    ExpenseCategoryCatalog.iconFor(
                                                      categoryKey,
                                                    ),
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    ExpenseCategoryCatalog.labelFor(
                                                      categoryKey,
                                                      Localizations.localeOf(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              selected:
                                                  ExpenseCategoryCatalog.isBuiltInKey(
                                                    categoryKey,
                                                  )
                                                  ? !isCustomCategoryMode &&
                                                        selectedCategory
                                                                .toLowerCase() ==
                                                            categoryKey
                                                                .toLowerCase()
                                                  : isCustomCategoryMode &&
                                                        ExpenseCategoryCatalog.normalizeStored(
                                                              customCategoryController
                                                                  .text,
                                                            ) ==
                                                            categoryKey,
                                              onSelected: (_) {
                                                setDialogState(() {
                                                  final isBuiltIn =
                                                      ExpenseCategoryCatalog.isBuiltInKey(
                                                        categoryKey,
                                                      );
                                                  isCustomCategoryMode =
                                                      !isBuiltIn;
                                                  selectedCategory = isBuiltIn
                                                      ? categoryKey
                                                      : '';
                                                  if (isBuiltIn) {
                                                    customCategoryController
                                                        .clear();
                                                  } else {
                                                    customCategoryController
                                                            .text =
                                                        categoryKey;
                                                  }
                                                  errorText = null;
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    _ExpenseFormSelector(
                                      label: t.workspaceCategory,
                                      value: selectedCategoryLabel,
                                      icon: selectedCategoryIcon,
                                      onTap: () async {
                                        final value = await pickCategoryValue(
                                          sheetContext,
                                          categoryDropdownValue,
                                        );
                                        if (!mounted ||
                                            !context.mounted ||
                                            value == null) {
                                          return;
                                        }
                                        setDialogState(() {
                                          if (value ==
                                              customCategoryDropdownValue) {
                                            isCustomCategoryMode = true;
                                            selectedCategory = '';
                                          } else {
                                            isCustomCategoryMode = false;
                                            selectedCategory = value;
                                            customCategoryController.clear();
                                          }
                                          errorText = null;
                                        });
                                      },
                                    ),
                                    if (isCustomCategoryMode) ...[
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: customCategoryController,
                                        maxLength: 64,
                                        decoration: InputDecoration(
                                          labelText: context
                                              .l10n
                                              .workspaceCategoryName,
                                          hintText: context
                                              .l10n
                                              .workspaceApartmentRentParkingEtc,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: noteController,
                                      minLines: 1,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        labelText: t.noteLabel,
                                        filled: false,
                                        prefixIcon: const Icon(
                                          Icons.description_outlined,
                                        ),
                                        border: const UnderlineInputBorder(),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppDesign.cardStroke(
                                              context,
                                            ),
                                          ),
                                        ),
                                        hintText: t.noteHint,
                                      ),
                                    ),
                                    if (!isSolo) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        t.participantsEmptyMeansAll,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 6),
                                      for (final user in users)
                                        CheckboxListTile(
                                          dense: true,
                                          visualDensity: VisualDensity.compact,
                                          contentPadding: EdgeInsets.zero,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          title: Row(
                                            children: [
                                              _largeMemberAvatar(
                                                id: user.id,
                                                name: user.preferredName,
                                                avatarUrl:
                                                    user.avatarThumbUrl ??
                                                    user.avatarUrl,
                                                size: 36,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(user.preferredName),
                                              ),
                                            ],
                                          ),
                                          value:
                                              selected.isEmpty ||
                                              selected.contains(user.id),
                                          onChanged: (value) => setDialogState(
                                            () {
                                              if (selected.isEmpty) {
                                                selected.addAll(
                                                  users.map((item) => item.id),
                                                );
                                              }
                                              if (value == true) {
                                                selected.add(user.id);
                                              } else {
                                                selected.remove(user.id);
                                              }
                                            },
                                          ),
                                        ),
                                      const SizedBox(height: 12),
                                      _ExpenseFormSelector(
                                        label: t.splitModeLabel,
                                        value: splitModeLabel(splitMode),
                                        icon: splitModeIcon(splitMode),
                                        onTap: () async {
                                          final value = await pickSplitMode(
                                            sheetContext,
                                            splitMode,
                                          );
                                          if (!mounted ||
                                              !context.mounted ||
                                              value == null) {
                                            return;
                                          }
                                          setDialogState(() {
                                            splitMode = value;
                                          });
                                        },
                                      ),
                                    ],
                                    if (!isSolo && splitMode != 'equal') ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        _splitModeHint(splitMode),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 8),
                                      ..._buildSplitInputFields(
                                        users: users,
                                        selected: selected,
                                        splitMode: splitMode,
                                        splitControllers: splitControllers,
                                      ),
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
                                                isReceiptScanning
                                            ? null
                                            : () => setDialogState(
                                                () => removeExistingReceipt =
                                                    false,
                                              ),
                                        icon: const Icon(Icons.undo),
                                        label: Text(t.restoreReceiptAction),
                                      ),
                                    OutlinedButton.icon(
                                      key: const ValueKey('receipt-add'),
                                      onPressed:
                                          isSaving ||
                                              isReceiptPicking ||
                                              isReceiptScanning
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
                                                receiptOcrHint = null;
                                                isReceiptScanning = true;
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
                                                final ocrAmount =
                                                    uploaded.ocrAmount;
                                                final ocrDate =
                                                    uploaded.ocrDate;
                                                final ocrMerchant =
                                                    uploaded.ocrMerchant;
                                                setDialogState(() {
                                                  preuploadedReceipt = uploaded;
                                                  selectedReceiptBytes = null;
                                                  if (ocrAmount != null &&
                                                      ocrAmount > 0 &&
                                                      _parseAmount(
                                                            amountController
                                                                .text,
                                                          ) <=
                                                          0) {
                                                    amountController.text =
                                                        _formatNumericInput(
                                                          ocrAmount,
                                                        );
                                                  }
                                                  final parsedOcrDate =
                                                      parseExpenseDate(ocrDate);
                                                  if (parsedOcrDate != null &&
                                                      existing == null) {
                                                    selectedExpenseDate =
                                                        parsedOcrDate;
                                                  }
                                                  if ((noteController.text)
                                                          .trim()
                                                          .isEmpty &&
                                                      ocrMerchant != null &&
                                                      ocrMerchant.isNotEmpty) {
                                                    noteController.text =
                                                        ocrMerchant;
                                                  }
                                                  receiptOcrHint =
                                                      ocrAmount != null ||
                                                          ocrDate != null ||
                                                          ocrMerchant != null
                                                      ? t.expenseReceiptRead
                                                      : t.expenseReceiptNoData;
                                                  isReceiptScanning = false;
                                                });
                                              } on ApiException catch (error) {
                                                if (!mounted ||
                                                    !context.mounted) {
                                                  return;
                                                }
                                                setDialogState(() {
                                                  isReceiptScanning = false;
                                                  preuploadedReceipt = null;
                                                  receiptOcrHint =
                                                      error.isNetworkError
                                                      ? t.expenseReceiptOffline
                                                      : error.message;
                                                });
                                              } catch (_) {
                                                if (!mounted ||
                                                    !context.mounted) {
                                                  return;
                                                }
                                                setDialogState(() {
                                                  isReceiptScanning = false;
                                                  preuploadedReceipt = null;
                                                  receiptOcrHint = t
                                                      .expenseReceiptScanFailed;
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
                                        busy: isReceiptScanning,
                                        enabled: !isReceiptPicking && !isSaving,
                                        status: receiptOcrHint,
                                        onRemove: () => setDialogState(() {
                                          selectedReceiptBytes = null;
                                          receiptPreviewBytes = null;
                                          selectedReceiptName = null;
                                          preuploadedReceipt = null;
                                          receiptOcrHint = null;
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
                                            isReceiptScanning
                                        ? null
                                        : () async {
                                            if (isSaving ||
                                                isReceiptPicking ||
                                                isReceiptScanning) {
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

                                            if (amount <= 0) {
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
                                              participants: participants,
                                              splitMode: splitMode,
                                              splitValues: splitValues,
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
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        amountController.dispose();
        noteController.dispose();
        customCategoryController.dispose();
        for (final controller in splitControllers.values) {
          controller.dispose();
        }
      });
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
      ? InkWell(
          onTap: onTap,
          borderRadius: AppDesign.cardRadius,
          child: InputDecorator(
            decoration: InputDecoration(labelText: label, filled: false),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(Icons.expand_more),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: amount),
          const SizedBox(width: 8),
          SizedBox(width: 112, child: currency),
        ],
      );
    },
  );
}

class _ExpenseQuickCategory extends StatelessWidget {
  const _ExpenseQuickCategory({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.labelStyle,
    this.materialTapTargetSize,
  });
  final Widget label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final TextStyle? labelStyle;
  final MaterialTapTargetSize? materialTapTargetSize;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
      ),
      child: TextButton(
        onPressed: () => onSelected(!selected),
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(),
          foregroundColor: selected
              ? Theme.of(context).colorScheme.primary
              : AppDesign.mutedColor(context),
        ),
        child: DefaultTextStyle.merge(style: labelStyle, child: label),
      ),
    ),
  );
}
