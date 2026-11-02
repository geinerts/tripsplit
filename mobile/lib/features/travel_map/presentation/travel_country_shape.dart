import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'travel_map_labels.dart';

class TravelCountryShape {
  const TravelCountryShape(this.code, this.rings);
  final String code;
  final List<List<LatLng>> rings;
  static List<TravelCountryShape>? _loaded;
  static Future<List<TravelCountryShape>> load() async =>
      _loaded ??= await _load();
  static Future<List<TravelCountryShape>> _load() async {
    final data =
        jsonDecode(await rootBundle.loadString('assets/maps/world.json'))
            as Map;
    await TravelMapLabel.load();
    final shapes = <TravelCountryShape>[];
    for (final feature in data['features'] as List) {
      final geometry = feature['geometry'] as Map;
      final polygons = geometry['type'] == 'Polygon'
          ? [geometry['coordinates']]
          : geometry['coordinates'] as List;
      for (final polygon in polygons) {
        final rings = (polygon as List)
            .map(
              (ring) => (ring as List)
                  .map(
                    (p) => LatLng(
                      (p[1] as num).toDouble().clamp(-85, 85),
                      (p[0] as num).toDouble(),
                    ),
                  )
                  .toList(),
            )
            .toList();
        shapes.add(
          TravelCountryShape(feature['properties']['code'] as String, rings),
        );
      }
    }
    return shapes;
  }
}
