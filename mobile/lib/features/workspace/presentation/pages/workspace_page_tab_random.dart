part of 'workspace_page.dart';

extension _WorkspacePageRandomTab on _WorkspacePageState {
  Widget _buildRandomTab(WorkspaceSnapshot snapshot) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.pickMembersGenerateTurn,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(
                          alpha: 0.55,
                        ),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.35),
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${t.membersLabel}: ${snapshot.users.length}',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(
                          alpha: 0.55,
                        ),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.35),
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${t.selectedLabel}: ${_randomSelection.length}',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: colors.tertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final user in snapshot.users)
                      FilterChip(
                        label: Text(user.nickname),
                        selected: _randomSelection.contains(user.id),
                        onSelected: _isMutating
                            ? null
                            : (selected) {
                                _updateState(() {
                                  if (selected) {
                                    _randomSelection.add(user.id);
                                  } else {
                                    _randomSelection.remove(user.id);
                                  }
                                });
                              },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _isMutating || !snapshot.isActive
              ? null
              : _onGeneratePressed,
          icon: const Icon(Icons.casino_outlined),
          label: Text(t.generateTurnAction),
        ),
        if (!snapshot.isActive) ...[
          const SizedBox(height: 8),
          Text(
            t.tripClosedRandomDisabled,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 12),
        if (_lastDraw != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.emoji_events_outlined),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lastDraw!.pickedUserNickname.isEmpty
                              ? t.userWithId(_lastDraw!.pickedUserId)
                              : _lastDraw!.pickedUserNickname,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.randomCycleDrawLeft(
                            _lastDraw!.cycleNo,
                            _lastDraw!.drawNo,
                            _lastDraw!.remainingCount,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          t.recentPicksTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (snapshot.orders.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(t.noPicksYet),
            ),
          )
        else
          ...snapshot.orders.map((order) {
            final name = order.members.isNotEmpty
                ? order.members.first.nickname
                : t.unknownLabel;

            return Card(
              child: ListTile(
                title: Text(name),
                subtitle: Text(
                  t.createdByLine(order.createdAt, order.createdByNickname),
                ),
              ),
            );
          }),
      ],
    );
  }
}
