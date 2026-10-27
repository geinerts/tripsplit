import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../core/auth/account_data_session.dart';
import '../../../app/theme/app_design.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_scaffold.dart';
import '../../trips/domain/entities/trip.dart';
import 'travel_visit_photo.dart';
import '../data/travel_location_service.dart';
import '../data/travel_places_repository.dart';
import '../domain/travel_place.dart';
import 'travel_map_canvas.dart';
import 'travel_place_sheet.dart';

class TravelMapPage extends StatefulWidget {
  const TravelMapPage({
    super.key,
    required this.repository,
    this.locations,
    this.loadTrips,
    this.initialTripId,
  });
  final TravelPlacesRepository repository;
  final TravelLocationService? locations;
  final Future<List<Trip>> Function()? loadTrips;
  final int? initialTripId;
  @override
  State<TravelMapPage> createState() => _TravelMapPageState();
}

class _TravelMapPageState extends State<TravelMapPage> {
  final _map = MapController();
  late final AccountDataLease _owner = widget.repository.capture();
  late final TravelLocationService _locations =
      widget.locations ?? NativeTravelLocationService();
  List<TravelCountryShape>? _shapes;
  List<TravelPlace> _places = [];
  TravelPlace? _selected;
  bool _loading = true, _busy = false, _offline = false, _ready = false;
  bool _locating = false;
  Object? _error;
  int _generation = 0;
  bool _initialTripOpened = false;
  bool get _current => mounted && _owner.isCurrent;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _generation++;
    _map.dispose();
    super.dispose();
  }

  void _sort() => _places.sort((a, b) {
    final dates = b.visitedOn.compareTo(a.visitedOn);
    return dates == 0 ? b.id.compareTo(a.id) : dates;
  });
  void _fit() {
    if (!_ready || !_current) return;
    if (_places.isEmpty) return;
    if (_places.length == 1) {
      _map.move(_places.first.point, 4);
      return;
    }
    _map.fitCamera(
      CameraFit.coordinates(
        coordinates: _places.map((p) => p.point).toList(),
        padding: const EdgeInsets.fromLTRB(48, 90, 48, 70),
        maxZoom: 5,
      ),
    );
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _owner.check();
      final results = await Future.wait<Object>([
        widget.repository.load(),
        if (_shapes == null) TravelCountryShape.load(),
      ]);
      if (!_current || generation != _generation) return;
      final data = results.first as TravelPlacesResult;
      setState(() {
        _places = data.places.toList();
        _sort();
        _offline = data.offline;
        _selected = null;
        if (results.length > 1) {
          _shapes = results[1] as List<TravelCountryShape>;
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fit();
        if (!_initialTripOpened && widget.initialTripId != null && mounted) {
          _initialTripOpened = true;
          _fromTrip(widget.initialTripId);
        }
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() {
          _error = error;
          if (!_owner.isCurrent ||
              error is ApiException &&
                  [401, 403, 404].contains(error.statusCode)) {
            _places = [];
            _selected = null;
          }
        });
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  void _notice(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _add({
    bool here = false,
    Trip? trip,
    PlaceCandidate? initial,
    TravelPlace? existing,
  }) async {
    if (_busy || _loading || !_current) return;
    setState(() {
      _busy = true;
      _locating = here;
    });
    try {
      final candidate = here
          ? await _locations.currentCity()
          : existing ?? initial;
      if (!mounted || !_current) return;
      setState(() => _locating = false);
      final saved = await showModalBottomSheet<TravelPlace>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => TravelPlaceSheet(
          locations: _locations,
          initial: candidate,
          existing: existing,
          trip: trip,
          repository: widget.repository,
          isCurrent: () => _current,
          save: (place, date, details) async {
            _owner.check();
            return widget.repository.save(place, date, details: details);
          },
        ),
      );
      if (!mounted || !_current || saved == null) return;
      setState(() {
        _places = [saved, ..._places.where((p) => p.id != saved.id)];
        _sort();
        _selected = saved;
        _offline = false;
      });
      if (_ready) _map.move(saved.point, 4.5);
      _notice(context.l10n.travelMapSaved);
    } on TravelLocationError catch (error) {
      if (!mounted || !_current) return;
      final t = context.l10n;
      _notice(switch (error.code) {
        'denied' || 'deniedForever' => t.travelMapDenied,
        'disabled' => t.travelMapDisabled,
        _ => t.travelMapLookupError,
      });
    } catch (_) {
      if (mounted && _current) _notice(context.l10n.travelMapLookupError);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _locating = false;
        });
      }
    }
  }

  Future<void> _fromTrip([int? initialId]) async {
    if (_busy || !_current || widget.loadTrips == null) return;
    setState(() => _busy = true);
    Trip? trip;
    try {
      final trips = await widget.loadTrips!();
      if (!mounted || !_current) return;
      if (initialId != null) {
        for (final item in trips) {
          if (item.id == initialId) {
            trip = item;
            break;
          }
        }
        if (trip == null) {
          _notice(context.l10n.travelMapError);
          return;
        }
      } else if (trips.isEmpty) {
        _notice(context.l10n.travelNoTrips);
        return;
      } else {
        trip = await showModalBottomSheet<Trip>(
          context: context,
          useSafeArea: true,
          isScrollControlled: true,
          builder: (context) => SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * .6,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      context.l10n.travelChooseTrip,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final item in trips)
                          ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                              [
                                item.dateFrom,
                                item.dateTo,
                              ].whereType<String>().join(' – '),
                            ),
                            leading: const Icon(Icons.luggage_outlined),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.pop(context, item),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted && _current) _notice(context.l10n.travelMapError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted || !_current || trip == null) return;
    PlaceCandidate? destination;
    final choices = trip.destinations.map(PlaceCandidate.fromJson).toList();
    if (choices.length == 1) destination = choices.single;
    if (choices.length > 1) {
      destination = await showModalBottomSheet<PlaceCandidate>(
        context: context,
        useSafeArea: true,
        builder: (context) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final city in choices)
                ListTile(
                  title: Text(city.city),
                  subtitle: Text(city.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, city),
                ),
            ],
          ),
        ),
      );
      if (destination == null) return;
    }
    if (!mounted || !_current) return;
    await _add(trip: trip, initial: destination);
  }

  Future<void> _delete(TravelPlace place) async {
    if (_busy || !_current) return;
    final t = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.travelMapDelete),
        content: Text(t.travelMapDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.travelMapCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.travelMapDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !_current) return;
    setState(() => _busy = true);
    try {
      await widget.repository.delete(place.id);
      if (!mounted || !_current) return;
      setState(() {
        _places.removeWhere((p) => p.id == place.id);
        _selected = null;
        _offline = false;
      });
    } catch (_) {
      if (_current) _notice(t.travelMapSaveError);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _locating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppPageScaffold(
      appBar: AppBar(
        backgroundColor: AppDesign.pageBaseColor(context),
        title: Text(t.travelMapTitle),
        actions: [
          IconButton(
            tooltip: t.travelMapRetry,
            onPressed: _loading || _busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t.travelMapSubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            if (widget.loadTrips != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  key: const ValueKey('travel-map-from-trip'),
                  onPressed: _busy || _loading || _error != null
                      ? null
                      : () => _fromTrip(),
                  icon: const Icon(Icons.luggage_outlined),
                  label: Text(t.travelFromTrip),
                ),
              ),
            const SizedBox(height: 12),
            if (_offline)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  t.travelMapOffline,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error is ApiException &&
                          (_error as ApiException).code ==
                              'travel_map_unavailable'
                      ? t.travelMapUnavailable
                      : t.travelMapError,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  if (_shapes != null)
                    Positioned.fill(
                      child: TravelMapCanvas(
                        controller: _map,
                        shapes: _shapes!,
                        places: _places,
                        selected: _selected,
                        busy: _busy,
                        photoBuilder: (place) => TravelVisitPhoto(
                          place: place,
                          repository: widget.repository,
                        ),
                        onEdit: (place) => _add(existing: place),
                        onOpenTrip: widget.loadTrips == null
                            ? null
                            : (place) => Navigator.pop(context, place.tripId),
                        onSelect: (p) {
                          if (_current) setState(() => _selected = p);
                        },
                        onDelete: _delete,
                        onFit: _fit,
                        onReady: () {
                          _ready = true;
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _fit(),
                          );
                        },
                      ),
                    ),
                  if (_loading)
                    const Center(child: CircularProgressIndicator()),
                  if (!_loading && _error == null && _places.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Material(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.travel_explore,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  t.travelMapEmpty,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t.travelMapEmptyBody,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_locating)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final here = FilledButton.icon(
                  key: const ValueKey('travel-map-here'),
                  onPressed: _busy || _loading || _error != null
                      ? null
                      : () => _add(here: true),
                  icon: const Icon(Icons.my_location),
                  label: Text(t.travelMapHere),
                );
                final manual = OutlinedButton.icon(
                  key: const ValueKey('travel-map-add'),
                  onPressed: _busy || _loading || _error != null ? null : _add,
                  icon: const Icon(Icons.add),
                  label: Text(t.travelMapAdd),
                );
                if (constraints.maxWidth < 360 ||
                    MediaQuery.textScalerOf(context).scale(14) > 18) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [here, const SizedBox(height: 8), manual],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: here),
                    const SizedBox(width: 10),
                    Expanded(child: manual),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
