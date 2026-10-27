import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/l10n/l10n.dart';
import '../domain/travel_place.dart';

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

class TravelMapCanvas extends StatelessWidget {
  const TravelMapCanvas({
    super.key,
    required this.controller,
    required this.shapes,
    required this.places,
    required this.selected,
    required this.onSelect,
    required this.onDelete,
    required this.onReady,
    required this.onFit,
    this.busy = false,
    this.photoBuilder,
    this.onEdit,
    this.onOpenTrip,
  });
  final MapController controller;
  final List<TravelCountryShape> shapes;
  final List<TravelPlace> places;
  final TravelPlace? selected;
  final ValueChanged<TravelPlace?> onSelect;
  final ValueChanged<TravelPlace> onDelete;
  final VoidCallback onReady, onFit;
  final bool busy;
  final Widget Function(TravelPlace)? photoBuilder;
  final ValueChanged<TravelPlace>? onEdit, onOpenTrip;
  @override
  Widget build(BuildContext context) {
    final t = context.l10n, colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final unique = <String, TravelPlace>{};
    for (final p in places) {
      unique.putIfAbsent(p.placeKey, () => p);
    }
    final countries = places.map((p) => p.countryCode).toSet();
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: FlutterMap(
        mapController: controller,
        options: MapOptions(
          initialCenter: const LatLng(48, 9),
          initialZoom: 3,
          minZoom: 1,
          maxZoom: 7,
          backgroundColor: dark
              ? const Color(0xff15272c)
              : const Color(0xffe7efee),
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          onTap: (_, point) => onSelect(null),
          onMapReady: onReady,
        ),
        children: [
          PolygonLayer(
            polygons: [
              for (final shape in shapes)
                Polygon(
                  points: shape.rings.first,
                  holePointsList: shape.rings.skip(1).toList(),
                  color: countries.contains(shape.code)
                      ? (dark
                            ? const Color(0xff325e4b)
                            : const Color(0xffcbe6d8))
                      : (dark
                            ? const Color(0xff293a3c)
                            : const Color(0xfff8f8f2)),
                  borderColor: dark
                      ? const Color(0xff425153)
                      : const Color(0xffcdd9d2),
                  borderStrokeWidth: .7,
                ),
            ],
          ),
          MarkerLayer(
            markers: [
              for (final place in unique.values)
                Marker(
                  point: place.point,
                  width: 48,
                  height: 48,
                  child: Semantics(
                    label: '${place.city}, ${place.country}',
                    button: true,
                    child: IconButton(
                      key: ValueKey('travel-pin-${place.id}'),
                      tooltip: place.city,
                      onPressed: () => onSelect(
                        selected?.placeKey == place.placeKey ? null : place,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        side: BorderSide(color: colors.surface, width: 3),
                      ),
                      icon: const Icon(Icons.check, size: 22),
                    ),
                  ),
                ),
            ],
          ),
          Builder(
            builder: (context) => LayoutBuilder(
              builder: (context, size) {
                final place = selected;
                if (place == null) return const SizedBox.shrink();
                final pixel = MapCamera.of(
                  context,
                ).latLngToScreenOffset(place.point);
                if (pixel.dx < 0 ||
                    pixel.dx > size.maxWidth ||
                    pixel.dy < 0 ||
                    pixel.dy > size.maxHeight) {
                  return const SizedBox.shrink();
                }
                final width = math.min(270.0, size.maxWidth - 24);
                final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
                final estimate =
                    (230.0 + (place.hasPhoto ? 90 : 0)) * scale.clamp(1.0, 1.6);
                final top =
                    (pixel.dy > estimate + 40
                            ? pixel.dy - estimate - 20
                            : pixel.dy + 28)
                        .clamp(
                          60.0,
                          math.max(60.0, size.maxHeight - estimate - 12),
                        );
                final visits = places
                    .where((p) => p.placeKey == place.placeKey)
                    .toList();
                final index = visits.indexWhere((p) => p.id == place.id);
                return Stack(
                  children: [
                    Positioned(
                      left: (pixel.dx - width / 2).clamp(
                        12.0,
                        math.max(12.0, size.maxWidth - width - 12),
                      ),
                      top: top.toDouble(),
                      width: width,
                      child: Material(
                        key: const ValueKey('travel-place-popup'),
                        color: colors.surface,
                        elevation: 8,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: math.max(100, size.maxHeight - top - 12),
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            place.city,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: t.travelMapClose,
                                        onPressed: () => onSelect(null),
                                        icon: const Icon(Icons.close, size: 18),
                                      ),
                                    ],
                                  ),
                                  if (place.hasPhoto &&
                                      photoBuilder != null) ...[
                                    photoBuilder!(place),
                                    const SizedBox(height: 8),
                                  ],
                                  if (place.title.isNotEmpty ||
                                      (place.tripName ?? '').isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text(
                                        place.title.isNotEmpty
                                            ? place.title
                                            : place.tripName!,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                    ),
                                  Text(
                                    place.subtitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat.yMMMd(
                                      Localizations.localeOf(
                                        context,
                                      ).toString(),
                                    ).format(DateTime.parse(place.visitedOn)),
                                  ),
                                  if (visits.length > 1)
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: t.travelPreviousVisit,
                                          onPressed: index > 0
                                              ? () =>
                                                    onSelect(visits[index - 1])
                                              : null,
                                          icon: const Icon(Icons.chevron_left),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${index + 1} / ${visits.length}',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: t.travelNextVisit,
                                          onPressed: index < visits.length - 1
                                              ? () =>
                                                    onSelect(visits[index + 1])
                                              : null,
                                          icon: const Icon(Icons.chevron_right),
                                        ),
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      if (place.tripId != null &&
                                          onOpenTrip != null)
                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: busy
                                                ? null
                                                : () => onOpenTrip!(place),
                                            icon: const Icon(
                                              Icons.open_in_new,
                                              size: 16,
                                            ),
                                            label: Text(t.travelOpenTrip),
                                          ),
                                        )
                                      else
                                        const Spacer(),
                                      if (onEdit != null)
                                        IconButton(
                                          key: const ValueKey(
                                            'travel-edit-visit',
                                          ),
                                          tooltip: t.travelEditVisit,
                                          onPressed: busy
                                              ? null
                                              : () => onEdit!(place),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 19,
                                          ),
                                        ),
                                      IconButton(
                                        tooltip: t.travelMapDelete,
                                        onPressed: busy
                                            ? null
                                            : () => onDelete(place),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 19,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 64,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  t.travelMapCounts(countries.length, unique.length),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filledTonal(
              tooltip: t.travelMapFit,
              onPressed: onFit,
              icon: const Icon(Icons.center_focus_strong),
            ),
          ),
          const Positioned(
            bottom: 8,
            right: 10,
            child: IgnorePointer(
              child: Text(
                'Natural Earth',
                style: TextStyle(fontSize: 11, color: Color(0xff849397)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
