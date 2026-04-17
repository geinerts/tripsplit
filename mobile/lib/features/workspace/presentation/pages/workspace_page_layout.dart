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

    final tabIndex = _workspaceTabIndex.clamp(0, 2);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBackground(
      child: ColoredBox(
        color: isDark
            ? Theme.of(context).scaffoldBackgroundColor
            : AppDesign.lightCanvas,
        child: RefreshIndicator(
          onRefresh: () {
            if (_isMutating) {
              return Future<void>.value();
            }
            return _loadData(showLoader: false);
          },
          notificationPredicate: (notification) {
            return notification.metrics.axis == Axis.vertical;
          },
          child: NestedScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: _buildOverviewPanel(context, snapshot),
                ),
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  primary: false,
                  toolbarHeight: 84,
                  collapsedHeight: 84,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: _buildWorkspaceStickyHeader(context),
                ),
              ];
            },
            body: _buildWorkspaceTab(snapshot, tabIndex),
          ),
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
      default:
        return _buildExpensesTab(snapshot);
    }
  }

  Widget _buildWorkspaceTabSwitcher(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 15,
      height: 1.0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final selectedTab = _workspaceTabIndex.clamp(0, 2);

        Widget buildTab({required int index, required String label}) {
          final selected = selectedTab == index;
          final foreground = selected
              ? (isDark ? colors.onSurface : AppDesign.lightForeground)
              : (isDark ? colors.onSurfaceVariant : AppDesign.lightMuted);
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: selected
                    ? (isDark ? colors.surface : AppDesign.lightSurface)
                    : Colors.transparent,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppDesign.selectedTabShadow(context),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    if (index == _workspaceTabIndex) {
                      return;
                    }
                    _updateState(() {
                      _workspaceTabIndex = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
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
              ),
            ),
          );
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? colors.surfaceContainer : AppDesign.lightSurfaceTab,
            border: Border.all(
              color: isDark
                  ? colors.outlineVariant.withValues(alpha: 0.35)
                  : AppDesign.lightStroke,
            ),
            boxShadow: AppDesign.softShadow(context),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                buildTab(index: 0, label: context.l10n.navExpenses),
                const SizedBox(width: 8),
                buildTab(index: 1, label: context.l10n.navBalances),
                const SizedBox(width: 8),
                buildTab(index: 2, label: context.l10n.workspaceSettle),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkspaceStickyHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.94)
            : AppDesign.lightCanvas,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? colors.outlineVariant.withValues(alpha: 0.2)
                : AppDesign.lightStroke,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: _buildWorkspaceTabSwitcher(context),
      ),
    );
  }

  Widget _buildWorkspaceLoadingSurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBackground(
      child: ColoredBox(
        color: isDark
            ? Theme.of(context).scaffoldBackgroundColor
            : AppDesign.lightCanvas,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
