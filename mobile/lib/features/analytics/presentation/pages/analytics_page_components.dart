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

class _AnalyticsFadeSlide extends StatelessWidget {
  const _AnalyticsFadeSlide({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final durationMs = 260 + (index * 80);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 8),
            child: child,
          ),
        );
      },
    );
  }
}

class _AnalyticsPressScale extends StatefulWidget {
  const _AnalyticsPressScale({
    required this.child,
    required this.onTap,
    this.enabled = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  final Widget child;
  final VoidCallback onTap;
  final bool enabled;
  final BorderRadius borderRadius;

  @override
  State<_AnalyticsPressScale> createState() => _AnalyticsPressScaleState();
}

class _AnalyticsPressScaleState extends State<_AnalyticsPressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted || !widget.enabled) {
      return;
    }
    if (_pressed == value) {
      return;
    }
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        scale: _pressed ? 0.97 : 1.0,
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius,
          child: Ink(
            decoration: BoxDecoration(borderRadius: widget.borderRadius),
            child: widget.child,
          ),
        ),
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      color: isDark
                          ? colors.surfaceContainerHighest.withValues(
                              alpha: 0.68,
                            )
                          : colors.surfaceContainerHighest.withValues(
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
                    '${segment.memberName}: ${AppFormatters.euro(context, segment.amount)}',
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
        ? Color.lerp(color, AppDesign.darkForeground, 0.36) ?? color
        : color;
    final trackColor = isDark
        ? AppDesign.darkForeground.withValues(alpha: 0.14)
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
                    : math.max(12.0, maxWidth * ratio);
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
        ? Color.lerp(color, AppDesign.darkForeground, 0.34) ?? color
        : color;
    final trackColor = isDark
        ? AppDesign.darkForeground.withValues(alpha: 0.14)
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
                    : math.max(12.0, maxWidth * ratio);
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

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.rows,
    required this.total,
    required this.backgroundColor,
  });

  final List<_CategoryTotalRow> rows;
  final double total;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutChartPainter(
        rows: rows,
        total: total,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.rows,
    required this.total,
    required this.backgroundColor,
  });

  final List<_CategoryTotalRow> rows;
  final double total;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final stroke = math.max(10.0, radius * 0.42);
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    final trackPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (rows.isEmpty || total <= 0) {
      return;
    }

    final segmentGap = 0.02;
    var start = -math.pi / 2;
    for (final row in rows) {
      final sweepRaw = ((row.total / total) * (math.pi * 2)).clamp(
        0.0,
        math.pi * 2,
      );
      var sweep = sweepRaw - segmentGap;
      if (sweep < 0) {
        sweep = sweepRaw;
      }
      final paint = Paint()
        ..color = row.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweepRaw;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.total != total ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _MemberAvatarStack extends StatelessWidget {
  const _MemberAvatarStack({required this.rows});

  final List<_MemberTotalRow> rows;

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first
          .substring(0, math.min(2, parts.first.length))
          .toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visibleRows = rows.take(4).toList(growable: false);
    final extraCount = rows.length - visibleRows.length;
    final itemCount = visibleRows.length + (extraCount > 0 ? 1 : 0);
    return SizedBox(
      width: (itemCount * 20) + 16,
      height: 30,
      child: Stack(
        children: [
          for (var index = 0; index < visibleRows.length; index++)
            Positioned(
              left: index * 20,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: visibleRows[index].color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? colors.surface.withValues(alpha: 0.82)
                        : AppDesign.lightSurface,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(visibleRows[index].name),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppDesign.darkForeground,
                  ),
                ),
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: visibleRows.length * 20,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isDark
                      ? colors.surfaceContainerHighest.withValues(alpha: 0.84)
                      : AppDesign.lightSurfaceMutedAlt,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? colors.surface.withValues(alpha: 0.78)
                        : AppDesign.lightSurface,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extraCount',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemberAmountChip extends StatelessWidget {
  const _MemberAmountChip({
    required this.initials,
    required this.amount,
    required this.color,
  });

  final String initials;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: isDark ? 0.92 : 1),
            border: Border.all(
              color: isDark
                  ? colors.outlineVariant.withValues(alpha: 0.52)
                  : AppDesign.lightSurface,
              width: 2,
            ),
          ),
          child: Text(
            initials,
            style: const TextStyle(
              color: AppDesign.darkForeground,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _AreaSparkline extends StatelessWidget {
  const _AreaSparkline({
    required this.points,
    required this.color,
    required this.axisColor,
    required this.emptyColor,
  });

  final List<_DayPoint> points;
  final Color color;
  final Color axisColor;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AreaSparklinePainter(
        points: points,
        color: color,
        axisColor: axisColor,
        emptyColor: emptyColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _AreaSparklinePainter extends CustomPainter {
  _AreaSparklinePainter({
    required this.points,
    required this.color,
    required this.axisColor,
    required this.emptyColor,
  });

  final List<_DayPoint> points;
  final Color color;
  final Color axisColor;
  final Color emptyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = axisColor.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      axisPaint,
    );

    if (points.isEmpty) {
      final emptyPaint = Paint()..color = emptyColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, size.height * 0.45, size.width, 10),
          const Radius.circular(6),
        ),
        emptyPaint,
      );
      return;
    }

    final maxValue = points.fold<double>(
      0,
      (max, point) => math.max(max, point.value),
    );
    if (maxValue <= 0) {
      final emptyPaint = Paint()..color = emptyColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, size.height * 0.45, size.width, 10),
          const Radius.circular(6),
        ),
        emptyPaint,
      );
      return;
    }

    final usableHeight = size.height - 18;
    final stepX = points.length <= 1 ? 0.0 : size.width / (points.length - 1);
    final linePath = Path();
    final areaPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = stepX * i;
      final ratio = (points[i].value / maxValue).clamp(0.0, 1.0);
      final y = usableHeight - (usableHeight * ratio);
      if (i == 0) {
        linePath.moveTo(x, y);
        areaPath.moveTo(x, size.height - 1);
        areaPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        areaPath.lineTo(x, y);
      }
    }

    areaPath.lineTo(size.width, size.height - 1);
    areaPath.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.34), color.withValues(alpha: 0.06)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _AreaSparklinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.axisColor != axisColor ||
        oldDelegate.emptyColor != emptyColor;
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
