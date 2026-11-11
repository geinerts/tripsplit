part of 'workspace_page.dart';

extension _WorkspacePageLayout on _WorkspacePageState {
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final t = context.l10n;
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.1,
    );

    return AppBar(
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: widget.onExitRequested == null
          ? null
          : IconButton(
              onPressed: widget.onExitRequested,
              icon: const Icon(Icons.arrow_back_ios_new),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
      title: Text(
        _displayTrip.name.isEmpty
            ? t.tripWithId(widget.trip.id)
            : _displayTrip.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: titleStyle,
      ),
      actions: [
        if (_isCurrentTripOwner() || widget.onTravelMapRequested != null)
          IconButton(
            onPressed: _openTripActionsSheet,
            icon: const Icon(Icons.more_vert),
            tooltip: t.settings,
          ),
        IconButton(
          onPressed: _onRefreshPressed,
          icon: const Icon(Icons.refresh),
          tooltip: t.syncNowAction,
        ),
        IconButton(
          onPressed: _openSettingsSheet,
          icon: const Icon(Icons.settings_outlined),
          tooltip: t.settings,
        ),
      ],
    );
  }

  void _onRefreshPressed() {
    if (_isMutating) {
      return;
    }
    unawaited(_loadData(showLoader: false));
  }

  Widget _buildBody(BuildContext context) {
    if (_isStartingWithAddExpense || _isLoading) {
      return _buildWorkspaceLoadingSurface(context);
    }
    if (_errorText != null || _snapshot == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildWorkspaceIllustratedState(
            asset: 'splyto_trip_load_error.svg',
            title: context.l10n.workspaceLoadErrorTitle,
            message: _errorText ?? context.l10n.noTripDataLoaded,
            action: OutlinedButton.icon(
              onPressed: () => _loadData(showLoader: true),
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retryAction),
            ),
          ),
        ],
      );
    }
    final snapshot = _snapshot!;
    final tab = widget.trip.isSolo ? 0 : _workspaceTabIndex.clamp(0, 3);
    const tabHeight = 64.0;
    return AppBackground(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: RefreshIndicator(
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: () => _isMutating
                ? Future<void>.value()
                : _loadData(showLoader: false),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 2,
                    child: _syncState == _SyncState.syncing
                        ? const LinearProgressIndicator()
                        : null,
                  ),
                ),
                if (_refreshError != null)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Semantics(
                        liveRegion: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              context.l10n.workspaceCachedWarning,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              _refreshError!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: _onRefreshPressed,
                                icon: const Icon(Icons.refresh),
                                label: Text(context.l10n.retryAction),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _buildOverviewPanel(context, snapshot),
                ),
                if (!widget.trip.isSolo)
                  SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    primary: false,
                    toolbarHeight: tabHeight,
                    collapsedHeight: tabHeight,
                    expandedHeight: tabHeight,
                    backgroundColor: AppDesign.pageBaseColor(context),
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: _buildWorkspaceTabSwitcher(context),
                  ),
                if (!widget.trip.isSolo)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    sliver: SliverToBoxAdapter(
                      child: Semantics(
                        header: true,
                        child: Text(
                          _workspaceTabLabel(context, tab),
                          key: const ValueKey('workspace-section-title'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ),
                if (tab == 0)
                  ..._buildExpensesSlivers(snapshot)
                else if (tab == 3)
                  ..._buildActivitySlivers()
                else
                  SliverToBoxAdapter(
                    child: switch (tab) {
                      1 => _buildBalancesTab(snapshot),
                      2 => _buildSettleTab(snapshot),
                      _ => const SizedBox.shrink(),
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _workspaceTabLabel(BuildContext context, int tab) => switch (tab) {
    1 => context.l10n.navBalances,
    2 => context.l10n.workspaceSettle,
    3 => context.l10n.workspaceActivityTab,
    _ => context.l10n.navExpenses,
  };

  Widget _buildWorkspaceTabSwitcher(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Settle uses the SPLYTO "Y" mark, one colour like the other tab icons.
    // It is a filled shape, so it is drawn a little larger to match their
    // visual weight.
    const icons = ['receipt-text', 'wallet', 'splyto-y', 'history'];
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 150);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  for (var index = 0; index < icons.length; index++)
                    Expanded(
                      child: Semantics(
                        selected: _workspaceTabIndex == index,
                        child: Tooltip(
                          message: _workspaceTabLabel(context, index),
                          child: AnimatedContainer(
                            duration: duration,
                            decoration: BoxDecoration(
                              color: _workspaceTabIndex == index
                                  ? colors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextButton(
                              key: ValueKey('workspace-tab-$index'),
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                padding: EdgeInsets.zero,
                                shape: const StadiumBorder(),
                                foregroundColor: _workspaceTabIndex == index
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                              ),
                              onPressed: () {
                                _updateState(() => _workspaceTabIndex = index);
                                if (index == 3 && !_activityLoaded) {
                                  unawaited(_loadTripActivity(reset: true));
                                }
                              },
                              child: SvgPicture.asset(
                                'assets/branding/workspace_${icons[index]}.svg',
                                width: index == 2 ? 30 : 24,
                                height: index == 2 ? 30 : 24,
                                excludeFromSemantics: true,
                                colorFilter: ColorFilter.mode(
                                  _workspaceTabIndex == index
                                      ? colors.onPrimary
                                      : colors.onSurfaceVariant,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspaceIllustratedState({
    required String asset,
    required String title,
    required String message,
    Widget? action,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          SplytoIllustration('assets/branding/$asset', width: 180, height: 140),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 16), action],
        ],
      ),
    );
  }

  Widget _buildWorkspaceLoadingSurface(BuildContext context) => Semantics(
    label: context.l10n.workspaceLoadingTrip,
    child: ExcludeSemantics(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AspectRatio(
            aspectRatio: 2.3,
            child: AppSkeletonBlock(radius: 8),
          ),
          const SizedBox(height: 16),
          const AppSkeletonBlock(width: 160, height: 20),
          const SizedBox(height: 24),
          const AppSkeletonBlock(height: 72),
          const SizedBox(height: 24),
          const AppSkeletonBlock(height: 48),
          for (var i = 0; i < 3; i++)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: AppSkeletonBlock(height: 72, radius: 8),
            ),
        ],
      ),
    ),
  );
}
