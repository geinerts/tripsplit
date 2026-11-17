import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/location/location_access.dart';
import '../domain/travel_place.dart';

class TravelLocationError implements Exception {
  const TravelLocationError(this.code);
  final String code;
}

abstract interface class TravelLocationService {
  Future<List<PlaceCandidate>> search(String query);
  Future<PlaceCandidate> currentCity();
}

/// Native geocoding is requested only after an explicit user action. Device
/// coordinates are used transiently to resolve a city, never sent to Splyto.
class NativeTravelLocationService implements TravelLocationService {
  Geocoding get _geocoder => Geocoding();
  static const _locale = Locale('en');
  static const _timeout = Duration(seconds: 20);
  String _city(Placemark p) => placemarkCity(p);
  PlaceCandidate _candidate(Placemark p, Location l) => PlaceCandidate(
    city: _city(p),
    region: (p.administrativeArea ?? '').trim(),
    country: (p.country ?? '').trim(),
    countryCode: (p.isoCountryCode ?? '').toUpperCase(),
    latitude: l.latitude,
    longitude: l.longitude,
  );
  bool _valid(Placemark p) =>
      _city(p).isNotEmpty &&
      (p.country ?? '').isNotEmpty &&
      RegExp(r'^[A-Z]{2}$').hasMatch((p.isoCountryCode ?? '').toUpperCase());

  @override
  Future<List<PlaceCandidate>> search(String query) async {
    if (query.trim().length < 2 || query.length > 200) return [];
    try {
      final geocoder = _geocoder;
      final locations = await geocoder
          .locationFromAddress(query.trim(), locale: _locale)
          .timeout(_timeout);
      final candidates = <PlaceCandidate>[];
      final seen = <String>{};
      for (final location in locations.take(4)) {
        final marks = await geocoder
            .placemarkFromCoordinates(
              location.latitude,
              location.longitude,
              locale: _locale,
            )
            .timeout(_timeout);
        final valid = marks.where(_valid);
        if (valid.isEmpty) continue;
        final mark = valid.first;
        final key =
            '${mark.isoCountryCode}|${mark.administrativeArea}|${_city(mark)}';
        if (!seen.add(key)) continue;
        // Resolve a city centre even if the query was a street address.
        final centres = await geocoder
            .locationFromAddress(
              [
                _city(mark),
                mark.administrativeArea,
                mark.country,
              ].whereType<String>().join(', '),
              locale: _locale,
            )
            .timeout(_timeout);
        if (centres.isNotEmpty) candidates.add(_candidate(mark, centres.first));
      }
      return candidates;
    } catch (_) {
      throw const TravelLocationError('lookup');
    }
  }

  @override
  Future<PlaceCandidate> currentCity() async {
    try {
      await ensureLocationPermission();
    } on LocationAccessException catch (error) {
      throw TravelLocationError(_codeFor(error.problem));
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 20),
        ),
      );
      // Two lookups at most: Apple and Google throttle quick bursts, and the
      // old exact name match failed on spellings such as Rīga and Riga.
      final geocoder = _geocoder;
      final marks = await geocoder
          .placemarkFromCoordinates(
            position.latitude,
            position.longitude,
            locale: _locale,
          )
          .timeout(_timeout);
      final valid = marks.where(_valid);
      if (valid.isEmpty) throw const TravelLocationError('lookup');
      final mark = valid.first;
      Location? centre;
      try {
        final centres = await geocoder
            .locationFromAddress(
              [
                _city(mark),
                mark.administrativeArea,
                mark.country,
              ].where((part) => (part ?? '').trim().isNotEmpty).join(', '),
              locale: _locale,
            )
            .timeout(_timeout);
        centre = centres.isEmpty ? null : centres.first;
      } catch (_) {
        centre = null;
      }
      return currentCityCandidate(
        mark,
        centre: centre,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on TravelLocationError {
      rethrow;
    } catch (error) {
      final problem = locationAccessProblemFor(error);
      throw TravelLocationError(problem == null ? 'lookup' : _codeFor(problem));
    }
  }

  static String _codeFor(LocationAccessProblem problem) => switch (problem) {
    LocationAccessProblem.denied => 'denied',
    LocationAccessProblem.deniedForever => 'deniedForever',
    LocationAccessProblem.servicesDisabled => 'disabled',
  };
}

/// The town of a placemark. Small places often have no locality, so the
/// district or county stands in for it.
String placemarkCity(Placemark p) {
  for (final value in [p.locality, p.subAdministrativeArea, p.subLocality]) {
    final clean = (value ?? '').trim();
    if (clean.isNotEmpty) return clean;
  }
  return '';
}

/// The current city as a place to save. It uses the city centre when that
/// lookup worked; otherwise the device position rounded to about 10 km, so
/// the exact spot is never stored.
@visibleForTesting
PlaceCandidate currentCityCandidate(
  Placemark mark, {
  Location? centre,
  required double latitude,
  required double longitude,
}) {
  double rounded(double value) => (value * 10).roundToDouble() / 10;
  return PlaceCandidate(
    city: placemarkCity(mark),
    region: (mark.administrativeArea ?? '').trim(),
    country: (mark.country ?? '').trim(),
    countryCode: (mark.isoCountryCode ?? '').toUpperCase(),
    latitude: centre?.latitude ?? rounded(latitude),
    longitude: centre?.longitude ?? rounded(longitude),
  );
}
