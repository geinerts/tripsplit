part of 'friends_page.dart';

enum _FriendRequestFeedType { incoming, outgoing }

extension _FriendsPageWidgets on _FriendsPageState {
  Widget _buildFriendsScaffold(BuildContext context) {
    final snapshot = _snapshot;
    return AppBackground(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.responsive.pageMaxWidth,
          ),
          child: RefreshIndicator(
            onRefresh: () => _loadSnapshot(showLoader: false),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  sliver: SliverList.list(
                    children: [
                      if (_isLoading && snapshot == null)
                        Semantics(
                          label: context.l10n.friendsLoading,
                          child: const Column(
                            children: [
                              AppSkeletonBlock(height: 50),
                              SizedBox(height: 24),
                              AppSkeletonBlock(height: 64),
                              SizedBox(height: 16),
                              AppSkeletonBlock(height: 64),
                              SizedBox(height: 16),
                              AppSkeletonBlock(height: 64),
                            ],
                          ),
                        ),
                      if (_isLoading && snapshot != null)
                        const LinearProgressIndicator(),
                      if (_errorText != null) ...[
                        _InlineErrorCard(
                          message: _errorText!,
                          retryLabel: context.l10n.retryAction,
                          onRetry: () => _loadSnapshot(showLoader: false),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (snapshot != null) ...[
                        const SizedBox(height: 8),
                        _buildListSwitch(snapshot),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: _qrAction(
                                  Icons.qr_code_2,
                                  context.l10n.friendsMyQr,
                                  _openMyFriendQr,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: AppDesign.cardStroke(context),
                              ),
                              Expanded(
                                child: _qrAction(
                                  Icons.qr_code_scanner,
                                  context.l10n.friendsScanQr,
                                  _openScanFriendQr,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_showRequests) ...[
                          _buildSectionHeadingRow(
                            title: context.l10n.friendsRequests,
                            trailing: Text(
                              '${_sectionCountRequests(snapshot)}',
                            ),
                          ),
                          if (_sectionCountRequests(snapshot) == 0)
                            Padding(
                              key: const ValueKey('friends-requests-empty'),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                context.l10n.friendsNoPendingActivity,
                                style: TextStyle(
                                  color: AppDesign.mutedColor(context),
                                ),
                              ),
                            )
                          else
                            _buildFriendRequestsFeed(snapshot),
                        ] else ...[
                          _buildSectionHeadingRow(
                            title: context.l10n.navFriends,
                            trailing: Text('${_sectionCountFriends(snapshot)}'),
                          ),
                          if (snapshot.friends.isEmpty)
                            _buildFriendsEmpty(snapshot),
                        ],
                      ],
                    ],
                  ),
                ),
                if (snapshot != null &&
                    !_showRequests &&
                    snapshot.friends.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemCount: snapshot.friends.length,
                      itemBuilder: (_, index) =>
                          _buildFriendListRow(snapshot.friends[index]),
                    ),
                  ),
                if (snapshot != null && !_showRequests && _friendsHasMore)
                  SliverToBoxAdapter(
                    child: _buildLoadMoreTextButton(
                      loading: _isLoadingMoreFriends,
                      onPressed: () => unawaited(_loadMoreFriends()),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Friends / Requests switch: icons only, like the trip form's
  /// With others / Just me switch; names are in tooltips and semantics.
  Widget _buildListSwitch(FriendsSnapshot snapshot) {
    final colors = Theme.of(context).colorScheme;
    final incoming = _pendingReceivedTotalCount > 0
        ? _pendingReceivedTotalCount
        : snapshot.pendingReceived.length;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 184),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedAlign(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 150),
                    alignment: _showRequests
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final requests in [false, true])
                      Expanded(
                        child: Tooltip(
                          message: requests
                              ? context.l10n.friendsRequests
                              : context.l10n.navFriends,
                          child: Semantics(
                            selected: _showRequests == requests,
                            label: requests
                                ? context.l10n.friendsRequests
                                : context.l10n.navFriends,
                            excludeSemantics: true,
                            button: true,
                            child: TextButton(
                              key: ValueKey(
                                requests
                                    ? 'friends-tab-requests'
                                    : 'friends-tab-friends',
                              ),
                              onPressed: () =>
                                  _updateState(() => _showRequests = requests),
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                                foregroundColor: _showRequests == requests
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Badge(
                                isLabelVisible: requests && incoming > 0,
                                label: Text(
                                  incoming > 99 ? '99+' : '$incoming',
                                ),
                                child: Icon(
                                  requests
                                      ? (_showRequests
                                            ? Icons.mail
                                            : Icons.mail_outline)
                                      : (_showRequests
                                            ? Icons.group_outlined
                                            : Icons.group),
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _qrAction(
    IconData icon,
    String title,
    Future<void> Function() action,
  ) => TextButton(
    onPressed: () => unawaited(action()),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 26),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );

  Widget _buildSectionHeadingRow({required String title, Widget? trailing}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Flexible(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10),
              DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppDesign.mutedColor(context),
                ),
                child: trailing,
              ),
            ],
          ],
        ),
      );

  Widget _buildFriendRequestsFeed(FriendsSnapshot snapshot) => Column(
    children: [
      for (final request in snapshot.pendingReceived)
        _buildFriendRequestFeedRow(
          request,
          type: _FriendRequestFeedType.incoming,
        ),
      for (final request in snapshot.pendingSent)
        _buildFriendRequestFeedRow(
          request,
          type: _FriendRequestFeedType.outgoing,
        ),
      if (_pendingReceivedHasMore)
        _buildLoadMoreTextButton(
          loading: _isLoadingMorePendingReceived,
          onPressed: () => unawaited(_loadMorePendingReceived()),
        ),
      if (_pendingSentHasMore)
        _buildLoadMoreTextButton(
          loading: _isLoadingMorePendingSent,
          onPressed: () => unawaited(_loadMorePendingSent()),
        ),
    ],
  );

  Widget _buildFriendRequestFeedRow(
    FriendRequest request, {
    required _FriendRequestFeedType type,
  }) {
    final busy = _respondLoading.contains(request.requestId);
    final incoming = type == _FriendRequestFeedType.incoming;
    final identity = Row(
      children: [
        ExcludeSemantics(child: _userAvatar(request.user, size: 48)),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFeedTextBlock(
            title: _friendPrimaryName(request.user),
            subtitle: incoming
                ? context.l10n.friendsIncomingRequestSubtitle
                : context.l10n.friendsOutgoingInviteSubtitle,
          ),
        ),
      ],
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (incoming) ...[
          IconButton.filled(
            tooltip: context.l10n.friendsAccept,
            onPressed: busy
                ? null
                : () => unawaited(_respondInvite(request, true)),
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            icon: const Icon(Icons.check, size: 26),
          ),
          const SizedBox(width: 4),
        ],
        IconButton.filledTonal(
          tooltip: incoming
              ? context.l10n.friendsDeclineAction
              : context.l10n.cancelAction,
          onPressed: busy
              ? null
              : () => incoming
                    ? unawaited(_respondInvite(request, false))
                    : unawaited(_cancelInvite(request)),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          icon: const Icon(Icons.close, size: 26),
        ),
      ],
    );
    return Column(
      key: ValueKey('friend-request-${request.requestId}'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (MediaQuery.textScalerOf(context).scale(16) > 23 ||
                  constraints.maxWidth < 300) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    identity,
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: 8),
                  actions,
                ],
              );
            },
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildFeedTextBlock({
    required String title,
    required String subtitle,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppDesign.mutedColor(context)),
      ),
    ],
  );

  Widget _buildLoadMoreTextButton({
    required bool loading,
    required VoidCallback onPressed,
  }) => TextButton.icon(
    onPressed: loading ? null : onPressed,
    icon: loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.expand_more_rounded),
    label: Text(context.l10n.tripsLoadMore),
  );

  Widget _buildFriendListRow(FriendUser friend) => Column(
    children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('friend-row-${friend.id}'),
          borderRadius: AppDesign.cardRadius,
          onTap: () => unawaited(_openFriendProfile(friend)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                ExcludeSemantics(child: _userAvatar(friend, size: 48)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeedTextBlock(
                    title: _friendPrimaryName(friend),
                    subtitle: _friendTripsLabel(friend),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  key: ValueKey('friend-more-${friend.id}'),
                  tooltip: context.l10n.friendsMoreActions,
                  onPressed: _friendActionLoading.contains(friend.id)
                      ? null
                      : () => unawaited(_openFriendListActions(friend)),
                  icon: const Icon(Icons.more_horiz_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
      const Divider(height: 1),
    ],
  );

  Widget _buildFriendsEmpty(FriendsSnapshot snapshot) => Padding(
    key: const ValueKey('friends-empty'),
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        SplytoIllustration(
          'assets/branding/splyto_empty_friends.svg',
          width: 180,
          height: 140,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.friendsNoFriendsYet,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(context.l10n.friendsEmptyBody, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => unawaited(_openFriendSearch()),
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: Text(context.l10n.friendsAddFriend),
        ),
      ],
    ),
  );

  int _sectionCountRequests(FriendsSnapshot snapshot) {
    final received = _pendingReceivedTotalCount > 0
        ? _pendingReceivedTotalCount
        : snapshot.pendingReceived.length;
    final sent = _pendingSentTotalCount > 0
        ? _pendingSentTotalCount
        : snapshot.pendingSent.length;
    return received + sent;
  }

  int _sectionCountFriends(FriendsSnapshot snapshot) {
    return _friendsTotalCount > 0
        ? _friendsTotalCount
        : snapshot.friends.length;
  }

  Widget _userAvatar(FriendUser user, {double size = 36}) =>
      FriendAvatar(user: user, size: size);

  String _friendPrimaryName(FriendUser user) {
    final display = user.preferredName.trim();
    if (display.isNotEmpty) {
      return display;
    }
    final fallback = user.nickname.trim();
    if (fallback.isNotEmpty) {
      return fallback;
    }
    return context.l10n.friendsUser;
  }

  String _friendTripsLabel(FriendUser friend) {
    final count = friend.commonTripsCount;
    if (count <= 0) {
      return context.l10n.workspaceNoCommonTripsFoundYet;
    }
    return context.l10n.friendsCommonTripsCount(count);
  }
}
