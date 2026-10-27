import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'app_formatters.dart';

/// Displays trip-currency totals. A budget is informational, never a spend gate.
class TripBudgetCard extends StatelessWidget {
  const TripBudgetCard({
    super.key,
    required this.budgetCents,
    required this.spentCents,
    required this.currencyCode,
    required this.isSolo,
  });
  final int budgetCents, spentCents;
  final String currencyCode;
  final bool isSolo;
  @override
  Widget build(BuildContext context) {
    if (budgetCents <= 0) return const SizedBox.shrink();
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final remaining = budgetCents - spentCents;
    final over = remaining < 0;
    String money(int cents) => AppFormatters.displayCurrencyFromCents(
      context,
      cents,
      currencyCode: currencyCode,
    );
    return Container(
      key: const ValueKey('trip-budget-card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isSolo ? t.tripBudgetTitle : t.tripBudgetGroupTitle,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(
                '${t.tripBudgetSpent}: ${money(spentCents)}',
                key: const ValueKey('trip-budget-spent'),
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '${t.tripBudgetLimit}: ${money(budgetCents)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: (spentCents / budgetCents).clamp(0, 1),
            minHeight: 5,
            color: over ? colors.error : colors.primary,
            borderRadius: BorderRadius.circular(5),
            semanticsLabel:
                '${t.tripBudgetSpent}: ${money(spentCents)} / ${money(budgetCents)}',
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                over ? t.tripBudgetOver : t.tripBudgetRemaining,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: over ? colors.error : colors.onSurfaceVariant,
                ),
              ),
              Text(
                money(remaining.abs()),
                key: const ValueKey('trip-budget-remaining'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: over ? colors.error : colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
