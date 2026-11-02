import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import '../../../core/l10n/l10n.dart';
import '../../../core/maps/mapbox_config.dart';
import '../../workspace/domain/entities/workspace_user.dart';
import '../domain/live_location.dart';

bool get mapboxLiveMapAvailable => mapboxAvailable;

// iOS decodes annotation PNGs at UIScreen.scale; Android uses bitmap pixels.
// Our 112px marker must occupy the same 56 logical pixels on either platform.
double liveMapIconScale(TargetPlatform platform, double pixelRatio) =>
    platform == TargetPlatform.iOS ? pixelRatio / 2 : .5;

mb.Point liveMapPoint(LiveMember member) => mb.Point(
  coordinates: mb.Position(member.point.longitude, member.point.latitude),
);

mb.Polygon liveAccuracyArea(LiveMember member) {
  const distance = geo.Distance();
  final ring = <mb.Position>[];
  for (var bearing = 0; bearing < 360; bearing += 10) {
    final point = distance.offset(
      member.point,
      member.accuracy.clamp(5.0, 2000.0),
      bearing.toDouble(),
    );
    ring.add(mb.Position(point.longitude, point.latitude));
  }
  return mb.Polygon(coordinates: [ring..add(ring.first)]);
}

class MapboxLiveMap extends StatefulWidget {
  const MapboxLiveMap({
    super.key,
    required this.members,
    required this.users,
    required this.serverNow,
    required this.selected,
    required this.onSelect,
  });

  final List<LiveMember> members;
  final List<WorkspaceUser> users;
  final DateTime serverNow;
  final int? selected;
  final ValueChanged<int?> onSelect;

  @override
  State<MapboxLiveMap> createState() => MapboxLiveMapState();
}

class MapboxLiveMapState extends State<MapboxLiveMap> {
  final _initialViewport = mb.CameraViewportState(
    center: mb.Point(coordinates: mb.Position(9, 48)),
    zoom: 3,
  );
  mb.MapboxMap? _map;
  mb.PointAnnotationManager? _markers;
  mb.PolygonAnnotationManager? _accuracy;
  mb.Cancelable? _taps;
  final _annotations = <int, mb.PointAnnotation>{};
  final _images = <String, Future<Uint8List>>{};
  bool _syncing = false, _pending = false, _fitted = false, _failed = false;
  int _revision = 0, _generation = 0;
  int? _lastFingerprint;
  Brightness? _brightness;

  @override
  void initState() {
    super.initState();
    mb.MapboxOptions.setAccessToken(mapboxAccessToken);
  }

  @override
  void didUpdateWidget(covariant MapboxLiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _queueSync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_brightness != brightness) {
      _brightness = brightness;
      if (_markers != null) {
        unawaited(_applyTheme());
        _queueSync();
      }
    }
  }

  Future<void> _applyTheme() async {
    try {
      await _map?.setStyleImportConfigProperties('basemap', {
        'lightPreset': _brightness == Brightness.dark ? 'night' : 'day',
        'theme': 'faded',
        'showPointOfInterestLabels': true,
        'showTransitLabels': false,
        'show3dObjects': false,
      });
    } catch (_) {
      // A failed style/network request is surfaced by onMapLoadErrorListener.
    }
  }

  Future<void> _created(mb.MapboxMap map) async {
    _map = map;
    try {
      await map.scaleBar.updateSettings(mb.ScaleBarSettings(enabled: false));
      await map.compass.updateSettings(mb.CompassSettings(enabled: false));
      await map.gestures.updateSettings(
        mb.GesturesSettings(rotateEnabled: false, pitchEnabled: false),
      );
      // The native location puck is disabled by default. Do not initialise the
      // SDK location component here: even setting enabled:false can initialise
      // iOS location services. GPS belongs to our explicit consent controller.
      // Keep the native logo/attribution control and its telemetry opt-out.
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _styleLoaded() async {
    final map = _map;
    if (map == null || !mounted) return;
    final generation = ++_generation;
    _taps?.cancel();
    _annotations.clear();
    _markers = null;
    try {
      await _applyTheme();
      final accuracy = await map.annotations.createPolygonAnnotationManager();
      final markers = await map.annotations.createPointAnnotationManager();
      if (!mounted || generation != _generation) return;
      _accuracy = accuracy;
      _markers = markers;
      await markers.setIconAllowOverlap(true);
      await markers.setIconIgnorePlacement(true);
      _taps = markers.tapEvents(
        onTap: (annotation) {
          if (!mounted) return;
          final entry = _annotations.entries
              .where((entry) => entry.value.id == annotation.id)
              .firstOrNull;
          if (entry != null &&
              widget.members.any((member) => member.userId == entry.key)) {
            widget.onSelect(entry.key);
          }
        },
      );
      _queueSync(force: true);
      if (!_fitted) await fitMembers();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> fitMembers() async {
    final map = _map, members = widget.members;
    if (map == null || members.isEmpty || !mounted) return;
    try {
      final camera = members.length == 1
          ? mb.CameraOptions(center: liveMapPoint(members.first), zoom: 15)
          : await map.cameraForCoordinatesPadding(
              members.map(liveMapPoint).toList(),
              mb.CameraOptions(bearing: 0, pitch: 0),
              mb.MbxEdgeInsets(top: 70, left: 60, bottom: 100, right: 60),
              16,
              null,
            );
      if (!mounted || map != _map) return;
      await map.flyTo(camera, mb.MapAnimationOptions(duration: 550));
      _fitted = true;
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _queueSync({bool force = false}) {
    // The session countdown rebuilds every second. Only send native annotation
    // changes for new positions, selection, appearance or freshness transitions.
    final fingerprint = Object.hash(
      widget.selected,
      Theme.of(context).colorScheme,
      Object.hashAll(
        widget.members.map(
          (member) => Object.hash(
            member.userId,
            member.name,
            member.point.latitude,
            member.point.longitude,
            member.accuracy,
            widget.serverNow.difference(member.observedAt).inSeconds < 30,
          ),
        ),
      ),
      Object.hashAll(
        widget.users.map(
          (user) => Object.hash(user.id, user.avatarThumbUrl, user.avatarUrl),
        ),
      ),
    );
    if (!force && fingerprint == _lastFingerprint) return;
    _lastFingerprint = fingerprint;
    _revision++;
    _pending = true;
    if (!_syncing && _markers != null) unawaited(_sync());
  }

  Future<void> _sync() async {
    _syncing = true;
    try {
      while (mounted && _pending && _markers != null) {
        _pending = false;
        final revision = _revision, generation = _generation;
        final markers = _markers!;
        final members = widget.members;
        final ids = members.map((m) => m.userId).toSet();
        // Expired/revoked members disappear before any avatar downloads.
        for (final id in _annotations.keys.toList()) {
          if (!ids.contains(id)) {
            await markers.delete(_annotations.remove(id)!);
          }
        }
        await _accuracy?.deleteAll();
        if (!mounted || generation != _generation) return;
        final selected = members
            .where((m) => m.userId == widget.selected)
            .firstOrNull;
        if (selected != null) {
          await _accuracy?.create(
            mb.PolygonAnnotationOptions(
              geometry: liveAccuracyArea(selected),
              fillColor: Theme.of(context).colorScheme.primary.toARGB32(),
              fillOpacity: .15,
            ),
          );
        }
        for (final member in members) {
          if (!mounted || revision != _revision || generation != _generation) {
            break;
          }
          final colors = Theme.of(context).colorScheme;
          final fresh =
              widget.serverNow.difference(member.observedAt).inSeconds < 30;
          final color = fresh ? colors.primary : colors.outline;
          final user = widget.users
              .where((u) => u.id == member.userId)
              .firstOrNull;
          final url = user?.avatarThumbUrl ?? user?.avatarUrl;
          final initial = member.name.isEmpty
              ? '?'
              : member.name.characters.first.toUpperCase();
          final key = '${member.userId}|$url|$initial|${color.toARGB32()}';
          final image = await _images.putIfAbsent(
            key,
            () => _markerImage(url, initial, color),
          );
          // Never reinsert an expired member after a slow image request.
          if (!mounted || revision != _revision || generation != _generation) {
            break;
          }
          final annotation = _annotations[member.userId];
          if (annotation == null) {
            _annotations[member.userId] = await markers.create(
              mb.PointAnnotationOptions(
                geometry: liveMapPoint(member),
                image: image,
                iconSize: liveMapIconScale(
                  defaultTargetPlatform,
                  MediaQuery.devicePixelRatioOf(context),
                ),
              ),
            );
          } else {
            annotation.geometry = liveMapPoint(member);
            annotation.image = image;
            await markers.update(annotation);
          }
        }
        if (!_fitted && mounted && members.isNotEmpty) await fitMembers();
        // Bound in-memory avatar storage to the active group, never disk-cache
        // member positions or persist images through an account change.
        _images.removeWhere(
          (key, _) => !ids.any((id) => key.startsWith('$id|')),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      _syncing = false;
    }
  }

  Future<Uint8List> _markerImage(
    String? url,
    String initial,
    Color color,
  ) async {
    ui.Image? photo;
    if (url != null) {
      final completer = Completer<ui.Image>();
      final stream = NetworkImage(url).resolve(const ImageConfiguration());
      final listener = ImageStreamListener(
        (info, _) {
          if (!completer.isCompleted) completer.complete(info.image.clone());
        },
        onError: (Object error, StackTrace? stack) {
          if (!completer.isCompleted) completer.completeError(error);
        },
      );
      stream.addListener(listener);
      try {
        photo = await completer.future.timeout(const Duration(seconds: 3));
      } catch (_) {
        // Keep initials for missing/unavailable profile pictures.
      } finally {
        stream.removeListener(listener);
      }
    }
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawCircle(
      const Offset(56, 56),
      53,
      Paint()..color = Colors.black26,
    );
    canvas.drawCircle(const Offset(56, 54), 50, Paint()..color = color);
    const rect = Rect.fromLTWH(12, 10, 88, 88);
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    canvas.drawColor(const Color(0xff162c2a), BlendMode.srcOver);
    if (photo != null) {
      paintImage(canvas: canvas, rect: rect, image: photo, fit: BoxFit.cover);
    } else {
      final text = TextPainter(
        text: TextSpan(
          text: initial,
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(56 - text.width / 2, 54 - text.height / 2));
      text.dispose();
    }
    canvas.restore();
    final picture = recorder.endRecording();
    final image = await picture.toImage(112, 112);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    photo?.dispose();
    return data!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      mb.MapWidget(
        key: const ValueKey('mapbox-live-map'),
        viewport: _initialViewport,
        onMapCreated: (map) => unawaited(_created(map)),
        onStyleLoadedListener: (_) => unawaited(_styleLoaded()),
        onMapLoadErrorListener: (_) {
          if (mounted) setState(() => _failed = true);
        },
        onMapLoadedListener: (_) {
          if (mounted && _failed) setState(() => _failed = false);
        },
      ),
      if (_failed)
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 68, 64, 12),
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
    _taps?.cancel();
    _map = null;
    _images.clear();
    super.dispose();
  }
}
