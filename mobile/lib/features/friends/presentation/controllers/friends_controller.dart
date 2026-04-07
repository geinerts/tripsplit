import '../../../trips/presentation/controllers/trips_controller.dart';
import '../../domain/entities/friends_section_page.dart';
import '../../domain/entities/friend_user.dart';
import '../../domain/entities/friends_snapshot.dart';
import '../../domain/usecases/cancel_friend_invite_use_case.dart';
import '../../domain/usecases/load_friends_section_page_use_case.dart';
import '../../domain/usecases/load_friends_snapshot_use_case.dart';
import '../../domain/usecases/remove_friend_use_case.dart';
import '../../domain/usecases/respond_friend_invite_use_case.dart';
import '../../domain/usecases/send_friend_invite_use_case.dart';

class FriendsController {
  FriendsController(
    this._loadSnapshotUseCase,
    this._loadSectionPageUseCase,
    this._sendInviteUseCase,
    this._respondInviteUseCase,
    this._cancelInviteUseCase,
    this._removeFriendUseCase,
    this._tripsController,
  );

  final LoadFriendsSnapshotUseCase _loadSnapshotUseCase;
  final LoadFriendsSectionPageUseCase _loadSectionPageUseCase;
  final SendFriendInviteUseCase _sendInviteUseCase;
  final RespondFriendInviteUseCase _respondInviteUseCase;
  final CancelFriendInviteUseCase _cancelInviteUseCase;
  final RemoveFriendUseCase _removeFriendUseCase;
  final TripsController _tripsController;
  FriendsSnapshot? _cachedSnapshot;
  DateTime? _cachedSnapshotAt;
  static const Duration _cacheTtl = Duration(minutes: 2);

  FriendsSnapshot? peekSnapshotCache({bool allowStale = true}) {
    final cached = _cachedSnapshot;
    if (cached == null) {
      return null;
    }
    if (!allowStale) {
      final at = _cachedSnapshotAt;
      if (at == null || DateTime.now().difference(at) > _cacheTtl) {
        return null;
      }
    }
    return cached;
  }

  Future<FriendsSnapshot> loadSnapshot({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = peekSnapshotCache(allowStale: false);
      if (cached != null) {
        return cached;
      }
    }
    final snapshot = await _loadSnapshotUseCase.call();
    _cachedSnapshot = snapshot;
    _cachedSnapshotAt = DateTime.now();
    return snapshot;
  }

  Future<FriendsSectionPage> loadSectionPage({
    required String section,
    int limit = 25,
    String? cursor,
    int? offset,
  }) {
    return _loadSectionPageUseCase.call(
      section: section,
      limit: limit,
      cursor: cursor,
      offset: offset,
    );
  }

  Future<void> sendInvite({required int userId}) {
    return _sendInviteUseCase.call(userId: userId);
  }

  Future<void> respondInvite({required int requestId, required bool accept}) {
    return _respondInviteUseCase.call(requestId: requestId, accept: accept);
  }

  Future<void> cancelInvite({required int requestId}) {
    return _cancelInviteUseCase.call(requestId: requestId);
  }

  Future<void> removeFriend({required int userId}) {
    return _removeFriendUseCase.call(userId: userId);
  }

  Future<List<FriendUser>> searchUsers({
    required String query,
    int limit = 20,
    List<int> excludeIds = const <int>[],
  }) async {
    final users = await _tripsController.loadDirectoryUsers(
      query: query,
      limit: limit,
      excludeIds: excludeIds,
    );
    return users
        .map(
          (user) => FriendUser(
            id: user.id,
            nickname: user.nickname,
            displayName: null,
            avatarUrl: user.avatarUrl,
            avatarThumbUrl: user.avatarThumbUrl,
          ),
        )
        .toList(growable: false);
  }

  void clearSnapshotCache() {
    _cachedSnapshot = null;
    _cachedSnapshotAt = null;
  }
}
