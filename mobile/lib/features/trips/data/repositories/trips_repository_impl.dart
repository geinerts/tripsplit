import 'dart:typed_data';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_invite_join_result.dart';
import '../../domain/entities/trip_invite_link.dart';
import '../../domain/entities/trip_invite_preview.dart';
import '../../domain/entities/trip_user.dart';
import '../../domain/entities/uploaded_trip_image.dart';
import '../../domain/repositories/trips_repository.dart';
import '../datasources/trips_remote_data_source.dart';
import '../local/trips_local_store.dart';

class TripsRepositoryImpl implements TripsRepository {
  TripsRepositoryImpl(this._remote, this._localStore);

  final TripsRemoteDataSource _remote;
  final TripsLocalStore _localStore;

  @override
  Future<List<Trip>> listTrips() async {
    try {
      final trips = await _remote.listTrips();
      await _localStore.writeTrips(trips);
      return trips;
    } on ApiException catch (error) {
      if (!error.isNetworkError) {
        rethrow;
      }
      final cached = await _localStore.readTrips();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<List<TripUser>> listDirectoryUsers({
    String query = '',
    int limit = 20,
    List<int> excludeIds = const <int>[],
  }) {
    return _remote.listDirectoryUsers(
      query: query,
      limit: limit,
      excludeIds: excludeIds,
    );
  }

  @override
  Future<Trip> createTrip({
    required String name,
    required String currencyCode,
    required List<int> memberIds,
    String? dateFrom,
    String? dateTo,
  }) {
    return _remote.createTrip(
      name: name,
      currencyCode: currencyCode,
      memberIds: memberIds,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  @override
  Future<Trip> updateTrip({
    required int tripId,
    required String name,
    String? imagePath,
    bool removeImage = false,
  }) {
    return _remote.updateTrip(
      tripId: tripId,
      name: name,
      imagePath: imagePath,
      removeImage: removeImage,
    );
  }

  @override
  Future<UploadedTripImageData> uploadTripImage({
    required int tripId,
    required String fileName,
    required Uint8List bytes,
  }) {
    return _remote.uploadTripImage(
      tripId: tripId,
      fileName: fileName,
      bytes: bytes,
    );
  }

  @override
  Future<int> addTripMembers({
    required int tripId,
    required List<int> memberIds,
  }) {
    return _remote.addTripMembers(tripId: tripId, memberIds: memberIds);
  }

  @override
  Future<void> removeTripMember({
    required int tripId,
    required int userId,
  }) async {
    await _remote.removeTripMember(tripId: tripId, userId: userId);
  }

  @override
  Future<void> leaveTrip({required int tripId}) async {
    await _remote.leaveTrip(tripId: tripId);
    if (tripId <= 0) {
      return;
    }
    final cached = await _localStore.readTrips();
    if (cached.isEmpty) {
      return;
    }
    final next = cached
        .where((trip) => trip.id != tripId)
        .toList(growable: false);
    await _localStore.writeTrips(next);
  }

  @override
  Future<void> deleteTrip({required int tripId}) async {
    await _remote.deleteTrip(tripId: tripId);
    if (tripId <= 0) {
      return;
    }
    final cached = await _localStore.readTrips();
    if (cached.isEmpty) {
      return;
    }
    final next = cached
        .where((trip) => trip.id != tripId)
        .toList(growable: false);
    await _localStore.writeTrips(next);
  }

  @override
  Future<TripInviteLink> createTripInviteLink({required int tripId}) {
    return _remote.createTripInviteLink(tripId: tripId);
  }

  @override
  Future<TripInviteJoinResult> joinTripInvite({
    required String inviteToken,
    required String previewNonce,
  }) {
    return _remote.joinTripInvite(
      inviteToken: inviteToken,
      previewNonce: previewNonce,
    );
  }

  @override
  Future<TripInvitePreview> previewTripInvite({required String inviteToken}) {
    return _remote.previewTripInvite(inviteToken: inviteToken);
  }
}
