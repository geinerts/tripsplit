part of 'workspace_page.dart';

class _ExpenseSplitDraft {
  const _ExpenseSplitDraft(
    this.mode,
    this.values, {
    this.items = const [],
    this.extra = 0,
  });
  final String mode;
  final Map<int, String> values;
  final List<ExpenseItem> items;
  final double extra;
}

/// A bounded editor with a scrollable body and an always reachable action.
class _ExpenseEditorSurface extends StatelessWidget {
  const _ExpenseEditorSurface({
    required this.title,
    required this.children,
    required this.onDone,
  });
  final String title;
  final List<Widget> children;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              math.max(
                0,
                media.size.height -
                    media.viewInsets.bottom -
                    media.padding.top -
                    40,
              ) *
              .9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('expense-editor-close'),
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    ...children,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const ValueKey('expense-editor-done'),
                  onPressed: onDone,
                  child: Text(context.l10n.doneStatus),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseParticipantsEditor extends StatefulWidget {
  const _ExpenseParticipantsEditor({
    required this.users,
    required this.selected,
    required this.avatarBuilder,
  });
  final List<WorkspaceUser> users;
  final Set<int> selected;
  final Widget Function(WorkspaceUser) avatarBuilder;
  @override
  State<_ExpenseParticipantsEditor> createState() =>
      _ExpenseParticipantsEditorState();
}

class _ExpenseParticipantsEditorState
    extends State<_ExpenseParticipantsEditor> {
  late final selected = {...widget.selected};
  @override
  Widget build(BuildContext context) => _ExpenseEditorSurface(
    title: context.l10n.expenseEditParticipants,
    onDone: selected.isEmpty ? null : () => Navigator.pop(context, selected),
    children: [
      for (final user in widget.users)
        CheckboxListTile(
          key: ValueKey('expense-participant-${user.id}'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.trailing,
          secondary: widget.avatarBuilder(user),
          title: Text(user.preferredName),
          value: selected.contains(user.id),
          onChanged: (value) => setState(() {
            value == true ? selected.add(user.id) : selected.remove(user.id);
          }),
        ),
      if (selected.isEmpty)
        Text(
          context.l10n.pickAtLeastOneParticipant,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
    ],
  );
}

class _ExpenseSplitEditor extends StatefulWidget {
  const _ExpenseSplitEditor({
    required this.users,
    required this.amount,
    required this.currencyCode,
    required this.initialMode,
    required this.initialValues,
    required this.avatarBuilder,
    this.initialItems = const [],
    this.initialExtra = 0,
  });
  final List<WorkspaceUser> users;
  final double amount;
  final String currencyCode;
  final String initialMode;
  final Map<int, String> initialValues;
  final List<ExpenseItem> initialItems;
  final double initialExtra;
  final Widget Function(WorkspaceUser) avatarBuilder;
  @override
  State<_ExpenseSplitEditor> createState() => _ExpenseSplitEditorState();
}

class _ExpenseSplitEditorState extends State<_ExpenseSplitEditor> {
  late String mode;
  final drafts = <String, Map<int, TextEditingController>>{};
  Map<int, TextEditingController> get controllers => drafts[mode]!;
  final _items = <_ExpenseItemDraft>[];
  final _extra = TextEditingController();

  void _addItem() => _items.add(
    _ExpenseItemDraft(people: widget.users.map((user) => user.id).toSet()),
  );

  @override
  void initState() {
    super.initState();
    mode = widget.initialMode == 'equal' ? 'exact' : widget.initialMode;
    _prepare(
      mode,
      seed: widget.initialMode == mode ? widget.initialValues : null,
    );
    final userIds = widget.users.map((user) => user.id).toSet();
    for (final item in widget.initialItems) {
      _items.add(
        _ExpenseItemDraft(
          name: item.name,
          amount: AppCurrencyCatalog.amountInputText(
            item.amount,
            widget.currencyCode,
          ),
          people: item.participantIds.where(userIds.contains).toSet(),
        ),
      );
    }
    if (_items.isEmpty) _addItem();
    if (widget.initialExtra > 0) {
      _extra.text = AppCurrencyCatalog.amountInputText(
        widget.initialExtra,
        widget.currencyCode,
      );
    }
  }

  void _prepare(String value, {Map<int, String>? seed}) {
    if (drafts.containsKey(value)) return;
    final total = value == 'percent' ? 10000 : (widget.amount * 100).round();
    final count = widget.users.length;
    drafts[value] = {
      for (var index = 0; index < count; index++)
        widget.users[index].id: TextEditingController(
          text:
              seed?[widget.users[index].id] ??
              (value == 'shares'
                  ? '1'
                  : value == 'adjustment'
                  ? '0'
                  : ((total ~/ count + (index < total % count ? 1 : 0)) / 100)
                        .toStringAsFixed(2)),
        ),
    };
  }

  @override
  void dispose() {
    for (final values in drafts.values) {
      for (final controller in values.values) {
        controller.dispose();
      }
    }
    for (final item in _items) {
      item.dispose();
    }
    _extra.dispose();
    super.dispose();
  }

  List<ExpenseItem> get _cleanItems => [
    for (final item in _items)
      ExpenseItem(
        name: item.name.text.trim(),
        amount: _parseAmount(item.amount.text),
        participantIds: item.people.toList()..sort(),
      ),
  ];

  bool get _itemsValid =>
      _parseAmount(_extra.text) >= 0 &&
      _cleanItems.every(
        (item) =>
            item.name.isNotEmpty &&
            item.name.length <= 80 &&
            item.amount > 0 &&
            item.participantIds.isNotEmpty,
      );

  /// What each person pays with the current values, when they fit.
  Map<int, int>? get _adjustedOwed => adjustmentOwedCents(
    (widget.amount * 100).round(),
    widget.users.map((user) => user.id).toList(),
    {
      for (final entry
          in drafts['adjustment']?.entries ??
              const <MapEntry<int, TextEditingController>>[])
        entry.key: (_parseAmount(entry.value.text) * 100).round(),
    },
  );

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    if (mode == 'itemized') return _buildItemized(context);
    final values = controllers.values
        .map((c) => double.tryParse(c.text.trim().replaceAll(',', '.')))
        .toList();
    final numbersValid =
        values.isNotEmpty &&
        values.every(
          (v) =>
              v != null &&
              v.isFinite &&
              (mode == 'adjustment' || v >= 0) &&
              (mode != 'shares' || (v > 0 && v == v.roundToDouble())),
        );
    final total = values.fold<int>(
      0,
      (sum, v) => sum + (v != null && v.isFinite ? (v * 100).round() : 0),
    );
    final expected = mode == 'percent' ? 10000 : (widget.amount * 100).round();
    final valid =
        numbersValid &&
        (mode == 'shares' ||
            (mode == 'adjustment'
                ? _adjustedOwed != null
                : total == expected)) &&
        widget.amount > 0;
    String format(int cents) => mode == 'percent'
        ? '${(cents / 100).toStringAsFixed(2)}%'
        : _formatMoney(context, cents / 100, currencyCode: widget.currencyCode);
    final difference = expected - total;
    final status = widget.amount <= 0
        ? t.amountMustBeGreaterThanZero
        : mode == 'adjustment'
        ? (valid ? t.expenseAdjustmentsHint : t.expenseAdjustmentsMustFit)
        : !numbersValid
        ? (mode == 'shares'
              ? t.workspaceSharesMustBeGreaterThan0ForAllParticipants
              : mode == 'percent'
              ? t.enterValidPercentages
              : t.enterValidExactAmounts)
        : mode == 'shares'
        ? '${t.sharesLabel}: ${total ~/ 100}'
        : difference == 0
        ? t.expenseSplitAllocated(format(expected))
        : difference > 0
        ? t.expenseSplitRemaining(format(difference))
        : t.expenseSplitOver(format(-difference));
    return _ExpenseEditorSurface(
      title: t.expenseCustomSplit,
      onDone: valid
          ? () => Navigator.pop(
              context,
              _ExpenseSplitDraft(mode, {
                for (final e in controllers.entries) e.key: e.value.text,
              }),
            )
          : null,
      children: [
        Text(
          '${t.totalLabel}: ${_formatMoney(context, widget.amount, currencyCode: widget.currencyCode)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _modeChips(context),
        const SizedBox(height: 12),
        for (final user in widget.users) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stacked =
                    constraints.maxWidth < 280 ||
                    MediaQuery.textScalerOf(context).scale(16) > 24;
                final label = Row(
                  children: [
                    widget.avatarBuilder(user),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.preferredName),
                          if (mode == 'adjustment' && _adjustedOwed != null)
                            Text(
                              format(_adjustedOwed![user.id] ?? 0),
                              key: ValueKey('split-result-${user.id}'),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
                final field = TextField(
                  key: ValueKey('split-input-${user.id}'),
                  controller: controllers[user.id],
                  onChanged: (_) => setState(() {}),
                  textAlign: TextAlign.end,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: mode != 'shares',
                    signed: mode == 'adjustment',
                  ),
                  decoration: InputDecoration(
                    labelText: mode == 'percent'
                        ? t.percentLabel
                        : mode == 'shares'
                        ? t.sharesLabel
                        : mode == 'adjustment'
                        ? t.expenseAdjustmentFieldLabel
                        : t.amountLabel,
                    suffixText: mode == 'percent'
                        ? '%'
                        : mode == 'exact' || mode == 'adjustment'
                        ? widget.currencyCode
                        : null,
                  ),
                );
                return stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [label, const SizedBox(height: 10), field],
                      )
                    : Row(
                        children: [
                          Expanded(child: label),
                          const SizedBox(width: 12),
                          SizedBox(width: 128, child: field),
                        ],
                      );
              },
            ),
          ),
          const Divider(height: 1),
        ],
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                valid ? Icons.check_circle_outline : Icons.info_outline,
                size: 18,
                color: valid
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  status,
                  key: const ValueKey('expense-split-status'),
                  style: TextStyle(
                    color: valid
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _modeChips(BuildContext context) {
    final t = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final option in [
          ('exact', t.exactAmountsLabel, Icons.payments_outlined),
          ('percent', t.percentagesLabel, Icons.percent),
          ('shares', t.sharesLabel, Icons.pie_chart_outline),
          ('adjustment', t.expenseAdjustmentsLabel, Icons.exposure_rounded),
          ('itemized', t.expenseItemsLabel, Icons.receipt_long_rounded),
        ])
          ChoiceChip(
            key: ValueKey('split-mode-${option.$1}'),
            labelStyle: Theme.of(context).textTheme.bodyMedium,
            showCheckmark: false,
            label: Text(option.$2),
            avatar: Icon(option.$3, size: 16),
            selected: mode == option.$1,
            onSelected: (_) => setState(() {
              if (option.$1 != 'itemized') _prepare(option.$1);
              mode = option.$1;
            }),
          ),
      ],
    );
  }

  Widget _buildItemized(BuildContext context) {
    final t = context.l10n;
    final valid = _itemsValid;
    final items = _cleanItems;
    final extra = _parseAmount(_extra.text);
    final total = items.fold<double>(
      extra.isFinite && extra > 0 ? extra : 0,
      (sum, item) => sum + (item.amount.isFinite ? item.amount : 0),
    );
    final owed = valid
        ? itemizedOwedCents(items, (extra * 100).round())
        : const <int, int>{};
    final totalText = _formatMoney(
      context,
      total,
      currencyCode: widget.currencyCode,
    );
    return _ExpenseEditorSurface(
      title: t.expenseCustomSplit,
      onDone: valid
          ? () => Navigator.pop(
              context,
              _ExpenseSplitDraft(
                'itemized',
                const {},
                items: items,
                extra: extra,
              ),
            )
          : null,
      children: [
        _modeChips(context),
        const SizedBox(height: 12),
        for (var index = 0; index < _items.length; index++) ...[
          _ExpenseItemEditor(
            key: ObjectKey(_items[index]),
            index: index,
            draft: _items[index],
            users: widget.users,
            currencyCode: widget.currencyCode,
            avatarBuilder: widget.avatarBuilder,
            onChanged: () => setState(() {}),
            onRemove: _items.length < 2
                ? null
                : () => setState(() {
                    _items.removeAt(index).dispose();
                  }),
          ),
          const Divider(height: 1),
        ],
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            key: const ValueKey('expense-add-item'),
            onPressed: _items.length >= 100 ? null : () => setState(_addItem),
            icon: const Icon(Icons.add_rounded),
            label: Text(t.expenseAddItem),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          key: const ValueKey('expense-item-extra'),
          controller: _extra,
          onChanged: (_) => setState(() {}),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: t.expenseItemExtra,
            helperText: t.expenseItemExtraHint,
            helperMaxLines: 2,
            suffixText: widget.currencyCode,
          ),
        ),
        const SizedBox(height: 12),
        for (final user in widget.users)
          if ((owed[user.id] ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text(user.preferredName)),
                  Text(
                    _formatMoney(
                      context,
                      owed[user.id]! / 100,
                      currencyCode: widget.currencyCode,
                    ),
                    key: ValueKey('split-result-${user.id}'),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Text(
            valid ? t.expenseItemsTotal(totalText) : t.expenseItemsInvalid,
            key: const ValueKey('expense-split-status'),
            style: TextStyle(
              color: valid
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpenseItemDraft {
  _ExpenseItemDraft({String name = '', String amount = '', Set<int>? people})
    : name = TextEditingController(text: name),
      amount = TextEditingController(text: amount),
      people = people ?? <int>{};
  final TextEditingController name;
  final TextEditingController amount;
  final Set<int> people;

  void dispose() {
    name.dispose();
    amount.dispose();
  }
}

class _ExpenseItemEditor extends StatelessWidget {
  const _ExpenseItemEditor({
    super.key,
    required this.index,
    required this.draft,
    required this.users,
    required this.currencyCode,
    required this.avatarBuilder,
    required this.onChanged,
    required this.onRemove,
  });
  final int index;
  final _ExpenseItemDraft draft;
  final List<WorkspaceUser> users;
  final String currencyCode;
  final Widget Function(WorkspaceUser) avatarBuilder;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: ValueKey('expense-item-name-$index'),
                  controller: draft.name,
                  onChanged: (_) => onChanged(),
                  maxLength: 80,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: t.expenseItemName,
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 112,
                child: TextField(
                  key: ValueKey('expense-item-amount-$index'),
                  controller: draft.amount,
                  onChanged: (_) => onChanged(),
                  textAlign: TextAlign.end,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: t.amountLabel,
                    suffixText: currencyCode,
                  ),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  key: ValueKey('expense-item-remove-$index'),
                  tooltip: t.expenseRemoveItem,
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final user in users)
                FilterChip(
                  key: ValueKey('expense-item-$index-person-${user.id}'),
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  showCheckmark: false,
                  avatar: ExcludeSemantics(child: avatarBuilder(user)),
                  label: Text(user.preferredName),
                  selected: draft.people.contains(user.id),
                  onSelected: (on) {
                    if (on) {
                      draft.people.add(user.id);
                    } else {
                      draft.people.remove(user.id);
                    }
                    onChanged();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseItemsSummary extends StatelessWidget {
  const _ExpenseItemsSummary({required this.expense, required this.nameFor});
  final TripExpense expense;
  final String Function(int id) nameFor;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    Widget line(String title, double amount, String? detail) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium),
                if (detail != null)
                  Text(detail, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatMoney(
              context,
              amount,
              currencyCode: expense.expenseCurrencyCode,
            ),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(t.expenseItemsLabel, style: theme.textTheme.titleSmall),
        ),
        const SizedBox(height: 4),
        for (final item in expense.items)
          line(
            item.name,
            item.amount,
            item.participantIds.map(nameFor).join(', '),
          ),
        if (expense.extraAmount > 0)
          line(t.expenseItemExtra, expense.extraAmount, null),
      ],
    );
  }
}
