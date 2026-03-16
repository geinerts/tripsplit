part of 'friends_page.dart';

extension _FriendsPageWidgets on _FriendsPageState {
  Widget _buildFriendsScaffold(BuildContext context) {
    final responsive = context.responsive;
    if (_isLoading && _snapshot == null) {
      return const AppBackground(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final snapshot =
        _snapshot ??
        const FriendsSnapshot(
          friends: <FriendUser>[],
          pendingSent: <FriendRequest>[],
          pendingReceived: <FriendRequest>[],
        );

    return AppBackground(
      child: RefreshIndicator(
        onRefresh: () => _loadSnapshot(showLoader: false),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: responsive.pageMaxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    responsive.pageHorizontalPadding,
                    12,
                    responsive.pageHorizontalPadding,
                    18,
                  ),
                  children: [
                    if (_errorText != null)
                      _InlineErrorCard(
                        message: _errorText!,
                        retryLabel: _txt(en: 'Retry', lv: 'Mēģināt vēlreiz'),
                        onRetry: () => _loadSnapshot(showLoader: false),
                      ),
                    if (_errorText != null) const SizedBox(height: 10),
                    _buildSummaryCard(snapshot),
                    const SizedBox(height: 10),
                    _buildAddFriendCard(snapshot),
                    const SizedBox(height: 10),
                    _buildIncomingCard(snapshot),
                    const SizedBox(height: 10),
                    _buildOutgoingCard(snapshot),
                    const SizedBox(height: 10),
                    _buildFriendsCard(snapshot),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(FriendsSnapshot snapshot) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSummaryMetric(
                title: _txt(en: 'Friends', lv: 'Draugi'),
                value: '${_friendsTotalCount > 0 ? _friendsTotalCount : snapshot.friends.length}',
              ),
            ),
            Container(
              width: 1,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),
            Expanded(
              child: _buildSummaryMetric(
                title: _txt(en: 'Incoming', lv: 'Saņemtie'),
                value:
                    '${_pendingReceivedTotalCount > 0 ? _pendingReceivedTotalCount : snapshot.pendingReceived.length}',
              ),
            ),
            Container(
              width: 1,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),
            Expanded(
              child: _buildSummaryMetric(
                title: _txt(en: 'Sent', lv: 'Nosūtītie'),
                value:
                    '${_pendingSentTotalCount > 0 ? _pendingSentTotalCount : snapshot.pendingSent.length}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }

  Widget _buildAddFriendCard(FriendsSnapshot snapshot) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _txt(en: 'Add friend', lv: 'Pievienot draugu'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: _txt(
                  en: 'Search by nickname...',
                  lv: 'Meklēt pēc segvārda...',
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (_searchController.text.trim().isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                              },
                              icon: const Icon(Icons.close),
                            )
                          : null),
              ),
            ),
            if (_searchController.text.trim().length >= 2) ...[
              const SizedBox(height: 10),
              if (_searchResults.isEmpty && !_isSearching)
                Text(
                  _txt(en: 'No users found.', lv: 'Lietotāji nav atrasti.'),
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                ..._searchResults.map(
                  (user) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _userAvatar(user),
                    title: Text(
                      user.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: OutlinedButton.icon(
                      onPressed: _inviteLoading.contains(user.id)
                          ? null
                          : () => _sendInvite(user),
                      icon: const Icon(Icons.person_add_alt_1, size: 18),
                      label: Text(_txt(en: 'Invite', lv: 'Uzaicināt')),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingCard(FriendsSnapshot snapshot) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _txt(en: 'Incoming requests', lv: 'Saņemtie pieprasījumi'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (snapshot.pendingReceived.isEmpty)
              Text(
                _txt(
                  en: 'No incoming requests.',
                  lv: 'Nav saņemtu pieprasījumu.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ...snapshot.pendingReceived.map((request) {
                final busy = _respondLoading.contains(request.requestId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      _userAvatar(request.user),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          request.user.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => _respondInvite(request, false),
                        child: Text(_txt(en: 'Decline', lv: 'Noraidīt')),
                      ),
                      FilledButton(
                        onPressed: busy
                            ? null
                            : () => _respondInvite(request, true),
                        child: Text(_txt(en: 'Accept', lv: 'Apstiprināt')),
                      ),
                    ],
                  ),
                );
              }),
            if (_pendingReceivedHasMore)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _isLoadingMorePendingReceived
                      ? null
                      : () => unawaited(_loadMorePendingReceived()),
                  icon: _isLoadingMorePendingReceived
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.expand_more),
                  label: Text(_txt(en: 'Load more', lv: 'Ielādēt vēl')),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutgoingCard(FriendsSnapshot snapshot) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _txt(en: 'Sent invites', lv: 'Nosūtītie uzaicinājumi'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (snapshot.pendingSent.isEmpty)
              Text(
                _txt(en: 'No sent invites.', lv: 'Nav nosūtītu uzaicinājumu.'),
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ...snapshot.pendingSent.map((request) {
                final busy = _cancelLoading.contains(request.requestId);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _userAvatar(request.user),
                  title: Text(
                    request.user.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Theme.of(context).colorScheme.tertiaryContainer
                              .withValues(alpha: 0.6),
                        ),
                        child: Text(
                          _txt(en: 'Pending', lv: 'Gaida'),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: busy ? null : () => _cancelInvite(request),
                        child: Text(_txt(en: 'Cancel', lv: 'Atcelt')),
                      ),
                    ],
                  ),
                );
              }),
            if (_pendingSentHasMore)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _isLoadingMorePendingSent
                      ? null
                      : () => unawaited(_loadMorePendingSent()),
                  icon: _isLoadingMorePendingSent
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.expand_more),
                  label: Text(_txt(en: 'Load more', lv: 'Ielādēt vēl')),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsCard(FriendsSnapshot snapshot) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _txt(en: 'My friends', lv: 'Mani draugi'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (snapshot.friends.isEmpty)
              Text(
                _txt(en: 'No friends yet.', lv: 'Draugu vēl nav.'),
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ...snapshot.friends.map(
                (friend) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _userAvatar(friend),
                  title: Text(
                    friend.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: TextButton.icon(
                    onPressed: _removeLoading.contains(friend.id)
                        ? null
                        : () => _removeFriend(friend),
                    icon: const Icon(Icons.person_remove_outlined, size: 18),
                    label: Text(_txt(en: 'Remove', lv: 'Noņemt')),
                  ),
                ),
              ),
            if (_isLoadingMoreFriends)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            if (_friendsHasMore && !_isLoadingMoreFriends)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _txt(
                    en: 'Scroll down to load more friends.',
                    lv: 'Ritini uz leju, lai ielādētu vēl draugus.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _userAvatar(FriendUser user) {
    const size = 36.0;
    final imageCacheSize = (size * MediaQuery.devicePixelRatioOf(context))
        .round();
    final initial = user.nickname.trim().isEmpty
        ? '?'
        : user.nickname.trim().substring(0, 1).toUpperCase();
    final avatarUrl = (user.avatarThumbUrl ?? user.avatarUrl)?.trim();

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          cacheWidth: imageCacheSize,
          cacheHeight: imageCacheSize,
          errorBuilder: (context, error, stackTrace) =>
              CircleAvatar(radius: 18, child: Text(initial)),
        ),
      );
    }

    return CircleAvatar(radius: 18, child: Text(initial));
  }
}
