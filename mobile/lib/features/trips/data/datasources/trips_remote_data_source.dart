import 'dart:typed_data';

import '../../../../core/network/legacy_trip_image_uploader.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_method.dart';
import '../../domain/entities/trip_invite_join_result.dart';
import '../../domain/entities/trip_invite_link.dart';
import '../../domain/entities/trip_invite_preview.dart';
import '../../domain/entities/uploaded_trip_image.dart';
import '../models/trip_model.dart';
import '../models/trip_user_model.dart';

abstract class TripsRemoteDataSource {
  Future<List<TripModel>> listTrips();
  Future<List<TripUserModel>> listDirectoryUsers({
    String query = '',
    int limit = 20,
    List<int> excludeIds = const <int>[],
  });
  Future<TripModel> createTrip({
    required String name,
    required String currencyCode,
    required List<int> memberIds,
  });
  Future<TripModel> updateTrip({
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

class TripsRemoteDataSourceImpl implements TripsRemoteDataSource {
  TripsRemoteDataSourceImpl(this._apiClient, this._tripImageUploader);

  final ApiClient _apiClient;
  final LegacyTripImageUploader _tripImageUploader;

  @override
  Future<List<TripModel>> listTrips() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('trips'),
      method: HttpMethod.get,
    );

    final list = response['trips'] as List<dynamic>? ?? <dynamic>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map(TripModel.fromLegacyMap)
        .toList(growable: false);
  }

  @override
  Future<List<TripUserModel>> listDirectoryUsers({
    String query = '',
    int limit = 20,
    List<int> excludeIds = const <int>[],
  }) async {
    final normalizedQuery = query.trim();
    final normalizedLimit = limit.clamp(1, 50).toInt();
    final normalizedExclude = excludeIds
        .where((id) => id > 0)
        .toSet()
        .toList(growable: false);

    final queryParams = <String, dynamic>{'limit': normalizedLimit};
    if (normalizedQuery.isNotEmpty) {
      queryParams['q'] = normalizedQuery;
    }
    if (normalizedExclude.isNotEmpty) {
      queryParams['exclude_ids'] = normalizedExclude.join(',');
    }

    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('search_users'),
      method: HttpMethod.get,
      query: queryParams,
    );

    final list = response['users'] as List<dynamic>? ?? <dynamic>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map(TripUserModel.fromLegacyMap)
        .toList(growable: false);
  }

  @override
  Future<TripModel> createTrip({
    required String name,
    required String currencyCode,
    required List<int> memberIds,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('create_trip'),
      method: HttpMethod.post,
      body: <String, dynamic>{
        'name': name,
        'currency_code': currencyCode,
        'member_ids': memberIds,
      },
    );

    final trip = response['trip'] as Map<String, dynamic>?;
    if (trip == null) {
      throw StateError('Missing trip payload in create_trip response.');
    }
    return TripModel.fromLegacyMap(trip);
  }

  @override
  Future<TripModel> updateTrip({
    required int tripId,
    required String name,
    String? imagePath,
    bool removeImage = false,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('update_trip'),
      method: HttpMethod.post,
      body: <String, dynamic>{
        'id': tripId,
        'name': name,
        if (removeImage) 'remove_image': true,
        if (imagePath != null && imagePath.trim().isNotEmpty)
          'image_path': imagePath.trim(),
      },
    );

    final trip = response['trip'] as Map<String, dynamic>?;
    if (trip == null) {
      throw StateError('Missing trip payload in update_trip response.');
    }
    return TripModel.fromLegacyMap(trip);
  }

  @override
  Future<UploadedTripImageData> uploadTripImage({
    required int tripId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final uploaded = await _tripImageUploader.uploadTripImage(
      tripId: tripId,
      fileName: fileName,
      bytes: bytes,
    );
    return UploadedTripImageData(
      path: uploaded.imagePath,
      url: uploaded.imageUrl,
      thumbUrl: uploaded.imageThumbUrl,
    );
  }

  @override
  Future<int> addTripMembers({
    required int tripId,
    required List<int> memberIds,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('add_trip_members'),
      method: HttpMethod.post,
      headers: <String, String>{'X-Trip-Id': '$tripId'},
      body: <String, dynamic>{'member_ids': memberIds},
    );
    return (response['added_count'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> deleteTrip({required int tripId}) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('delete_trip'),
      method: HttpMethod.post,
      body: <String, dynamic>{'id': tripId},
    );
  }

  @override
  Future<TripInviteLink> createTripInviteLink({required int tripId}) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('create_trip_invite'),
      method: HttpMethod.post,
      headers: <String, String>{'X-Trip-Id': '$tripId'},
    );

    final inviteUrl = (response['invite_url'] as String? ?? '').trim();
    final inviteToken = (response['invite_token'] as String? ?? '').trim();
    if (inviteUrl.isEmpty || inviteToken.isEmpty) {
      throw StateError(
        'Missing invite link payload in create_trip_invite response.',
      );
    }
    return TripInviteLink(
      tripId: (response['trip_id'] as num?)?.toInt() ?? tripId,
      inviteUrl: inviteUrl,
      inviteToken: inviteToken,
      expiresAt: (response['expires_at'] as String?)?.trim().isNotEmpty == true
          ? (response['expires_at'] as String).trim()
          : null,
      expiresInSeconds: (response['expires_in_sec'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<TripInviteJoinResult> joinTripInvite({
    required String inviteToken,
    required String previewNonce,
  }) async {
    final normalizedToken = inviteToken.trim();
    final normalizedPreviewNonce = previewNonce.trim();
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('join_trip_invite'),
      method: HttpMethod.post,
      body: <String, dynamic>{
        'invite_token': normalizedToken,
        'preview_nonce': normalizedPreviewNonce,
      },
    );

    final trip = response['trip'] as Map<String, dynamic>?;
    if (trip == null) {
      throw StateError('Missing trip payload in join_trip_invite response.');
    }
    return TripInviteJoinResult(
      trip: TripModel.fromLegacyMap(trip),
      alreadyMember: response['already_member'] == true,
    );
  }

  @override
  Future<TripInvitePreview> previewTripInvite({
    required String inviteToken,
  }) async {
    final normalizedToken = inviteToken.trim();
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('preview_trip_invite'),
      method: HttpMethod.post,
      body: <String, dynamic>{'invite_token': normalizedToken},
    );

    final invite = response['invite'] as Map<String, dynamic>?;
    if (invite == null) {
      throw StateError(
        'Missing invite payload in preview_trip_invite response.',
      );
    }

    final inviter = invite['inviter'] as Map<String, dynamic>? ?? const {};
    final inviterName = (inviter['display_name'] as String? ?? '').trim();
    final previewNonce = (invite['preview_nonce'] as String? ?? '').trim();
    if (previewNonce.isEmpty) {
      throw StateError(
        'Missing preview nonce payload in preview_trip_invite response.',
      );
    }

    return TripInvitePreview(
      inviteToken: (invite['invite_token'] as String? ?? normalizedToken)
          .trim(),
      previewNonce: previewNonce,
      tripId: (invite['trip_id'] as num?)?.toInt() ?? 0,
      tripName: (invite['trip_name'] as String? ?? '').trim(),
      inviterName: inviterName,
      expiresAt: (invite['expires_at'] as String?)?.trim().isNotEmpty == true
          ? (invite['expires_at'] as String).trim()
          : null,
      previewNonceExpiresAt:
          (invite['preview_nonce_expires_at'] as String?)?.trim().isNotEmpty ==
              true
          ? (invite['preview_nonce_expires_at'] as String).trim()
          : null,
      alreadyMember: invite['already_member'] == true,
    );
  }
}
