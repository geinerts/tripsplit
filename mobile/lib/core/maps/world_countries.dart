import 'dart:convert';

import 'package:flutter/services.dart';

/// One country outline from the bundled Natural Earth map
/// (`assets/maps/world.json`, see its NOTICE.txt). Points are (longitude,
/// latitude) in degrees.
class WorldCountry {
  const WorldCountry(this.code, this.polygons);

  final String code;

  /// Outer rings only; holes are not needed at the scale the map is drawn.
  final List<List<Offset>> polygons;

  static List<WorldCountry>? _loaded;

  /// Loads the outlines once and keeps them for the rest of the session.
  static Future<List<WorldCountry>> load() async =>
      // The bundle's own cache would keep an unfinished load; keep only the
      // parsed outlines.
      _loaded ??= parse(
        await rootBundle.loadString('assets/maps/world.json', cache: false),
      );

  static List<WorldCountry> parse(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    return [
      for (final feature in (data['features'] as List).cast<Map>())
        WorldCountry(
          '${(feature['properties'] as Map)['code'] ?? ''}',
          _polygons(feature['geometry'] as Map),
        ),
    ];
  }

  static List<List<Offset>> _polygons(Map geometry) {
    final coordinates = geometry['coordinates'] as List;
    final polygons = geometry['type'] == 'Polygon'
        ? [coordinates]
        : coordinates;
    return [
      for (final polygon in polygons.cast<List>())
        [
          for (final point in (polygon.first as List).cast<List>())
            Offset((point[0] as num).toDouble(), (point[1] as num).toDouble()),
        ],
    ];
  }
}
