part of 'workspace_page.dart';

extension _WorkspacePageDialogs on _WorkspacePageState {
  Future<_ExpenseFormResult?> _showExpenseDialog({
    required List<WorkspaceUser> users,
    TripExpense? existing,
  }) async {
    final amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
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

    final selected = existing == null
        ? <int>{}
        : existing.participants.map((p) => p.id).toSet();
    final rawSplitMode = (existing?.splitMode ?? 'equal').trim().toLowerCase();
    final isLegacySplitMode =
        rawSplitMode != 'equal' && rawSplitMode != 'exact';
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

    return showDialog<_ExpenseFormResult>(
      context: context,
      builder: (context) {
        final t = context.l10n;
        String? errorText;

        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  existing == null ? t.addExpenseTitle : t.editExpenseTitle,
                ),
                content: SizedBox(
                  width: 450,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: t.amountLabel,
                            hintText: t.amountHint,
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
                          _plainLocalizedText(en: 'Category', lv: 'Kategorija'),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final option in ExpenseCategoryCatalog.builtIn)
                              ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(option.icon, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      option.labelForLocale(
                                        Localizations.localeOf(context),
                                      ),
                                    ),
                                  ],
                                ),
                                selected:
                                    !isCustomCategoryMode &&
                                    selectedCategory.toLowerCase() ==
                                    option.key,
                                onSelected: (_) {
                                  setDialogState(() {
                                    isCustomCategoryMode = false;
                                    selectedCategory = option.key;
                                  });
                                },
                              ),
                            ChoiceChip(
                              avatar: const Icon(Icons.add, size: 16),
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
                            style: Theme.of(context).textTheme.bodySmall,
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
                        if (existing != null && existing.receiptUrl != null)
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
                                }
                              });
                            },
                          ),
                        OutlinedButton.icon(
                          onPressed: removeExistingReceipt
                              ? null
                              : () async {
                                  final picked = await _pickReceiptFile();
                                  if (!mounted || !context.mounted) {
                                    return;
                                  }
                                  if (picked == null) {
                                    return;
                                  }
                                  setDialogState(() {
                                    selectedReceiptBytes = picked.bytes;
                                    selectedReceiptName = picked.fileName;
                                    removeExistingReceipt = false;
                                  });
                                },
                          icon: const Icon(Icons.attach_file),
                          label: Text(t.chooseReceiptFile),
                        ),
                        if (selectedReceiptName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            t.selectedFileLabel(selectedReceiptName!),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ] else if (existing != null &&
                            existing.receiptUrl != null &&
                            !removeExistingReceipt) ...[
                          const SizedBox(height: 4),
                          Text(
                            t.currentReceiptAttached,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (errorText != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    child: Text(t.cancelAction),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final amount = _parseAmount(amountController.text);
                      final date = dateController.text.trim();
                      final note = noteController.text.trim();
                      final rawCategory = isCustomCategoryMode
                          ? customCategoryController.text.trim()
                          : selectedCategory.trim();

                      if (amount <= 0) {
                        setDialogState(() {
                          errorText = t.amountMustBeGreaterThanZero;
                        });
                        return;
                      }

                      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
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

                      if (isCustomCategoryMode && rawCategory.length < 2) {
                        setDialogState(() {
                          errorText = _plainLocalizedText(
                            en: 'Category must be at least 2 characters.',
                            lv: 'Kategorijai jābūt vismaz 2 rakstzīmēm.',
                          );
                        });
                        return;
                      }

                      final category = ExpenseCategoryCatalog.normalizeStored(
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
                          errorText = t.noteMustBeMaxChars(255);
                        });
                        return;
                      }

                      final participants = selected.toList(growable: false)
                        ..sort();
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
                            errorText = t.pickAtLeastOneParticipant;
                          });
                          return;
                        }

                        if (splitMode == 'exact') {
                          var totalCents = 0;
                          for (final userId in resolvedParticipants) {
                            final controller = splitControllers[userId];
                            final raw = controller?.text.trim() ?? '';
                            final value = _parseAmount(raw);
                            if (raw.isEmpty || value < 0) {
                              setDialogState(() {
                                errorText = t.enterValidExactAmounts;
                              });
                              return;
                            }
                            totalCents += (value * 100).round();
                            splitValues.add(
                              ExpenseSplitValue(userId: userId, value: value),
                            );
                          }
                          if (totalCents != amountCents) {
                            setDialogState(() {
                              errorText = t.exactSplitMustMatchTotal(
                                _formatMoney(amount),
                              );
                            });
                            return;
                          }
                        }
                      }

                      Navigator.of(context, rootNavigator: true).pop(
                        _ExpenseFormResult(
                          amount: amount,
                          date: date,
                          category: category,
                          note: note,
                          participants: participants,
                          splitMode: splitMode,
                          splitValues: splitValues,
                          receiptFileBytes: selectedReceiptBytes,
                          receiptFileName: selectedReceiptName,
                          removeReceipt: removeExistingReceipt,
                        ),
                      );
                    },
                    child: Text(existing == null ? t.addAction : t.saveAction),
                  ),
                ],
              );
            },
          );
        },
      );
  }
}
