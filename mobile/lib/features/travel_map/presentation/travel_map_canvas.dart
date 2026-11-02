import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../domain/travel_place.dart';
import 'travel_map_labels.dart';
import 'travel_country_shape.dart';
import 'travel_map_overlay.dart';
import 'mapbox_travel_map.dart';
import '../../../core/maps/mapbox_config.dart';
export 'travel_country_shape.dart';

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
    this.nativeKey,
    this.busy = false,
    this.photoBuilder,
    this.onEdit,
    this.onOpenTrip,
  });
  final GlobalKey<MapboxTravelMapState>? nativeKey;
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
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final unique = <String, TravelPlace>{};
    for (final p in places) {
      unique.putIfAbsent(p.placeKey, () => p);
    }
    final countries = places.map((p) => p.countryCode).toSet();
    Widget overlay(
      BuildContext context,
      Map<String, Offset> positions, {
      bool showPins = false,
    }) => TravelMapOverlay(
      positions: positions,
      places: places,
      selected: selected,
      onSelect: onSelect,
      onDelete: onDelete,
      onFit: onFit,
      busy: busy,
      photoBuilder: photoBuilder,
      onEdit: onEdit,
      onOpenTrip: onOpenTrip,
      showPins: showPins,
    );
    if (mapboxAvailable) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: MapboxTravelMap(
          key: nativeKey,
          shapes: shapes,
          places: places,
          onReady: onReady,
          onClearSelection: () => onSelect(null),
          overlayBuilder: (context, positions) =>
              overlay(context, positions, showPins: true),
        ),
      );
    }
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
          TravelMapLabels(pins: unique.values.map((p) => p.point).toList()),
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
                      style: IconButton.styleFrom(padding: EdgeInsets.zero),
                      icon: Container(
                        key: ValueKey('travel-pin-symbol-${place.id}'),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary,
                          border: Border.all(color: colors.surface, width: 1.5),
                        ),
                        child: Icon(
                          Icons.check,
                          size: 12,
                          color: colors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Builder(
            builder: (context) => overlay(context, {
              for (final place in unique.values)
                place.placeKey: MapCamera.of(
                  context,
                ).latLngToScreenOffset(place.point),
            }),
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
