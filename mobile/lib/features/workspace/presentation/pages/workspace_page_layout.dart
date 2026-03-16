part of 'workspace_page.dart';

extension _WorkspacePageLayout on _WorkspacePageState {
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final t = context.l10n;
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
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

  IconData _tripStatusIcon() {
    if (_isTripActive) {
      return Icons.play_circle_fill;
    }
    if (_isTripSettling) {
      return Icons.payments_outlined;
    }
    return Icons.archive_outlined;
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
    return AppBackground(
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(child: _buildOverviewPanel(context, snapshot)),
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
    );
  }

  Widget _buildWorkspaceTab(WorkspaceSnapshot snapshot, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _buildBalancesTab(snapshot);
      case 1:
        return _buildExpensesTab(snapshot);
      case 2:
        return _buildRandomTab(snapshot);
      default:
        return _buildBalancesTab(snapshot);
    }
  }

  Widget _buildWorkspaceTabSwitcher(BuildContext context) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 13,
      height: 1.0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final showIcons = constraints.maxWidth >= 390;
        final selectedTab = _workspaceTabIndex.clamp(0, 2);

        Widget buildTab({
          required int index,
          required String label,
          required IconData icon,
        }) {
          final selected = selectedTab == index;
          final foreground = selected
              ? colors.onPrimaryContainer
              : colors.onSurfaceVariant;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? colors.primary.withValues(alpha: 0.42)
                      : colors.outlineVariant.withValues(alpha: 0.42),
                  width: selected ? 1.4 : 1,
                ),
                color: selected
                    ? colors.primaryContainer.withValues(alpha: 0.72)
                    : colors.surface.withValues(alpha: 0.76),
              ),
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
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 11,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showIcons) ...[
                          Icon(icon, size: 16, color: foreground),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.46),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surface.withValues(alpha: 0.96),
                colors.surfaceContainerLow.withValues(alpha: 0.88),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F0F172A),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                buildTab(
                  index: 0,
                  label: t.navBalances,
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(width: 8),
                buildTab(
                  index: 1,
                  label: t.navExpenses,
                  icon: Icons.receipt_long_outlined,
                ),
                const SizedBox(width: 8),
                buildTab(
                  index: 2,
                  label: t.navRandom,
                  icon: Icons.casino_outlined,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkspaceStickyHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.94),
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: _buildWorkspaceTabSwitcher(context),
      ),
    );
  }


}
