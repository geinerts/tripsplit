part of 'workspace_page.dart';

extension _WorkspacePageLayoutOverview on _WorkspacePageState {
  Widget _buildOverviewPanel(BuildContext context, WorkspaceSnapshot snapshot) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final syncVisual = _syncVisual(context, _syncState);
    final tripStatusLabel = _isTripActive
        ? t.activeStatus
        : (_isTripSettling ? t.settlingStatus : t.archivedStatus);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: _WorkspaceSectionCard(
        accent: colors.primary,
        radius: 22,
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: _isOverviewExpanded,
            onExpansionChanged: (expanded) {
              if (_isOverviewExpanded == expanded) {
                return;
              }
              _updateState(() {
                _isOverviewExpanded = expanded;
              });
            },
            tilePadding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            leading: Icon(_tripStatusIcon()),
            title: Text(t.overviewTitle),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _OverviewMetaPill(
                    icon: _tripStatusIcon(),
                    label: tripStatusLabel,
                    color: _isTripActive
                        ? colors.primary
                        : (_isTripSettling
                              ? colors.tertiary
                              : colors.secondary),
                  ),
                  _OverviewMetaPill(
                    icon: syncVisual.icon,
                    label: syncVisual.label,
                    color: syncVisual.foreground,
                  ),
                  if (_pendingQueueCount > 0)
                    _OverviewMetaPill(
                      icon: Icons.cloud_upload_outlined,
                      label: t.queuedCountLabel(_pendingQueueCount),
                      color: colors.tertiary,
                    ),
                ],
              ),
            ),
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _isLoading || _isMutating
                        ? null
                        : () => _loadData(showLoader: false),
                    icon: const Icon(Icons.sync),
                    label: Text(t.syncNowAction),
                  ),
                  if (_canEditMembers)
                    OutlinedButton.icon(
                      onPressed: _isLoading || _isMutating
                          ? null
                          : _openAddMembersDialog,
                      icon: const Icon(Icons.group_add),
                      label: Text(t.addMembersAction),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _SummaryCard(snapshot: snapshot),
              if (!snapshot.isActive)
                _buildClosedTripBanner(
                  context,
                  snapshot,
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                ),
              if (_pendingQueueCount > 0)
                _buildOfflineQueueBanner(
                  context,
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                ),
              if (_queuedMutations.isNotEmpty)
                _buildQueuedChangesCard(
                  context,
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                ),
            ],
          ),
        ),
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
                : context.l10n.tripFinishedCompleteSettlements,
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineQueueBanner(
    BuildContext context, {
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(12, 0, 12, 8),
  }) {
    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.tertiaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          context.l10n.offlineQueuePendingChanges(_pendingQueueCount),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
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

class _OverviewMetaPill extends StatelessWidget {
  const _OverviewMetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
