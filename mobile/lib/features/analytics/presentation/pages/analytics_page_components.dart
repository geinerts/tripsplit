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

/// Formats a share of the total as a short, locale-aware percentage.
///
/// Shares under 10% keep one decimal so small slices stay distinguishable.
String _analyticsPercent(BuildContext context, int value, int total) {
  final fraction = total <= 0 ? 0.0 : value / total;
  return (NumberFormat.percentPattern(
          Localizations.localeOf(context).toString(),
        )
        ..minimumFractionDigits = 0
        ..maximumFractionDigits = fraction < 0.0995 ? 1 : 0)
      .format(fraction);
}

/// Where one percentage label of [_AnalyticsDonutLayout] is drawn.
class _DonutLabel {
  _DonutLabel({
    required this.index,
    required this.text,
    required this.size,
    required this.angle,
    required this.inside,
  });
  final int index;
  final String text;
  final Size size;

  /// Middle angle of the slice, in radians, clockwise from 3 o'clock.
  final double angle;
  final bool inside;
  bool get right => math.cos(angle) >= 0;

  /// Vertical centre of an outside label after collision handling.
  double y = 0;
}

/// Geometry of the category donut: the ring, and percentages placed inside
/// a slice when they fit or beside the ring with a leader line otherwise.
class _AnalyticsDonutLayout {
  _AnalyticsDonutLayout._({
    required this.size,
    required this.center,
    required this.radius,
    required this.labels,
  });

  static const double _maxRadius = 72;
  static const double _minRadius = 54;

  /// Ring thickness; it scales with the ring so labels keep fitting inside.
  static double strokeFor(double radius) => (radius * 0.47).roundToDouble();

  /// Slices smaller than this share get no label; the legend and screen
  /// reader text still carry their percentage.
  static const double minLabelFraction = 0.02;

  /// Distance from the ring to where the leader line meets the label.
  static const double _lineReach = 14;
  static const double _textGap = 4;
  static const double _labelSpacing = 2;

  final Size size;
  final Offset center;
  final double radius;
  final List<_DonutLabel> labels;
  double get stroke => strokeFor(radius);

  /// Whether a horizontal label centred on the ring fits inside its slice:
  /// every corner of the label must lie within the ring and the slice.
  static bool _fitsInside(Size label, double angle, double sweep, double r) {
    final stroke = strokeFor(r);
    final mid = Offset(math.cos(angle), math.sin(angle)) * (r - stroke / 2);
    final start = angle - sweep / 2;
    for (final dx in [-1.0, 1.0]) {
      for (final dy in [-1.0, 1.0]) {
        final corner =
            mid + Offset(dx * (label.width / 2 + 1), dy * label.height / 2);
        final distance = corner.distance;
        if (distance < r - stroke + 1 || distance > r - 1) return false;
        if (sweep >= 2 * math.pi - 0.001) continue;
        final offset = (corner.direction - start) % (2 * math.pi);
        if (offset > sweep) return false;
      }
    }
    return true;
  }

  static Size _measure(String text, TextStyle style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final size = painter.size;
    painter.dispose();
    return size;
  }

  factory _AnalyticsDonutLayout.compute({
    required List<int> values,
    required List<String> percents,
    required TextStyle style,
    required TextScaler scaler,
    required double maxWidth,
  }) {
    final total = values.fold<int>(0, (a, b) => a + b);
    final measured = <int, Size>{
      for (var i = 0; i < values.length; i++)
        if (total > 0 && values[i] / total >= minLabelFraction)
          i: _measure(percents[i], style, scaler),
    };
    final angles = <double>[];
    var start = -math.pi / 2;
    for (final value in values) {
      final sweep = total <= 0 ? 0.0 : 2 * math.pi * value / total;
      angles.add(start + sweep / 2);
      start += sweep;
    }
    double sweepOf(int i) => total <= 0 ? 0 : 2 * math.pi * values[i] / total;

    List<_DonutLabel> place(double radius, Set<int> dropped) => [
      for (final entry in measured.entries)
        if (!dropped.contains(entry.key))
          _DonutLabel(
            index: entry.key,
            text: percents[entry.key],
            size: entry.value,
            angle: angles[entry.key],
            inside: _fitsInside(
              entry.value,
              angles[entry.key],
              sweepOf(entry.key),
              radius,
            ),
          ),
    ];
    double sideWidth(List<_DonutLabel> labels, bool right) => labels
        .where((l) => !l.inside && l.right == right)
        .fold<double>(
          0,
          (w, l) => math.max(w, l.size.width + _lineReach + _textGap),
        );
    double widthOf(double radius, List<_DonutLabel> labels) =>
        sideWidth(labels, false) + 2 * radius + sideWidth(labels, true);

    // Shrink the ring first, then drop the smallest outside labels, until the
    // chart fits the available width.
    var radius = _maxRadius;
    final dropped = <int>{};
    var labels = place(radius, dropped);
    while (widthOf(radius, labels) > maxWidth) {
      if (radius > _minRadius) {
        radius = math.max(_minRadius, radius - 6);
      } else {
        final outside = labels.where((l) => !l.inside).toList();
        if (outside.isEmpty) break;
        outside.sort((a, b) => values[a.index].compareTo(values[b.index]));
        dropped.add(outside.first.index);
      }
      labels = place(radius, dropped);
    }

    final outside = labels.where((l) => !l.inside).toList();
    final labelHeight = outside.fold<double>(
      0,
      (h, l) => math.max(h, l.size.height),
    );
    final verticalPad = outside.isEmpty ? 0.0 : labelHeight / 2 + 2;
    final height = 2 * radius + 2 * verticalPad;
    final centerY = verticalPad + radius;

    // Spread labels on each side so they never overlap; when a side has more
    // labels than fit vertically, the smallest ones are left out.
    for (final right in [false, true]) {
      final side = outside.where((l) => l.right == right).toList()
        ..sort((a, b) => math.sin(a.angle).compareTo(math.sin(b.angle)));
      while (side.isNotEmpty) {
        final step = labelHeight + _labelSpacing;
        final minY = labelHeight / 2;
        final maxY = height - labelHeight / 2;
        for (final label in side) {
          label.y = (centerY + (radius + 8) * math.sin(label.angle)).clamp(
            minY,
            maxY,
          );
        }
        for (var i = 1; i < side.length; i++) {
          side[i].y = math.max(side[i].y, side[i - 1].y + step);
        }
        if (side.last.y > maxY) {
          side.last.y = maxY;
          for (var i = side.length - 2; i >= 0; i--) {
            side[i].y = math.min(side[i].y, side[i + 1].y - step);
          }
        }
        if (side.first.y >= minY - 0.5) break;
        final smallest = side.reduce(
          (a, b) => values[a.index] <= values[b.index] ? a : b,
        );
        side.remove(smallest);
        labels.remove(smallest);
      }
    }

    final center = Offset(sideWidth(labels, false) + radius, centerY);
    return _AnalyticsDonutLayout._(
      size: Size(widthOf(radius, labels), height),
      center: center,
      radius: radius,
      labels: labels,
    );
  }
}

class _AnalyticsDonut extends CustomPainter {
  _AnalyticsDonut({
    required this.layout,
    required this.values,
    required this.colors,
    required this.labelStyle,
    required this.textScaler,
    required this.textColor,
  });
  final _AnalyticsDonutLayout layout;
  final List<int> values;
  final List<Color> colors;
  final TextStyle labelStyle;
  final TextScaler textScaler;
  final Color textColor;

  static Color _onSlice(Color slice) {
    const dark = Color(0xFF111315);
    final light = slice.computeLuminance();
    final whiteContrast = 1.05 / (light + 0.05);
    final darkContrast = (light + 0.05) / (dark.computeLuminance() + 0.05);
    return darkContrast >= whiteContrast ? dark : Colors.white;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (a, b) => a + b);
    if (total <= 0) return;
    final center = layout.center;
    final radius = layout.radius;
    final stroke = layout.stroke;
    final ring = Rect.fromCircle(center: center, radius: radius - stroke / 2);
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

    for (final label in layout.labels) {
      final direction = Offset(math.cos(label.angle), math.sin(label.angle));
      final painter = TextPainter(
        text: TextSpan(
          text: label.text,
          style: labelStyle.copyWith(
            color: label.inside ? _onSlice(colors[label.index]) : textColor,
          ),
        ),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      if (label.inside) {
        final at = center + direction * (radius - stroke / 2);
        painter.paint(
          canvas,
          at - Offset(painter.width / 2, painter.height / 2),
        );
      } else {
        final sign = label.right ? 1.0 : -1.0;
        final anchor = center + direction * (radius + 1);
        final elbow = center + direction * (radius + 8);
        final end = Offset(
          center.dx + sign * (radius + _AnalyticsDonutLayout._lineReach),
          label.y,
        );
        canvas.drawPath(
          Path()
            ..moveTo(anchor.dx, anchor.dy)
            ..lineTo(elbow.dx, elbow.dy)
            ..lineTo(end.dx, end.dy),
          Paint()
            ..color = colors[label.index]
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        final x = label.right
            ? end.dx + _AnalyticsDonutLayout._textGap
            : end.dx - _AnalyticsDonutLayout._textGap - painter.width;
        painter.paint(canvas, Offset(x, label.y - painter.height / 2));
      }
      painter.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant _AnalyticsDonut oldDelegate) => true;
}
