import 'dart:convert';
import 'dart:typed_data';
import '../../../core/auth/account_data_session.dart';
import '../../../core/auth/account_local_storage.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/http_method.dart';
import '../domain/travel_place.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import '../../../core/media/app_image_cropper.dart';
import '../../../core/media/image_crop_service.dart';
import '../../../core/network/legacy_image_source_uploader.dart';

class TravelPlacesResult {
  const TravelPlacesResult(this.places, {this.offline = false});
  final List<TravelPlace> places;
  final bool offline;
}

abstract interface class TravelPlacesRepository {
  AccountDataLease capture();
  Future<TravelPlacesResult> load();
  Future<TravelPlace> save(
    PlaceCandidate place,
    String date, {
    VisitDetails details = const VisitDetails(),
  });
  Future<Uint8List?> photo(TravelPlace place);

  /// Opens the crop editor for a saved visit photo. Returns null when cancelled.
  Future<TravelPlace?> editPhotoCrop(
    BuildContext context,
    TravelPlace place, {
    required String title,
  });
  Future<void> delete(int id);
}

class ApiTravelPlacesRepository implements TravelPlacesRepository {
  ApiTravelPlacesRepository(
    this.api,
    this.storage, {
    this.cropService,
    this.sourceUploader,
  });
  final ApiClient api;
  final AccountLocalStorage storage;
  final ImageCropService? cropService;
  final LegacyTravelPhotoSourceUploader? sourceUploader;
  static const cacheKey = 'travel_places_v1';
  @override
  AccountDataLease capture() => storage.session.capture();
  Future<List<TravelPlace>?> _cached() async {
    final raw = await storage.read(cacheKey);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map(
            (item) =>
                TravelPlace.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _cache(List<TravelPlace> places) => storage.write(
    cacheKey,
    jsonEncode(places.map((p) => p.toJson()).toList()),
  );
  @override
  Future<TravelPlacesResult> load() => storage.session.run(() async {
    try {
      final result = await api.request(
        path: ApiEndpoints.legacyAction('list_travel_places'),
        method: HttpMethod.get,
      );
      final places = (result['places'] as List)
          .map((p) => TravelPlace.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList();
      await _cache(places);
      return TravelPlacesResult(places);
    } on ApiException catch (error) {
      if (!error.isNetworkError) rethrow;
      final cached = await _cached();
      if (cached == null) rethrow;
      return TravelPlacesResult(cached, offline: true);
    }
  });
  @override
  Future<TravelPlace> save(
    PlaceCandidate place,
    String date, {
    VisitDetails details = const VisitDetails(),
  }) => storage.session.run(() async {
    final result = await api.request(
      path: ApiEndpoints.legacyAction('save_travel_place'),
      method: HttpMethod.post,
      body: {
        'city': place.city,
        'region': place.region,
        'country': place.country,
        'country_code': place.countryCode,
        'latitude': place.latitude,
        'longitude': place.longitude,
        'visited_on': date,
        if (details.id != null) 'id': details.id,
        if (details.tripId != null) 'trip_id': details.tripId,
        'title': details.title,
        if (details.photo != null) 'photo_base64': base64Encode(details.photo!),
        if (details.removePhoto) 'remove_photo': true,
      },
    );
    final saved = TravelPlace.fromJson(
      Map<String, dynamic>.from(result['place'] as Map),
    );
    if (!saved.hasPhoto || details.photo != null || details.removePhoto) {
      await storage.update('travel_photo_${saved.id}', (_) => null);
    }
    final existing = await _cached() ?? [];
    await _cache([saved, ...existing.where((p) => p.id != saved.id)]);
    final source = details.photoSource;
    if (source != null && saved.hasPhoto) {
      // The visit and its photo are saved. Without the original, only zooming is lost.
      try {
        await sourceUploader?.upload(placeId: saved.id, source: source);
      } catch (_) {}
    }
    return saved;
  });
  @override
  Future<TravelPlace?> editPhotoCrop(
    BuildContext context,
    TravelPlace place, {
    required String title,
  }) async {
    final response = await cropService?.edit(
      context,
      kind: ImageCropKind.travel,
      title: title,
      aspectRatio: AppImageCropper.tripAspectRatio,
      placeId: place.id,
    );
    if (response == null) return null;
    return storage.session.run(() async {
      final saved = TravelPlace.fromJson(
        (response['place'] as Map).cast<String, dynamic>(),
      );
      await storage.update('travel_photo_${saved.id}', (_) => null);
      final existing = await _cached() ?? const <TravelPlace>[];
      await _cache([saved, ...existing.where((p) => p.id != saved.id)]);
      return saved;
    });
  }

  @override
  Future<Uint8List?> photo(TravelPlace place) => storage.session.run(() async {
    if (!place.hasPhoto) return null;
    final key = 'travel_photo_${place.id}';
    final cached = await storage.read(key);
    if (cached != null) {
      try {
        final data = jsonDecode(cached) as Map;
        if (data['version'] == place.photoVersion) {
          return base64Decode(data['bytes'] as String);
        }
      } on FormatException {
        await storage.update(key, (_) => null);
      } on TypeError {
        await storage.update(key, (_) => null);
      }
    }
    final response = await api.request(
      path: ApiEndpoints.legacyAction('travel_place_photo'),
      method: HttpMethod.get,
      query: {'id': place.id},
    );
    final raw = response['photo_base64'] as String?;
    if (raw == null) return null;
    await storage.write(
      key,
      jsonEncode({'version': place.photoVersion, 'bytes': raw}),
    );
    return base64Decode(raw);
  });
  @override
  Future<void> delete(int id) => storage.session.run(() async {
    await api.request(
      path: ApiEndpoints.legacyAction('delete_travel_place'),
      method: HttpMethod.post,
      body: {'id': id},
    );
    await storage.update('travel_photo_$id', (_) => null);
    final existing = await _cached() ?? [];
    await _cache(existing.where((p) => p.id != id).toList());
  });
}
