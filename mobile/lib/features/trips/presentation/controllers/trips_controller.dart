import 'dart:async';
import 'dart:typed_data';

import '../../../../core/errors/api_exception.dart';
import '../../data/local/trips_local_store.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_invite_join_result.dart';
import '../../domain/entities/trip_invite_link.dart';
import '../../domain/entities/trip_invite_preview.dart';
import '../../domain/entities/trip_user.dart';
import '../../domain/entities/uploaded_trip_image.dart';
import '../../domain/usecases/add_trip_members_use_case.dart';
import '../../domain/usecases/delete_trip_use_case.dart';
import '../../domain/usecases/create_trip_use_case.dart';
import '../../domain/usecases/create_trip_invite_link_use_case.dart';
import '../../domain/usecases/list_directory_users_use_case.dart';
import '../../domain/usecases/join_trip_invite_use_case.dart';
import '../../domain/usecases/list_trips_use_case.dart';
import '../../domain/usecases/preview_trip_invite_use_case.dart';
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
    this._previewTripInviteUseCase,
    this._joinTripInviteUseCase,
    this._updateTripUseCase,
    this._uploadTripImageUseCase,
    this._localStore,
  );

  final ListTripsUseCase _listTripsUseCase;
  final ListDirectoryUsersUseCase _listDirectoryUsersUseCase;
  final CreateTripUseCase _createTripUseCase;
  final AddTripMembersUseCase _addTripMembersUseCase;
  final DeleteTripUseCase _deleteTripUseCase;
  final CreateTripInviteLinkUseCase _createTripInviteLinkUseCase;
  final PreviewTripInviteUseCase _previewTripInviteUseCase;
  final JoinTripInviteUseCase _joinTripInviteUseCase;
  final UpdateTripUseCase _updateTripUseCase;
  final UploadTripImageUseCase _uploadTripImageUseCase;
  final TripsLocalStore _localStore;
  List<Trip> _cachedTrips = const <Trip>[];
  DateTime? _cachedTripsAt;
  bool _diskCachePrimed = false;
  Future<void>? _primeDiskCacheInFlight;
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
      await _primeCacheFromDisk();
      final cached = peekTripsCache(allowStale: false);
      if (cached != null) {
        return cached;
      }
    }

    try {
      final trips = await _listTripsUseCase.call();
      await _setCachedTrips(trips, persist: true);
      return _cachedTrips;
    } on ApiException catch (error) {
      if (!error.isNetworkError) {
        rethrow;
      }
      await _primeCacheFromDisk();
      final cached = peekTripsCache(allowStale: true);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<List<Trip>?> primeTripsCacheFromDisk() async {
    await _primeCacheFromDisk();
    return peekTripsCache(allowStale: true);
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
    required String currencyCode,
    required List<int> memberIds,
  }) {
    return _createTripUseCase.call(
      name: name,
      currencyCode: currencyCode,
      memberIds: memberIds,
    );
  }

  Future<Trip> updateTrip({
    required int tripId,
    required String name,
    String? imagePath,
    bool removeImage = false,
  }) {
    return _updateTripUseCase.call(
      tripId: tripId,
      name: name,
      imagePath: imagePath,
      removeImage: removeImage,
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

  Future<TripInvitePreview> previewTripInvite({required String inviteToken}) {
    return _previewTripInviteUseCase.call(inviteToken: inviteToken);
  }

  Future<TripInviteJoinResult> joinTripInvite({
    required String inviteToken,
    required String previewNonce,
  }) {
    return _joinTripInviteUseCase.call(
      inviteToken: inviteToken,
      previewNonce: previewNonce,
    );
  }

  void clearTripsCache() {
    _cachedTrips = const <Trip>[];
    _cachedTripsAt = null;
    _diskCachePrimed = true;
    _primeDiskCacheInFlight = null;
    unawaited(_localStore.clear());
  }

  Future<void> _setCachedTrips(
    List<Trip> trips, {
    required bool persist,
  }) async {
    _cachedTrips = List<Trip>.unmodifiable(trips);
    _cachedTripsAt = DateTime.now();
    _diskCachePrimed = true;
    if (persist) {
      await _localStore.writeTrips(_cachedTrips);
    }
  }

  Future<void> _primeCacheFromDisk() async {
    if (_diskCachePrimed) {
      return;
    }
    final inFlight = _primeDiskCacheInFlight;
    if (inFlight != null) {
      await inFlight;
      return;
    }
    final next = () async {
      try {
        final persisted = await _localStore.readTrips();
        if (persisted.isNotEmpty) {
          await _setCachedTrips(persisted, persist: false);
        }
      } finally {
        _diskCachePrimed = true;
      }
    }();
    _primeDiskCacheInFlight = next;
    await next;
    _primeDiskCacheInFlight = null;
  }
}
