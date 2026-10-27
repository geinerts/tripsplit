part of 'main_shell_page.dart';

extension _MainShellPageWidgets on _MainShellPageState {
  Widget _buildShellScaffold(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );
    return AppPageScaffold(
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
          if (_canShowWorkspaceTripActions)
            IconButton(
              onPressed: _workspaceCommandController.requestOpenTripActions,
              icon: const Icon(Icons.more_horiz_rounded),
              tooltip: context.l10n.settings,
            ),
          _buildNotificationsAction(context),
        ],
      ),
      body: _isWorkspaceOpen
          ? WorkspacePage(
              key: ValueKey('workspace-${_openedTrip!.id}'),
              trip: _openedTrip!,
              workspaceController: widget.workspaceController,
              tripsController: widget.tripsController,
              friendsController: widget.friendsController,
              authController: widget.authController,
              showAppBar: false,
              showBottomNav: false,
              openAddExpenseOnStart: _openAddExpenseOnWorkspaceStart,
              commandController: _workspaceCommandController,
              onExitRequested: _closeWorkspaceInShell,
              onTravelMapRequested: widget.travelPlacesRepository == null
                  ? null
                  : () => _openTravelMap(tripId: _openedTrip!.id),
              onTripUpdated: (trip) {
                if (_openedTrip?.id == trip.id) {
                  _updateState(() => _openedTrip = trip);
                }
              },
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
                  onServerTripsState: _onHomeServerTripsState,
                  onInteractionStateChanged: (busy) {
                    _homeInteractionBusy = busy;
                    _scheduleQuickStart();
                  },
                ),
                AnalyticsPage(
                  active:
                      _selectedTabIndex == _MainShellPageState._tabActivities &&
                      !_isWorkspaceOpen,
                  tripsController: widget.tripsController,
                  workspaceController: widget.workspaceController,
                  authController: widget.authController,
                  commandController: _analyticsCommandController ??=
                      AnalyticsPageCommandController(),
                  onOpenTrip: (trip) => _openWorkspaceInShell(trip),
                ),
                FriendsPage(
                  tripsController: widget.tripsController,
                  onOpenTrip: (trip) => _openWorkspaceInShell(trip),
                  controller: widget.friendsController,
                  authController: widget.authController,
                  workspaceController: widget.workspaceController,
                  commandController: _friendsCommandController,
                ),
                ProfilePage(
                  controller: widget.authController,
                  showAppBar: false,
                  showBottomNav: false,
                  onProfileChanged: _onProfileChanged,
                  onQuickStartRequested: _replayQuickStart,
                  onTravelMapRequested: widget.travelPlacesRepository == null
                      ? null
                      : () => _openTravelMap(),
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
    final logoAsset = AppDesign.isDark(context)
        ? 'assets/branding/logo_full_dark.png'
        : 'assets/branding/logo_full.png';
    if (!showLogo) {
      return Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: titleStyle,
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 4),
        child: SizedBox(
          width: 110,
          height: 40,
          child: Image.asset(
            logoAsset,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
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

  bool get _canShowWorkspaceTripActions {
    final trip = _openedTrip;
    return _isWorkspaceOpen &&
        trip != null &&
        (widget.travelPlacesRepository != null ||
            (trip.isActive && trip.canCurrentUserManageTrip));
  }

  Widget _buildNotificationsAction(BuildContext context) {
    final unread = _unreadNotificationsCount;
    final badgeText = unread > 99 ? '99+' : '$unread';
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: IconButton(
        key: const ValueKey(AppTestKeys.shellNotificationsButton),
        onPressed: _isLoggingOut ? null : _onNotificationsPressed,
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
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 16,
                  ),
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
      ),
    );
  }
}
