part of 'workspace_page.dart';

class _ExpenseSplitDraft {
  const _ExpenseSplitDraft(this.mode, this.values);
  final String mode;
  final Map<int, String> values;
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
  });
  final List<WorkspaceUser> users;
  final double amount;
  final String currencyCode;
  final String initialMode;
  final Map<int, String> initialValues;
  final Widget Function(WorkspaceUser) avatarBuilder;
  @override
  State<_ExpenseSplitEditor> createState() => _ExpenseSplitEditorState();
}

class _ExpenseSplitEditorState extends State<_ExpenseSplitEditor> {
  late String mode;
  final drafts = <String, Map<int, TextEditingController>>{};
  Map<int, TextEditingController> get controllers => drafts[mode]!;

  @override
  void initState() {
    super.initState();
    mode = widget.initialMode == 'equal' ? 'exact' : widget.initialMode;
    _prepare(
      mode,
      seed: widget.initialMode == mode ? widget.initialValues : null,
    );
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final values = controllers.values
        .map((c) => double.tryParse(c.text.trim().replaceAll(',', '.')))
        .toList();
    final numbersValid =
        values.isNotEmpty &&
        values.every(
          (v) =>
              v != null &&
              v.isFinite &&
              v >= 0 &&
              (mode != 'shares' || (v > 0 && v == v.roundToDouble())),
        );
    final total = values.fold<int>(
      0,
      (sum, v) => sum + (v != null && v.isFinite ? (v * 100).round() : 0),
    );
    final expected = mode == 'percent' ? 10000 : (widget.amount * 100).round();
    final valid =
        numbersValid &&
        (mode == 'shares' || total == expected) &&
        widget.amount > 0;
    String format(int cents) => mode == 'percent'
        ? '${(cents / 100).toStringAsFixed(2)}%'
        : _formatMoney(context, cents / 100, currencyCode: widget.currencyCode);
    final difference = expected - total;
    final status = !numbersValid
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
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final option in [
              ('exact', t.exactAmountsLabel, Icons.payments_outlined),
              ('percent', t.percentagesLabel, Icons.percent),
              ('shares', t.sharesLabel, Icons.pie_chart_outline),
            ])
              ChoiceChip(
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                showCheckmark: false,
                label: Text(option.$2),
                avatar: Icon(option.$3, size: 16),
                selected: mode == option.$1,
                onSelected: (_) => setState(() {
                  _prepare(option.$1);
                  mode = option.$1;
                }),
              ),
          ],
        ),
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
                    Expanded(child: Text(user.preferredName)),
                  ],
                );
                final field = TextField(
                  key: ValueKey('split-input-${user.id}'),
                  controller: controllers[user.id],
                  onChanged: (_) => setState(() {}),
                  textAlign: TextAlign.end,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: mode != 'shares',
                  ),
                  decoration: InputDecoration(
                    labelText: mode == 'percent'
                        ? t.percentLabel
                        : mode == 'shares'
                        ? t.sharesLabel
                        : t.amountLabel,
                    suffixText: mode == 'percent'
                        ? '%'
                        : mode == 'exact'
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
}
