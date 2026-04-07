part of 'workspace_page.dart';

extension _WorkspacePageDialogs on _WorkspacePageState {
  Future<_ExpenseFormResult?> _showExpenseDialog({
    required List<WorkspaceUser> users,
    TripExpense? existing,
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
    final dateController = TextEditingController(
      text: existing?.expenseDate.isNotEmpty == true
          ? existing!.expenseDate
          : _todayIsoDate(),
    );
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
    if (existing != null && splitMode != 'equal') {
      for (final participant in existing.participants) {
        final seedValue = isLegacySplitMode
            ? participant.owedAmount
            : (participant.splitValue ?? participant.owedAmount);
        splitControllers[participant.id] = TextEditingController(
          text: seedValue != null ? _formatNumericInput(seedValue) : '',
        );
      }
    }
    Uint8List? selectedReceiptBytes;
    String? selectedReceiptName;
    bool removeExistingReceipt = false;
    try {
      return await Navigator.of(context).push<_ExpenseFormResult>(
        MaterialPageRoute<_ExpenseFormResult>(
          builder: (sheetContext) {
            final t = sheetContext.l10n;
            String? errorText;

            Future<String?> pickCurrencyCode(
              BuildContext dialogContext,
              String currentCode,
            ) async {
              var query = '';
              return showModalBottomSheet<String>(
                context: dialogContext,
                showDragHandle: true,
                useSafeArea: true,
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
                              final haystack =
                                  '${item.code} ${item.label} ${item.symbol}'
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
                                  hintText: _plainLocalizedText(
                                    en: 'Search currency',
                                    lv: 'Meklēt valūtu',
                                  ),
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
                                        _plainLocalizedText(
                                          en: 'No currencies found',
                                          lv: 'Valūtas netika atrastas',
                                        ),
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
                                                      '${item.code} - ${item.label}',
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
                final viewInsetsBottom = MediaQuery.of(
                  context,
                ).viewInsets.bottom;
                final maxSheetHeight = MediaQuery.sizeOf(context).height;

                return Scaffold(
                  body: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: viewInsetsBottom),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxSheetHeight),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                            Flexible(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
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
                                      _plainLocalizedText(
                                        en: 'Currency',
                                        lv: 'Valūta',
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
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
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: AppDesign.cardStroke(
                                                context,
                                              ),
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
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  '${selectedCurrency.code} - ${selectedCurrency.label}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              ),
                                              Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
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
                                    TextField(
                                      controller: dateController,
                                      decoration: InputDecoration(
                                        labelText: t.dateLabel,
                                        hintText: t.dateFormatHint,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _plainLocalizedText(
                                        en: 'Category',
                                        lv: 'Kategorija',
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final option
                                            in ExpenseCategoryCatalog.builtIn)
                                          ChoiceChip(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(option.icon, size: 16),
                                                const SizedBox(width: 6),
                                                Text(
                                                  option.labelForLocale(
                                                    Localizations.localeOf(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            selected:
                                                !isCustomCategoryMode &&
                                                selectedCategory
                                                        .toLowerCase() ==
                                                    option.key,
                                            onSelected: (_) {
                                              setDialogState(() {
                                                isCustomCategoryMode = false;
                                                selectedCategory = option.key;
                                              });
                                            },
                                          ),
                                        ChoiceChip(
                                          avatar: const Icon(
                                            Icons.add,
                                            size: 16,
                                          ),
                                          label: Text(
                                            _plainLocalizedText(
                                              en: 'Custom category',
                                              lv: 'Sava kategorija',
                                            ),
                                          ),
                                          selected: isCustomCategoryMode,
                                          onSelected: (_) {
                                            setDialogState(() {
                                              isCustomCategoryMode = true;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    if (isCustomCategoryMode) ...[
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: customCategoryController,
                                        maxLength: 64,
                                        decoration: InputDecoration(
                                          labelText: _plainLocalizedText(
                                            en: 'Category name',
                                            lv: 'Kategorijas nosaukums',
                                          ),
                                          hintText: _plainLocalizedText(
                                            en: 'Apartment rent, parking, etc.',
                                            lv: 'Dzīvokļa īre, stāvvieta u.c.',
                                          ),
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
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final user in users)
                                          FilterChip(
                                            label: Text(user.nickname),
                                            selected: selected.contains(
                                              user.id,
                                            ),
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
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
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
                                            removeExistingReceipt =
                                                value == true;
                                            if (removeExistingReceipt) {
                                              selectedReceiptBytes = null;
                                              selectedReceiptName = null;
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
                                                selectedReceiptName =
                                                    picked.fileName;
                                                removeExistingReceipt = false;
                                              });
                                            },
                                      icon: const Icon(Icons.attach_file),
                                      label: Text(t.chooseReceiptFile),
                                    ),
                                    if (selectedReceiptName != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        t.selectedFileLabel(
                                          selectedReceiptName!,
                                        ),
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
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                10,
                                12,
                                12,
                              ),
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
                                        final date = dateController.text.trim();
                                        final note = noteController.text.trim();
                                        final rawCategory = isCustomCategoryMode
                                            ? customCategoryController.text
                                                  .trim()
                                            : selectedCategory.trim();

                                        if (amount <= 0) {
                                          setDialogState(() {
                                            errorText =
                                                t.amountMustBeGreaterThanZero;
                                          });
                                          return;
                                        }

                                        if (!RegExp(
                                          r'^\d{4}-\d{2}-\d{2}$',
                                        ).hasMatch(date)) {
                                          setDialogState(() {
                                            errorText = t.dateMustMatchFormat;
                                          });
                                          return;
                                        }

                                        if (rawCategory.isEmpty) {
                                          setDialogState(() {
                                            errorText = isCustomCategoryMode
                                                ? _plainLocalizedText(
                                                    en: 'Enter a custom category.',
                                                    lv: 'Ievadi savu kategoriju.',
                                                  )
                                                : _plainLocalizedText(
                                                    en: 'Pick an expense category.',
                                                    lv: 'Izvēlies izdevuma kategoriju.',
                                                  );
                                          });
                                          return;
                                        }

                                        if (isCustomCategoryMode &&
                                            rawCategory.length < 2) {
                                          setDialogState(() {
                                            errorText = _plainLocalizedText(
                                              en: 'Category must be at least 2 characters.',
                                              lv: 'Kategorijai jābūt vismaz 2 rakstzīmēm.',
                                            );
                                          });
                                          return;
                                        }

                                        final category =
                                            ExpenseCategoryCatalog.normalizeStored(
                                              rawCategory,
                                            );
                                        if (category.length > 64) {
                                          setDialogState(() {
                                            errorText = _plainLocalizedText(
                                              en: 'Category must be up to 64 characters.',
                                              lv: 'Kategorija var būt līdz 64 rakstzīmēm.',
                                            );
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
                                                        .map((user) => user.id)
                                                        .where((id) => id > 0)
                                                        .toList(growable: false)
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
                                                  controller?.text.trim() ?? '';
                                              final value = _parseAmount(raw);
                                              if (raw.isEmpty || value < 0) {
                                                setDialogState(() {
                                                  errorText =
                                                      t.enterValidExactAmounts;
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
                                                  controller?.text.trim() ?? '';
                                              final value = _parseAmount(raw);
                                              if (raw.isEmpty || value < 0) {
                                                setDialogState(() {
                                                  errorText = _plainLocalizedText(
                                                    en: 'Enter valid percentages for all participants.',
                                                    lv: 'Ievadi derīgus procentus visiem dalībniekiem.',
                                                  );
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
                                                errorText = _plainLocalizedText(
                                                  en: 'Percentage split must total 100%.',
                                                  lv: 'Procentu sadalei jāsummējas līdz 100%.',
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
                                                  controller?.text.trim() ?? '';
                                              final value = _parseAmount(raw);
                                              final rounded = value.round();
                                              if (raw.isEmpty || rounded <= 0) {
                                                setDialogState(() {
                                                  errorText = _plainLocalizedText(
                                                    en: 'Shares must be greater than 0 for all participants.',
                                                    lv: 'Daļām jābūt lielākām par 0 visiem dalībniekiem.',
                                                  );
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
                                            receiptFileBytes:
                                                selectedReceiptBytes,
                                            receiptFileName:
                                                selectedReceiptName,
                                            removeReceipt:
                                                removeExistingReceipt,
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
        dateController.dispose();
        for (final controller in splitControllers.values) {
          controller.dispose();
        }
      });
    }
  }
}
