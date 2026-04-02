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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBackground(
      child: ColoredBox(
        color: isDark
            ? Theme.of(context).scaffoldBackgroundColor
            : _splytoCreamBg,
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
              ? (isDark ? colors.onSurface : _splytoFg)
              : (isDark ? colors.onSurfaceVariant : _splytoMuted);
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: selected
                    ? (isDark ? colors.surface : _splytoCard)
                    : Colors.transparent,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: isDark
                              ? colors.shadow.withValues(alpha: 0.25)
                              : const Color(0x1A2C2418),
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
            color: isDark ? colors.surfaceContainer : const Color(0xFFF0ECE3),
            border: Border.all(
              color: isDark
                  ? colors.outlineVariant.withValues(alpha: 0.35)
                  : _splytoStroke,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                buildTab(
                  index: 0,
                  label: _localizedText(
                    context,
                    en: 'Expenses',
                    lv: 'Izdevumi',
                  ),
                ),
                const SizedBox(width: 8),
                buildTab(
                  index: 1,
                  label: _localizedText(
                    context,
                    en: 'Balances',
                    lv: 'Bilances',
                  ),
                ),
                const SizedBox(width: 8),
                buildTab(
                  index: 2,
                  label: _localizedText(context, en: 'Settle', lv: 'Norēķini'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.94)
            : _splytoCreamBg,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? colors.outlineVariant.withValues(alpha: 0.2)
                : _splytoStroke,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: _buildWorkspaceTabSwitcher(context),
      ),
    );
  }
}
