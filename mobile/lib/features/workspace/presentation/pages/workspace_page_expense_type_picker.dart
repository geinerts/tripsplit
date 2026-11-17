part of 'workspace_page.dart';

/// The shown name of a type: built-in keys are translated, own types stay as
/// written.
String _expenseTypeLabel(BuildContext context, String type) {
  final t = context.l10n;
  return switch (type) {
    'restaurant' => t.expenseTypeRestaurant,
    'cafe' => t.expenseTypeCafe,
    'bar' => t.expenseTypeBar,
    'fast_food' => t.expenseTypeFastFood,
    'snacks' => t.expenseTypeSnacks,
    'taxi' => t.expenseTypeTaxi,
    'flight' => t.expenseTypeFlight,
    'train' => t.expenseTypeTrain,
    'bus' => t.expenseTypeBus,
    'car_rental' => t.expenseTypeCarRental,
    'ferry' => t.expenseTypeFerry,
    'public_transport' => t.expenseTypePublicTransport,
    'hotel' => t.expenseTypeHotel,
    'hostel' => t.expenseTypeHostel,
    'apartment' => t.expenseTypeApartment,
    'camping' => t.expenseTypeCamping,
    _ => type,
  };
}

/// "Food · Restaurant" with the type a little lighter, or just "Food".
Widget _expenseCategoryTitle(
  BuildContext context,
  TripExpense expense, {
  TextStyle? style,
  int maxLines = 1,
  Key? key,
}) {
  final category = ExpenseCategoryCatalog.labelFor(
    expense.category,
    Localizations.localeOf(context),
  );
  final type = expense.subcategory;
  final muted = Theme.of(context).colorScheme.onSurfaceVariant;
  return Text.rich(
    TextSpan(
      text: category,
      children: [
        if (type != null && type.trim().isNotEmpty)
          TextSpan(
            text: ' · ${_expenseTypeLabel(context, type)}',
            style: TextStyle(color: muted, fontWeight: FontWeight.w400),
          ),
      ],
    ),
    key: key,
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    style: style,
  );
}

/// Own types used in this trip for a category, with how often each was used.
/// Names match without case, keeping the first spelling seen.
Map<String, (String, int)> _tripCustomTypes(
  Iterable<TripExpense> expenses,
  String category,
) {
  final found = <String, (String, int)>{};
  for (final expense in expenses) {
    if (ExpenseCategoryCatalog.normalizeStored(expense.category) != category) {
      continue;
    }
    final type = ExpenseTypeCatalog.clean(expense.subcategory);
    if (type == null || ExpenseTypeCatalog.isBuiltIn(type)) continue;
    final key = ExpenseTypeCatalog.matchKey(type);
    final current = found[key];
    found[key] = (current?.$1 ?? type, (current?.$2 ?? 0) + 1);
  }
  return found;
}

/// What the type menu returns: a type, or none.
class _ExpenseTypeChoice {
  const _ExpenseTypeChoice(this.type);
  final String? type;
}

/// Opens the type menu right under [anchor] (the category field), in the
/// same style as the expense filter menu. Typing an own type lifts it above
/// the keyboard.
Future<_ExpenseTypeChoice?> _showExpenseTypeMenu({
  required BuildContext context,
  required Rect anchor,
  required String category,
  required String? selected,
  required Map<String, (String, int)> tripTypes,
}) {
  return showGeneralDialog<_ExpenseTypeChoice>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 140),
    transitionBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
    pageBuilder: (_, _, _) => _ExpenseTypeMenu(
      anchor: anchor,
      category: category,
      selected: selected,
      tripTypes: tripTypes,
    ),
  );
}

/// Puts the menu under the anchor, or as low as the keyboard allows.
class _ExpenseTypeMenuLayout extends SingleChildLayoutDelegate {
  const _ExpenseTypeMenuLayout({
    required this.anchor,
    required this.width,
    required this.top,
    required this.bottom,
  });

  final Rect anchor;
  final double width;
  final double top;
  final double bottom;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        minWidth: width,
        maxWidth: width,
        maxHeight: math.max(120, bottom - top),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final left = anchor.left.clamp(
      16.0,
      math.max(16.0, size.width - width - 16),
    );
    final y = math.max(
      top,
      math.min(anchor.bottom + 6, bottom - childSize.height),
    );
    return Offset(left.toDouble(), y);
  }

  @override
  bool shouldRelayout(_ExpenseTypeMenuLayout old) =>
      old.anchor != anchor ||
      old.width != width ||
      old.top != top ||
      old.bottom != bottom;
}

/// "Type of food · optional": no type, the built-in types, this trip's
/// regular own types (3+ uses) and "Custom type…" typed in place.
class _ExpenseTypeMenu extends StatefulWidget {
  const _ExpenseTypeMenu({
    required this.anchor,
    required this.category,
    required this.selected,
    required this.tripTypes,
  });

  final Rect anchor;
  final String category;
  final String? selected;
  final Map<String, (String, int)> tripTypes;

  @override
  State<_ExpenseTypeMenu> createState() => _ExpenseTypeMenuState();
}

class _ExpenseTypeMenuState extends State<_ExpenseTypeMenu> {
  late final _custom = TextEditingController(
    text:
        widget.selected != null &&
            !ExpenseTypeCatalog.isBuiltIn(widget.selected!) &&
            !_isRegular(widget.selected!)
        ? widget.selected
        : '',
  );
  late bool _typing = _custom.text.isNotEmpty;

  List<String> get _regular => [
    for (final entry in widget.tripTypes.values)
      if (entry.$2 >= 3) entry.$1,
  ];

  bool _isRegular(String type) => _regular.any(
    (regular) =>
        ExpenseTypeCatalog.matchKey(regular) ==
        ExpenseTypeCatalog.matchKey(type),
  );

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _pick(String? type) => Navigator.pop(
    context,
    _ExpenseTypeChoice(ExpenseTypeCatalog.clean(type)),
  );

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final media = MediaQuery.of(context);
    final (title, none) = switch (widget.category) {
      'food' => (t.expenseTypeTitleFood, t.expenseTypeNoneFood),
      'transport' => (t.expenseTypeTitleTransport, t.expenseTypeNoneTransport),
      'accommodation' => (
        t.expenseTypeTitleAccommodation,
        t.expenseTypeNoneAccommodation,
      ),
      'activities' => (
        t.expenseTypeTitleActivities,
        t.expenseTypeNoneActivities,
      ),
      _ => (t.expenseTypeTitleShopping, t.expenseTypeNoneShopping),
    };
    final selectedKey = widget.selected == null
        ? null
        : ExpenseTypeCatalog.matchKey(widget.selected!);
    final query = ExpenseTypeCatalog.matchKey(_custom.text);
    final suggestions = query.isEmpty
        ? const <String>[]
        : [
            for (final entry in widget.tripTypes.values)
              if (ExpenseTypeCatalog.matchKey(entry.$1).contains(query) &&
                  ExpenseTypeCatalog.matchKey(entry.$1) != query)
                entry.$1,
          ].take(4).toList(growable: false);
    final canSave = ExpenseTypeCatalog.clean(_custom.text) != null;
    final menu = Material(
      key: const ValueKey('expense-type-menu'),
      elevation: 8,
      color: colors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant, width: .5),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Text.rich(
                TextSpan(
                  text: title,
                  children: [
                    TextSpan(
                      text: '  ${t.expenseTypeOptional}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(height: 1),
            _FilterMenuOption(
              key: const ValueKey('expense-type-none'),
              icon: Icons.remove_circle_outline,
              label: none,
              selected: widget.selected == null,
              onTap: () => _pick(null),
            ),
            for (final option in ExpenseTypeCatalog.forCategory(
              widget.category,
            ))
              _FilterMenuOption(
                key: ValueKey('expense-type-${option.key}'),
                icon: option.icon,
                label: _expenseTypeLabel(context, option.key),
                selected: selectedKey == option.key,
                onTap: () => _pick(option.key),
              ),
            for (final type in _regular)
              _FilterMenuOption(
                key: ValueKey(
                  'expense-type-trip-${ExpenseTypeCatalog.matchKey(type)}',
                ),
                icon: Icons.label_outline_rounded,
                label: type,
                selected: selectedKey == ExpenseTypeCatalog.matchKey(type),
                onTap: () => _pick(type),
              ),
            if (!_typing)
              _FilterMenuOption(
                key: const ValueKey('expense-type-custom'),
                icon: Icons.edit_outlined,
                label: t.expenseTypeCustom,
                selected: false,
                onTap: () => setState(() => _typing = true),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                child: TextField(
                  key: const ValueKey('expense-type-custom-field'),
                  controller: _custom,
                  autofocus: true,
                  maxLength: ExpenseTypeCatalog.maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (value) {
                    if (ExpenseTypeCatalog.clean(value) != null) _pick(value);
                  },
                  decoration: InputDecoration(
                    hintText: t.expenseTypeCustomHint,
                    counterText: '',
                    isDense: true,
                    filled: false,
                    contentPadding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Material(
                        color: canSave
                            ? colors.primary
                            : colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(9),
                        child: InkWell(
                          key: const ValueKey('expense-type-custom-save'),
                          borderRadius: BorderRadius.circular(9),
                          onTap: canSave ? () => _pick(_custom.text) : null,
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(
                              Icons.check_rounded,
                              size: 20,
                              semanticLabel: t.saveAction,
                              color: canSave
                                  ? colors.onPrimary
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              for (final suggestion in suggestions)
                InkWell(
                  key: ValueKey(
                    'expense-type-suggestion-${ExpenseTypeCatalog.matchKey(suggestion)}',
                  ),
                  onTap: () => _pick(suggestion),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.short_text_rounded,
                            size: 20,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _boldPart(
                              suggestion,
                              _custom.text.trim(),
                              theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
    final keyboard = media.viewInsets.bottom;
    return CustomSingleChildLayout(
      delegate: _ExpenseTypeMenuLayout(
        anchor: widget.anchor,
        width: math.min(
          math.max(widget.anchor.width, 260),
          media.size.width - 32,
        ),
        top: media.padding.top + 8,
        bottom:
            media.size.height - math.max(keyboard, media.padding.bottom) - 8,
      ),
      child: menu,
    );
  }

  /// The typed part in bold, the rest plain.
  Widget _boldPart(String text, String typed, TextStyle? style) {
    final at = text.toLowerCase().indexOf(typed.toLowerCase());
    if (typed.isEmpty || at < 0) return Text(text, style: style);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, at)),
          TextSpan(
            text: text.substring(at, at + typed.length),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: text.substring(at + typed.length)),
        ],
      ),
      style: style,
    );
  }
}
