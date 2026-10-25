part of 'analytics_page.dart';

class _AnalyticsTabs extends StatelessWidget {
  const _AnalyticsTabs({
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.segmented = false,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  final bool segmented;
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
                    border: segmented
                        ? Border.all(
                            color: i == selected
                                ? colors.primary
                                : colors.outlineVariant,
                          )
                        : Border(
                            bottom: BorderSide(
                              width: i == selected ? 2 : 1,
                              color: i == selected
                                  ? colors.primary
                                  : colors.outlineVariant,
                            ),
                          ),
                    borderRadius: segmented
                        ? BorderRadius.horizontal(
                            left: i == 0
                                ? const Radius.circular(8)
                                : Radius.zero,
                            right: i == labels.length - 1
                                ? const Radius.circular(8)
                                : Radius.zero,
                          )
                        : null,
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

class _AnalyticsDonut extends CustomPainter {
  _AnalyticsDonut({required this.values, required this.colors});
  final List<int> values;
  final List<Color> colors;
  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (a, b) => a + b);
    if (total <= 0) return;
    var start = -math.pi / 2;
    final rect = (Offset.zero & size).deflate(14);
    for (var i = 0; i < values.length; i++) {
      final sweep = 2 * math.pi * values[i] / total;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 28,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _AnalyticsDonut oldDelegate) => true;
}
