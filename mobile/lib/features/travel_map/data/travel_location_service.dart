import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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
  String _city(Placemark p) => (p.locality ?? '').trim();
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
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const TravelLocationError('disabled');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const TravelLocationError('deniedForever');
    }
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      throw const TravelLocationError('denied');
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final marks = await _geocoder
          .placemarkFromCoordinates(
            position.latitude,
            position.longitude,
            locale: _locale,
          )
          .timeout(_timeout);
      final valid = marks.where(_valid);
      if (valid.isEmpty) throw const TravelLocationError('lookup');
      final mark = valid.first;
      final candidates = await search(
        [
          _city(mark),
          mark.administrativeArea,
          mark.country,
        ].whereType<String>().join(', '),
      );
      final matching = candidates.where(
        (c) =>
            c.countryCode == (mark.isoCountryCode ?? '').toUpperCase() &&
            c.city.toLowerCase() == _city(mark).toLowerCase(),
      );
      if (matching.isEmpty) throw const TravelLocationError('lookup');
      return matching.first;
    } on TravelLocationError {
      rethrow;
    } catch (_) {
      throw const TravelLocationError('lookup');
    }
  }
}
