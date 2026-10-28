part of 'workspace_page.dart';

extension _WorkspacePageLayoutOverview on _WorkspacePageState {
  Widget _buildOverviewPanel(BuildContext context, WorkspaceSnapshot snapshot) {
    final t = context.l10n;
    final theme = Theme.of(context);
    // Balances cover the whole trip; snapshot.expenses is capped by the API.
    final total = snapshot.balances.fold<double>(
      0,
      (sum, item) => sum + item.paid,
    );
    BalanceItem? mine;
    for (final balance in snapshot.balances) {
      if (balance.id == _currentUserId) mine = balance;
    }
    final status = snapshot.isArchived
        ? t.archivedStatus
        : snapshot.isSettling
        ? t.settlingStatus
        : t.activeStatus;
    final dates = AppFormatters.tripDateRange(
      context,
      startRaw: widget.trip.dateFrom,
      endRaw: widget.trip.dateTo,
      unknownLabel: '',
    );
    final cover = (_displayTrip.imageUrl ?? _displayTrip.imageThumbUrl ?? '')
        .trim();
    final net = mine?.net;
    Widget fallback() => const SplytoIllustration(
      'assets/branding/splyto_trip_cover_large.svg',
      fit: BoxFit.contain,
    );
    Widget metric(String label, double? value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value == null
              ? '—'
              : AppFormatters.displayCurrencyFromCents(
                  context,
                  (value * 100).round(),
                  currencyCode: widget.trip.currencyCode,
                ),
          key: ValueKey(
            label == t.yourShare ? 'workspace-share' : 'workspace-total',
          ),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
    final coverWidget = ExcludeSemantics(
      child: ClipRRect(
        borderRadius: AppDesign.cardRadius,
        child: AspectRatio(
          aspectRatio: AppImageCropper.tripAspectRatio,
          child: cover.isEmpty
              ? fallback()
              : Image.network(
                  cover,
                  key: const ValueKey('workspace-cover-photo'),
                  fit: BoxFit.contain,
                  errorBuilder: (_, error, stack) => fallback(),
                ),
        ),
      ),
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final statusDate = Wrap(
              spacing: 10,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      snapshot.isArchived
                          ? Icons.inventory_2_outlined
                          : snapshot.isSettling
                          ? Icons.sync
                          : Icons.circle,
                      size: 9,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (dates.isNotEmpty)
                  Text(
                    '·  $dates',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            );
            final members = Semantics(
              label: t.workspaceMemberCount(snapshot.users.length),
              button: true,
              child: Tooltip(
                message: t.workspaceMemberCount(snapshot.users.length),
                child: InkWell(
                  onTap: () => _openTripMembersListSheet(snapshot.users),
                  borderRadius: AppDesign.cardRadius,
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final user in snapshot.users.take(3))
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: ExcludeSemantics(
                              child: _largeMemberAvatar(
                                id: user.id,
                                name: user.preferredName,
                                avatarUrl:
                                    user.avatarThumbUrl ?? user.avatarUrl,
                                size: 32,
                              ),
                            ),
                          ),
                        if (snapshot.users.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text('+${snapshot.users.length - 3}'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
            if (widget.trip.isSolo) return statusDate;
            if (MediaQuery.textScalerOf(context).scale(16) > 23 ||
                constraints.maxWidth < 300) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [statusDate, members],
              );
            }
            return Row(
              children: [
                Expanded(child: statusDate),
                const SizedBox(width: 8),
                members,
              ],
            );
          },
        ),
        if (_canOpenLiveMap)
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedBuilder(
              animation: widget.liveLocationController!,
              builder: (context, _) {
                final sharing =
                    widget.liveLocationController!.sharing(widget.trip.id) !=
                        null &&
                    !widget.liveLocationController!.stopping(widget.trip.id);
                return TextButton.icon(
                  key: const ValueKey('trip-live-map'),
                  onPressed: _openLiveMap,
                  icon: Icon(
                    sharing ? Icons.my_location : Icons.location_on_outlined,
                    size: 20,
                  ),
                  label: Text(
                    sharing
                        ? '${t.liveMapTitle} · ${t.liveSharing}'
                        : t.liveMapTitle,
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            final totalMetric = metric(
              widget.trip.isSolo
                  ? t.workspacePersonalTotal
                  : t.workspaceTripTotal,
              snapshot.balances.isEmpty ? null : total,
            );
            if (widget.trip.isSolo) return totalMetric;
            final shareMetric = metric(t.yourShare, mine?.owed);
            if (constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(16) > 21) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  totalMetric,
                  const SizedBox(height: 16),
                  shareMetric,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: totalMetric),
                Container(
                  width: 1,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  color: AppDesign.cardStroke(context),
                ),
                Expanded(child: shareMetric),
              ],
            );
          },
        ),
        if (!widget.trip.isSolo && net != null) ...[
          const SizedBox(height: 4),
          Text(
            net.abs() < .005
                ? t.workspaceBalanceEven
                : (net < 0
                      ? t.workspaceBalanceOwe(
                          AppFormatters.displayCurrencyFromCents(
                            context,
                            (net.abs() * 100).round(),
                            currencyCode: widget.trip.currencyCode,
                          ),
                        )
                      : t.workspaceBalanceReceive(
                          AppFormatters.displayCurrencyFromCents(
                            context,
                            (net * 100).round(),
                            currencyCode: widget.trip.currencyCode,
                          ),
                        )),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: net < -.004
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
        ],
        if (_tripBudgetCents != null) ...[
          const SizedBox(height: 16),
          TripBudgetCard(
            budgetCents: _tripBudgetCents!,
            spentCents: (total * 100).round(),
            currencyCode: widget.trip.currencyCode,
            isSolo: widget.trip.isSolo,
          ),
        ],
        if (!snapshot.isActive) ...[
          const SizedBox(height: 16),
          _buildClosedTripBanner(context, snapshot, padding: EdgeInsets.zero),
        ],
        if (_queuedMutations.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildQueuedChangesCard(context, padding: EdgeInsets.zero),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 640) {
            return Row(
              key: const ValueKey('workspace-wide-overview'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: coverWidget),
                const SizedBox(width: 24),
                Expanded(flex: 6, child: details),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [coverWidget, const SizedBox(height: 4), details],
          );
        },
      ),
    );
  }

  Widget _buildClosedTripBanner(
    BuildContext context,
    WorkspaceSnapshot snapshot, {
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(12, 0, 12, 8),
  }) {
    return Padding(
      padding: padding,
      child: Card(
        color: snapshot.isArchived
            ? Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.4)
            : Theme.of(
                context,
              ).colorScheme.tertiaryContainer.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            snapshot.isArchived
                ? context.l10n.tripArchivedReadOnly
                : _settlementsCompleted(snapshot)
                ? context.l10n.settledStatus
                : context.l10n.tripFinishedCompleteSettlements,
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusBadge(BuildContext context, {bool compact = false}) {
    final visual = _syncVisual(context, _syncState);
    final offline =
        _syncState == _SyncState.offline ||
        _syncState == _SyncState.offlineQueue;
    final label = _refreshError != null && !_workspaceOffline
        ? context.l10n.workspaceRefreshFailed
        : _pendingQueueCount > 0
        ? context.l10n.syncChangesWaiting(_pendingQueueCount)
        : (_syncState == _SyncState.syncing
              ? context.l10n.syncingStatus
              : (offline
                    ? context.l10n.offlineStatus
                    : context.l10n.syncAllSynced));
    if (compact &&
        _refreshError == null &&
        _pendingQueueCount == 0 &&
        !offline) {
      return IconButton(
        tooltip: label,
        color: Theme.of(context).colorScheme.primary,
        onPressed: _isMutating || _syncState == _SyncState.syncing
            ? null
            : _onRefreshPressed,
        icon: Icon(visual.icon),
      );
    }
    return TextButton.icon(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      onPressed: _isMutating || _syncState == _SyncState.syncing
          ? null
          : _onRefreshPressed,
      icon: Icon(visual.icon, size: 20),
      label: Text(label),
    );
  }

  Widget _buildQueuedChangesCard(
    BuildContext context, {
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(12, 0, 12, 8),
  }) {
    final preview = _queuedMutations.take(3).toList(growable: false);
    return Padding(
      padding: padding,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.queuedChangesTitle(_queuedMutations.length),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              for (var i = 0; i < preview.length; i++) ...[
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  minLeadingWidth: 20,
                  leading: Icon(_queuedMutationIcon(preview[i].type), size: 18),
                  title: Text(_queuedMutationTitle(preview[i])),
                  subtitle: Text(
                    '${_queuedMutationSubtitle(preview[i])} • ${_formatQueueTimestamp(preview[i].createdAtMillis)}',
                  ),
                ),
                if (i < preview.length - 1) const Divider(height: 1),
              ],
              if (_queuedMutations.length > preview.length) ...[
                const SizedBox(height: 4),
                Text(
                  context.l10n.moreCount(
                    _queuedMutations.length - preview.length,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
