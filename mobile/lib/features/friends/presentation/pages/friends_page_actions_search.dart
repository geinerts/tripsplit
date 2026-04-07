part of 'friends_page.dart';

extension _FriendsPageActionsSearch on _FriendsPageState {
  List<int> _searchExcludeIds(FriendsSnapshot snapshot) {
    final ids = <int>{};
    for (final friend in snapshot.friends) {
      ids.add(friend.id);
    }
    for (final req in snapshot.pendingSent) {
      ids.add(req.user.id);
    }
    for (final req in snapshot.pendingReceived) {
      ids.add(req.user.id);
    }
    return ids.toList(growable: false);
  }
}
