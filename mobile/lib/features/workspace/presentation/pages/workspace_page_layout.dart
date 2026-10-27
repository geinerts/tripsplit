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
    final tabHeight = math.max(
      56.0,
      MediaQuery.textScalerOf(context).scale(16) * 1.5 + 24,
    );
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

  Widget _buildWorkspaceTabSwitcher(BuildContext context) {
    final tabs = <(int, String)>[
      (0, context.l10n.navExpenses),
      if (!widget.trip.isSolo) (1, context.l10n.navBalances),
      if (!widget.trip.isSolo) (2, context.l10n.workspaceSettle),
      if (!widget.trip.isSolo) (3, context.l10n.workspaceActivityTab),
    ];
    final colors = Theme.of(context).colorScheme;
    Widget tabButton((int, String) tab) => Semantics(
      selected: _workspaceTabIndex == tab.$1,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2,
              color: _workspaceTabIndex == tab.$1
                  ? colors.primary
                  : Colors.transparent,
            ),
          ),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            foregroundColor: _workspaceTabIndex == tab.$1
                ? colors.onSurface
                : colors.onSurfaceVariant,
            shape: const RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
          onPressed: () {
            _updateState(() => _workspaceTabIndex = tab.$1);
            if (tab.$1 == 3 && !_activityLoaded) {
              unawaited(_loadTripActivity(reset: true));
            }
          },
          child: Text(tab.$2),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.outlineVariant)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final labelsFit =
                tabs.fold<double>(0, (sum, tab) {
                  final painter = TextPainter(
                    text: TextSpan(
                      text: tab.$2,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    textDirection: Directionality.of(context),
                    textScaler: MediaQuery.textScalerOf(context),
                  )..layout();
                  return sum + painter.width + 16;
                }) <=
                constraints.maxWidth;
            return labelsFit
                ? Row(
                    children: [
                      for (final tab in tabs) Expanded(child: tabButton(tab)),
                    ],
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [for (final tab in tabs) tabButton(tab)],
                    ),
                  );
          },
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
