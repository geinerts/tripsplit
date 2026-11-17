part of 'workspace_page.dart';

/// One receipt line: a name, the price for one and how many there were.
class _ExpenseItemDraft {
  _ExpenseItemDraft({
    String name = '',
    String price = '',
    Map<int, int>? taken,
    this.shared = false,
  }) : name = TextEditingController(text: name),
       price = TextEditingController(text: price),
       taken = taken ?? <int, int>{};

  final TextEditingController name;
  final TextEditingController price;
  int qty = 1;

  /// A single item several people had together (dessert, water). It stays
  /// on everyone's list; other single items disappear once someone takes them.
  bool shared;

  /// Units per person. With a single unit, everyone ticked shares it.
  final Map<int, int> taken;

  int get priceCents {
    final value = _parseAmount(price.text);
    return value.isFinite && value > 0 ? (value * 100).round() : 0;
  }

  int get totalCents => priceCents * qty;
  bool get isBlank => name.text.trim().isEmpty && price.text.trim().isEmpty;
  bool get filled =>
      name.text.trim().isNotEmpty &&
      name.text.trim().length <= 80 &&
      priceCents > 0;
  int get assigned => qty == 1
      ? (taken.isEmpty ? 0 : 1)
      : taken.values.fold<int>(0, (sum, units) => sum + units);
  int get left => math.max(0, qty - assigned);

  int get unassignedCents =>
      qty == 1 ? (taken.isEmpty ? totalCents : 0) : left * priceCents;

  /// Keeps the people valid after the quantity changed.
  void fitTaken() {
    if (qty == 1) {
      for (final id in taken.keys.toList()) {
        taken[id] = 1;
      }
      if (taken.length > 1) shared = true;
      return;
    }
    shared = false;
    if (taken.length > 1 && taken.values.every((units) => units == 1)) {
      // A shared single item became several: nobody has picked units yet.
      if (taken.length > qty) taken.clear();
    }
    var over = assigned - qty;
    for (final id in taken.keys.toList().reversed) {
      if (over <= 0) break;
      final cut = math.min(over, taken[id]!);
      taken[id] = taken[id]! - cut;
      over -= cut;
      if (taken[id] == 0) taken.remove(id);
    }
  }

  void dispose() {
    name.dispose();
    price.dispose();
  }
}

/// What the server stores: a line with several units becomes one line per
/// unit, each with the person who had it. The itemized contract stays as is.
List<ExpenseItem> _expandItemDrafts(Iterable<_ExpenseItemDraft> drafts) {
  final items = <ExpenseItem>[];
  for (final draft in drafts) {
    if (!draft.filled || draft.taken.isEmpty) continue;
    final name = draft.name.text.trim();
    final amount = draft.priceCents / 100;
    final ids = draft.taken.keys.toList()..sort();
    if (draft.qty == 1) {
      items.add(ExpenseItem(name: name, amount: amount, participantIds: ids));
      continue;
    }
    for (final id in ids) {
      for (var unit = 0; unit < draft.taken[id]!; unit++) {
        items.add(
          ExpenseItem(name: name, amount: amount, participantIds: [id]),
        );
      }
    }
  }
  return items;
}

/// Lines with the same name and price, each for one person, show as "×N".
List<_ExpenseItemDraft> _mergeItemDrafts(
  List<ExpenseItem> items,
  Set<int> userIds,
  String currencyCode,
) {
  final drafts = <_ExpenseItemDraft>[];
  for (final item in items) {
    final ids = item.participantIds.where(userIds.contains).toList();
    final cents = (item.amount * 100).round();
    final last = drafts.isEmpty ? null : drafts.last;
    if (last != null &&
        ids.length == 1 &&
        last.name.text == item.name &&
        last.priceCents == cents &&
        last.taken.isNotEmpty &&
        !last.shared &&
        (last.qty > 1 || last.taken.length == 1)) {
      last.qty++;
      last.taken[ids.first] = (last.taken[ids.first] ?? 0) + 1;
      continue;
    }
    drafts.add(
      _ExpenseItemDraft(
        name: item.name,
        price: AppCurrencyCatalog.amountInputText(item.amount, currencyCode),
        taken: {for (final id in ids) id: 1},
        shared: ids.length > 1,
      ),
    );
  }
  return drafts;
}

Color _warnColor(BuildContext context) =>
    (Theme.of(context).extension<AppSemanticColors>() ??
            AppSemanticColors.light)
        .statusPendingForeground;

/// Underline-only fields, used by every custom split method.
InputDecoration _lineInputDecoration(
  BuildContext context, {
  String? label,
  String? hint,
  String? suffix,
  Widget? prefixIcon,
}) {
  final colors = Theme.of(context).colorScheme;
  final line = UnderlineInputBorder(
    borderSide: BorderSide(color: colors.outlineVariant, width: 1.5),
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixText: suffix,
    prefixIcon: prefixIcon,
    filled: false,
    isDense: true,
    counterText: '',
    contentPadding: const EdgeInsets.symmetric(vertical: 8),
    border: line,
    enabledBorder: line,
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: colors.primary, width: 2),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: colors.error, width: 1.5),
    ),
  );
}

/// "By item": first the receipt lines, then each person ticks what they had.
class _ItemizedSplitEditor extends StatefulWidget {
  const _ItemizedSplitEditor({
    required this.users,
    required this.amount,
    required this.currencyCode,
    required this.items,
    required this.extra,
    required this.avatarBuilder,
    required this.modeTile,
  });

  final List<WorkspaceUser> users;
  final double amount;
  final String currencyCode;
  final List<_ExpenseItemDraft> items;
  final TextEditingController extra;
  final Widget Function(WorkspaceUser) avatarBuilder;
  final Widget modeTile;

  @override
  State<_ItemizedSplitEditor> createState() => _ItemizedSplitEditorState();
}

class _ItemizedSplitEditorState extends State<_ItemizedSplitEditor> {
  bool _peopleTab = false;
  int? _editing;
  late int _person = widget.users.first.id;

  List<_ExpenseItemDraft> get _items => widget.items;

  @override
  void initState() {
    super.initState();
    if (_items.every((item) => item.isBlank)) _editing = 0;
  }

  String _money(int cents) =>
      _formatMoney(context, cents / 100, currencyCode: widget.currencyCode);

  int get _extraCents {
    final value = _parseAmount(widget.extra.text);
    return value.isFinite && value > 0 ? (value * 100).round() : 0;
  }

  List<_ExpenseItemDraft> get _filled =>
      _items.where((item) => item.filled).toList(growable: false);

  int get _enteredCents =>
      _filled.fold<int>(_extraCents, (sum, item) => sum + item.totalCents);

  int get _receiptCents => (widget.amount * 100).round();

  int get _expandedCount =>
      _filled.fold<int>(0, (sum, item) => sum + (item.qty == 1 ? 1 : item.qty));

  bool get _listReady {
    final extra = _parseAmount(widget.extra.text);
    return _filled.isNotEmpty &&
        _items.every((item) => item.filled || item.isBlank) &&
        _expandedCount <= 100 &&
        extra.isFinite &&
        extra >= 0 &&
        (_receiptCents <= 0 || _receiptCents == _enteredCents);
  }

  bool get _allAssigned => _filled.every((item) => item.left == 0);

  String _userName(int id) =>
      widget.users.where((user) => user.id == id).firstOrNull?.preferredName ??
      '';

  void _addItem() {
    if (_items.length >= 100) return;
    _items.add(_ExpenseItemDraft());
    _editing = _items.length - 1;
  }

  void _nextItem() => setState(() {
    final current = _editing;
    if (current == null) return;
    if (current < _items.length - 1) {
      _editing = current + 1;
    } else if (!_items[current].isBlank) {
      _addItem();
    }
  });

  void _removeItem(int index) => setState(() {
    _items.removeAt(index).dispose();
    if (_items.isEmpty) _items.add(_ExpenseItemDraft());
    _editing = null;
  });

  void _openPeople() => setState(() {
    _items.removeWhere((item) {
      final blank = item.isBlank && _items.length > 1;
      if (blank) item.dispose();
      return blank;
    });
    _editing = null;
    _peopleTab = true;
  });

  void _done() {
    Navigator.pop(
      context,
      _ExpenseSplitDraft(
        'itemized',
        const {},
        items: _expandItemDrafts(_filled),
        extra: _extraCents / 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.expenseCustomSplit,
                      style: Theme.of(context).textTheme.titleLarge,
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
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widget.modeTile,
                    const SizedBox(height: 12),
                    _tabs(context),
                    const SizedBox(height: 14),
                    if (_peopleTab)
                      ..._peopleBody(context)
                    else
                      ..._itemsBody(context),
                  ],
                ),
              ),
            ),
            _bottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    Widget tab(bool people, IconData icon, String label, String key) {
      final selected = _peopleTab == people;
      final enabled = !people || _listReady;
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          enabled: enabled,
          label: label,
          excludeSemantics: true,
          child: Material(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              key: ValueKey(key),
              borderRadius: BorderRadius.circular(20),
              onTap: !enabled || selected
                  ? null
                  : () => people
                        ? _openPeople()
                        : setState(() => _peopleTab = false),
              child: SizedBox(
                height: 40,
                child: Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? colors.onPrimary
                      : enabled
                      ? colors.onSurfaceVariant
                      : colors.onSurfaceVariant.withValues(alpha: .4),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          tab(
            false,
            Icons.receipt_long_outlined,
            t.expenseItemsLabel,
            'expense-items-tab-items',
          ),
          tab(
            true,
            Icons.people_outline_rounded,
            t.expenseItemsPeople,
            'expense-items-tab-people',
          ),
        ],
      ),
    );
  }

  // ---- Items tab ----------------------------------------------------------

  List<Widget> _itemsBody(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final entered = _enteredCents;
    final receipt = _receiptCents;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );
    return [
      Row(
        children: [
          Expanded(child: Text(t.expenseItemsEntered, style: muted)),
          Text(
            receipt > 0
                ? t.expenseItemsEnteredOf(_money(entered), _money(receipt))
                : _money(entered),
            key: const ValueKey('expense-items-entered'),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      if (receipt > 0) ...[
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: (entered / receipt).clamp(0, 1).toDouble(),
          minHeight: 4,
          borderRadius: BorderRadius.circular(999),
          color: entered > receipt ? _warnColor(context) : null,
        ),
      ],
      const SizedBox(height: 18),
      Text(
        t.expenseItemList,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 4),
      for (var index = 0; index < _items.length; index++)
        _editing == index
            ? _itemEditRow(context, index)
            : _itemRow(context, index),
      InkWell(
        key: const ValueKey('expense-add-item'),
        onTap: _items.length >= 100 ? null : () => setState(_addItem),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              _iconTile(context, Icons.add_rounded, primary: true),
              const SizedBox(width: 12),
              Text(
                t.expenseAddItem,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      const Divider(height: 1),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _iconTile(context, Icons.percent_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.expenseItemExtra, style: theme.textTheme.bodyLarge),
                  Text(t.expenseItemsExtraShort, style: muted),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 104,
              child: TextField(
                key: const ValueKey('expense-item-extra'),
                controller: widget.extra,
                onChanged: (_) => setState(() {}),
                textAlign: TextAlign.end,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _lineInputDecoration(
                  context,
                  hint: '0',
                  suffix: widget.currencyCode,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _iconTile(
    BuildContext context,
    IconData icon, {
    bool primary = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: primary
            ? colors.primary.withValues(alpha: .12)
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 17,
        color: primary ? colors.primary : colors.onSurfaceVariant,
      ),
    );
  }

  Widget _qtyChip(BuildContext context, int qty) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '×$qty',
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _itemRow(BuildContext context, int index) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final item = _items[index];
    final name = item.name.text.trim();
    return InkWell(
      key: ValueKey('expense-item-row-$index'),
      onTap: () => setState(() => _editing = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.outlineVariant)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name.isEmpty ? t.expenseItemName : name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: name.isEmpty
                                ? colors.onSurfaceVariant
                                : null,
                          ),
                        ),
                      ),
                      if (item.qty > 1) _qtyChip(context, item.qty),
                    ],
                  ),
                  if (item.qty == 1 && item.shared)
                    Text(
                      t.expenseItemShared,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  if (item.qty > 1 && item.priceCents > 0)
                    Text(
                      t.expenseItemEach(_money(item.priceCents)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              item.filled ? _money(item.totalCents) : '—',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: item.filled ? null : _warnColor(context),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepper(
    BuildContext context, {
    required int value,
    required VoidCallback? onMinus,
    required VoidCallback? onPlus,
    required String keyPrefix,
    bool compact = false,
  }) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    Widget button(IconData icon, VoidCallback? onTap, String key, String tip) =>
        IconButton(
          key: ValueKey('$keyPrefix-$key'),
          tooltip: tip,
          visualDensity: VisualDensity.compact,
          constraints: BoxConstraints.tightFor(
            width: compact ? 34 : 40,
            height: compact ? 32 : 40,
          ),
          padding: EdgeInsets.zero,
          iconSize: compact ? 16 : 20,
          color: colors.primary,
          onPressed: onTap,
          icon: Icon(icon),
        );
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(compact ? 16 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(Icons.remove_rounded, onMinus, 'minus', t.expenseItemQty),
          Text(
            '$value',
            key: ValueKey('$keyPrefix-value'),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          button(Icons.add_rounded, onPlus, 'plus', t.expenseItemQty),
        ],
      ),
    );
  }

  Widget _itemEditRow(BuildContext context, int index) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final item = _items[index];
    return Container(
      key: ValueKey('expense-item-editor-$index'),
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: ValueKey('expense-item-name-$index'),
            controller: item.name,
            autofocus: item.isBlank,
            onChanged: (_) => setState(() {}),
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            style: theme.textTheme.bodyLarge,
            decoration: _lineInputDecoration(context, hint: t.expenseItemName),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 116,
                child: TextField(
                  key: ValueKey('expense-item-amount-$index'),
                  controller: item.price,
                  onChanged: (_) => setState(() {}),
                  textAlign: TextAlign.end,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onSubmitted: (_) => _nextItem(),
                  decoration: _lineInputDecoration(
                    context,
                    label: t.expenseItemPriceEach,
                    suffix: widget.currencyCode,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.expenseItemQty,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _stepper(
                    context,
                    value: item.qty,
                    keyPrefix: 'expense-item-qty-$index',
                    onMinus: item.qty <= 1
                        ? null
                        : () => setState(() {
                            item.qty--;
                            item.fitTaken();
                          }),
                    onPlus: _expandedCount >= 100 || item.qty >= 99
                        ? null
                        : () => setState(() {
                            item.qty++;
                            item.fitTaken();
                          }),
                  ),
                ],
              ),
              if (item.priceCents > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '= ${_money(item.totalCents)}',
                    key: ValueKey('expense-item-total-$index'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (item.qty == 1) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Semantics(
                button: true,
                toggled: item.shared,
                child: Material(
                  color: item.shared
                      ? colors.primary.withValues(alpha: .14)
                      : colors.surfaceContainerHighest,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    key: ValueKey('expense-item-shared-$index'),
                    customBorder: const StadiumBorder(),
                    onTap: () => setState(() {
                      item.shared = !item.shared;
                      if (!item.shared && item.taken.length > 1) {
                        item.taken.clear();
                      }
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.shared
                                ? Icons.check_rounded
                                : Icons.group_outlined,
                            size: 17,
                            color: item.shared
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t.expenseItemShared,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: item.shared
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          Row(
            children: [
              if (_items.length > 1)
                TextButton.icon(
                  key: ValueKey('expense-item-remove-$index'),
                  onPressed: () => _removeItem(index),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(t.expenseRemoveItem),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.onSurfaceVariant,
                  ),
                ),
              const Spacer(),
              TextButton(
                key: const ValueKey('expense-next-item'),
                onPressed: item.isBlank && index == _items.length - 1
                    ? null
                    : _nextItem,
                child: Text('${t.expenseNextItem} ›'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- People tab ---------------------------------------------------------

  List<Widget> _peopleBody(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final expanded = _expandItemDrafts(_filled);
    final owed = itemizedOwedCents(expanded, _extraCents);
    final itemsOnly = itemizedOwedCents(expanded, 0);
    final person = _person;
    final allAssigned = _allAssigned;
    final active = <int>[];
    final gone = <int>[];
    for (var index = 0; index < _items.length; index++) {
      final item = _items[index];
      if (!item.filled) continue;
      final mine = item.taken[person] ?? 0;
      final open = item.qty == 1
          ? item.shared || item.taken.isEmpty
          : item.left > 0;
      // Shared items stay open: anyone can still join them.
      if (mine > 0 ||
          (item.qty == 1 && item.shared) ||
          (!allAssigned && open)) {
        active.add(index);
      } else if (!allAssigned) {
        gone.add(index);
      }
    }
    final extraShare = (owed[person] ?? 0) - (itemsOnly[person] ?? 0);
    return [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final user in widget.users)
              _personPick(context, user, owed[user.id] ?? 0),
          ],
        ),
      ),
      const SizedBox(height: 8),
      for (final index in active) _personItemRow(context, index, person),
      if (_extraCents > 0)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              _iconTile(context, Icons.percent_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.expenseItemExtra, style: theme.textTheme.bodyLarge),
                    Text(
                      t.expenseItemsExtraShort,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _money(extraShare),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      for (final index in gone) _goneRow(context, index),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          key: const ValueKey('expense-people-add-item'),
          onPressed: _items.length >= 100
              ? null
              : () => setState(() {
                  _peopleTab = false;
                  _addItem();
                }),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(t.expenseAddItem),
        ),
      ),
    ];
  }

  Widget _personPick(BuildContext context, WorkspaceUser user, int cents) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = user.id == _person;
    final has = _items.any((item) => (item.taken[user.id] ?? 0) > 0);
    return Semantics(
      button: true,
      selected: selected,
      label: '${user.preferredName}, ${_money(cents)}',
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('expense-person-${user.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _person = user.id),
        child: Container(
          width: 76,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.primary : Colors.transparent,
              width: 1.5,
            ),
            color: selected ? colors.primary.withValues(alpha: .08) : null,
          ),
          child: Column(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: has ? colors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: SizedBox.expand(
                        child: FittedBox(child: widget.avatarBuilder(user)),
                      ),
                    ),
                    if (has)
                      PositionedDirectional(
                        end: -2,
                        bottom: -2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.surface, width: 2),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 11,
                            color: colors.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.preferredName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              Text(
                _money(cents),
                key: ValueKey('split-result-${user.id}'),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cents > 0 ? null : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggle(_ExpenseItemDraft item, int person) => setState(() {
    final mine = item.taken[person] ?? 0;
    if (mine > 0) {
      item.taken.remove(person);
    } else if (item.qty == 1
        ? item.shared || item.taken.isEmpty
        : item.left > 0) {
      item.taken[person] = 1;
    }
  });

  Widget _personItemRow(BuildContext context, int index, int person) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final item = _items[index];
    final mine = item.taken[person] ?? 0;
    final others = item.taken.keys.where((id) => id != person).toList();
    final String? subtitle;
    final int cents;
    if (item.qty == 1) {
      subtitle = others.isNotEmpty
          ? t.expenseItemsSharedWith(others.map(_userName).join(', '))
          : item.shared
          ? t.expenseItemShared
          : null;
      cents =
          item.priceCents ~/ (mine > 0 ? item.taken.length : others.length + 1);
    } else {
      subtitle = mine > 0
          ? [
              t.expenseItemsOfQty(mine, item.qty),
              if (item.left > 0) t.expenseItemsLeft(item.left),
            ].join(' · ')
          : '${t.expenseItemsLeft(item.left)} · '
                '${t.expenseItemEach(_money(item.priceCents))}';
      cents = mine > 0 ? mine * item.priceCents : item.priceCents;
    }
    return InkWell(
      key: ValueKey('expense-item-$index-person-$person'),
      onTap: () => _toggle(item, person),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.outlineVariant)),
        ),
        child: Row(
          children: [
            Semantics(
              checked: mine > 0,
              label: item.name.text.trim(),
              child: Checkbox(
                value: mine > 0,
                onChanged: (_) => _toggle(item, person),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name.text.trim(),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      if (item.qty > 1) _qtyChip(context, item.qty),
                    ],
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _money(cents),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: mine > 0 ? FontWeight.w600 : FontWeight.w400,
                    color: mine > 0 ? null : colors.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (item.qty > 1) ...[
                  const SizedBox(height: 4),
                  _stepper(
                    context,
                    compact: true,
                    value: mine,
                    keyPrefix: 'expense-item-$index-units-$person',
                    onMinus: mine <= 0
                        ? null
                        : () => setState(() {
                            if (mine <= 1) {
                              item.taken.remove(person);
                            } else {
                              item.taken[person] = mine - 1;
                            }
                          }),
                    onPlus: item.left <= 0
                        ? null
                        : () => setState(() => item.taken[person] = mine + 1),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _goneRow(BuildContext context, int index) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final item = _items[index];
    final names = item.taken.keys.map(_userName).join(', ');
    return Padding(
      key: ValueKey('expense-item-taken-$index'),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.check_rounded,
            size: 18,
            color: colors.onSurfaceVariant.withValues(alpha: .6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${item.name.text.trim()} · $names',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Bottom ---------------------------------------------------------------

  Widget _bottomBar(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final ready = _listReady;
    late final Widget status;
    late final Widget button;
    if (!_peopleTab) {
      final receipt = _receiptCents;
      final entered = _enteredCents;
      final itemsCents = entered - _extraCents;
      final diff = receipt - entered;
      final ok = receipt <= 0 || diff == 0;
      final text = receipt > 0 && diff > 0
          ? t.expenseItemsMissing(_money(diff))
          : receipt > 0 && diff < 0
          ? t.expenseItemsOver(_money(-diff))
          : _extraCents > 0
          ? '${t.expenseItemsCheck(_money(itemsCents), _money(_extraCents), _money(entered))} ✓'
          : t.expenseItemsTotal(_money(entered));
      status = Text(
        text,
        key: const ValueKey('expense-split-status'),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: ok ? colors.onSurfaceVariant : _warnColor(context),
          fontWeight: ok ? FontWeight.w400 : FontWeight.w600,
        ),
      );
      button = ElevatedButton.icon(
        key: const ValueKey('expense-items-to-people'),
        onPressed: ready ? _openPeople : null,
        icon: const Icon(Icons.people_outline_rounded, size: 20),
        label: Text(t.expenseItemsPeople),
      );
    } else if (!_allAssigned) {
      final unassigned = _filled.fold<int>(
        0,
        (sum, item) => sum + item.unassignedCents,
      );
      status = Row(
        key: const ValueKey('expense-split-status'),
        children: [
          Expanded(
            child: Text(
              t.expenseItemsNotAssigned,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            _money(unassigned),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
      final ids = widget.users.map((user) => user.id).toList();
      button = ElevatedButton(
        key: const ValueKey('expense-next-person'),
        onPressed: ids.length < 2
            ? null
            : () => setState(() {
                _person = ids[(ids.indexOf(_person) + 1) % ids.length];
              }),
        child: Text(t.expenseItemsNextPerson),
      );
    } else {
      status = Text(
        '✓ ${t.expenseItemsAllAssigned(_money(_enteredCents))}',
        key: const ValueKey('expense-split-status'),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
      );
      button = ElevatedButton(
        key: const ValueKey('expense-editor-done'),
        onPressed: ready ? _done : null,
        child: Text(t.doneStatus),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(liveRegion: true, child: status),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: button),
        ],
      ),
    );
  }
}
