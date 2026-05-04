part of 'workspace_page.dart';

extension _WorkspacePageDialogs on _WorkspacePageState {
  Future<_ExpenseFormResult?> _showExpenseDialog({
    required List<WorkspaceUser> users,
    TripExpense? existing,
    List<TripExpense> recentExpenses = const <TripExpense>[],
  }) async {
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

    final selected = existing == null
        ? <int>{}
        : existing.participants.map((p) => p.id).toSet();
    final rawSplitMode = (existing?.splitMode ?? 'equal').trim().toLowerCase();
    final supportedSplitModes = <String>{'equal', 'exact', 'percent', 'shares'};
    final isLegacySplitMode = !supportedSplitModes.contains(rawSplitMode);
    var splitMode = isLegacySplitMode ? 'exact' : rawSplitMode;
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
    String? selectedReceiptName;
    UploadedReceiptData? preuploadedReceipt;
    bool isReceiptScanning = false;
    String? receiptOcrHint;
    bool removeExistingReceipt = false;
    try {
      return await Navigator.of(context).push<_ExpenseFormResult>(
        AppFormPageRoute<_ExpenseFormResult>(
          builder: (sheetContext) {
            final t = sheetContext.l10n;
            String? errorText;
            String formatExpenseDate(DateTime value) {
              final dd = value.day.toString().padLeft(2, '0');
              final mm = value.month.toString().padLeft(2, '0');
              final yyyy = value.year.toString().padLeft(4, '0');
              return '$dd.$mm.$yyyy';
            }

            Future<String?> pickCurrencyCode(
              BuildContext dialogContext,
              String currentCode,
            ) async {
              var query = '';
              return showAppBottomSheet<String>(
                context: dialogContext,
                builder: (pickerContext) {
                  final maxHeight =
                      MediaQuery.sizeOf(pickerContext).height * 0.62;
                  return SizedBox(
                    height: maxHeight,
                    child: StatefulBuilder(
                      builder: (context, setPickerState) {
                        final normalizedQuery = query.trim().toUpperCase();
                        final filtered = AppCurrencyCatalog.supported
                            .where((item) {
                              if (normalizedQuery.isEmpty) {
                                return true;
                              }
                              final label = AppCurrencyCatalog.labelForCode(
                                item.code,
                                context.l10n,
                              );
                              final haystack =
                                  '${item.code} $label ${item.symbol}'
                                      .toUpperCase();
                              return haystack.contains(normalizedQuery);
                            })
                            .toList(growable: false);

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                              child: TextField(
                                textInputAction: TextInputAction.search,
                                onChanged: (value) {
                                  setPickerState(() {
                                    query = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      context.l10n.profileEditSearchCurrency,
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: filtered.isEmpty
                                  ? Center(
                                      child: Text(
                                        context
                                            .l10n
                                            .profileEditNoCurrenciesFound,
                                        style: Theme.of(
                                          pickerContext,
                                        ).textTheme.bodyMedium,
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        0,
                                        12,
                                        12,
                                      ),
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(height: 6),
                                      itemBuilder: (context, index) {
                                        final item = filtered[index];
                                        final selected =
                                            item.code == currentCode;
                                        return Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            onTap: () => Navigator.of(
                                              pickerContext,
                                            ).pop(item.code),
                                            child: Ink(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    12,
                                                    10,
                                                    12,
                                                    10,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                color: selected
                                                    ? Theme.of(pickerContext)
                                                          .colorScheme
                                                          .primary
                                                          .withValues(
                                                            alpha: 0.10,
                                                          )
                                                    : Theme.of(pickerContext)
                                                          .colorScheme
                                                          .surfaceContainerHighest
                                                          .withValues(
                                                            alpha: 0.45,
                                                          ),
                                                border: Border.all(
                                                  color: selected
                                                      ? Theme.of(
                                                          pickerContext,
                                                        ).colorScheme.primary
                                                      : AppDesign.cardStroke(
                                                          pickerContext,
                                                        ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 34,
                                                    height: 34,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Theme.of(
                                                        pickerContext,
                                                      ).colorScheme.surface,
                                                      border: Border.all(
                                                        color:
                                                            AppDesign.cardStroke(
                                                              pickerContext,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      item.symbol,
                                                      style:
                                                          Theme.of(
                                                                pickerContext,
                                                              )
                                                              .textTheme
                                                              .titleMedium
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      '${item.code} - ${AppCurrencyCatalog.labelForCode(item.code, context.l10n)}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          Theme.of(
                                                                pickerContext,
                                                              )
                                                              .textTheme
                                                              .titleSmall
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                    ),
                                                  ),
                                                  if (selected)
                                                    Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: Theme.of(
                                                        pickerContext,
                                                      ).colorScheme.primary,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
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
                final quickCategoryKeys = recentCategoryKeys();
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
                return AppFormScaffold(
                  child: SizedBox.expand(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              existing == null
                                  ? t.addExpenseTitle
                                  : t.editExpenseTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: amountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    labelText: t.amountLabel,
                                    hintText: t.amountHint,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  context.l10n.workspaceCurrency,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
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
                                    child: Ink(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        12,
                                        12,
                                        12,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: AppDesign.cardStroke(context),
                                        ),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.35),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                              border: Border.all(
                                                color: AppDesign.cardStroke(
                                                  context,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              selectedCurrency.symbol,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '${selectedCurrency.code} - ${AppCurrencyCatalog.labelForCode(selectedCurrency.code, context.l10n)}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  borderRadius: BorderRadius.circular(14),
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
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: t.dateLabel,
                                      suffixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18,
                                      ),
                                    ),
                                    child: Text(
                                      formatExpenseDate(selectedExpenseDate),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  context.l10n.workspaceCategory,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                if (quickCategoryKeys.isNotEmpty) ...[
                                  Text(
                                    'Quick categories',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppDesign.mutedColor(context),
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
                                        ChoiceChip(
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
                                              isCustomCategoryMode = !isBuiltIn;
                                              selectedCategory = isBuiltIn
                                                  ? categoryKey
                                                  : '';
                                              if (isBuiltIn) {
                                                customCategoryController
                                                    .clear();
                                              } else {
                                                customCategoryController.text =
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
                                DropdownButtonFormField<String>(
                                  key: ValueKey<String>(
                                    categoryDropdownValue ?? 'category-empty',
                                  ),
                                  initialValue: categoryDropdownValue,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.workspaceCategory,
                                    hintText: context
                                        .l10n
                                        .workspacePickAnExpenseCategory,
                                  ),
                                  items: [
                                    for (final option
                                        in ExpenseCategoryCatalog.builtIn)
                                      DropdownMenuItem<String>(
                                        value: option.key,
                                        child: Row(
                                          children: [
                                            Icon(option.icon, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                ExpenseCategoryCatalog.labelFor(
                                                  option.key,
                                                  Localizations.localeOf(
                                                    context,
                                                  ),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    DropdownMenuItem<String>(
                                      value: customCategoryDropdownValue,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.add, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              context
                                                  .l10n
                                                  .workspaceCustomCategory,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) {
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
                                      labelText:
                                          context.l10n.workspaceCategoryName,
                                      hintText: context
                                          .l10n
                                          .workspaceApartmentRentParkingEtc,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                TextField(
                                  controller: noteController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: t.noteLabel,
                                    hintText: t.noteHint,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  t.participantsEmptyMeansAll,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final user in users)
                                      FilterChip(
                                        label: Text(user.nickname),
                                        selected: selected.contains(user.id),
                                        onSelected: (value) {
                                          setDialogState(() {
                                            if (value) {
                                              selected.add(user.id);
                                            } else {
                                              selected.remove(user.id);
                                            }
                                          });
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  initialValue: splitMode,
                                  decoration: InputDecoration(
                                    labelText: t.splitModeLabel,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'equal',
                                      child: Text(t.equalSplitLabel),
                                    ),
                                    DropdownMenuItem(
                                      value: 'exact',
                                      child: Text(t.exactAmountsLabel),
                                    ),
                                    DropdownMenuItem(
                                      value: 'percent',
                                      child: Text(t.percentagesLabel),
                                    ),
                                    DropdownMenuItem(
                                      value: 'shares',
                                      child: Text(t.sharesLabel),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    setDialogState(() {
                                      splitMode = value;
                                    });
                                  },
                                ),
                                if (splitMode != 'equal') ...[
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
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 6),
                                if (existing != null &&
                                    existing.receiptUrl != null)
                                  CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: Text(t.removeCurrentReceipt),
                                    value: removeExistingReceipt,
                                    onChanged: (value) {
                                      setDialogState(() {
                                        removeExistingReceipt = value == true;
                                        if (removeExistingReceipt) {
                                          selectedReceiptBytes = null;
                                          selectedReceiptName = null;
                                          preuploadedReceipt = null;
                                          receiptOcrHint = null;
                                        }
                                      });
                                    },
                                  ),
                                OutlinedButton.icon(
                                  onPressed: removeExistingReceipt
                                      ? null
                                      : () async {
                                          final picked =
                                              await _pickReceiptFile();
                                          if (!mounted || !context.mounted) {
                                            return;
                                          }
                                          if (picked == null) {
                                            return;
                                          }
                                          setDialogState(() {
                                            selectedReceiptBytes = picked.bytes;
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
                                                  payload: ReceiptUploadPayload(
                                                    fileName: picked.fileName,
                                                    bytes: picked.bytes,
                                                    tripId: widget.trip.id,
                                                  ),
                                                );
                                            if (!mounted || !context.mounted) {
                                              return;
                                            }
                                            final ocrAmount =
                                                uploaded.ocrAmount;
                                            final ocrDate = uploaded.ocrDate;
                                            final ocrMerchant =
                                                uploaded.ocrMerchant;
                                            setDialogState(() {
                                              preuploadedReceipt = uploaded;
                                              selectedReceiptBytes = null;
                                              if (ocrAmount != null &&
                                                  ocrAmount > 0 &&
                                                  _parseAmount(
                                                        amountController.text,
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
                                                  ? 'Receipt read and form updated.'
                                                  : 'Receipt attached. OCR found no clear amount/date/merchant.';
                                              isReceiptScanning = false;
                                            });
                                          } on ApiException catch (error) {
                                            if (!mounted || !context.mounted) {
                                              return;
                                            }
                                            setDialogState(() {
                                              isReceiptScanning = false;
                                              preuploadedReceipt = null;
                                              receiptOcrHint =
                                                  error.isNetworkError
                                                  ? 'Receipt will upload when you save. OCR needs internet/server access.'
                                                  : error.message;
                                            });
                                          } catch (_) {
                                            if (!mounted || !context.mounted) {
                                              return;
                                            }
                                            setDialogState(() {
                                              isReceiptScanning = false;
                                              preuploadedReceipt = null;
                                              receiptOcrHint =
                                                  'Receipt selected. OCR could not read this image.';
                                            });
                                          }
                                        },
                                  icon: const Icon(Icons.attach_file),
                                  label: Text(t.chooseReceiptFile),
                                ),
                                if (isReceiptScanning) ...[
                                  const SizedBox(height: 8),
                                  const LinearProgressIndicator(minHeight: 2),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reading receipt...',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                                if (selectedReceiptName != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    t.selectedFileLabel(selectedReceiptName!),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ] else if (existing != null &&
                                    existing.receiptUrl != null &&
                                    !removeExistingReceipt) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    t.currentReceiptAttached,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                                if (receiptOcrHint != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    receiptOcrHint!,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: preuploadedReceipt != null
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                                if (errorText != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    errorText!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () =>
                                      Navigator.of(sheetContext).pop(),
                                  child: Text(t.cancelAction),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    final amount = _parseAmount(
                                      amountController.text,
                                    );
                                    final date = toIsoDate(selectedExpenseDate);
                                    final note = noteController.text.trim();
                                    final rawCategory = isCustomCategoryMode
                                        ? customCategoryController.text.trim()
                                        : selectedCategory.trim();

                                    if (amount <= 0) {
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
                                        errorText = t.noteMustBeMaxChars(255);
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
                                                    .map((user) => user.id)
                                                    .where((id) => id > 0)
                                                    .toList(growable: false)
                                          ..sort();
                                    final amountCents = (amount * 100).round();
                                    final splitValues = <ExpenseSplitValue>[];

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
                                              controller?.text.trim() ?? '';
                                          final value = _parseAmount(raw);
                                          if (raw.isEmpty || value < 0) {
                                            setDialogState(() {
                                              errorText =
                                                  t.enterValidExactAmounts;
                                            });
                                            return;
                                          }
                                          totalCents += (value * 100).round();
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
                                              controller?.text.trim() ?? '';
                                          final value = _parseAmount(raw);
                                          if (raw.isEmpty || value < 0) {
                                            setDialogState(() {
                                              errorText = context
                                                  .l10n
                                                  .enterValidPercentages;
                                            });
                                            return;
                                          }
                                          final basisPoints = (value * 100)
                                              .round();
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
                                      } else if (splitMode == 'shares') {
                                        for (final userId
                                            in resolvedParticipants) {
                                          final controller =
                                              splitControllers[userId];
                                          final raw =
                                              controller?.text.trim() ?? '';
                                          final value = _parseAmount(raw);
                                          final rounded = value.round();
                                          if (raw.isEmpty || rounded <= 0) {
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

                                    Navigator.of(sheetContext).pop(
                                      _ExpenseFormResult(
                                        amount: amount,
                                        currencyCode: selectedCurrencyCode,
                                        date: date,
                                        category: category,
                                        note: note,
                                        participants: participants,
                                        splitMode: splitMode,
                                        splitValues: splitValues,
                                        receiptFileBytes: selectedReceiptBytes,
                                        receiptFileName: selectedReceiptName,
                                        preuploadedReceipt: preuploadedReceipt,
                                        removeReceipt: removeExistingReceipt,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    existing == null
                                        ? t.addAction
                                        : t.saveAction,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
