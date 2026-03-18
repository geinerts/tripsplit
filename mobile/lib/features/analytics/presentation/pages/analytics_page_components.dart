part of 'analytics_page.dart';

class _MemberMeta {
  const _MemberMeta({required this.id, required this.name});

  final int id;
  final String name;
}

class _DayPoint {
  const _DayPoint({required this.label, required this.value});

  final String label;
  final double value;
}

class _MemberTotalRow {
  const _MemberTotalRow({
    required this.id,
    required this.name,
    required this.total,
    required this.color,
  });

  final int id;
  final String name;
  final double total;
  final Color color;
}

class _CategoryTotalRow {
  const _CategoryTotalRow({
    required this.key,
    required this.label,
    required this.icon,
    required this.total,
    required this.color,
  });

  final String key;
  final String label;
  final IconData icon;
  final double total;
  final Color color;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _MemberDaySegment {
  const _MemberDaySegment({
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.color,
  });

  final int memberId;
  final String memberName;
  final double amount;
  final Color color;
}

class _DayStackedBar extends StatelessWidget {
  const _DayStackedBar({
    required this.dayLabel,
    required this.dayTotal,
    required this.maxDayTotal,
    required this.segments,
    required this.onSegmentTap,
  });

  final String dayLabel;
  final double dayTotal;
  final double maxDayTotal;
  final List<_MemberDaySegment> segments;
  final ValueChanged<_MemberDaySegment> onSegmentTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final barHeight = 112.0;
    final fillRatio = (maxDayTotal <= 0 ? 0.0 : (dayTotal / maxDayTotal))
        .clamp(0.0, 1.0)
        .toDouble();
    final fillHeight = barHeight * fillRatio;
    const width = 58.0;

    return SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox(
            height: 118,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: ColoredBox(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.42,
                      ),
                    ),
                  ),
                  if (fillHeight > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: fillHeight,
                      child: _StackedSegmentsArea(
                        segments: segments,
                        dayTotal: dayTotal,
                        onSegmentTap: onSegmentTap,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dayLabel,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StackedSegmentsArea extends StatelessWidget {
  const _StackedSegmentsArea({
    required this.segments,
    required this.dayTotal,
    required this.onSegmentTap,
  });

  final List<_MemberDaySegment> segments;
  final double dayTotal;
  final ValueChanged<_MemberDaySegment> onSegmentTap;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty || dayTotal <= 0) {
      return const SizedBox.shrink();
    }
    final sortedSegments = List<_MemberDaySegment>.from(segments)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return LayoutBuilder(
      builder: (context, constraints) {
        var offsetBottom = 0.0;
        final children = <Widget>[];
        for (final segment in sortedSegments) {
          final ratio = (segment.amount / dayTotal).clamp(0.0, 1.0);
          final segmentHeight = constraints.maxHeight * ratio;
          if (segmentHeight <= 0) {
            continue;
          }
          children.add(
            Positioned(
              left: 0,
              right: 0,
              bottom: offsetBottom,
              height: segmentHeight,
              child: Tooltip(
                message:
                    '${segment.memberName}: ${segment.amount.toStringAsFixed(2)} €',
                child: InkWell(
                  onTap: () => onSegmentTap(segment),
                  child: ColoredBox(
                    color: segment.color.withValues(alpha: 0.95),
                  ),
                ),
              ),
            ),
          );
          offsetBottom += segmentHeight;
        }
        return Stack(children: children);
      },
    );
  }
}

class _SingleBar extends StatelessWidget {
  const _SingleBar({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = (maxValue <= 0 ? 0.0 : (value / maxValue))
        .clamp(0.0, 1.0)
        .toDouble();
    return Tooltip(
      message: valueLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 130,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: ColoredBox(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.46),
                    ),
                  ),
                  FractionallySizedBox(
                    heightFactor: ratio,
                    widthFactor: 1,
                    alignment: Alignment.bottomCenter,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalMemberBar extends StatelessWidget {
  const _HorizontalMemberBar({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.highlight,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double maxValue;
  final Color color;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ratio = (maxValue <= 0 ? 0.0 : (value / maxValue))
        .clamp(0.0, 1.0)
        .toDouble();
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark
        ? Color.lerp(color, Colors.white, 0.42) ?? color
        : color;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : colors.surfaceContainerHighest.withValues(alpha: 0.46);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? colors.primary.withValues(alpha: 0.08) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                valueLabel,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final width = ratio <= 0
                    ? 0.0
                    : math.max(4.0, maxWidth * ratio);
                return SizedBox(
                  height: 10,
                  child: Stack(
                    children: [
                      Positioned.fill(child: ColoredBox(color: trackColor)),
                      if (width > 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: width,
                            decoration: BoxDecoration(
                              color: barColor.withValues(
                                alpha: isDark ? 1 : 0.92,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalCategoryBar extends StatelessWidget {
  const _HorizontalCategoryBar({
    required this.icon,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String valueLabel;
  final double value;
  final double maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = (maxValue <= 0 ? 0.0 : (value / maxValue))
        .clamp(0.0, 1.0)
        .toDouble();
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark
        ? Color.lerp(color, Colors.white, 0.44) ?? color
        : color;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : colors.surfaceContainerHighest.withValues(alpha: 0.46);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: barColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                valueLabel,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final width = ratio <= 0
                    ? 0.0
                    : math.max(4.0, maxWidth * ratio);
                return SizedBox(
                  height: 10,
                  child: Stack(
                    children: [
                      Positioned.fill(child: ColoredBox(color: trackColor)),
                      if (width > 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: width,
                            decoration: BoxDecoration(
                              color: barColor.withValues(
                                alpha: isDark ? 1 : 0.92,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  const _InlineErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retryAction),
            ),
          ],
        ),
      ),
    );
  }
}
