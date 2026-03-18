part of 'main_shell_page.dart';

extension _MainShellPageWidgets on _MainShellPageState {
  Widget _buildShellScaffold(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: _showTopBackButton
            ? IconButton(
                onPressed: _onTopBackPressed,
                icon: const Icon(Icons.arrow_back_ios_new),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              )
            : null,
        title: _buildAppBarTitle(context, titleStyle),
        actions: [
          IconButton(
            onPressed: _isLoggingOut ? null : _onRefreshPressed,
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.syncAction,
          ),
          _buildNotificationsAction(context),
          IconButton(
            onPressed: _isLoggingOut ? null : _openSettingsSheet,
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.l10n.settings,
          ),
        ],
      ),
      body: _isWorkspaceOpen
          ? WorkspacePage(
              trip: _openedTrip!,
              workspaceController: widget.workspaceController,
              tripsController: widget.tripsController,
              authController: widget.authController,
              showAppBar: false,
              showBottomNav: false,
              commandController: _workspaceCommandController,
              onExitRequested: _closeWorkspaceInShell,
            )
          : IndexedStack(
              index: _stackIndex,
              children: [
                TripsPage(
                  controller: widget.tripsController,
                  authController: widget.authController,
                  showInlineHeader: false,
                  showBottomNav: false,
                  commandController: _tripsCommandController,
                  onTripOpened: _openWorkspaceInShell,
                ),
                AnalyticsPage(
                  tripsController: widget.tripsController,
                  workspaceController: widget.workspaceController,
                  authController: widget.authController,
                  commandController: _analyticsCommandController ??=
                      AnalyticsPageCommandController(),
                  onOpenTrip: (trip) => _openWorkspaceInShell(trip),
                ),
                FriendsPage(
                  controller: widget.friendsController,
                  commandController: _friendsCommandController,
                ),
                ProfilePage(
                  controller: widget.authController,
                  showAppBar: false,
                  showBottomNav: false,
                  onProfileChanged: _onProfileChanged,
                  onEditModeChanged: _onProfileEditModeChanged,
                  commandController: _profileCommandController,
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildAppBarTitle(BuildContext context, TextStyle? titleStyle) {
    final title = _topTitle(context);
    final showLogo =
        !_isWorkspaceOpen && _selectedTabIndex == _MainShellPageState._tabHome;
    if (!showLogo) {
      return Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: titleStyle,
      );
    }
    return Row(
      children: [
        Image.asset(
          'assets/branding/logo_mark.png',
          width: 30,
          height: 30,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final t = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700);
    final user = widget.authController.currentUser;
    final avatarBytes = widget.authController.avatarBytesFor(user);
    final avatarUrl = widget.authController.avatarUrlFor(
      user,
      preferThumb: true,
    );
    final displayName = (user?.displayName ?? user?.nickname ?? '').trim();
    final avatarLetter = displayName.isEmpty
        ? t.travelerFallbackName.substring(0, 1).toUpperCase()
        : displayName.substring(0, 1).toUpperCase();

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return labelStyle?.copyWith(color: colorScheme.onPrimaryContainer);
          }
          return labelStyle?.copyWith(color: colorScheme.onSurfaceVariant);
        }),
      ),
      child: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined, size: 26),
            selectedIcon: const Icon(Icons.home, size: 26),
            label: t.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.query_stats_outlined, size: 26),
            selectedIcon: const Icon(Icons.query_stats, size: 26),
            label: t.navActivities,
          ),
          NavigationDestination(
            icon: _buildAddExpenseNavIcon(selected: false),
            selectedIcon: _buildAddExpenseNavIcon(selected: true),
            label: t.navExpenses,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline, size: 26),
            selectedIcon: const Icon(Icons.people, size: 26),
            label: t.navFriends,
          ),
          NavigationDestination(
            icon: _profileNavAvatar(
              avatarBytes: avatarBytes,
              avatarUrl: avatarUrl,
              avatarLetter: avatarLetter,
              color: colorScheme.onSurfaceVariant,
            ),
            selectedIcon: _profileNavAvatar(
              avatarBytes: avatarBytes,
              avatarUrl: avatarUrl,
              avatarLetter: avatarLetter,
              color: colorScheme.onPrimaryContainer,
            ),
            label: t.navProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsAction(BuildContext context) {
    final unread = _unreadNotificationsCount;
    final badgeText = unread > 99 ? '99+' : '$unread';
    return IconButton(
      key: const ValueKey(AppTestKeys.shellNotificationsButton),
      onPressed: (_isLoggingOut || _isNotificationsLoading)
          ? null
          : _onNotificationsPressed,
      tooltip: context.l10n.notificationsTitle,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none_outlined),
          if (unread > 0)
            Positioned(
              right: -7,
              top: -7,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(999),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 16),
                alignment: Alignment.center,
                child: Text(
                  badgeText,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 1.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddExpenseNavIcon({required bool selected}) {
    const width = 70.0;
    const height = 36.0;
    const iconSize = 20.0;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppDesign.logoBackgroundGradient,
        border: Border.all(
          color: Colors.white.withValues(alpha: selected ? 0.55 : 0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x66141E30),
            blurRadius: selected ? 14 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(Icons.add_rounded, size: iconSize, color: Colors.white),
    );
  }

  Widget _profileNavAvatar({
    required Uint8List? avatarBytes,
    required String? avatarUrl,
    required String avatarLetter,
    required Color color,
  }) {
    const size = 26.0;
    final imageCacheSize = (size * MediaQuery.devicePixelRatioOf(context))
        .round();
    if (avatarBytes != null && avatarBytes.isNotEmpty) {
      return ClipOval(
        child: Image.memory(
          avatarBytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
    }
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
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
              _profileNavAvatarLetter(avatarLetter: avatarLetter, color: color),
        ),
      );
    }
    return _profileNavAvatarLetter(avatarLetter: avatarLetter, color: color);
  }

  Widget _profileNavAvatarLetter({
    required String avatarLetter,
    required Color color,
  }) {
    const size = 26.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.16),
      ),
      alignment: Alignment.center,
      child: Text(
        avatarLetter,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
