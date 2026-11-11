import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';
import '../l10n/l10n.dart';

enum AppBottomNavItem { home, analytics, expenses, friends, profile }

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedItem,
    required this.onSelected,
    required this.avatarLetter,
    this.avatarBytes,
    this.avatarUrl,
    this.vertical = false,
  });

  final AppBottomNavItem? selectedItem;
  final ValueChanged<AppBottomNavItem> onSelected;
  final Uint8List? avatarBytes;
  final String? avatarUrl;
  final String avatarLetter;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final labels = [
      t.navHome,
      t.navActivities,
      t.navExpenses,
      t.navFriends,
      t.navProfile,
    ];
    const icons = [
      Icons.home_outlined,
      Icons.query_stats_outlined,
      Icons.receipt_long_outlined,
      Icons.people_outline,
      Icons.account_circle_outlined,
    ];
    // Icons only, no labels: the selected tab gets a filled icon. Names stay
    // in the tooltip and the screen reader label.
    const selectedIcons = [
      Icons.home,
      Icons.query_stats,
      Icons.receipt_long,
      Icons.people,
      Icons.account_circle,
    ];
    IconData iconFor(AppBottomNavItem item) =>
        selectedItem == item ? selectedIcons[item.index] : icons[item.index];
    if (vertical) {
      return Material(
        key: const ValueKey('app-navigation-rail'),
        color: AppDesign.pageBaseColor(context),
        child: SizedBox(
          width: 104,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: colors.outlineVariant)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  for (final item in AppBottomNavItem.values)
                    Semantics(
                      button: true,
                      selected: item == AppBottomNavItem.expenses
                          ? null
                          : selectedItem == item,
                      label: item == AppBottomNavItem.expenses
                          ? t.addExpensesAction
                          : labels[item.index],
                      child: Tooltip(
                        message: item == AppBottomNavItem.expenses
                            ? t.addExpensesAction
                            : labels[item.index],
                        child: InkWell(
                          key: ValueKey('nav-${item.name}'),
                          onTap: () => onSelected(item),
                          overlayColor: const WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          splashFactory: NoSplash.splashFactory,
                          child: ExcludeSemantics(
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    selectedItem == item &&
                                        item != AppBottomNavItem.expenses
                                    ? colors.primary.withValues(alpha: .10)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: item == AppBottomNavItem.expenses
                                  ? Center(child: _buildExpenseIcon(context))
                                  : Icon(
                                      iconFor(item),
                                      size: 26,
                                      color: selectedItem == item
                                          ? colors.primary
                                          : colors.onSurfaceVariant,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            top: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppDesign.pageBaseColor(context),
                border: Border(top: BorderSide(color: colors.outlineVariant)),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in AppBottomNavItem.values)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: item == AppBottomNavItem.expenses
                            ? null
                            : selectedItem == item,
                        label: item == AppBottomNavItem.expenses
                            ? t.addExpensesAction
                            : labels[item.index],
                        child: Tooltip(
                          message: item == AppBottomNavItem.expenses
                              ? t.addExpensesAction
                              : labels[item.index],
                          child: InkWell(
                            key: ValueKey('nav-${item.name}'),
                            onTap: () => onSelected(item),
                            // The hit area includes the space above the bar for
                            // the raised action; do not paint a rectangular ink
                            // overlay into that transparent space.
                            overlayColor: const WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            splashFactory: NoSplash.splashFactory,
                            child: ExcludeSemantics(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 72,
                                  minWidth: 48,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    item == AppBottomNavItem.expenses ? 0 : 4,
                                    item == AppBottomNavItem.expenses ? 0 : 31,
                                    item == AppBottomNavItem.expenses ? 0 : 4,
                                    item == AppBottomNavItem.expenses ? 0 : 15,
                                  ),
                                  child: item == AppBottomNavItem.expenses
                                      ? Align(
                                          alignment: Alignment.topCenter,
                                          child: _buildExpenseIcon(context),
                                        )
                                      : Icon(
                                          iconFor(item),
                                          size: 26,
                                          color: selectedItem == item
                                              ? colors.primary
                                              : colors.onSurfaceVariant,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseIcon(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pageColor = AppDesign.pageBaseColor(context);
    return Container(
      key: const ValueKey('nav-expenses-raised-icon'),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pageColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: .16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 34,
          height: 32,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 28,
                  color: colors.onPrimary,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: pageColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.add, size: 18, color: colors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
