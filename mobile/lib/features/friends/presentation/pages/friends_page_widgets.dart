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
                        _buildFriendSearchField(snapshot),
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
                        _buildInlineSearchResults(snapshot),
                        if (_sectionCountRequests(snapshot) > 0) ...[
                          const SizedBox(height: 8),
                          _buildSectionHeadingRow(
                            title: context.l10n.friendsRequests,
                            trailing: Text(
                              '${_sectionCountRequests(snapshot)}',
                            ),
                          ),
                          _buildFriendRequestsFeed(snapshot),
                        ],
                        const SizedBox(height: 24),
                        _buildSectionHeadingRow(
                          title: context.l10n.navFriends,
                          trailing: Text('${_sectionCountFriends(snapshot)}'),
                        ),
                        if (snapshot.friends.isEmpty)
                          _buildFriendsEmpty(snapshot),
                      ],
                    ],
                  ),
                ),
                if (snapshot != null && snapshot.friends.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemCount: snapshot.friends.length,
                      itemBuilder: (_, index) =>
                          _buildFriendListRow(snapshot.friends[index]),
                    ),
                  ),
                if (snapshot != null && _friendsHasMore)
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

  Widget _buildFriendSearchField(FriendsSnapshot snapshot) => TextField(
    key: const ValueKey('friends-search'),
    controller: _searchController,
    focusNode: _searchFocusNode,
    textInputAction: TextInputAction.search,
    onChanged: (value) => _onFriendSearchChanged(snapshot, value),
    decoration: InputDecoration(
      hintText: context.l10n.friendsSearchByNameOrEmail,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: _friendSearchQuery.isEmpty
          ? null
          : IconButton(
              tooltip: context.l10n.workspaceClearSearch,
              onPressed: () => _clearInlineFriendSearch(),
              icon: const Icon(Icons.close_rounded),
            ),
    ),
  );

  Widget _buildInlineSearchResults(FriendsSnapshot snapshot) {
    if (_friendSearchQuery.isEmpty) {
      return const SizedBox.shrink();
    }
    if (_friendSearchQuery.length < 2) {
      return Text(context.l10n.friendsTypeAtLeast2CharactersToSearch);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isSearchingUsers)
            const LinearProgressIndicator()
          else if (_friendSearchError != null) ...[
            Text(
              _friendSearchError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            TextButton(
              onPressed: () =>
                  _performInlineFriendSearch(snapshot, _friendSearchQuery),
              child: Text(context.l10n.retryAction),
            ),
          ] else if (_friendSearchResults.isEmpty)
            Text(context.l10n.friendsNoUsersFound)
          else
            for (final user in _friendSearchResults)
              _buildInlineSearchUserRow(snapshot, user),
        ],
      ),
    );
  }

  Widget _buildInlineSearchUserRow(
    FriendsSnapshot snapshot,
    FriendUser user,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              ExcludeSemantics(
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1,
                  child: _userAvatar(user, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _friendPrimaryName(user),
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
                  onPressed: _inlineInviteLoading.contains(user.id)
                      ? null
                      : () => unawaited(_sendInlineInvite(snapshot, user)),
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
                    onPressed: _inlineInviteLoading.contains(user.id)
                        ? null
                        : () => unawaited(_sendInlineInvite(snapshot, user)),
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
                const Icon(Icons.more_horiz_rounded),
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
          onPressed: () => _searchFocusNode.requestFocus(),
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: Text(context.l10n.friendsAddFriend),
        ),
      ],
    ),
  );

  void _onFriendSearchChanged(FriendsSnapshot snapshot, String rawValue) {
    final query = rawValue.trim();
    _searchGeneration++;
    _friendSearchDebounce?.cancel();
    _updateState(() {
      _friendSearchQuery = query;
      _friendSearchError = null;
      _friendSearchResults = const <FriendUser>[];
      _isSearchingUsers = query.length >= 2;
    });
    if (query.length < 2) {
      _clearInlineFriendSearch(keepText: true);
      return;
    }
    _friendSearchDebounce = Timer(
      const Duration(milliseconds: 280),
      () => unawaited(_performInlineFriendSearch(snapshot, query)),
    );
  }

  Future<void> _performInlineFriendSearch(
    FriendsSnapshot snapshot,
    String query,
  ) async {
    final generation = ++_searchGeneration;
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2) {
      return;
    }
    _updateState(() {
      _isSearchingUsers = true;
      _friendSearchError = null;
    });
    try {
      final users = await widget.controller.searchUsers(
        query: normalizedQuery,
        limit: 8,
        excludeIds: _searchExcludeIds(_snapshot ?? snapshot),
      );
      if (!mounted ||
          _friendSearchQuery != normalizedQuery ||
          generation != _searchGeneration) {
        return;
      }
      _updateState(() {
        _friendSearchResults = users;
        _isSearchingUsers = false;
      });
    } on ApiException catch (error) {
      if (!mounted ||
          _friendSearchQuery != normalizedQuery ||
          generation != _searchGeneration) {
        return;
      }
      if ([401, 403, 404].contains(error.statusCode) ||
          error.code == 'account_changed') {
        _handleFriendsLoadError(error);
        return;
      }
      _updateState(() {
        _friendSearchError = error.message;
        _isSearchingUsers = false;
      });
    } catch (_) {
      if (!mounted ||
          _friendSearchQuery != normalizedQuery ||
          generation != _searchGeneration) {
        return;
      }
      _updateState(() {
        _friendSearchError = context.l10n.friendsSearchFailedTryAgain;
        _isSearchingUsers = false;
      });
    }
  }

  Future<void> _sendInlineInvite(
    FriendsSnapshot snapshot,
    FriendUser user,
  ) async {
    if (_inlineInviteLoading.contains(user.id)) {
      return;
    }
    _updateState(() {
      _inlineInviteLoading.add(user.id);
    });
    try {
      await widget.controller.sendInvite(userId: user.id);
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.friendsInviteSentTo(user.preferredName));
      _updateState(() {
        _friendSearchResults = _friendSearchResults
            .where((candidate) => candidate.id != user.id)
            .toList(growable: false);
      });
      await _loadSnapshot(showLoader: false);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.friendsFailedToSendInvite, isError: true);
    } finally {
      if (mounted) {
        _updateState(() {
          _inlineInviteLoading.remove(user.id);
        });
      }
    }
  }

  void _clearInlineFriendSearch({bool keepText = false}) {
    _searchGeneration++;
    _friendSearchDebounce?.cancel();
    _updateState(() {
      if (!keepText) {
        _searchController.clear();
        _friendSearchQuery = '';
      }
      _isSearchingUsers = false;
      _friendSearchError = null;
      _friendSearchResults = const <FriendUser>[];
      _inlineInviteLoading.clear();
    });
  }

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

  Widget _userAvatar(FriendUser user, {double size = 36}) {
    final imageCacheSize = (size * MediaQuery.devicePixelRatioOf(context))
        .round();
    final display = _friendPrimaryName(user);
    final initials = _friendInitials(display);
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
              _avatarFallback(initials: initials, size: size, seed: user.id),
        ),
      );
    }

    return _avatarFallback(initials: initials, size: size, seed: user.id);
  }

  Widget _avatarFallback({
    required String initials,
    required double size,
    required int seed,
  }) {
    final color = Theme.of(context).colorScheme.primaryContainer;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.34,
          height: 1,
        ),
      ),
    );
  }

  String _friendInitials(String displayName) {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

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
