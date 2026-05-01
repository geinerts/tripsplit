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
                        retryLabel: context.l10n.retryAction,
                        onRetry: () => _loadSnapshot(showLoader: false),
                      ),
                    if (_errorText != null) const SizedBox(height: 12),
                    _buildFriendSearchField(snapshot),
                    _buildInlineSearchResults(snapshot),
                    const SizedBox(height: 22),
                    _buildSectionHeadingRow(
                      title: context.l10n.statusPending.toUpperCase(),
                      trailing: _countBadge(_sectionCountIncoming(snapshot)),
                    ),
                    const SizedBox(height: 10),
                    _buildPendingRequestsList(
                      snapshot,
                      requests: snapshot.pendingReceived,
                    ),
                    const SizedBox(height: 18),
                    _buildSectionHeadingRow(
                      title: context.l10n.navFriends.toUpperCase(),
                      trailing: _countBadge(_sectionCountFriends(snapshot)),
                    ),
                    const SizedBox(height: 10),
                    _buildFriendsList(snapshot, friends: snapshot.friends),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFriendSearchField(FriendsSnapshot snapshot) {
    return Material(
      color: Colors.transparent,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        textInputAction: TextInputAction.search,
        onChanged: (value) => _onFriendSearchChanged(snapshot, value),
        decoration: InputDecoration(
          hintText: context.l10n.friendsSearchByNameOrEmail,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _friendSearchQuery.isEmpty
              ? IconButton(
                  tooltip: context.l10n.friendsAddFriend,
                  onPressed: () => unawaited(_openAddFriendActions(snapshot)),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                )
              : IconButton(
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
                  onPressed: () {
                    _searchController.clear();
                    _clearInlineFriendSearch();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: AppDesign.cardSurface(context),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: AppDesign.cardStroke(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: AppDesign.cardStroke(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineSearchResults(FriendsSnapshot snapshot) {
    final query = _friendSearchQuery.trim();
    if (query.length < 2 &&
        !_isSearchingUsers &&
        _friendSearchResults.isEmpty &&
        _friendSearchError == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: AppSurfaceCard(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        borderColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSearchingUsers)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.friendsSearchUsers,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppDesign.mutedColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_friendSearchError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Text(
                  _friendSearchError!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppDesign.destructiveColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (_friendSearchResults.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Text(
                  context.l10n.friendsNoUsersFound,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppDesign.mutedColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              for (var i = 0; i < _friendSearchResults.length; i++) ...[
                _buildInlineSearchUserRow(snapshot, _friendSearchResults[i]),
                if (i < _friendSearchResults.length - 1)
                  Divider(
                    height: 1,
                    color: AppDesign.cardStroke(context).withValues(alpha: 0.5),
                  ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildInlineSearchUserRow(FriendsSnapshot snapshot, FriendUser user) {
    final busy = _inlineInviteLoading.contains(user.id);
    return AppListRow(
      leading: _userAvatar(user, size: 42),
      title: _friendPrimaryName(user),
      subtitle: user.nickname.trim().isEmpty ? null : user.nickname.trim(),
      trailing: FilledButton.icon(
        onPressed: busy
            ? null
            : () => unawaited(_sendInlineInvite(snapshot, user)),
        icon: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.person_add_alt_1_rounded, size: 17),
        label: Text(context.l10n.friendsInviteAction),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
    );
  }

  Widget _buildSectionHeadingRow({required String title, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.7,
                color: AppDesign.mutedColor(context),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _countBadge(int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
      ),
      child: Text(
        '$value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppDesign.titleColor(context).withValues(alpha: 0.82),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildPendingRequestsList(
    FriendsSnapshot snapshot, {
    required List<FriendRequest> requests,
  }) {
    if (snapshot.pendingReceived.isEmpty) {
      return _buildEmptyPanel(
        icon: Icons.mark_email_unread_outlined,
        message: context.l10n.friendsNoIncomingRequests,
      );
    }
    if (requests.isEmpty) {
      return _buildEmptyPanel(
        icon: Icons.search_off_rounded,
        message: context.l10n.friendsNoUsersFound,
      );
    }

    return Column(
      children: [
        for (var i = 0; i < requests.length; i++) ...[
          _buildPendingRequestCard(requests[i]),
          if (i < requests.length - 1) const SizedBox(height: 10),
        ],
        if (_pendingReceivedHasMore) ...[
          const SizedBox(height: 10),
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
                  : const Icon(Icons.expand_more_rounded),
              label: Text(context.l10n.tripsLoadMore),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPendingRequestCard(FriendRequest request) {
    final busy = _respondLoading.contains(request.requestId);
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: primary.withValues(
          alpha: AppDesign.isDark(context) ? 0.08 : 0.06,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Row(
        children: [
          _userAvatar(request.user, size: 58),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _friendPrimaryName(request.user),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppDesign.titleColor(context),
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.friendsIncoming,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppDesign.mutedColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _buildRequestActionButton(
            icon: Icons.check_rounded,
            busy: busy,
            foreground: AppDesign.darkForeground,
            background: primary,
            borderColor: primary,
            onPressed: () => _respondInvite(request, true),
          ),
          const SizedBox(width: 8),
          _buildRequestActionButton(
            icon: Icons.close_rounded,
            busy: false,
            foreground: AppDesign.mutedColor(context),
            background: Colors.transparent,
            borderColor: AppDesign.cardStroke(context),
            onPressed: busy ? null : () => _respondInvite(request, false),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestActionButton({
    required IconData icon,
    required bool busy,
    required Color foreground,
    required Color background,
    required Color borderColor,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: busy ? null : onPressed,
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: busy
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(foreground),
                    ),
                  )
                : Icon(icon, color: foreground, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList(
    FriendsSnapshot snapshot, {
    required List<FriendUser> friends,
  }) {
    if (snapshot.friends.isEmpty) {
      return _buildEmptyPanel(
        icon: Icons.people_outline_rounded,
        message: context.l10n.friendsNoFriendsYet,
      );
    }
    if (friends.isEmpty) {
      return _buildEmptyPanel(
        icon: Icons.search_off_rounded,
        message: context.l10n.friendsNoUsersFound,
      );
    }

    return Column(
      children: [
        for (var i = 0; i < friends.length; i++) ...[
          _buildFriendListCard(friends[i]),
          if (i < friends.length - 1) const SizedBox(height: 10),
        ],
        if (_isLoadingMoreFriends)
          const Padding(
            padding: EdgeInsets.only(top: 12),
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
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.friendsScrollDownToLoadMoreFriends,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppDesign.mutedColor(context),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFriendListCard(FriendUser friend) {
    return AppSurfaceCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      onTap: () => unawaited(_openFriendProfile(friend)),
      borderColor: AppDesign.cardStroke(context).withValues(alpha: 0.45),
      child: Row(
        children: [
          _userAvatar(friend, size: 58),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _friendPrimaryName(friend),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppDesign.titleColor(context),
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _friendTripsLabel(friend),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppDesign.mutedColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.chevron_right_rounded,
            color: AppDesign.mutedColor(context).withValues(alpha: 0.72),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPanel({required IconData icon, required String message}) {
    return AppSurfaceCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Row(
        children: [
          Icon(icon, color: AppDesign.mutedColor(context), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppDesign.mutedColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onFriendSearchChanged(FriendsSnapshot snapshot, String rawValue) {
    final query = rawValue.trim();
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
      if (!mounted || _friendSearchQuery != normalizedQuery) {
        return;
      }
      _updateState(() {
        _friendSearchResults = users;
        _isSearchingUsers = false;
      });
    } on ApiException catch (error) {
      if (!mounted || _friendSearchQuery != normalizedQuery) {
        return;
      }
      _updateState(() {
        _friendSearchError = error.message;
        _isSearchingUsers = false;
      });
    } catch (_) {
      if (!mounted || _friendSearchQuery != normalizedQuery) {
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

  int _sectionCountIncoming(FriendsSnapshot snapshot) {
    return _pendingReceivedTotalCount > 0
        ? _pendingReceivedTotalCount
        : snapshot.pendingReceived.length;
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
    final palette = <Color>[
      const Color(0xFF35B7C9),
      const Color(0xFF6D56B8),
      const Color(0xFFC98625),
      const Color(0xFF5E9F54),
      const Color(0xFFB95C7F),
    ];
    final color = palette[seed.abs() % palette.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppDesign.darkForeground,
          fontWeight: FontWeight.w800,
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
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
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
      return context.l10n.noTripsYet;
    }
    return count == 1 ? '1 trip' : '$count trips';
  }
}
