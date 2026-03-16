import '../../domain/entities/friend_request.dart';
import '../../domain/entities/friend_user.dart';
import '../../domain/entities/friends_section_page.dart';
import 'friend_request_model.dart';
import 'friend_user_model.dart';

class FriendsSectionPageModel extends FriendsSectionPage {
  const FriendsSectionPageModel({
    required super.section,
    required super.friendsCount,
    required super.pendingSentCount,
    required super.pendingReceivedCount,
    required super.friends,
    required super.requests,
    required super.hasMore,
    required super.nextCursor,
    required super.nextOffset,
  });

  factory FriendsSectionPageModel.fromLegacyMap(
    Map<String, dynamic> map, {
    required String section,
  }) {
    final counts = map['counts'] as Map<String, dynamic>? ?? const {};
    final items = map['items'] as List<dynamic>? ?? const <dynamic>[];
    final pagination = map['pagination'] as Map<String, dynamic>? ?? const {};

    final normalizedSection = section.trim().toLowerCase();
    if (normalizedSection == 'friends') {
      return FriendsSectionPageModel(
        section: normalizedSection,
        friendsCount: (counts['friends'] as num?)?.toInt() ?? items.length,
        pendingSentCount: (counts['pending_sent'] as num?)?.toInt() ?? 0,
        pendingReceivedCount:
            (counts['pending_received'] as num?)?.toInt() ?? 0,
        friends: items
            .whereType<Map<String, dynamic>>()
            .map(FriendUserModel.fromLegacyMap)
            .toList(growable: false),
        requests: const <FriendRequest>[],
        hasMore: pagination['has_more'] == true,
        nextCursor: (pagination['next_cursor'] as String?)?.trim().isEmpty ==
                true
            ? null
            : pagination['next_cursor'] as String?,
        nextOffset: (pagination['next_offset'] as num?)?.toInt(),
      );
    }

    final requestUserKey = normalizedSection == 'pending_sent' ? 'to' : 'from';
    return FriendsSectionPageModel(
      section: normalizedSection,
      friendsCount: (counts['friends'] as num?)?.toInt() ?? 0,
      pendingSentCount:
          (counts['pending_sent'] as num?)?.toInt() ??
          (normalizedSection == 'pending_sent' ? items.length : 0),
      pendingReceivedCount:
          (counts['pending_received'] as num?)?.toInt() ??
          (normalizedSection == 'pending_received' ? items.length : 0),
      friends: const <FriendUser>[],
      requests: items
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => FriendRequestModel.fromLegacyMap(
              item,
              userKey: requestUserKey,
            ),
          )
          .toList(growable: false),
      hasMore: pagination['has_more'] == true,
      nextCursor:
          (pagination['next_cursor'] as String?)?.trim().isEmpty == true
          ? null
          : pagination['next_cursor'] as String?,
      nextOffset: (pagination['next_offset'] as num?)?.toInt(),
    );
  }
}
