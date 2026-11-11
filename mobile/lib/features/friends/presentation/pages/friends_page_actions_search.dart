part of 'friends_page.dart';

extension _FriendsPageActionsSearch on _FriendsPageState {
  Future<void> _openFriendSearch() async {
    if (_searchPageOpen) return;
    _searchPageOpen = true;
    final accountId = widget.authController.currentUser?.id;
    try {
      await Navigator.of(context).push<void>(
        AppPageRoute<void>(
          builder: (_) => FriendSearchPage(
            controller: widget.controller,
            accountIsCurrent: () =>
                mounted &&
                accountId != null &&
                widget.authController.currentUser?.id == accountId,
            excludeIds: () {
              final snapshot = _snapshot;
              return {
                ?accountId,
                ...?snapshot?.friends.map((user) => user.id),
                ...?snapshot?.pendingSent.map((request) => request.user.id),
                ...?snapshot?.pendingReceived.map((request) => request.user.id),
              };
            },
            friends: () => _snapshot?.friends ?? const <FriendUser>[],
            onOpenFriend: (friend) async {
              if (mounted &&
                  widget.authController.currentUser?.id == accountId) {
                await _openFriendProfile(friend);
              }
            },
            onInvited: () async {
              if (mounted &&
                  widget.authController.currentUser?.id == accountId) {
                await _loadSnapshot(showLoader: false);
              }
            },
          ),
        ),
      );
    } finally {
      _searchPageOpen = false;
    }
  }
}
