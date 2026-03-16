import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_method.dart';
import '../models/friends_section_page_model.dart';
import '../models/friends_snapshot_model.dart';

abstract class FriendsRemoteDataSource {
  Future<FriendsSnapshotModel> loadFriends();
  Future<FriendsSectionPageModel> loadSectionPage({
    required String section,
    int limit,
    String? cursor,
    int? offset,
  });

  Future<void> sendInvite({required int userId});

  Future<void> respondInvite({required int requestId, required bool accept});

  Future<void> cancelInvite({required int requestId});

  Future<void> removeFriend({required int userId});
}

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  FriendsRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<FriendsSnapshotModel> loadFriends() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('friends_list'),
      method: HttpMethod.get,
    );
    return FriendsSnapshotModel.fromLegacyMap(response);
  }

  @override
  Future<FriendsSectionPageModel> loadSectionPage({
    required String section,
    int limit = 25,
    String? cursor,
    int? offset,
  }) async {
    final normalizedSection = section.trim().toLowerCase();
    final normalizedLimit = limit.clamp(1, 100);
    final queryParts = <String>[
      'section=${Uri.encodeQueryComponent(normalizedSection)}',
      'limit=$normalizedLimit',
    ];
    if (cursor != null && cursor.trim().isNotEmpty) {
      queryParts.add('cursor=${Uri.encodeQueryComponent(cursor.trim())}');
    } else if (offset != null && offset > 0) {
      queryParts.add('offset=$offset');
    }

    final response = await _apiClient.request(
      path: '${ApiEndpoints.legacyAction('friends_list')}&${queryParts.join('&')}',
      method: HttpMethod.get,
    );
    return FriendsSectionPageModel.fromLegacyMap(
      response,
      section: normalizedSection,
    );
  }

  @override
  Future<void> sendInvite({required int userId}) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('send_friend_invite'),
      method: HttpMethod.post,
      body: <String, dynamic>{'user_id': userId},
    );
  }

  @override
  Future<void> respondInvite({
    required int requestId,
    required bool accept,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('respond_friend_invite'),
      method: HttpMethod.post,
      body: <String, dynamic>{
        'request_id': requestId,
        'accept': accept,
      },
    );
  }

  @override
  Future<void> cancelInvite({required int requestId}) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('cancel_friend_invite'),
      method: HttpMethod.post,
      body: <String, dynamic>{'request_id': requestId},
    );
  }

  @override
  Future<void> removeFriend({required int userId}) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('remove_friend'),
      method: HttpMethod.post,
      body: <String, dynamic>{'user_id': userId},
    );
  }
}
