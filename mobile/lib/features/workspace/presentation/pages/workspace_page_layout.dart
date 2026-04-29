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
        widget.trip.name.isEmpty
            ? t.tripWithId(widget.trip.id)
            : widget.trip.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: titleStyle,
      ),
      actions: [
        if (_isCurrentTripOwner())
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
    if (_isStartingWithAddExpense) {
      return _buildWorkspaceLoadingSurface(context);
    }

    if (_isLoading) {
      return _buildWorkspaceLoadingSurface(context);
    }

    if (_errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorText!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _loadData(showLoader: true),
                child: Text(context.l10n.retryAction),
              ),
            ],
          ),
        ),
      );
    }

    final snapshot = _snapshot;
    if (snapshot == null) {
      return Center(child: Text(context.l10n.noTripDataLoaded));
    }

    final tabIndex = _workspaceTabIndex.clamp(0, 3);
    return AppBackground(
      child: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () {
          if (_isMutating) {
            return Future<void>.value();
          }
          return _loadData(showLoader: false);
        },
        notificationPredicate: (notification) {
          return notification.metrics.axis == Axis.vertical &&
              notification.depth == 0;
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildOverviewPanel(context, snapshot)),
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              primary: false,
              toolbarHeight: 60,
              collapsedHeight: 60,
              expandedHeight: 60,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: _buildWorkspaceStickyHeader(context),
            ),
            SliverToBoxAdapter(child: _buildWorkspaceTab(snapshot, tabIndex)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceTab(WorkspaceSnapshot snapshot, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _buildExpensesTab(snapshot);
      case 1:
        return _buildBalancesTab(snapshot);
      case 2:
        return _buildSettleTab(snapshot);
      case 3:
        return _buildActivityTab();
      default:
        return _buildExpensesTab(snapshot);
    }
  }

  Widget _buildWorkspaceTabSwitcher(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTab = _workspaceTabIndex.clamp(0, 3);
    final activeColor = isDark ? AppDesign.darkAccent : AppDesign.lightPrimary;
    final dividerColor = isDark
        ? colors.outlineVariant.withValues(alpha: 0.28)
        : AppDesign.lightStroke.withValues(alpha: 0.95);
    final labelStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontSize: 15,
      height: 1.0,
      letterSpacing: 0.1,
    );

    Widget buildTab({required int index, required String label}) {
      final selected = selectedTab == index;
      final foreground = selected
          ? (isDark ? AppDesign.darkForeground : AppDesign.lightForeground)
          : (isDark
                ? colors.onSurfaceVariant.withValues(alpha: 0.64)
                : AppDesign.lightMuted.withValues(alpha: 0.86));

      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (index == _workspaceTabIndex) {
                return;
              }
              _updateState(() {
                _workspaceTabIndex = index;
              });
              if (index == 3 && !_activityLoaded) {
                unawaited(_loadTripActivity(reset: true));
              }
            },
            child: SizedBox(
              height: 48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: labelStyle?.copyWith(
                          color: foreground,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        width: selected
                            ? math.min(constraints.maxWidth * 0.70, 84)
                            : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          buildTab(index: 0, label: context.l10n.navExpenses),
          buildTab(index: 1, label: context.l10n.navBalances),
          buildTab(index: 2, label: context.l10n.workspaceSettle),
          buildTab(
            index: 3,
            label: Localizations.localeOf(context).languageCode == 'lv'
                ? 'Aktivitāte'
                : 'Activity',
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceStickyHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
      child: _buildWorkspaceTabSwitcher(context),
    );
  }

  Widget _buildWorkspaceLoadingSurface(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        top: !widget.showAppBar,
        bottom: !widget.showBottomNav,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
          children: [
            _buildWorkspaceLoadingOverviewSkeleton(context),
            const SizedBox(height: 10),
            _buildWorkspaceLoadingTabSwitcherSkeleton(context),
            const SizedBox(height: 12),
            _buildWorkspaceLoadingSectionSkeleton(context),
            const SizedBox(height: 12),
            _buildWorkspaceLoadingExpenseCardSkeleton(context),
            const SizedBox(height: 10),
            _buildWorkspaceLoadingExpenseCardSkeleton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceLoadingOverviewSkeleton(BuildContext context) {
    return Container(
      height: 210,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppDesign.cardStroke(context)),
        color: AppDesign.cardSurface(context).withValues(alpha: 0.88),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBlock(width: 170, height: 36, radius: 12),
          SizedBox(height: 12),
          AppSkeletonBlock(width: 84, height: 84, radius: 42),
          Spacer(),
          AppSkeletonBlock(height: 14, radius: 8),
          SizedBox(height: 8),
          AppSkeletonBlock(height: 14, radius: 8),
        ],
      ),
    );
  }

  Widget _buildWorkspaceLoadingTabSwitcherSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppDesign.cardStroke(context)),
        color: AppDesign.cardSurface(context).withValues(alpha: 0.88),
      ),
      child: const Row(
        children: [
          Expanded(child: AppSkeletonBlock(height: 44, radius: 18)),
          SizedBox(width: 8),
          Expanded(child: AppSkeletonBlock(height: 44, radius: 18)),
          SizedBox(width: 8),
          Expanded(child: AppSkeletonBlock(height: 44, radius: 18)),
        ],
      ),
    );
  }

  Widget _buildWorkspaceLoadingSectionSkeleton(BuildContext context) {
    return const Row(
      children: [
        AppSkeletonBlock(width: 132, height: 30, radius: 10),
        SizedBox(width: 10),
        AppSkeletonBlock(width: 30, height: 30, radius: 15),
      ],
    );
  }

  Widget _buildWorkspaceLoadingExpenseCardSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppDesign.cardStroke(context)),
        color: AppDesign.cardSurface(context).withValues(alpha: 0.88),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBlock(width: 64, height: 64, radius: 18),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonBlock(width: 140, height: 24, radius: 10),
                    SizedBox(height: 8),
                    AppSkeletonBlock(width: 110, height: 18, radius: 8),
                  ],
                ),
              ),
              SizedBox(width: 8),
              AppSkeletonBlock(width: 92, height: 24, radius: 10),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              AppSkeletonBlock(width: 31, height: 31, radius: 16),
              SizedBox(width: 8),
              AppSkeletonBlock(width: 120, height: 16, radius: 8),
            ],
          ),
        ],
      ),
    );
  }
}
