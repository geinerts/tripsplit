part of 'workspace_page.dart';

extension _WorkspaceSettlementCards on _WorkspacePageState {
  /// Three steps: everyone marks ready, the creator ends the trip, people pay.
  Widget _settleStepBar({required int step, String? caption}) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final labels = [
      '1 · ${t.settleStepReady}',
      '2 · ${t.settleStepTripEnds}',
      '3 · ${t.settleStepPay}',
    ];
    return Semantics(
      key: const ValueKey('settle-step-bar'),
      label: '${labels[step.clamp(1, 3) - 1]}, $step / 3',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: i < step
                              ? colors.primary
                              : colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[i],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: i + 1 == step
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          fontWeight: i + 1 == step
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (caption != null) ...[
            const SizedBox(height: 8),
            Text(
              caption,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _settlementSummary(WorkspaceSnapshot snapshot) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final remaining = snapshot.settlements.where((s) => !s.isConfirmed);
    final incoming = remaining
        .where((s) => s.toUserId == _currentUserId)
        .fold<int>(0, (sum, s) => sum + (s.amount * 100).round());
    final outgoing = remaining
        .where((s) => s.fromUserId == _currentUserId)
        .fold<int>(0, (sum, s) => sum + (s.amount * 100).round());
    if (incoming == 0 && outgoing == 0) return const SizedBox.shrink();
    Widget metric(String label, int cents, String key) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (snapshot.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  t.settleEstimateBadge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _balanceMoney(cents / 100),
          key: ValueKey(key),
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
    return Padding(
      key: const ValueKey('settle-personal-summary'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (incoming > 0)
            metric(
              snapshot.isActive
                  ? t.analyticsYouGetBack
                  : t.settleStillToReceive,
              incoming,
              'settle-summary-incoming',
            ),
          if (incoming > 0 && outgoing > 0) const SizedBox(height: 12),
          if (outgoing > 0)
            metric(
              snapshot.isActive ? t.analyticsYouOwe : t.settleStillToPay,
              outgoing,
              'settle-summary-outgoing',
            ),
        ],
      ),
    );
  }

  Widget _buildFinishTripActionBlock({
    required bool canFinishTrip,
    required int readyMembers,
    required int totalMembers,
    required bool hasPendingPayments,
    required bool isCurrentUserReady,
    required bool canToggleReady,
  }) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final members = [
      ..._snapshot!.users.where((u) => u.id == _currentUserId),
      ..._snapshot!.users.where((u) => u.id != _currentUserId),
    ];
    return Column(
      key: const ValueKey('settle-readiness-card'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t.workspaceReadyToSettle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$readyMembers / $totalMembers',
              semanticsLabel: t.settlementReadyCount(
                readyMembers,
                totalMembers,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            for (final member in members)
              _settleReadyAvatar(
                member,
                ready: member.id == _currentUserId
                    ? isCurrentUserReady
                    : member.isReadyToSettle,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                t.settleAddedAllMyExpenses,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Semantics(
              label: t.workspaceIMReady,
              child: Switch.adaptive(
                key: const ValueKey('settle-ready-switch'),
                value: isCurrentUserReady,
                onChanged: canToggleReady ? _onReadyToSettleChanged : null,
              ),
            ),
          ],
        ),
        if (hasPendingPayments) ...[
          const SizedBox(height: 4),
          Text(
            t.paymentPendingBeforeFinish,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
        if (_canEditMembers) ...[
          const SizedBox(height: 10),
          FilledButton.icon(
            key: const ValueKey('settle-finish-trip'),
            onPressed: canFinishTrip ? _onEndTripPressed : null,
            icon: const Icon(Icons.flag_outlined, size: 20),
            label: Text(t.finishTripAction),
          ),
        ],
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _settleReadyAvatar(WorkspaceUser member, {required bool ready}) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final name = member.id == _currentUserId
        ? '${member.preferredName} · ${t.youLabel}'
        : member.preferredName;
    return Semantics(
      label:
          '$name, ${ready ? t.settlementMemberReady : t.settlementMemberNotReady}',
      excludeSemantics: true,
      child: Tooltip(
        message: name,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Opacity(
                opacity: ready ? 1 : .6,
                child: _largeMemberAvatar(
                  id: member.id,
                  name: member.preferredName,
                  avatarUrl: member.avatarThumbUrl ?? member.avatarUrl,
                  size: 42,
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ready
                        ? colors.primary
                        : colors.surfaceContainerHighest,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    ready ? Icons.check_rounded : Icons.schedule_rounded,
                    size: 10,
                    color: ready ? colors.onPrimary : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "To you", "You pay" and "Between others" in that order.
  Widget _buildSettleSections({
    required WorkspaceSnapshot snapshot,
    required List<SettlementItem> settlements,
    required Map<int, WorkspaceUser> usersById,
  }) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final ordered = [
      ...settlements.where((s) => !s.isConfirmed),
      ...settlements.where((s) => s.isConfirmed),
    ];
    final incoming = ordered
        .where((s) => s.toUserId == _currentUserId)
        .toList(growable: false);
    final outgoing = ordered
        .where((s) => s.fromUserId == _currentUserId)
        .toList(growable: false);
    final others = ordered
        .where(
          (s) => s.toUserId != _currentUserId && s.fromUserId != _currentUserId,
        )
        .toList(growable: false);
    Widget header(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (incoming.isNotEmpty) ...[
          header(t.settleToYou),
          for (final item in incoming)
            _buildSettleMineRow(
              snapshot: snapshot,
              item: item,
              usersById: usersById,
              incoming: true,
            ),
        ],
        if (outgoing.isNotEmpty) ...[
          header(t.settleYouPaySection),
          for (final item in outgoing)
            _buildSettleMineRow(
              snapshot: snapshot,
              item: item,
              usersById: usersById,
              incoming: false,
            ),
        ],
        if (others.isNotEmpty) ...[
          header(t.settleBetweenOthers),
          for (final item in others)
            _buildSettleOthersRow(
              snapshot: snapshot,
              item: item,
              usersById: usersById,
            ),
        ],
      ],
    );
  }

  String _settlementCardKey(SettlementItem item) =>
      '${item.id ?? '${item.fromUserId}-${item.toUserId}'}';

  String? _settleStatusText(WorkspaceSnapshot snapshot, SettlementItem item) {
    if (snapshot.isActive) return null;
    final t = context.l10n;
    return item.isConfirmed
        ? t.statusConfirmed
        : item.isSent
        ? t.statusSent
        : t.statusPending;
  }

  void _openSettleRow(
    WorkspaceSnapshot snapshot,
    SettlementItem item,
    Map<int, WorkspaceUser> usersById,
  ) {
    unawaited(
      _openSettlementFlowTimelineSheet(
        snapshot: snapshot,
        item: item,
        usersById: usersById,
      ),
    );
  }

  Widget _buildSettleMineRow({
    required WorkspaceSnapshot snapshot,
    required SettlementItem item,
    required Map<int, WorkspaceUser> usersById,
    required bool incoming,
  }) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final key = _settlementCardKey(item);
    final otherId = incoming ? item.fromUserId : item.toUserId;
    final otherUser = usersById[otherId];
    final otherName = _paymentMemberName(
      incoming ? item.from : item.to,
      otherId,
      otherUser,
    );
    final payable = _tripPaymentOutstandingAmount(snapshot, item);
    final canRequest =
        snapshot.isActive && item.isSuggested && incoming && payable > .004;
    final canRecord =
        snapshot.isActive && item.isSuggested && !incoming && payable > .004;
    final canAct =
        !snapshot.isActive &&
        !snapshot.isArchived &&
        (item.canMarkSent || item.canConfirmReceived);
    final status = _settleStatusText(snapshot, item);
    final subtitle = [
      incoming ? t.settlePaysYou : t.settleYouPayRow,
      ?status,
    ].join(' · ');
    Widget? action;
    if (canRequest || canRecord) {
      action = _settleChipButton(
        key: ValueKey('settle-row-action-$key'),
        icon: canRequest
            ? Icons.notifications_none_rounded
            : Icons.payments_outlined,
        label: canRequest ? t.settleRequestShort : t.settleRecordShort,
        onTap: _isMutating
            ? null
            : () => _openTripPaymentComposerSheet(
                settlement: item,
                maxAmount: payable,
                isRequest: canRequest,
              ),
      );
    } else if (canAct) {
      action = _settleChipButton(
        key: ValueKey('settle-row-action-$key'),
        icon: item.canConfirmReceived
            ? Icons.check_circle_outline
            : Icons.payments_outlined,
        label: item.canConfirmReceived
            ? t.confirmReceivedAction
            : t.iSentAction,
        onTap: _isMutating
            ? null
            : () => item.canConfirmReceived
                  ? _onSettlementConfirmReceived(item)
                  : _onSettlementMarkSent(item),
      );
    }
    final amount = Text(
      _balanceMoney(item.amount),
      key: ValueKey('settlement-amount-$key'),
      textAlign: TextAlign.end,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: item.isConfirmed
            ? colors.onSurfaceVariant
            : incoming
            ? colors.primary
            : null,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    return InkWell(
      key: ValueKey('settlement-card-$key'),
      onTap: () => _openSettleRow(snapshot, item, usersById),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(16) > 21;
            final trailing = Column(
              crossAxisAlignment: stacked
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                amount,
                if (action != null) ...[const SizedBox(height: 6), action],
              ],
            );
            final names = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: item.isConfirmed || item.isSent
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                ),
                if (stacked) ...[const SizedBox(height: 8), trailing],
              ],
            );
            return Column(
              children: [
                Row(
                  children: [
                    _largeMemberAvatar(
                      id: otherId,
                      name: otherName,
                      avatarUrl:
                          otherUser?.avatarThumbUrl ?? otherUser?.avatarUrl,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: names),
                    if (!stacked) ...[
                      const SizedBox(width: 12),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * .5,
                        ),
                        child: trailing,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettleOthersRow({
    required WorkspaceSnapshot snapshot,
    required SettlementItem item,
    required Map<int, WorkspaceUser> usersById,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final key = _settlementCardKey(item);
    final from = usersById[item.fromUserId];
    final to = usersById[item.toUserId];
    final fromName = _paymentMemberName(item.from, item.fromUserId, from);
    final toName = _paymentMemberName(item.to, item.toUserId, to);
    final status = _settleStatusText(snapshot, item);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );
    return InkWell(
      key: ValueKey('settlement-card-$key'),
      onTap: () => _openSettleRow(snapshot, item, usersById),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              height: 34,
              child: Stack(
                children: [
                  _largeMemberAvatar(
                    id: item.fromUserId,
                    name: fromName,
                    avatarUrl: from?.avatarThumbUrl ?? from?.avatarUrl,
                    size: 28,
                  ),
                  Positioned(
                    left: 16,
                    top: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                      child: _largeMemberAvatar(
                        id: item.toUserId,
                        name: toName,
                        avatarUrl: to?.avatarThumbUrl ?? to?.avatarUrl,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle.merge(
                    style: muted,
                    child: _settlementPairTitle(context, fromName, toName),
                  ),
                  if (status != null)
                    Text(
                      status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _balanceMoney(item.amount),
              key: ValueKey('settlement-amount-$key'),
              style: muted?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settleChipButton({
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        key: key,
        color: colors.primary.withValues(alpha: enabled ? .12 : .06),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15, color: colors.primary),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
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
}
