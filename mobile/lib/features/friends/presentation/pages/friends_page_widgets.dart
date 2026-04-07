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
                    _buildSectionTabs(),
                    const SizedBox(height: 10),
                    if (_sectionTabIndex == _FriendsPageState._tabIncoming) ...[
                      _buildSectionHeadingRow(
                        title: _txt(
                          en: 'INCOMING REQUESTS',
                          lv: 'SAŅEMTIE PIEPRASĪJUMI',
                        ),
                        trailing: _countBadge(_sectionCountIncoming(snapshot)),
                      ),
                      const SizedBox(height: 8),
                      _buildIncomingCard(snapshot),
                      const SizedBox(height: 10),
                    ],
                    if (_sectionTabIndex == _FriendsPageState._tabSent) ...[
                      _buildSectionHeadingRow(
                        title: _txt(
                          en: 'SENT INVITES',
                          lv: 'NOSŪTĪTIE UZAICINĀJUMI',
                        ),
                        trailing: _countBadge(_sectionCountSent(snapshot)),
                      ),
                      const SizedBox(height: 8),
                      _buildOutgoingCard(snapshot),
                      const SizedBox(height: 10),
                    ],
                    if (_sectionTabIndex == _FriendsPageState._tabFriends) ...[
                      _buildSectionHeadingRow(
                        title: _txt(en: 'MY FRIENDS', lv: 'MANI DRAUGI'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _countBadge(_sectionCountFriends(snapshot)),
                            const SizedBox(width: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () => unawaited(_openScanFriendQr()),
                                child: Ink(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.12),
                                  ),
                                  child: Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () =>
                                    unawaited(_openAddFriendActions(snapshot)),
                                child: Ink(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.12),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFriendsCard(snapshot),
                    ],
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
    final friendsCount = _friendsTotalCount > 0
        ? _friendsTotalCount
        : snapshot.friends.length;
    final incomingCount = _pendingReceivedTotalCount > 0
        ? _pendingReceivedTotalCount
        : snapshot.pendingReceived.length;
    final sentCount = _pendingSentTotalCount > 0
        ? _pendingSentTotalCount
        : snapshot.pendingSent.length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryMetricCard(
            icon: Icons.people_alt_outlined,
            label: _txt(en: 'Friends', lv: 'Draugi'),
            value: friendsCount.toString(),
            iconTint: colors.primary,
            iconBg: colors.primary.withValues(alpha: 0.12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryMetricCard(
            icon: Icons.move_to_inbox_outlined,
            label: _txt(en: 'Incoming', lv: 'Saņemtie'),
            value: incomingCount.toString(),
            iconTint: AppDesign.lightAccent,
            iconBg: AppDesign.lightAccent.withValues(alpha: 0.18),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryMetricCard(
            icon: Icons.arrow_forward_rounded,
            label: _txt(en: 'Sent', lv: 'Nosūtītie'),
            value: sentCount.toString(),
            iconTint: AppDesign.destructiveColor(context),
            iconBg: AppDesign.destructiveColor(context).withValues(alpha: 0.14),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTabs() {
    final labels = [
      _txt(en: 'Friends', lv: 'Draugi'),
      _txt(en: 'Incoming', lv: 'Saņemtie'),
      _txt(en: 'Sent', lv: 'Nosūtītie'),
    ];
    return AppChipTabs(
      labels: labels,
      selectedIndex: _sectionTabIndex,
      onChanged: (nextIndex) {
        _updateState(() {
          _sectionTabIndex = nextIndex;
        });
      },
    );
  }

  Widget _buildSummaryMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconTint,
    required Color iconBg,
  }) {
    final isDark = AppDesign.isDark(context);
    final titleStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppDesign.mutedColor(context),
      fontWeight: FontWeight.w800,
      letterSpacing: 0.35,
    );
    final valueStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: AppDesign.titleColor(context),
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppDesign.cardSurface(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.30)
              : AppDesign.cardStroke(context),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: iconTint),
          ),
          const SizedBox(height: 9),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: valueStyle,
          ),
        ],
      ),
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
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
                color: AppDesign.mutedColor(context),
              ),
            ),
          ),
          if (trailing != null) ...[trailing],
        ],
      ),
    );
  }

  Widget _countBadge(int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
      ),
      child: Text(
        '$value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  int _sectionCountIncoming(FriendsSnapshot snapshot) {
    return _pendingReceivedTotalCount > 0
        ? _pendingReceivedTotalCount
        : snapshot.pendingReceived.length;
  }

  int _sectionCountSent(FriendsSnapshot snapshot) {
    return _pendingSentTotalCount > 0
        ? _pendingSentTotalCount
        : snapshot.pendingSent.length;
  }

  int _sectionCountFriends(FriendsSnapshot snapshot) {
    return _friendsTotalCount > 0
        ? _friendsTotalCount
        : snapshot.friends.length;
  }

  Widget _buildEmptyMessage(String message) {
    return Text(
      message,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: AppDesign.mutedColor(context)),
    );
  }

  Future<void> _openAddFriendSheet(FriendsSnapshot snapshot) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AddFriendBottomSheet(
          txt: _txt,
          showSnack: _showSnack,
          searchUsers: (query) => widget.controller.searchUsers(
            query: query,
            limit: 20,
            excludeIds: _searchExcludeIds(_snapshot ?? snapshot),
          ),
          sendInvite: (userId) => widget.controller.sendInvite(userId: userId),
          onInviteSuccess: (nickname) async {
            if (!mounted) {
              return;
            }
            _showSnack(
              _txt(
                en: 'Invite sent to $nickname.',
                lv: 'Uzaicinājums nosūtīts lietotājam $nickname.',
              ),
            );
            await _loadSnapshot(showLoader: false);
          },
          userAvatarBuilder: _userAvatar,
        );
      },
    );
  }

  Widget _buildIncomingCard(FriendsSnapshot snapshot) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (snapshot.pendingReceived.isEmpty)
            _buildEmptyMessage(
              _txt(en: 'No incoming requests', lv: 'Nav saņemtu pieprasījumu'),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _friendPrimaryName(request.user),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppDesign.titleColor(context),
                                ),
                          ),
                          if (_friendSecondaryLabel(request.user) != null)
                            Text(
                              _friendSecondaryLabel(request.user)!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppDesign.mutedColor(context),
                                  ),
                            ),
                        ],
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
    );
  }

  Widget _buildOutgoingCard(FriendsSnapshot snapshot) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (snapshot.pendingSent.isEmpty)
            _buildEmptyMessage(
              _txt(en: 'No sent invites', lv: 'Nav nosūtītu uzaicinājumu'),
            )
          else
            ...snapshot.pendingSent.map((request) {
              final busy = _cancelLoading.contains(request.requestId);
              return AppListRow(
                leading: _userAvatar(request.user),
                title: _friendPrimaryName(request.user),
                subtitle: _friendSecondaryLabel(request.user),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.tertiaryContainer.withValues(alpha: 0.6),
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
    );
  }

  Widget _buildFriendsCard(FriendsSnapshot snapshot) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (snapshot.friends.isEmpty)
            _buildEmptyMessage(_txt(en: 'No friends yet', lv: 'Draugu vēl nav'))
          else
            ...snapshot.friends.map(
              (friend) => AppListRow(
                leading: _userAvatar(friend),
                title: _friendPrimaryName(friend),
                subtitle: _friendSecondaryLabel(friend),
                onTap: () => unawaited(_openFriendProfile(friend)),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: AppDesign.mutedColor(context),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppDesign.mutedColor(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _userAvatar(FriendUser user) {
    const size = 36.0;
    final imageCacheSize = (size * MediaQuery.devicePixelRatioOf(context))
        .round();
    final display = _friendPrimaryName(user);
    final initial = display.trim().isEmpty
        ? '?'
        : display.trim().substring(0, 1).toUpperCase();
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

  String _friendPrimaryName(FriendUser user) {
    final display = user.preferredName.trim();
    if (display.isNotEmpty) {
      return display;
    }
    final fallback = user.nickname.trim();
    if (fallback.isNotEmpty) {
      return fallback;
    }
    return _txt(en: 'User', lv: 'Lietotājs');
  }

  String? _friendSecondaryLabel(FriendUser user) {
    final nickname = user.nickname.trim();
    if (nickname.isEmpty) {
      return null;
    }
    final primary = _friendPrimaryName(user).trim();
    if (primary.toLowerCase() == nickname.toLowerCase()) {
      return null;
    }
    return '@$nickname';
  }
}

typedef _FriendsTxt = String Function({required String en, required String lv});
typedef _FriendsShowSnack = void Function(String message, {bool isError});

class _AddFriendBottomSheet extends StatefulWidget {
  const _AddFriendBottomSheet({
    required this.txt,
    required this.showSnack,
    required this.searchUsers,
    required this.sendInvite,
    required this.onInviteSuccess,
    required this.userAvatarBuilder,
  });

  final _FriendsTxt txt;
  final _FriendsShowSnack showSnack;
  final Future<List<FriendUser>> Function(String query) searchUsers;
  final Future<void> Function(int userId) sendInvite;
  final Future<void> Function(String nickname) onInviteSuccess;
  final Widget Function(FriendUser user) userAvatarBuilder;

  @override
  State<_AddFriendBottomSheet> createState() => _AddFriendBottomSheetState();
}

class _AddFriendBottomSheetState extends State<_AddFriendBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _inviteLoading = <int>{};
  List<FriendUser> _searchResults = const <FriendUser>[];
  Timer? _searchDebounce;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String rawValue) {
    _searchDebounce?.cancel();
    final value = rawValue.trim();
    if (value.length < 2) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = const <FriendUser>[];
        });
      }
      return;
    }
    _searchDebounce = Timer(
      const Duration(milliseconds: 280),
      () => unawaited(_performSearch(value)),
    );
  }

  Future<void> _performSearch(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2) {
      return;
    }
    if (mounted) {
      setState(() {
        _isSearching = true;
      });
    }
    try {
      final users = await widget.searchUsers(normalizedQuery);
      if (!mounted) {
        return;
      }
      if (_searchController.text.trim() != normalizedQuery) {
        return;
      }
      setState(() {
        _searchResults = users;
        _isSearching = false;
      });
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
      widget.showSnack(error.message, isError: true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
      widget.showSnack(
        widget.txt(
          en: 'Search failed. Try again.',
          lv: 'Meklēšana neizdevās. Mēģini vēlreiz.',
        ),
        isError: true,
      );
    }
  }

  Future<void> _invite(FriendUser user) async {
    if (_inviteLoading.contains(user.id)) {
      return;
    }
    if (mounted) {
      setState(() {
        _inviteLoading.add(user.id);
      });
    }
    try {
      await widget.sendInvite(user.id);
      await widget.onInviteSuccess(user.nickname);
      if (!mounted) {
        return;
      }
      setState(() {
        _inviteLoading.remove(user.id);
        _searchResults = _searchResults
            .where((candidate) => candidate.id != user.id)
            .toList(growable: false);
      });
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _inviteLoading.remove(user.id);
        });
      }
      widget.showSnack(error.message, isError: true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _inviteLoading.remove(user.id);
        });
      }
      widget.showSnack(
        widget.txt(
          en: 'Failed to send invite.',
          lv: 'Neizdevās nosūtīt uzaicinājumu.',
        ),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.84,
          child: Container(
            decoration: BoxDecoration(
              color: AppDesign.cardSurface(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 46,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppDesign.mutedColor(
                      context,
                    ).withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.txt(
                                en: 'Add friend',
                                lv: 'Pievienot draugu',
                              ),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                            ),
                          ),
                          IconButton(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).closeButtonTooltip,
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        autofocus: true,
                        onChanged: _onQueryChanged,
                        decoration: InputDecoration(
                          hintText: widget.txt(
                            en: 'Search by nickname',
                            lv: 'Meklēt pēc segvārda',
                          ),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : (query.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _searchDebounce?.cancel();
                                          _searchController.clear();
                                          if (mounted) {
                                            setState(() {
                                              _isSearching = false;
                                              _searchResults =
                                                  const <FriendUser>[];
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.close),
                                      )
                                    : null),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (query.length < 2)
                        Text(
                          widget.txt(
                            en: 'Type at least 2 characters to search.',
                            lv: 'Ievadi vismaz 2 simbolus, lai meklētu.',
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppDesign.mutedColor(context)),
                        )
                      else if (!_isSearching && _searchResults.isEmpty)
                        Text(
                          widget.txt(
                            en: 'No users found',
                            lv: 'Lietotāji nav atrasti',
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppDesign.mutedColor(context)),
                        )
                      else
                        ..._searchResults.map((user) {
                          final busy = _inviteLoading.contains(user.id);
                          return AppListRow(
                            leading: widget.userAvatarBuilder(user),
                            title: user.preferredName.trim().isNotEmpty
                                ? user.preferredName.trim()
                                : user.nickname,
                            subtitle:
                                user.preferredName.trim().isNotEmpty &&
                                    user.preferredName.trim().toLowerCase() !=
                                        user.nickname.trim().toLowerCase()
                                ? '@${user.nickname.trim()}'
                                : null,
                            trailing: OutlinedButton.icon(
                              onPressed: busy
                                  ? null
                                  : () => unawaited(_invite(user)),
                              icon: busy
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_add_alt_1,
                                      size: 18,
                                    ),
                              label: Text(
                                widget.txt(en: 'Invite', lv: 'Uzaicināt'),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
