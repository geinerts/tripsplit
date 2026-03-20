import 'dart:typed_data';

import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_invite_link.dart';
import '../../domain/entities/trip_user.dart';
import '../../domain/entities/uploaded_trip_image.dart';
import '../../domain/usecases/add_trip_members_use_case.dart';
import '../../domain/usecases/delete_trip_use_case.dart';
import '../../domain/usecases/create_trip_use_case.dart';
import '../../domain/usecases/create_trip_invite_link_use_case.dart';
import '../../domain/usecases/list_directory_users_use_case.dart';
import '../../domain/usecases/list_trips_use_case.dart';
import '../../domain/usecases/update_trip_use_case.dart';
import '../../domain/usecases/upload_trip_image_use_case.dart';

class TripsController {
  TripsController(
    this._listTripsUseCase,
    this._listDirectoryUsersUseCase,
    this._createTripUseCase,
    this._addTripMembersUseCase,
    this._deleteTripUseCase,
    this._createTripInviteLinkUseCase,
    this._updateTripUseCase,
    this._uploadTripImageUseCase,
  );

  final ListTripsUseCase _listTripsUseCase;
  final ListDirectoryUsersUseCase _listDirectoryUsersUseCase;
  final CreateTripUseCase _createTripUseCase;
  final AddTripMembersUseCase _addTripMembersUseCase;
  final DeleteTripUseCase _deleteTripUseCase;
  final CreateTripInviteLinkUseCase _createTripInviteLinkUseCase;
  final UpdateTripUseCase _updateTripUseCase;
  final UploadTripImageUseCase _uploadTripImageUseCase;
  List<Trip> _cachedTrips = const <Trip>[];
  DateTime? _cachedTripsAt;
  static const Duration _cacheTtl = Duration(minutes: 2);

  List<Trip>? peekTripsCache({bool allowStale = true}) {
    if (_cachedTrips.isEmpty) {
      return null;
    }
    if (!allowStale) {
      final at = _cachedTripsAt;
      if (at == null || DateTime.now().difference(at) > _cacheTtl) {
        return null;
      }
    }
    return List<Trip>.unmodifiable(_cachedTrips);
  }

  Future<List<Trip>> loadTrips({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = peekTripsCache(allowStale: false);
      if (cached != null) {
        return cached;
      }
    }

    final trips = await _listTripsUseCase.call();
    _cachedTrips = List<Trip>.unmodifiable(trips);
    _cachedTripsAt = DateTime.now();
    return _cachedTrips;
  }

  Future<List<TripUser>> loadDirectoryUsers({
    String query = '',
    int limit = 20,
    List<int> excludeIds = const <int>[],
  }) {
    return _listDirectoryUsersUseCase.call(
      query: query,
      limit: limit,
      excludeIds: excludeIds,
    );
  }

  Future<Trip> createTrip({
    required String name,
    required List<int> memberIds,
  }) {
    return _createTripUseCase.call(name: name, memberIds: memberIds);
  }

  Future<Trip> updateTrip({
    required int tripId,
    required String name,
    String? imagePath,
  }) {
    return _updateTripUseCase.call(
      tripId: tripId,
      name: name,
      imagePath: imagePath,
    );
  }

  Future<UploadedTripImageData> uploadTripImage({
    required int tripId,
    required String fileName,
    required Uint8List bytes,
  }) {
    return _uploadTripImageUseCase.call(
      tripId: tripId,
      fileName: fileName,
      bytes: bytes,
    );
  }

  Future<int> addMembers({required int tripId, required List<int> memberIds}) {
    return _addTripMembersUseCase.call(tripId: tripId, memberIds: memberIds);
  }

  Future<void> deleteTrip({required int tripId}) async {
    await _deleteTripUseCase.call(tripId: tripId);
    clearTripsCache();
  }

  Future<TripInviteLink> createTripInviteLink({required int tripId}) {
    return _createTripInviteLinkUseCase.call(tripId: tripId);
  }

  void clearTripsCache() {
    _cachedTrips = const <Trip>[];
    _cachedTripsAt = null;
  }
}
