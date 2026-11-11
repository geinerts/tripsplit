part of 'friend_search_page.dart';

extension _FriendSearchPageWidgets on _FriendSearchPageState {
  Widget _buildSearchPage(BuildContext context) {
    final friendMatches = _friendMatches;
    final friendIds = {for (final friend in friendMatches) friend.id};
    return AppPageScaffold(
      appBar: AppBar(title: Text(context.l10n.friendsSearchUsers)),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.responsive.pageMaxWidth,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: TextField(
                  key: const ValueKey('friends-search'),
                  controller: _textController,
                  autofocus: true,
                  enabled: !_denied,
                  textInputAction: TextInputAction.search,
                  onChanged: _changeQuery,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    hintText: context.l10n.friendsSearchByNameOrEmail,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: context.l10n.workspaceClearSearch,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _textController.clear();
                              _changeQuery('');
                            },
                          ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  key: const ValueKey('friends-search-results'),
                  controller: _scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    if (_loading) const LinearProgressIndicator(),
                    // Friends come first, before anyone the server finds.
                    for (final friend in friendMatches)
                      _buildSearchFriendRow(friend),
                    if (!_loading) ...[
                      if (_query.length < 2 && !_denied)
                        Text(
                          context.l10n.friendsTypeAtLeast2CharactersToSearch,
                        ),
                      if (_query.length >= 2 &&
                          _results.isEmpty &&
                          friendMatches.isEmpty &&
                          _error == null &&
                          !_denied)
                        Text(context.l10n.friendsNoUsersFound),
                      for (final user in _results)
                        if (!friendIds.contains(user.id))
                          _buildSearchUserRow(user),
                      if (_error != null) ...[
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        if (!_denied)
                          TextButton(
                            onPressed: () => _search(more: _results.isNotEmpty),
                            child: Text(context.l10n.retryAction),
                          ),
                      ],
                      if (_hasMore && _error == null)
                        TextButton.icon(
                          key: const ValueKey('friends-search-show-more'),
                          onPressed: _loadingMore
                              ? null
                              : () => _search(more: true),
                          icon: _loadingMore
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.expand_more_rounded),
                          label: Text(context.l10n.friendsShowMore),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFriendRow(FriendUser friend) {
    final open = widget.onOpenFriend;
    return Column(
      key: ValueKey('friend-search-friend-${friend.id}'),
      children: [
        Semantics(
          button: open != null,
          label:
              '${friend.preferredName}, ${context.l10n.friendRelationshipLabel}',
          excludeSemantics: true,
          child: InkWell(
            onTap: open == null
                ? null
                : () => unawaited(_openFriend(open, friend)),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  MediaQuery.withClampedTextScaling(
                    maxScaleFactor: 1,
                    child: FriendAvatar(user: friend, size: 40),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      friend.preferredName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  UserProfileBadge(context.l10n.friendRelationshipLabel),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSearchUserRow(FriendUser user) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      key: ValueKey('friend-search-user-${user.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              ExcludeSemantics(
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1,
                  child: FriendAvatar(user: user, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user.preferredName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 12),
              if (MediaQuery.textScalerOf(context).scale(14) > 21)
                IconButton.filled(
                  tooltip: context.l10n.friendsInviteAction,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: _sending.contains(user.id)
                      ? null
                      : () => unawaited(_sendInvite(user)),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 20),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * .42,
                  ),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      textStyle: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(fontSize: 14),
                      tapTargetSize: MaterialTapTargetSize.padded,
                      visualDensity: VisualDensity.standard,
                    ),
                    onPressed: _sending.contains(user.id)
                        ? null
                        : () => unawaited(_sendInvite(user)),
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                    label: Text(
                      context.l10n.friendsInviteAction,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(),
      ],
    ),
  );
}
