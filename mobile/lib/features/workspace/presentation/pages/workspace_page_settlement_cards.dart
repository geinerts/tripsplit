part of 'workspace_page.dart';

extension _WorkspaceSettlementCards on _WorkspacePageState {
  Widget _settlementSummary(WorkspaceSnapshot snapshot) {
    final t = context.l10n;
    final theme = Theme.of(context);
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
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
      padding: const EdgeInsets.only(bottom: 20),
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
          const SizedBox(height: 6),
          Text(
            snapshot.isActive
                ? t.settleEstimateCaption
                : t.settleOutstandingCaption,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishTripActionBlock({
    required ColorScheme colors,
    required bool canFinishTrip,
    required bool allMembersReady,
    required int readyMembers,
    required int totalMembers,
    required bool hasPendingPayments,
    required bool isCurrentUserReady,
    required bool canToggleReady,
    required String finishLabel,
    required String creatorMustFinishLabel,
  }) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final me = _snapshot!.users
        .where((u) => u.id == _currentUserId)
        .firstOrNull;
    final subtitle = hasPendingPayments
        ? t.paymentPendingBeforeFinish
        : allMembersReady
        ? t.workspaceAllMembersAreReadyYouCanStartSettlements
        : !isCurrentUserReady
        ? t.settleWaitingForYou
        : t.workspaceWaitingForEveryoneToMarkReady;
    return Container(
      key: const ValueKey('settle-readiness-card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                t.workspaceReadyToSettle,
                style: theme.textTheme.titleMedium,
              ),
              Semantics(
                label: t.settlementReadyCount(readyMembers, totalMembers),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$readyMembers / $totalMembers',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: totalMembers == 0 ? 0 : readyMembers / totalMembers,
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
            semanticsLabel: t.settlementReadyCount(readyMembers, totalMembers),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (MediaQuery.textScalerOf(context).scale(16) <= 23) ...[
                _largeMemberAvatar(
                  id: _currentUserId,
                  name: me?.preferredName ?? t.youLabel,
                  avatarUrl: me?.avatarThumbUrl ?? me?.avatarUrl,
                  size: 34,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  me == null
                      ? t.workspaceIMReady
                      : '${me.preferredName} · ${t.youLabel}',
                  style: theme.textTheme.titleSmall,
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
          Text(
            t.workspaceConfirmThatYouAddedAllYourExpenses,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          for (final member in _snapshot!.users.where(
            (u) => u.id != _currentUserId,
          ))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _largeMemberAvatar(
                    id: member.id,
                    name: member.preferredName,
                    avatarUrl: member.avatarThumbUrl ?? member.avatarUrl,
                    size: 34,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.preferredName,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          member.isReadyToSettle
                              ? t.settlementMemberReady
                              : t.settlementMemberNotReady,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: member.isReadyToSettle
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    member.isReadyToSettle
                        ? Icons.check_circle_outline
                        : Icons.schedule,
                    size: 20,
                    color: member.isReadyToSettle
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          if (_canEditMembers)
            FilledButton.icon(
              key: const ValueKey('settle-finish-trip'),
              onPressed: canFinishTrip ? _onEndTripPressed : null,
              icon: const Icon(Icons.flag_outlined, size: 20),
              label: Text(finishLabel),
            )
          else
            Text(
              creatorMustFinishLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementFlowCard({
    required WorkspaceSnapshot snapshot,
    required SettlementItem item,
    required Map<int, WorkspaceUser> usersById,
    required AppSemanticColors semantic,
  }) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final key = '${item.id ?? '${item.fromUserId}-${item.toUserId}'}';
    final expanded = _expandedSettlementCards.contains(key);
    final from = usersById[item.fromUserId];
    final to = usersById[item.toUserId];
    String name(String fallback, int id, WorkspaceUser? user) =>
        '${_paymentMemberName(fallback, id, user)}${id == _currentUserId ? ' · ${t.youLabel}' : ''}';
    final fromName = name(item.from, item.fromUserId, from);
    final toName = name(item.to, item.toUserId, to);
    final payable = _tripPaymentOutstandingAmount(snapshot, item);
    final canRequest =
        snapshot.isActive &&
        item.isSuggested &&
        item.toUserId == _currentUserId &&
        payable > .004;
    final canRecord =
        snapshot.isActive &&
        item.isSuggested &&
        item.fromUserId == _currentUserId &&
        payable > .004;
    final canAct =
        !snapshot.isActive &&
        !snapshot.isArchived &&
        (item.canMarkSent || item.canConfirmReceived);
    final status = item.isConfirmed
        ? t.statusConfirmed
        : item.isSent
        ? t.statusSent
        : t.statusPending;
    final statusIcon = item.isConfirmed
        ? Icons.check_circle_outline
        : item.isSent
        ? Icons.done
        : Icons.schedule;
    final amount = Text(
      _balanceMoney(item.amount),
      key: ValueKey('settlement-amount-$key'),
      textAlign: TextAlign.end,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              expanded: expanded,
              child: InkWell(
                key: ValueKey('settlement-card-$key'),
                onTap: () => _updateState(() {
                  if (expanded) {
                    _expandedSettlementCards.remove(key);
                  } else {
                    _expandedSettlementCards.add(key);
                  }
                }),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked =
                          constraints.maxWidth < 300 ||
                          MediaQuery.textScalerOf(context).scale(16) > 21;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _largeMemberAvatar(
                                id: item.fromUserId,
                                name: fromName,
                                avatarUrl:
                                    from?.avatarThumbUrl ?? from?.avatarUrl,
                                size: 34,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fromName,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 14,
                                          color: colors.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            toName,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!stacked) ...[
                                const SizedBox(width: 8),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: constraints.maxWidth * .45,
                                  ),
                                  child: amount,
                                ),
                              ],
                              const SizedBox(width: 4),
                              Icon(
                                expanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.chevron_right,
                                size: 20,
                                color: colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                          if (stacked) ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: amount,
                            ),
                          ],
                          if (!snapshot.isActive) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  statusIcon,
                                  size: 15,
                                  color: item.isSent || item.isConfirmed
                                      ? colors.primary
                                      : colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    status,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: item.isSent || item.isConfirmed
                                          ? colors.primary
                                          : colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    if (snapshot.isActive) ...[
                      Text(
                        t.settleEstimateCaption,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (canRequest || canRecord)
                      OutlinedButton.icon(
                        onPressed: _isMutating
                            ? null
                            : () => _openTripPaymentComposerSheet(
                                settlement: item,
                                maxAmount: payable,
                                isRequest: canRequest,
                              ),
                        icon: Icon(
                          canRequest
                              ? Icons.notification_add_outlined
                              : Icons.payments_outlined,
                          size: 20,
                        ),
                        label: Text(
                          canRequest
                              ? t.paymentRequestAction
                              : t.paymentRecordAction,
                        ),
                      ),
                    if (canAct)
                      FilledButton.icon(
                        onPressed: _isMutating
                            ? null
                            : () => item.canConfirmReceived
                                  ? _onSettlementConfirmReceived(item)
                                  : _onSettlementMarkSent(item),
                        icon: Icon(
                          item.canConfirmReceived
                              ? Icons.check_circle_outline
                              : Icons.payments_outlined,
                          size: 20,
                        ),
                        label: Text(
                          item.canConfirmReceived
                              ? t.confirmReceivedAction
                              : t.iSentAction,
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => _openSettlementFlowTimelineSheet(
                        snapshot: snapshot,
                        item: item,
                        usersById: usersById,
                      ),
                      icon: const Icon(Icons.more_horiz, size: 20),
                      label: Text(t.workspaceOpenFlow),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
