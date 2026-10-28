import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TravelMapLabel {
  const TravelMapLabel({
    required this.name,
    required this.point,
    required this.zoom,
    required this.rank,
    required this.country,
    this.spanishName,
  });
  final String name;
  final String? spanishName;
  final LatLng point;
  final double zoom;
  final int rank;
  final bool country;
  static List<TravelMapLabel> loaded = const [];
  static Future<void> load() async {
    if (loaded.isNotEmpty) return;
    final raw =
        jsonDecode(await rootBundle.loadString('assets/maps/labels.json'))
            as List;
    loaded =
        raw
            .map(
              (item) => TravelMapLabel(
                name: item['name'] as String,
                spanishName: item['name_es'] as String?,
                point: LatLng(
                  (item['lat'] as num).toDouble(),
                  (item['lon'] as num).toDouble(),
                ),
                zoom: (item['zoom'] as num).toDouble(),
                rank: (item['rank'] as num).toInt(),
                country: item['kind'] == 'country',
              ),
            )
            .toList()
          ..sort((a, b) {
            if (a.country != b.country) return a.country ? -1 : 1;
            return a.rank.compareTo(b.rank);
          });
  }
}

/// Offline reference labels. Cull offscreen labels and reserve space for pins.
class TravelMapLabels extends StatelessWidget {
  const TravelMapLabels({super.key, required this.pins});
  final List<LatLng> pins;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: CustomPaint(
      size: Size.infinite,
      painter: _LabelsPainter(
        camera: MapCamera.of(context),
        labels: TravelMapLabel.loaded,
        pins: pins,
        dark: Theme.of(context).brightness == Brightness.dark,
        locale: Localizations.localeOf(context).languageCode,
        scale: MediaQuery.textScalerOf(context).scale(11).clamp(11, 14) / 11,
      ),
    ),
  );
}

class _LabelsPainter extends CustomPainter {
  const _LabelsPainter({
    required this.camera,
    required this.labels,
    required this.pins,
    required this.dark,
    required this.locale,
    required this.scale,
  });
  final MapCamera camera;
  final List<TravelMapLabel> labels;
  final List<LatLng> pins;
  final bool dark;
  final String locale;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final occupied = <Rect>[
      Rect.fromLTWH(0, 0, size.width, 62),
      for (final pin in pins)
        Rect.fromCircle(center: camera.latLngToScreenOffset(pin), radius: 17),
    ];
    final bounds = Offset.zero & size;
    for (final label in labels) {
      if (camera.zoom < label.zoom) continue;
      final point = camera.latLngToScreenOffset(label.point);
      if (!bounds.inflate(20).contains(point)) continue;
      final name = locale == 'es'
          ? label.spanishName ?? label.name
          : label.name;
      final text = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 2,
        text: TextSpan(
          text: name,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: (label.country ? 11 : 10) * scale,
            fontWeight: label.country ? FontWeight.w600 : FontWeight.w400,
            color: dark ? const Color(0xffc6d6d5) : const Color(0xff50655f),
            shadows: [
              Shadow(
                color: dark ? const Color(0xff293a3c) : const Color(0xfff8f8f2),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        textAlign: TextAlign.center,
      )..layout(maxWidth: 105 * scale);
      final origin = point - Offset(text.width / 2, text.height / 2);
      final rect = (origin & text.size).inflate(label.country ? 7 : 5);
      if (!bounds.contains(rect.topLeft) ||
          !bounds.contains(rect.bottomRight) ||
          occupied.any((other) => other.overlaps(rect))) {
        text.dispose();
        continue;
      }
      occupied.add(rect);
      text.paint(canvas, origin);
      text.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant _LabelsPainter old) =>
      old.camera != camera ||
      old.labels != labels ||
      old.pins != pins ||
      old.dark != dark ||
      old.locale != locale ||
      old.scale != scale;
}
