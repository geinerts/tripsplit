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
                  friendsController: widget.friendsController,
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
    final neutralSelection = _isWorkspaceOpen;
    final user = widget.authController.currentUser;
    final avatarBytes = widget.authController.avatarBytesFor(user);
    final avatarUrl = widget.authController.avatarUrlFor(
      user,
      preferThumb: true,
    );
    final displayName = (user?.displayName ?? user?.nickname ?? '').trim();
    final avatarLetter =
        (displayName.isEmpty ? context.l10n.travelerFallbackName : displayName)
            .substring(0, 1)
            .toUpperCase();
    final selectedItem = neutralSelection
        ? null
        : switch (_selectedTabIndex) {
            _MainShellPageState._tabActivities => AppBottomNavItem.analytics,
            _MainShellPageState._tabFriends => AppBottomNavItem.friends,
            _MainShellPageState._tabProfile => AppBottomNavItem.profile,
            _ => AppBottomNavItem.home,
          };

    return AppBottomNavBar(
      selectedItem: selectedItem,
      avatarBytes: avatarBytes,
      avatarUrl: avatarUrl,
      avatarLetter: avatarLetter,
      onSelected: (item) {
        switch (item) {
          case AppBottomNavItem.home:
            _onDestinationSelected(_MainShellPageState._tabHome);
            break;
          case AppBottomNavItem.analytics:
            _onDestinationSelected(_MainShellPageState._tabActivities);
            break;
          case AppBottomNavItem.expenses:
            _onDestinationSelected(_MainShellPageState._tabAddExpense);
            break;
          case AppBottomNavItem.friends:
            _onDestinationSelected(_MainShellPageState._tabFriends);
            break;
          case AppBottomNavItem.profile:
            _onDestinationSelected(_MainShellPageState._tabProfile);
            break;
        }
      },
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
}
