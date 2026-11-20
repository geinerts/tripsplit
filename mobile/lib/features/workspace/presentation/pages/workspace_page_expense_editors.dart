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

/// What "Fill from receipt" gives the item editor: lines to fill, or only a
/// message when the receipt could not be used.
class _ReceiptFill {
  const _ReceiptFill({this.draft, this.currencyCode, this.message});

  final ReceiptSplitDraft? draft;
  final String? currencyCode;
  final String? message;
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
    this.scanReceipt,
    this.addPerson,
  });
  final List<WorkspaceUser> users;
  final double amount;
  final String currencyCode;
  final String initialMode;
  final Map<int, String> initialValues;
  final List<ExpenseItem> initialItems;
  final double initialExtra;
  final Widget Function(WorkspaceUser) avatarBuilder;

  /// AI receipt reading for "By item"; null hides the button.
  final Future<_ReceiptFill?> Function()? scanReceipt;

  /// Adds someone to the split (quick split only); null hides "+ Add".
  final Future<WorkspaceUser?> Function()? addPerson;
  @override
  State<_ExpenseSplitEditor> createState() => _ExpenseSplitEditorState();
}

class _ExpenseSplitEditorState extends State<_ExpenseSplitEditor> {
  late String mode;
  final drafts = <String, Map<int, TextEditingController>>{};
  Map<int, TextEditingController> get controllers => drafts[mode]!;
  final _items = <_ExpenseItemDraft>[];
  final _extra = TextEditingController();

  /// People whose value was typed in, per mode. The others share what's left.
  final _pinned = <String, Set<int>>{};

  bool _scanning = false;
  String? _scanMessage;

  /// Everyone in the split; grows when a person is added from People.
  late final List<WorkspaceUser> _users = List.of(widget.users);

  Future<WorkspaceUser?> _addPerson() async {
    final add = widget.addPerson;
    if (add == null) return null;
    final person = await add();
    if (!mounted || person == null) return null;
    setState(() {
      if (_users.any((user) => user.id == person.id)) return;
      _users.add(person);
      // Values typed for other methods no longer fit; they start again.
      for (final entry in drafts.entries.toList()) {
        if (entry.key == mode) continue;
        for (final controller in entry.value.values) {
          controller.dispose();
        }
        drafts.remove(entry.key);
      }
      _pinned.clear();
    });
    return person;
  }

  /// Set once a receipt was read: its total and currency replace the form's
  /// for the item list, and a new run rebuilds the item editor from scratch.
  double? _scanAmount;
  String? _scanCurrency;
  int _scanRun = 0;

  Future<void> _scan() async {
    final scan = widget.scanReceipt;
    if (scan == null || _scanning) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _scanning = true;
      _scanMessage = null;
    });
    final fill = await scan();
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _scanMessage = fill?.message;
      final draft = fill?.draft;
      if (draft == null) return;
      final currency = fill?.currencyCode ?? widget.currencyCode;
      // The old rows' fields are still attached until this frame is built.
      final old = List.of(_items);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final item in old) {
          item.dispose();
        }
      });
      _items
        ..clear()
        ..addAll([
          for (final line in draft.lines)
            _ExpenseItemDraft(
              name: line.name,
              price: AppCurrencyCatalog.amountInputText(
                line.unitCents / 100,
                currency,
              ),
            )..qty = line.qty,
        ]);
      _extra.text = draft.extraCents > 0
          ? AppCurrencyCatalog.amountInputText(draft.extraCents / 100, currency)
          : '';
      _scanAmount = draft.totalCents / 100;
      _scanCurrency = currency;
      _scanRun++;
    });
  }

  Widget _receiptButton(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final message = _scanMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          key: const ValueKey('receipt-ai-fill'),
          onPressed: _scanning ? null : _scan,
          icon: _scanning
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome_outlined),
          label: Text(_scanning ? t.receiptAiReading : t.receiptAiFillAction),
        ),
        if (message != null) ...[
          const SizedBox(height: 6),
          Text(
            message,
            key: const ValueKey('receipt-ai-message'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    mode = widget.initialMode == 'equal' ? 'exact' : widget.initialMode;
    _prepare(
      mode,
      seed: widget.initialMode == mode ? widget.initialValues : null,
    );
    _items.addAll(
      _mergeItemDrafts(
        widget.initialItems,
        _users.map((user) => user.id).toSet(),
        widget.currencyCode,
      ),
    );
    if (_items.isEmpty) _items.add(_ExpenseItemDraft());
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
    final count = _users.length;
    drafts[value] = {
      for (var index = 0; index < count; index++)
        _users[index].id: TextEditingController(
          text:
              seed?[_users[index].id] ??
              (value == 'shares'
                  ? '1'
                  : value == 'adjustment'
                  ? '0'
                  : ((total ~/ count + (index < total % count ? 1 : 0)) / 100)
                        .toStringAsFixed(2)),
        ),
    };
  }

  bool get _autoFills => mode == 'exact' || mode == 'percent';

  /// Keeps typed values and splits the rest of the total evenly among
  /// everyone not typed in yet, so the split always adds up while it can.
  void _onEdited(int userId) {
    if (!_autoFills) return;
    final pinned = _pinned.putIfAbsent(mode, () => <int>{})..add(userId);
    final free = [
      for (final user in _users)
        if (!pinned.contains(user.id)) user.id,
    ];
    if (free.isEmpty) return;
    final expected = mode == 'percent' ? 10000 : (widget.amount * 100).round();
    var taken = 0;
    for (final id in pinned) {
      final value = _parseAmount(controllers[id]?.text ?? '');
      if (value.isFinite && value > 0) taken += (value * 100).round();
    }
    final rest = math.max(0, expected - taken);
    for (var i = 0; i < free.length; i++) {
      final cents = rest ~/ free.length + (i < rest % free.length ? 1 : 0);
      controllers[free[i]]?.text = (cents / 100).toStringAsFixed(2);
    }
  }

  void _splitEvenly() {
    _pinned.remove(mode);
    final total = mode == 'percent' ? 10000 : (widget.amount * 100).round();
    final count = _users.length;
    for (var i = 0; i < count; i++) {
      final cents = total ~/ count + (i < total % count ? 1 : 0);
      controllers[_users[i].id]?.text = (cents / 100).toStringAsFixed(2);
    }
  }

  /// What each person pays in money, for methods whose values aren't money.
  Map<int, int>? _moneyPreview(List<double?> values) {
    final amountCents = (widget.amount * 100).round();
    if (amountCents <= 0) return null;
    if (mode == 'adjustment') return _adjustedOwed;
    if (mode != 'percent' && mode != 'shares') return null;
    final ids = controllers.keys.toList();
    if (values.any((v) => v == null || !v.isFinite || v < 0)) return null;
    final weights = values.map((v) => v!).toList();
    final total = mode == 'percent'
        ? 100.0
        : weights.fold<double>(0, (sum, v) => sum + v);
    if (total <= 0) return null;
    return {
      for (var i = 0; i < ids.length; i++)
        ids[i]: (amountCents * weights[i] / total).round(),
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

  /// What each person pays with the current values, when they fit.
  Map<int, int>? get _adjustedOwed => adjustmentOwedCents(
    (widget.amount * 100).round(),
    _users.map((user) => user.id).toList(),
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
    final preview = _moneyPreview(values);
    final pinned = _pinned[mode] ?? const <int>{};
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
        if (_autoFills && pinned.isNotEmpty)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              key: const ValueKey('split-evenly'),
              onPressed: () => setState(_splitEvenly),
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: Text(t.expenseSplitEvenly),
            ),
          ),
        const SizedBox(height: 12),
        for (final user in _users) ...[
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
                          if (preview?[user.id] case final cents?)
                            Text(
                              _formatMoney(
                                context,
                                cents / 100,
                                currencyCode: widget.currencyCode,
                              ),
                              key: ValueKey('split-result-${user.id}'),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
                final field = TextField(
                  key: ValueKey('split-input-${user.id}'),
                  controller: controllers[user.id],
                  onChanged: (_) => setState(() => _onEdited(user.id)),
                  textAlign: TextAlign.end,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: mode != 'shares',
                    signed: mode == 'adjustment',
                  ),
                  decoration: _lineInputDecoration(
                    context,
                    label: mode == 'percent'
                        ? t.percentLabel
                        : mode == 'shares'
                        ? t.sharesLabel
                        : mode == 'adjustment'
                        ? t.expenseAdjustmentFieldLabel
                        : t.amountLabel,
                    suffix: mode == 'percent'
                        ? '%'
                        : mode == 'exact' || mode == 'adjustment'
                        ? widget.currencyCode
                        : null,
                    // A lock marks values you typed; the others fill in.
                    prefixIcon: _autoFills && pinned.contains(user.id)
                        ? Icon(
                            Icons.lock_outline_rounded,
                            size: 16,
                            key: ValueKey('split-pinned-${user.id}'),
                          )
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

  static List<(String, String, String, IconData)> _modeOptions(
    BuildContext context,
  ) {
    final t = context.l10n;
    return [
      (
        'exact',
        t.exactAmountsLabel,
        t.expenseSplitExactHint,
        Icons.payments_outlined,
      ),
      ('percent', t.percentagesLabel, t.expenseSplitPercentHint, Icons.percent),
      (
        'shares',
        t.sharesLabel,
        t.expenseSplitSharesHint,
        Icons.pie_chart_outline,
      ),
      (
        'adjustment',
        t.expenseAdjustmentsLabel,
        t.expenseSplitAdjustmentHint,
        Icons.exposure_rounded,
      ),
      (
        'itemized',
        t.expenseItemsLabel,
        t.expenseSplitItemsHint,
        Icons.receipt_long_rounded,
      ),
    ];
  }

  void _selectMode(String value) => setState(() {
    if (value != 'itemized') _prepare(value);
    mode = value;
  });

  /// One row like the category and date rows; the methods open in a list.
  Widget _modeChips(BuildContext context) {
    final t = context.l10n;
    final options = _modeOptions(context);
    final current = options.firstWhere(
      (option) => option.$1 == mode,
      orElse: () => options.first,
    );
    return _ExpenseCompactTile(
      key: const ValueKey('expense-split-method'),
      label: t.expenseSplitMethodTitle,
      value: current.$2,
      icon: current.$4,
      onTap: () async {
        final picked = await showAppBottomSheet<String>(
          context: context,
          builder: (sheetContext) =>
              _ExpenseSplitModePicker(options: options, selected: mode),
        );
        if (!mounted || picked == null || picked == mode) return;
        _selectMode(picked);
      },
    );
  }

  Widget _buildItemized(BuildContext context) => _ItemizedSplitEditor(
    key: ValueKey('itemized-$_scanRun'),
    users: _users,
    amount: _scanAmount ?? widget.amount,
    currencyCode: _scanCurrency ?? widget.currencyCode,
    receiptAction: widget.scanReceipt == null ? null : _receiptButton(context),
    addPerson: widget.addPerson == null ? null : _addPerson,
    items: _items,
    extra: _extra,
    avatarBuilder: widget.avatarBuilder,
    modeTile: _modeChips(context),
  );
}

/// The split methods as a list: icon, name, one-line explanation, check.
class _ExpenseSplitModePicker extends StatelessWidget {
  const _ExpenseSplitModePicker({
    required this.options,
    required this.selected,
  });
  final List<(String, String, String, IconData)> options;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                context.l10n.expenseSplitMethodTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final (index, option) in options.indexed) ...[
              if (index > 0) const Divider(height: 1),
              ListTile(
                key: ValueKey('split-mode-${option.$1}'),
                contentPadding: EdgeInsets.zero,
                selected: option.$1 == selected,
                leading: Icon(
                  option.$4,
                  color: option.$1 == selected
                      ? colors.primary
                      : AppDesign.mutedColor(context),
                ),
                title: Text(
                  option.$2,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  option.$3,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppDesign.mutedColor(context),
                  ),
                ),
                trailing: option.$1 == selected
                    ? Icon(Icons.check_rounded, color: colors.primary)
                    : null,
                onTap: () => Navigator.pop(context, option.$1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Same item at the same price, each for one person, shows as one line:
/// "Beer ×2 · €4.50 each · Matiss ×2" with the total on the right.
class _ExpenseItemsSummaryLine {
  _ExpenseItemsSummaryLine(this.name, this.unitCents);
  final String name;
  final int unitCents;
  int qty = 0;
  final List<int> people = [];
  bool shared = false;
}

class _ExpenseItemsSummary extends StatelessWidget {
  const _ExpenseItemsSummary({required this.expense, required this.nameFor});
  final TripExpense expense;
  final String Function(int id) nameFor;

  static List<_ExpenseItemsSummaryLine> groupLines(List<ExpenseItem> items) {
    final lines = <_ExpenseItemsSummaryLine>[];
    final byKey = <String, _ExpenseItemsSummaryLine>{};
    for (final item in items) {
      final cents = (item.amount * 100).round();
      if (item.participantIds.length != 1) {
        // Shared by several people: its own line, never merged.
        lines.add(
          _ExpenseItemsSummaryLine(item.name, cents)
            ..qty = 1
            ..shared = true
            ..people.addAll(item.participantIds),
        );
        continue;
      }
      final key = '${item.name.trim().toLowerCase()}|$cents';
      final line = byKey.putIfAbsent(key, () {
        final created = _ExpenseItemsSummaryLine(item.name.trim(), cents);
        lines.add(created);
        return created;
      });
      line.qty++;
      line.people.add(item.participantIds.single);
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    String money(int cents) => _formatMoney(
      context,
      cents / 100,
      currencyCode: expense.expenseCurrencyCode,
    );
    String people(_ExpenseItemsSummaryLine line) {
      final counts = <int, int>{};
      for (final id in line.people) {
        counts[id] = (counts[id] ?? 0) + 1;
      }
      // One person: just the name, the ×N is already on the item. Several:
      // counts only when someone had more than one, then for everyone.
      final withCounts =
          counts.length > 1 && counts.values.any((count) => count > 1);
      return [
        for (final entry in counts.entries)
          withCounts
              ? '${nameFor(entry.key)} ×${entry.value}'
              : nameFor(entry.key),
      ].join(', ');
    }

    Widget row({
      required String title,
      int qty = 1,
      required int totalCents,
      String? detail,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: title,
                    children: [
                      if (qty > 1)
                        TextSpan(
                          text: '  ×$qty',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                if (detail != null && detail.isNotEmpty)
                  Text(detail, style: muted),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            money(totalCents),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
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
        for (final line in groupLines(expense.items))
          row(
            title: line.name,
            qty: line.qty,
            totalCents: line.unitCents * line.qty,
            detail: [
              if (line.qty > 1) t.expenseItemEach(money(line.unitCents)),
              people(line),
            ].join(' · '),
          ),
        if (expense.extraAmount > 0)
          row(
            title: t.expenseItemExtra,
            totalCents: (expense.extraAmount * 100).round(),
          ),
      ],
    );
  }
}
