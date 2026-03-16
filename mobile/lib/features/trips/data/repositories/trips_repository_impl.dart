import 'dart:typed_data';

import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_user.dart';
import '../../domain/entities/uploaded_trip_image.dart';
import '../../domain/repositories/trips_repository.dart';
import '../datasources/trips_remote_data_source.dart';

class TripsRepositoryImpl implements TripsRepository {
  TripsRepositoryImpl(this._remote);

  final TripsRemoteDataSource _remote;

  @override
  Future<List<Trip>> listTrips() {
    return _remote.listTrips();
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
    required List<int> memberIds,
  }) {
    return _remote.createTrip(name: name, memberIds: memberIds);
  }

  @override
  Future<Trip> updateTrip({
    required int tripId,
    required String name,
    String? imagePath,
  }) {
    return _remote.updateTrip(tripId: tripId, name: name, imagePath: imagePath);
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
}
