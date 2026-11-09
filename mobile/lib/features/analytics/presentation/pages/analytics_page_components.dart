part of 'analytics_page.dart';

class _AnalyticsTabs extends StatelessWidget {
  const _AnalyticsTabs({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                selected: i == selected,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: i == selected ? 2 : 1,
                        color: i == selected
                            ? colors.primary
                            : colors.outlineVariant,
                      ),
                    ),
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      foregroundColor: i == selected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                      shape: const RoundedRectangleBorder(),
                    ),
                    onPressed: () => onSelected(i),
                    child: Text(labels[i], textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Formats a share of the total as a short, locale-aware percentage.
///
/// One decimal keeps small categories visible and the legend consistent.
String _analyticsPercent(BuildContext context, int value, int total) {
  final fraction = total <= 0 ? 0.0 : value / total;
  return (NumberFormat.percentPattern(
          Localizations.localeOf(context).toString(),
        )
        ..minimumFractionDigits = 1
        ..maximumFractionDigits = 1)
      .format(fraction);
}

class _AnalyticsScopeSwitch extends StatelessWidget {
  const _AnalyticsScopeSwitch({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedAlign(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 150),
                    alignment: selected == 0
                        ? AlignmentDirectional.centerStart
                        : AlignmentDirectional.centerEnd,
                    child: FractionallySizedBox(
                      widthFactor: .5,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Expanded(
                        child: Semantics(
                          selected: selected == i,
                          child: TextButton(
                            key: ValueKey('analytics-scope-$i'),
                            onPressed: () => onSelected(i),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              foregroundColor: selected == i
                                  ? colors.onPrimary
                                  : colors.onSurfaceVariant,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  i == 0
                                      ? Icons.pie_chart_outline
                                      : Icons.person_outline,
                                  size: 21,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    labels[i],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Category proportions; the complete percentages live in the legend below.
class _AnalyticsDonut extends CustomPainter {
  _AnalyticsDonut({required this.values, required this.colors});
  final List<int> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (a, b) => a + b);
    if (total <= 0) return;
    final radius = math.min(size.width, size.height) / 2;
    final stroke = radius * .3;
    final ring = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius - stroke / 2,
    );
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = 2 * math.pi * values[i] / total;
      canvas.drawArc(
        ring,
        start,
        sweep,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _AnalyticsDonut oldDelegate) => true;
}
