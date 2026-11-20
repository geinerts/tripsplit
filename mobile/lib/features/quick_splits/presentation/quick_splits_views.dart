import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_design.dart';
import '../../../core/expenses/expense_category_catalog.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_formatters.dart';
import '../../../core/ui/app_sheet.dart';
import '../domain/quick_split.dart';
import 'quick_splits_controller.dart';

/// The name a quick split goes by: its note, else its category.
String quickSplitTitle(BuildContext context, QuickSplit split) =>
    split.note.trim().isNotEmpty
    ? split.note.trim()
    : ExpenseCategoryCatalog.labelFor(
        split.category,
        Localizations.localeOf(context),
      );

String _money(BuildContext context, double amount, String currency) =>
    AppFormatters.currency(context, amount, currencyCode: currency);

String _date(BuildContext context, String raw) {
  final date = DateTime.tryParse(raw);
  if (date == null) return raw;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final t = context.l10n;
  if (day == today) return t.notificationsToday;
  if (day == today.subtract(const Duration(days: 1))) {
    return t.shellYesterday;
  }
  return AppFormatters.shortDayMonth(context, day);
}

/// The Quick splits list on home: newest first, a record of who had what.
class QuickSplitsList extends StatelessWidget {
  const QuickSplitsList({
    super.key,
    required this.controller,
    required this.onOpen,
  });

  final QuickSplitsController controller;
  final ValueChanged<QuickSplit> onOpen;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final t = context.l10n;
      final items = controller.items;
      if (!controller.hasLoaded) {
        if (controller.hasFailed) {
          return _Message(
            key: const ValueKey('quick-splits-error'),
            text: controller.isOffline
                ? t.quickSplitsOffline
                : t.quickSplitsLoadFailed,
            actionLabel: t.retryAction,
            onAction: controller.load,
          );
        }
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (items.isEmpty) {
        return _Message(
          key: const ValueKey('quick-splits-empty'),
          text: t.quickSplitsEmpty,
        );
      }
      return Column(
        key: const ValueKey('quick-splits-list'),
        children: [
          for (final split in items) ...[
            _QuickSplitRow(split: split, onTap: () => onOpen(split)),
            if (split != items.last) const Divider(height: 1),
          ],
          if (controller.hasMore)
            TextButton(
              onPressed: controller.isLoading
                  ? null
                  : () => controller.load(more: true),
              child: Text(t.quickSplitsShowMore),
            ),
        ],
      );
    },
  );
}

class _Message extends StatelessWidget {
  const _Message({
    super.key,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
    child: Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppDesign.mutedColor(context),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    ),
  );
}

class _QuickSplitRow extends StatelessWidget {
  const _QuickSplitRow({required this.split, required this.onTap});

  final QuickSplit split;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final muted = AppDesign.mutedColor(context);
    final title = quickSplitTitle(context, split);
    final subtitle =
        '${_date(context, split.date)} · ${t.homePeople(split.peopleCount)}';
    final mine = _money(context, split.myAmount, split.currencyCode);
    final total = _money(context, split.amount, split.currencyCode);
    return Semantics(
      button: true,
      label: '$title, $subtitle, ${t.quickSplitYourPart(mine)}',
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('quick-split-${split.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  ExpenseCategoryCatalog.iconFor(split.category),
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    mine,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.quickSplitOfTotal(total),
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the person chose in the quick split sheet.
enum QuickSplitSheetAction { addToTrip, edit, delete }

/// Each person's amount, Share result, and for the creator: Add to a trip,
/// edit and delete.
Future<QuickSplitSheetAction?> showQuickSplitSheet(
  BuildContext context, {
  required QuickSplit split,
  Widget? receiptAction,
  bool canAddToTrip = false,
}) => showAppBottomSheet<QuickSplitSheetAction>(
  context: context,
  builder: (sheetContext) => QuickSplitSheet(
    split: split,
    receiptAction: receiptAction,
    canAddToTrip: canAddToTrip,
  ),
);

class QuickSplitSheet extends StatelessWidget {
  const QuickSplitSheet({
    super.key,
    required this.split,
    this.receiptAction,
    this.canAddToTrip = false,
  });

  /// Shown only when an active trip has every person of this quick split.
  final bool canAddToTrip;

  final QuickSplit split;

  /// Opens the receipt photo; shown when the quick split has one.
  final Widget? receiptAction;

  static String _splitLabel(BuildContext context, String mode) {
    final t = context.l10n;
    return switch (mode.trim().toLowerCase()) {
      'exact' => t.exactAmountsLabel,
      'percent' => t.percentagesLabel,
      'shares' => t.sharesLabel,
      'adjustment' => t.expenseAdjustmentsLabel,
      'itemized' => t.expenseItemsLabel,
      _ => t.equalSplitLabel,
    };
  }

  static IconData _splitIcon(String mode) =>
      switch (mode.trim().toLowerCase()) {
        'exact' => Icons.payments_outlined,
        'percent' => Icons.percent_rounded,
        'shares' => Icons.pie_chart_outline_rounded,
        'adjustment' => Icons.exposure_rounded,
        'itemized' => Icons.receipt_long_rounded,
        _ => Icons.drag_handle_rounded,
      };

  Widget _chip(
    BuildContext context, {
    required Key key,
    required Widget leading,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Container(
      key: key,
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(child: leading),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Beer ×2 · €4.50 each · You, Anna" with the line total on the right,
  /// then tax or tip; the same layout as a trip expense.
  List<Widget> _items(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    String money(int cents) => _money(context, cents / 100, split.currencyCode);
    String nameFor(int id) {
      for (final person in split.people) {
        if (person.id == id) return person.isMe ? t.youLabel : person.name;
      }
      return '?';
    }

    String people(QuickSplitItemLine line) {
      final counts = <int, int>{};
      for (final id in line.personIds) {
        counts[id] = (counts[id] ?? 0) + 1;
      }
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

    return [
      Semantics(
        header: true,
        child: Text(t.expenseItemsLabel, style: theme.textTheme.titleSmall),
      ),
      const SizedBox(height: 4),
      for (final line in QuickSplitItemLine.group(split.items))
        row(
          title: line.name,
          qty: line.qty,
          totalCents: line.totalCents,
          detail: [
            if (line.qty > 1) t.expenseItemEach(money(line.unitCents)),
            people(line),
          ].join(' · '),
        ),
      if (split.extraAmount > 0)
        row(
          title: t.expenseItemExtra,
          totalCents: (split.extraAmount * 100).round(),
        ),
    ];
  }

  String _shareText(BuildContext context) {
    final t = context.l10n;
    final lines = <String>[
      '${quickSplitTitle(context, split)} · ${_date(context, split.date)}',
      t.quickSplitShareTotal(
        _money(context, split.amount, split.currencyCode),
        split.payer?.name ?? split.paidByName,
      ),
      for (final person in split.people)
        '${person.name}: ${_money(context, person.amount, split.currencyCode)}',
      '— Splyto',
    ];
    return lines.join('\n');
  }

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: _shareText(context),
          subject: quickSplitTitle(context, split),
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(context.l10n.quickSplitShareFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final muted = AppDesign.mutedColor(context);
    final payer = split.payer;
    final payerName = payer == null
        ? split.paidByName
        : payer.isMe
        ? t.youLabel
        : payer.name;
    final amountStyle = theme.textTheme.titleSmall?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        key: const ValueKey('quick-split-sheet'),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    quickSplitTitle(context, split),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                if (split.canEdit) ...[
                  IconButton(
                    key: const ValueKey('quick-split-edit'),
                    tooltip: t.editAction,
                    onPressed: () =>
                        Navigator.of(context).pop(QuickSplitSheetAction.edit),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    key: const ValueKey('quick-split-delete'),
                    tooltip: t.deleteAction,
                    onPressed: () =>
                        Navigator.of(context).pop(QuickSplitSheetAction.delete),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_date(context, split.date)} · ${t.quickSplitPaidBy(payerName)}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                ),
                Text(
                  _money(context, split.amount, split.currencyCode),
                  style: amountStyle,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(
                  context,
                  key: const ValueKey('quick-split-mode'),
                  leading: Icon(
                    _splitIcon(split.splitMode),
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  label: _splitLabel(context, split.splitMode),
                ),
                ?receiptAction,
              ],
            ),
            if (split.items.isNotEmpty) ...[
              const SizedBox(height: 16),
              ..._items(context),
            ],
            const SizedBox(height: 16),
            for (final person in split.people) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    _PersonAvatar(
                      name: person.name,
                      url: person.avatarThumbUrl,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        person.isMe ? t.youLabel : person.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Text(
                      _money(context, person.amount, split.currencyCode),
                      style: amountStyle,
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 1),
            const SizedBox(height: 8),
            TextButton.icon(
              key: const ValueKey('quick-split-share'),
              onPressed: () => _share(context),
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(t.quickSplitShareResult),
            ),
            if (split.canEdit && canAddToTrip) ...[
              const Divider(height: 1),
              ListTile(
                key: const ValueKey('quick-split-add-to-trip'),
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.luggage_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(t.quickSplitAddToTrip),
                subtitle: Text(t.quickSplitAddToTripHint),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () =>
                    Navigator.of(context).pop(QuickSplitSheetAction.addToTrip),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({required this.name, this.url});

  final String name;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().characters.first.toUpperCase();
    final fallback = CircleAvatar(
      radius: 18,
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
      child: Text(initial),
    );
    final link = (url ?? '').trim();
    if (link.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        link,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}
