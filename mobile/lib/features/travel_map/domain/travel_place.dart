import 'dart:typed_data';
import 'package:latlong2/latlong.dart';

class VisitDetails {
  const VisitDetails({
    this.id,
    this.tripId,
    this.title = '',
    this.photo,
    this.removePhoto = false,
  });
  final int? id, tripId;
  final String title;
  final Uint8List? photo;
  final bool removePhoto;
}

class PlaceCandidate {
  const PlaceCandidate({
    required this.city,
    required this.region,
    required this.country,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });
  final String city, region, country, countryCode;
  final double latitude, longitude;
  LatLng get point => LatLng(latitude, longitude);
  factory PlaceCandidate.fromJson(Map<String, dynamic> json) => PlaceCandidate(
    city: json['city'] as String,
    region: json['region'] as String? ?? '',
    country: json['country'] as String,
    countryCode: json['country_code'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );
  String get subtitle =>
      [if (region.isNotEmpty && region != city) region, country].join(', ');
  Map<String, dynamic> toJson() => {
    'city': city,
    'region': region,
    'country': country,
    'country_code': countryCode,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class TravelPlace extends PlaceCandidate {
  const TravelPlace({
    required this.id,
    required this.placeKey,
    required this.visitedOn,
    this.tripId,
    this.tripName,
    this.title = '',
    this.hasPhoto = false,
    this.photoVersion = 0,
    this.photoSource,
    required super.city,
    required super.region,
    required super.country,
    required super.countryCode,
    required super.latitude,
    required super.longitude,
  });
  final int id;
  final int? tripId;
  final String? tripName, photoSource;
  final String title;
  final bool hasPhoto;
  final int photoVersion;
  final String placeKey, visitedOn;
  factory TravelPlace.fromJson(Map<String, dynamic> json) => TravelPlace(
    id: (json['id'] as num).toInt(),
    placeKey: json['place_key'] as String,
    visitedOn: json['visited_on'] as String,
    tripId: (json['trip_id'] as num?)?.toInt(),
    tripName: json['trip_name'] as String?,
    title: json['title'] as String? ?? '',
    hasPhoto: json['has_photo'] == true,
    photoVersion: (json['photo_version'] as num?)?.toInt() ?? 0,
    photoSource: json['photo_source'] as String?,
    city: json['city'] as String,
    region: json['region'] as String? ?? '',
    country: json['country'] as String,
    countryCode: json['country_code'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );
  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'id': id,
    'place_key': placeKey,
    'visited_on': visitedOn,
    'trip_id': tripId,
    'trip_name': tripName,
    'title': title,
    'has_photo': hasPhoto,
    'photo_version': photoVersion,
    'photo_source': photoSource,
  };
}
