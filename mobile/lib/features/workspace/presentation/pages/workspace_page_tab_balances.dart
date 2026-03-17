part of 'workspace_page.dart';

extension _WorkspacePageBalancesTab on _WorkspacePageState {
  Widget _buildBalancesTab(WorkspaceSnapshot snapshot) {
    final colors = Theme.of(context).colorScheme;
    final t = context.l10n;
    final canFinishTrip = snapshot.isActive && _canEditMembers && !_isMutating;
    final usersById = <int, WorkspaceUser>{
      for (final user in snapshot.users) user.id: user,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      children: [
        if (snapshot.isActive) ...[
          _buildFinishTripActionBlock(
            colors: colors,
            canFinishTrip: canFinishTrip,
            finishLabel: t.finishTripStartSettlementsAction,
            creatorMustFinishLabel: t.creatorMustFinishTripFirst,
          ),
          const SizedBox(height: 12),
        ] else
          _WorkspaceSectionCard(
            accent: snapshot.isArchived ? colors.secondary : colors.tertiary,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _openSettlementProgressDetails(snapshot),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          (snapshot.isArchived
                                  ? colors.secondary
                                  : colors.tertiary)
                              .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      snapshot.isArchived
                          ? Icons.check_circle_outline
                          : Icons.payments_outlined,
                      color: snapshot.isArchived
                          ? colors.secondary
                          : colors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.isArchived
                              ? t.settlementProgressTripArchived
                              : t.settlementInProgress,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          snapshot.settlementTotal > 0
                              ? t.settlementConfirmedProgress(
                                  snapshot.settlementConfirmed,
                                  snapshot.settlementTotal,
                                )
                              : t.noPaymentsNeeded,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        if (snapshot.balances.isEmpty)
          _WorkspaceSectionCard(
            accent: colors.secondary,
            padding: const EdgeInsets.all(16),
            child: Text(t.noBalancesYet),
          )
        else
          ...snapshot.balances.map((item) {
            final netColor = item.net < 0 ? colors.error : colors.primary;
            final member = usersById[item.id];
            final preferredName = (member?.preferredName ?? item.nickname).trim();
            final displayName = preferredName.isEmpty
                ? t.userWithId(item.id)
                : preferredName;
            final nickname = (member?.nickname ?? item.nickname).trim();
            final showNicknameSecondary =
                nickname.isNotEmpty &&
                displayName.toLowerCase() != nickname.toLowerCase();
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () =>
                    _openBalanceDetails(snapshot: snapshot, item: item),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _balanceAvatar(
                            name: displayName,
                            avatarUrl: member?.avatarThumbUrl ?? member?.avatarUrl,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (showNicknameSecondary)
                                  Text(
                                    nickname,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: netColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _signedMoney(item.net),
                              style: TextStyle(
                                color: netColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _DetailChip(
                              icon: Icons.account_balance_wallet_outlined,
                              label: t.paidLabel,
                              value: _formatMoney(item.paid),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DetailChip(
                              icon: Icons.payments_outlined,
                              label: t.owesLabel,
                              value: _formatMoney(item.owed),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
        Text(t.settlements, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildSettlementsOverviewCard(snapshot),
      ],
    );
  }

  Widget _buildFinishTripActionBlock({
    required ColorScheme colors,
    required bool canFinishTrip,
    required String finishLabel,
    required String creatorMustFinishLabel,
  }) {
    // Keep a stable slot while current user id is being resolved to avoid
    // first-frame button/content jumping.
    if (_currentUserId <= 0) {
      return const SizedBox(height: 50);
    }

    if (_canEditMembers) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: canFinishTrip
              ? AppDesign.logoBackgroundGradient
              : LinearGradient(
                  colors: [
                    colors.surfaceContainerHighest,
                    colors.surfaceContainerHighest,
                  ],
                ),
        ),
        child: ElevatedButton.icon(
          onPressed: canFinishTrip ? _onEndTripPressed : null,
          icon: const Icon(Icons.flag_outlined),
          label: Text(finishLabel),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: canFinishTrip
                ? Colors.white
                : colors.onSurfaceVariant,
            disabledForegroundColor: colors.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    return _WorkspaceSectionCard(
      accent: colors.tertiary,
      child: Text(
        creatorMustFinishLabel,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _balanceAvatar({required String name, required String? avatarUrl}) {
    const size = 38.0;
    final imageCacheSize = (size * MediaQuery.devicePixelRatioOf(context))
        .round();
    final normalizedUrl = (avatarUrl ?? '').trim();
    if (normalizedUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          normalizedUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          cacheWidth: imageCacheSize,
          cacheHeight: imageCacheSize,
          errorBuilder: (context, error, stackTrace) =>
              _balanceAvatarFallback(name),
        ),
      );
    }
    return _balanceAvatarFallback(name);
  }

  Widget _balanceAvatarFallback(String name) {
    final letter = name.trim().isEmpty ? '?' : name.trim().substring(0, 1);
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppDesign.brandGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSettlementsOverviewCard(WorkspaceSnapshot snapshot) {
    final t = context.l10n;
    final settlements = snapshot.settlements;
    final confirmedCount = settlements
        .where((item) => item.status.trim().toLowerCase() == 'confirmed')
        .length;
    final openCount = settlements.length - confirmedCount;
    final subtitle = snapshot.isActive
        ? t.settlementOverviewPreviewSubtitle
        : (snapshot.isArchived
              ? t.settlementOverviewArchivedSubtitle
              : t.settlementOverviewInProgressSubtitle);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    snapshot.isArchived
                        ? Icons.check_circle_outline
                        : (snapshot.isActive
                              ? Icons.preview_outlined
                              : Icons.payments_outlined),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    snapshot.isArchived
                        ? t.settlementsDone
                        : (snapshot.isActive
                              ? t.settlementPreview
                              : t.settlementInProgress),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${settlements.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DetailChip(
                  icon: Icons.swap_horiz,
                  label: t.rowsLabel,
                  value: '${settlements.length}',
                ),
                _DetailChip(
                  icon: Icons.hourglass_bottom,
                  label: t.openLabel,
                  value: '$openCount',
                ),
                _DetailChip(
                  icon: Icons.check_circle_outline,
                  label: t.confirmedLabel,
                  value: '$confirmedCount',
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: settlements.isEmpty
                    ? null
                    : () => _openSettlementProgressDetails(snapshot),
                icon: const Icon(Icons.open_in_new),
                label: Text(
                  settlements.isEmpty ? t.noSettlements : t.openSettlements,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _settlementStatusColor(BuildContext context, String status) {
    switch (status.trim().toLowerCase()) {
      case 'confirmed':
        return Theme.of(context).colorScheme.primary;
      case 'sent':
        return Theme.of(context).colorScheme.tertiary;
      case 'pending':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  String _settlementStatusLabel(BuildContext context, String status) {
    final t = context.l10n;
    switch (status.trim().toLowerCase()) {
      case 'confirmed':
        return t.statusConfirmed;
      case 'sent':
        return t.statusSent;
      case 'pending':
        return t.statusPending;
      case 'suggested':
        return t.statusSuggested;
      default:
        return status.trim();
    }
  }

  String _settlementPairText(String from, String to) => '$from • $to';

  Widget _settlementPairTitle(BuildContext context, String from, String to) {
    return Row(
      children: [
        Flexible(
          child: Text(from, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 15,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Flexible(child: Text(to, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

}
