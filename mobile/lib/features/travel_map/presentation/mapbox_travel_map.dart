import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import '../../../core/l10n/l10n.dart';
import '../../../core/maps/mapbox_config.dart';
import '../domain/travel_place.dart';
import 'travel_country_shape.dart';

/// Quiet, flat map for private memories. Visit details and photos remain Flutter
/// widgets on the device; neither is added to a remote Mapbox dataset.
class MapboxTravelMap extends StatefulWidget {
  const MapboxTravelMap({
    super.key,
    required this.shapes,
    required this.places,
    required this.onReady,
    required this.onClearSelection,
    required this.overlayBuilder,
  });

  final List<TravelCountryShape> shapes;
  final List<TravelPlace> places;
  final VoidCallback onReady, onClearSelection;
  final Widget Function(BuildContext, Map<String, Offset>) overlayBuilder;

  @override
  State<MapboxTravelMap> createState() => MapboxTravelMapState();
}

class MapboxTravelMapState extends State<MapboxTravelMap> {
  static const _source = 'splyto-visited-countries';
  static const _layer = 'splyto-visited-country-fill';
  mb.MapboxMap? _map;
  Map<String, Offset> _positions = {};
  Brightness? _brightness;
  bool _styleReady = false, _failed = false, _notifiedReady = false;
  bool _projecting = false, _projectAgain = false;
  bool _syncingCountries = false, _countriesAgain = false;
  int _generation = 0, _placesRevision = 0;

  bool get _dark => _brightness == Brightness.dark;
  String get _style => _dark
      ? 'mapbox://styles/mapbox/dark-v11'
      : 'mapbox://styles/mapbox/light-v11';
  List<TravelPlace> get _unique => {
    for (final place in widget.places.reversed) place.placeKey: place,
  }.values.toList();
  mb.Point _point(TravelPlace place) =>
      mb.Point(coordinates: mb.Position(place.longitude, place.latitude));

  @override
  void initState() {
    super.initState();
    mb.MapboxOptions.setAccessToken(mapboxAccessToken);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_brightness == brightness) return;
    _brightness = brightness;
    if (_map != null) {
      _styleReady = false;
      _generation++;
      unawaited(
        _map!.loadStyleURI(_style).catchError((Object _) {
          if (mounted) setState(() => _failed = true);
        }),
      );
    }
  }

  @override
  void didUpdateWidget(covariant MapboxTravelMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.places != widget.places) {
      _placesRevision++;
      // Revoke deleted/account-switched markers before an asynchronous projection.
      final keys = widget.places.map((p) => p.placeKey).toSet();
      _positions.removeWhere((key, _) => !keys.contains(key));
      _project();
      _syncCountries();
    }
  }

  Future<void> _created(mb.MapboxMap map) async {
    _map = map;
    map.addInteraction(
      mb.TapInteraction.onMap((_) {
        if (mounted) widget.onClearSelection();
      }),
    );
    try {
      await map.setCamera(
        mb.CameraOptions(
          center: mb.Point(coordinates: mb.Position(9, 48)),
          zoom: 3,
        ),
      );
      await map.setBounds(mb.CameraBoundsOptions(minZoom: 1, maxZoom: 12));
      await map.scaleBar.updateSettings(mb.ScaleBarSettings(enabled: false));
      await map.compass.updateSettings(mb.CompassSettings(enabled: false));
      await map.gestures.updateSettings(
        mb.GesturesSettings(rotateEnabled: false, pitchEnabled: false),
      );
      // Do not initialise Mapbox's location component: opening memories must
      // never request GPS. Keep native logo, attribution and telemetry opt-out.
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _styleLoaded() async {
    final map = _map;
    if (map == null || !mounted) return;
    final generation = ++_generation;
    _styleReady = false;
    try {
      final layers = await map.getStyleLayers();
      for (final layer in layers.whereType<mb.StyleObjectInfo>()) {
        if (!mounted || generation != _generation) return;
        final id = layer.id;
        // Keep country, region and city labels. Remove local navigation clutter.
        if (id.contains('poi') ||
            id.contains('transit') ||
            id.contains('road-label') ||
            id.contains('road-number') ||
            id.contains('airport') ||
            id.contains('building')) {
          await map.setStyleLayerProperty(id, 'visibility', 'none');
        }
        if (id == 'country-label' ||
            id == 'state-label' ||
            id.startsWith('settlement-')) {
          await map.setStyleLayerProperty(
            id,
            'text-color',
            _dark ? '#c4d6d2' : '#526963',
          );
          await map.setStyleLayerProperty(
            id,
            'text-halo-color',
            _dark ? '#293a3c' : '#f5f6ef',
          );
          await map.setStyleLayerProperty(id, 'text-halo-width', .5);
        }
        if (id.startsWith('admin-') && id.endsWith('-bg')) {
          await map.setStyleLayerProperty(id, 'visibility', 'none');
        } else if (id.startsWith('admin-')) {
          await map.setStyleLayerProperty(
            id,
            'line-color',
            _dark ? '#596d6b' : '#b4c6bf',
          );
        }
        if (id == 'background' || id == 'land') {
          await map.setStyleLayerProperty(
            id,
            'background-color',
            _dark ? '#293a3c' : '#f5f6ef',
          );
        } else if (id == 'water') {
          await map.setStyleLayerProperty(
            id,
            'fill-color',
            _dark ? '#15272c' : '#e1efed',
          );
        }
      }
      if (!mounted || generation != _generation) return;
      await map.addSource(mb.GeoJsonSource(id: _source, data: _countryData()));
      // Below labels/boundaries. Coarse bundled outlines fade away as the user
      // zooms into cities; the detailed Mapbox basemap remains visible.
      final before = layers
          .whereType<mb.StyleObjectInfo>()
          .where(
            (layer) => layer.id.contains('admin') || layer.id.contains('label'),
          )
          .firstOrNull
          ?.id;
      await map.addStyleLayer(
        jsonEncode({
          'id': _layer,
          'type': 'fill',
          'source': _source,
          'paint': {
            'fill-color': _dark ? '#55b58d' : '#239875',
            'fill-opacity': [
              'interpolate',
              ['linear'],
              ['zoom'],
              3,
              .22,
              4.5,
              0.0,
            ],
          },
        }),
        mb.LayerPosition(below: before),
      );
      if (!mounted || generation != _generation) return;
      _styleReady = true;
      _syncCountries();
      _project();
      if (!_notifiedReady) {
        _notifiedReady = true;
        widget.onReady();
      }
    } catch (_) {
      if (mounted && generation == _generation) setState(() => _failed = true);
    }
  }

  String _countryData() {
    final codes = widget.places.map((p) => p.countryCode).toSet();
    return jsonEncode({
      'type': 'FeatureCollection',
      'features': [
        for (final shape in widget.shapes)
          if (codes.contains(shape.code))
            {
              'type': 'Feature',
              'properties': <String, Object>{},
              'geometry': {
                'type': 'Polygon',
                'coordinates': [
                  for (final ring in shape.rings)
                    [
                      for (final p in ring) [p.longitude, p.latitude],
                    ],
                ],
              },
            },
      ],
    });
  }

  Future<void> _syncCountries() async {
    _countriesAgain = true;
    if (_syncingCountries || !_styleReady || _map == null) return;
    _syncingCountries = true;
    try {
      while (mounted && _countriesAgain && _styleReady) {
        _countriesAgain = false;
        await _map!.setStyleSourceProperty(_source, 'data', _countryData());
      }
    } catch (_) {
      if (mounted && _styleReady) setState(() => _failed = true);
    } finally {
      _syncingCountries = false;
    }
  }

  Future<void> _project() async {
    _projectAgain = true;
    if (_projecting || _map == null) return;
    _projecting = true;
    try {
      // Coalesce camera events; at most one platform projection is in flight.
      while (mounted && _projectAgain && _map != null) {
        _projectAgain = false;
        final places = _unique, revision = _placesRevision;
        final pixels = await _map!.pixelsForCoordinates(
          places.map(_point).toList(),
        );
        if (!mounted) return;
        if (revision != _placesRevision) continue;
        setState(
          () => _positions = {
            for (var i = 0; i < places.length && i < pixels.length; i++)
              if (pixels[i].x.isFinite && pixels[i].y.isFinite)
                places[i].placeKey: Offset(pixels[i].x, pixels[i].y),
          },
        );
      }
    } catch (_) {
      // The native view can disappear during navigation or a style reload.
    } finally {
      _projecting = false;
    }
  }

  Future<void> fitPlaces() async {
    final map = _map, places = _unique;
    if (map == null || !mounted) return;
    try {
      final camera = places.isEmpty
          ? mb.CameraOptions(
              center: mb.Point(coordinates: mb.Position(9, 48)),
              zoom: 3,
            )
          : places.length == 1
          ? mb.CameraOptions(center: _point(places.first), zoom: 4.5)
          : await map.cameraForCoordinatesPadding(
              places.map(_point).toList(),
              mb.CameraOptions(bearing: 0, pitch: 0),
              mb.MbxEdgeInsets(top: 90, left: 48, bottom: 70, right: 48),
              5,
              null,
            );
      if (!mounted) return;
      await map.flyTo(camera, mb.MapAnimationOptions(duration: 500));
      _project();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> focusPlace(TravelPlace place) async {
    if (_map == null) return;
    try {
      await _map!.flyTo(
        mb.CameraOptions(center: _point(place), zoom: 5),
        mb.MapAnimationOptions(duration: 500),
      );
      _project();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      mb.MapWidget(
        key: const ValueKey('mapbox-travel-map'),
        styleUri: _style,
        onMapCreated: (map) => unawaited(_created(map)),
        onStyleLoadedListener: (_) => unawaited(_styleLoaded()),
        onCameraChangeListener: (_) => unawaited(_project()),
        onMapIdleListener: (_) => unawaited(_project()),
        onMapLoadErrorListener: (_) {
          if (mounted) setState(() => _failed = true);
        },
        onMapLoadedListener: (_) {
          if (mounted && _failed) setState(() => _failed = false);
          _project();
        },
      ),
      widget.overlayBuilder(context, _positions),
      if (_failed)
        Positioned(
          top: 64,
          left: 12,
          right: 12,
          child: IgnorePointer(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(context.l10n.liveMapLoadError),
              ),
            ),
          ),
        ),
    ],
  );

  @override
  void dispose() {
    _generation++;
    _map = null;
    super.dispose();
  }
}
