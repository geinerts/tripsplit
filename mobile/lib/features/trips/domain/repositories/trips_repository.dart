import 'dart:typed_data';

import '../entities/trip.dart';
import '../entities/trip_invite_join_result.dart';
import '../entities/trip_invite_link.dart';
import '../entities/trip_invite_preview.dart';
import '../entities/trip_user.dart';
import '../entities/uploaded_trip_image.dart';

abstract class TripsRepository {
  Future<List<Trip>> listTrips();
  Future<List<TripUser>> listDirectoryUsers({
    String query = '',
    int limit = 20,
    List<int> excludeIds = const <int>[],
  });
  Future<Trip> createTrip({
    required String name,
    required String currencyCode,
    required List<int> memberIds,
  });
  Future<Trip> updateTrip({
    required int tripId,
    required String name,
    String? imagePath,
    bool removeImage = false,
  });
  Future<UploadedTripImageData> uploadTripImage({
    required int tripId,
    required String fileName,
    required Uint8List bytes,
  });
  Future<int> addTripMembers({
    required int tripId,
    required List<int> memberIds,
  });
  Future<void> deleteTrip({required int tripId});
  Future<TripInviteLink> createTripInviteLink({required int tripId});
  Future<TripInvitePreview> previewTripInvite({required String inviteToken});
  Future<TripInviteJoinResult> joinTripInvite({
    required String inviteToken,
    required String previewNonce,
  });
}
