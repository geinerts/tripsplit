part of 'analytics_page.dart';

extension _AnalyticsPageCategories on _AnalyticsPageState {
  Widget _categories(AnalyticsReport report) {
    final rows = report.categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    String percent(int value) =>
        _analyticsPercent(context, value, report.totalCents);
    // Leave room for the open arrow on every row once one category has types,
    // so the amounts stay in one column.
    final typesByCategory = {
      for (final row in rows) row.key: report.types(row.key),
    };
    final arrowSlot = typesByCategory.values.any(_hasTypes);
    Widget withTypes(MapEntry<String, int> row, Widget child) =>
        _categoryWithTypes(row, typesByCategory[row.key]!, arrowSlot, child);
    Widget legend() => Column(
      children: [
        for (final row in rows)
          Padding(
            key: ValueKey('analytics-category-${row.key}'),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: withTypes(
              row,
              _byTrip
                  // Announce each category with its amount and visible percentage.
                  ? Semantics(
                      container: true,
                      label:
                          '${_categoryName(row.key)}, ${_money(row.value)}, '
                          '${percent(row.value)}',
                      excludeSemantics: true,
                      child: _tripCategoryLegendRow(row, percent(row.value)),
                    )
                  : Column(
                      children: [
                        _categoryLegendRow(row),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${(row.value * 100 / report.totalCents).toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: LinearProgressIndicator(
                            value: row.value / report.totalCents,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            color: _categoryColor(row.key),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
      ],
    );
    if (!_byTrip) {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(16) > 20) {
            return legend();
          }
          return Column(
            children: [
              for (final row in rows)
                Padding(
                  key: ValueKey('analytics-category-${row.key}'),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: withTypes(
                    row,
                    Row(
                      children: [
                        SizedBox(
                          width: 112,
                          child: Text(_categoryName(row.key)),
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: row.value / report.totalCents,
                            minHeight: 14,
                            borderRadius: BorderRadius.circular(4),
                            color: _categoryColor(row.key),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 86,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _money(row.value),
                                textAlign: TextAlign.end,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${(row.value * 100 / report.totalCents).toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: AspectRatio(
              aspectRatio: 1,
              child: MergeSemantics(
                child: CustomPaint(
                  key: const ValueKey('analytics-category-donut'),
                  painter: _AnalyticsDonut(
                    values: rows.map((e) => e.value).toList(),
                    colors: rows.map((e) => _categoryColor(e.key)).toList(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(54),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          key: const ValueKey('analytics-chart-summary'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _personal
                                  ? context.l10n.yourShare
                                  : context.l10n.workspaceTripTotal,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppDesign.mutedColor(context),
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _money(report.totalCents),
                              key: const ValueKey('analytics-total'),
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.analyticsExpenseCount(
                                report.expenseCount,
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppDesign.mutedColor(context),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_personal) ...[_summaryMetrics(report), const SizedBox(height: 20)],
        legend(),
      ],
    );
  }

  static bool _hasTypes(List<AnalyticsTypeAmount> types) =>
      types.any((row) => row.type != null);

  /// A category row that opens to show what was spent per expense type.
  /// Categories without typed expenses stay plain.
  Widget _categoryWithTypes(
    MapEntry<String, int> row,
    List<AnalyticsTypeAmount> types,
    bool arrowSlot,
    Widget child,
  ) {
    if (!arrowSlot) return child;
    if (!_hasTypes(types)) {
      return Row(
        children: [
          Expanded(child: child),
          const SizedBox(width: 28),
        ],
      );
    }
    final open = _openCategories.contains(row.key);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: open,
          child: InkWell(
            key: ValueKey('analytics-category-toggle-${row.key}'),
            borderRadius: BorderRadius.circular(8),
            onTap: () => _updateState(() {
              if (!_openCategories.remove(row.key)) {
                _openCategories.add(row.key);
              }
            }),
            child: Row(
              children: [
                Expanded(child: child),
                SizedBox(
                  width: 28,
                  child: Icon(
                    open ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (open)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 20, top: 4),
            child: Column(
              children: [
                for (final type in types) _typeRow(row.key, type, row.value),
              ],
            ),
          ),
      ],
    );
  }

  Widget _typeRow(String category, AnalyticsTypeAmount type, int total) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final name = type.type == null
        ? context.l10n.analyticsNoType
        : expenseTypeLabel(context, type.type!);
    return Padding(
      key: ValueKey('analytics-type-$category-${type.type ?? '-'}'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: type.type == null ? muted : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(_money(type.cents), style: theme.textTheme.bodyMedium),
          SizedBox(
            width: 64,
            child: Text(
              _analyticsPercent(context, type.cents, total),
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _tripCategoryLegendRow(MapEntry<String, int> row, String percent) {
    final theme = Theme.of(context);
    final name = _categoryName(row.key);
    final amount = _money(row.value);
    final nameStyle = theme.textTheme.bodyMedium!;
    final amountStyle = theme.textTheme.titleMedium!;
    double textWidth(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    final figures = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(amount, style: amountStyle, textAlign: TextAlign.end),
        const SizedBox(height: 2),
        Text(
          percent,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, box) {
        final stacked =
            textWidth(name, nameStyle) + textWidth(amount, amountStyle) + 40 >
            box.maxWidth;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Icon(
                Icons.circle,
                size: 12,
                color: _categoryColor(row.key),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: nameStyle),
                        const SizedBox(height: 6),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: figures,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(name, style: nameStyle)),
                        const SizedBox(width: 16),
                        figures,
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _categoryLegendRow(MapEntry<String, int> row) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Icon(Icons.circle, size: 12, color: _categoryColor(row.key)),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(_categoryName(row.key))),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          _money(row.value),
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    ],
  );
}
