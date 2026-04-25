part of 'workspace_page.dart';

extension _WorkspacePageSettlementDetails on _WorkspacePageState {
  Future<void> _openSettlementFlowTimelineSheet({
    required WorkspaceSnapshot snapshot,
    required SettlementItem item,
    required Map<int, WorkspaceUser> usersById,
  }) async {
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final t = sheetContext.l10n;
            final semantic =
                Theme.of(sheetContext).extension<AppSemanticColors>() ??
                AppSemanticColors.light;
            final liveSnapshot = _snapshot ?? snapshot;
            final liveItem = _resolveLiveSettlement(
              snapshot: liveSnapshot,
              fallback: item,
            );

            final normalizedStatus = liveItem.status.trim().toLowerCase();
            final fromUser = usersById[liveItem.fromUserId];
            final toUser = usersById[liveItem.toUserId];
            final fromName =
                (fromUser?.preferredName ?? liveItem.from).trim().isEmpty
                ? t.userWithId(liveItem.fromUserId)
                : (fromUser?.preferredName ?? liveItem.from).trim();
            final toName = (toUser?.preferredName ?? liveItem.to).trim().isEmpty
                ? t.userWithId(liveItem.toUserId)
                : (toUser?.preferredName ?? liveItem.to).trim();

            final isTripFinished = !liveSnapshot.isActive;
            final isPaid =
                normalizedStatus == 'sent' || normalizedStatus == 'confirmed';
            final isConfirmed = normalizedStatus == 'confirmed';
            final isSettled = isConfirmed && liveSnapshot.allSettled;
            final tripFinishedAt =
                liveSnapshot.tripEndedAt ?? liveItem.createdAt;
            final paidAt = liveItem.markedSentAt ?? liveItem.confirmedAt;
            final confirmedAt = liveItem.confirmedAt;
            final settledAt = _resolveSettledAtRaw(liveSnapshot, liveItem);

            final steps = <_SettlementFlowStep>[
              _SettlementFlowStep(
                title: sheetContext.l10n.workspaceTripFinished,
                subtitle: isTripFinished
                    ? sheetContext
                          .l10n
                          .workspaceSettlementsAreUnlockedForThisTrip
                    : sheetContext.l10n.workspaceFinishTripToStartSettlements,
                icon: Icons.flag_rounded,
                isDone: isTripFinished,
                completedAtRaw: isTripFinished ? tripFinishedAt : null,
              ),
              _SettlementFlowStep(
                title: sheetContext.l10n.paidLabel,
                subtitle: isPaid
                    ? sheetContext.l10n.workspaceMarkedTransferAsSent(fromName)
                    : sheetContext.l10n.workspaceWaitingForToMarkAsPaid(
                        fromName,
                      ),
                icon: Icons.payments_rounded,
                isDone: isPaid,
                completedAtRaw: isPaid ? paidAt : null,
              ),
              _SettlementFlowStep(
                title: sheetContext.l10n.statusConfirmed,
                subtitle: isConfirmed
                    ? sheetContext.l10n.workspaceConfirmedReceivingThePayment(
                        toName,
                      )
                    : sheetContext.l10n.workspaceWaitingForToConfirm(toName),
                icon: Icons.verified_rounded,
                isDone: isConfirmed,
                completedAtRaw: isConfirmed ? confirmedAt : null,
              ),
              _SettlementFlowStep(
                title: sheetContext.l10n.settledStatus,
                subtitle: isSettled
                    ? sheetContext
                          .l10n
                          .workspaceAllTripSettlementsAreFullyCompleted
                    : sheetContext
                          .l10n
                          .workspaceFinalStateAfterAllTransfersAreConfirmed,
                icon: Icons.done_all_rounded,
                isDone: isSettled,
                completedAtRaw: isSettled ? settledAt : null,
              ),
            ];

            final activeIndex = steps.indexWhere((step) => !step.isDone);
            final highlightIndex = activeIndex == -1
                ? steps.length - 1
                : activeIndex;

            final canMutateSettlement = !liveSnapshot.isArchived;
            final canRemind =
                canMutateSettlement &&
                liveItem.id != null &&
                ((normalizedStatus == 'pending' &&
                        _currentUserId > 0 &&
                        _currentUserId == liveItem.toUserId) ||
                    (normalizedStatus == 'sent' &&
                        _currentUserId > 0 &&
                        _currentUserId == liveItem.fromUserId));

            final canPrimaryAction =
                canMutateSettlement &&
                (liveItem.canMarkSent || liveItem.canConfirmReceived);
            final primaryActionLabel = liveItem.canConfirmReceived
                ? t.confirmReceivedAction
                : t.iSentAction;
            final primaryActionIcon = liveItem.canConfirmReceived
                ? Icons.verified_rounded
                : Icons.payments_rounded;
            final quickRevolutUri = _buildSettlementRevolutQuickPayUri(
              settlement: liveItem,
              payee: toUser,
              currencyCode: widget.trip.currencyCode,
            );
            final quickPaypalUri = _buildSettlementPaypalQuickPayUri(
              settlement: liveItem,
              payee: toUser,
              currencyCode: widget.trip.currencyCode,
            );
            final quickWiseUri = _buildSettlementWiseQuickPayUri(
              settlement: liveItem,
              payee: toUser,
              currencyCode: widget.trip.currencyCode,
            );
            final hasQuickPayActions =
                quickRevolutUri != null ||
                quickPaypalUri != null ||
                quickWiseUri != null;

            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.9,
                child: Container(
                  decoration: BoxDecoration(
                    color: semantic.sheetSurface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 46,
                        height: 6,
                        decoration: BoxDecoration(
                          color: semantic.sheetHandle,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    sheetContext.l10n.workspaceSettlementFlow,
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      Navigator.of(sheetContext).pop(),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: semantic.sheetPanelSurfaceMuted,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: semantic.sheetBorder),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildSettlementPartyCard(
                                          context: sheetContext,
                                          label: sheetContext.l10n.tripsFrom,
                                          name: fromName,
                                          icon: Icons.north_east_rounded,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: semantic.flowStepCurrent
                                                .withValues(alpha: 0.20),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                            color: semantic.flowStepCurrent,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildSettlementPartyCard(
                                          context: sheetContext,
                                          label: sheetContext.l10n.tripsTo,
                                          name: toName,
                                          icon: Icons.south_west_rounded,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: semantic.sheetPanelSurface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: semantic.sheetBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.payments_outlined,
                                          size: 18,
                                          color: semantic.flowStepCurrent,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          sheetContext.l10n.amountLabel,
                                          style: Theme.of(sheetContext)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppDesign.mutedColor(
                                                  sheetContext,
                                                ),
                                              ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatMoney(
                                            sheetContext,
                                            liveItem.amount,
                                            currencyCode:
                                                widget.trip.currencyCode,
                                          ),
                                          style: Theme.of(sheetContext)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: semantic.flowStepCurrent,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSettlementFlowSteps(
                              context: sheetContext,
                              steps: steps,
                              highlightIndex: highlightIndex,
                            ),
                            const SizedBox(height: 16),
                            for (var i = 0; i < steps.length; i++) ...[
                              _buildSettlementFlowEventTile(
                                context: sheetContext,
                                step: steps[i],
                                isCurrent:
                                    !steps[i].isDone && i == highlightIndex,
                              ),
                              if (i < steps.length - 1)
                                const SizedBox(height: 10),
                            ],
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: semantic.sheetPanelSurfaceMuted,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: semantic.sheetBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sheetContext.l10n.workspaceActions,
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 8),
                                  if (hasQuickPayActions) ...[
                                    Text(
                                      sheetContext.l10n.workspaceQuickPay,
                                      style: Theme.of(sheetContext)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppDesign.mutedColor(
                                              sheetContext,
                                            ),
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (quickRevolutUri != null)
                                          OutlinedButton.icon(
                                            onPressed: _isMutating
                                                ? null
                                                : () =>
                                                      _openSettlementPaymentLink(
                                                        quickRevolutUri,
                                                      ),
                                            icon: const Icon(
                                              Icons.bolt_rounded,
                                              size: 17,
                                            ),
                                            label: Text(
                                              sheetContext
                                                  .l10n
                                                  .workspacePayWithRevolut,
                                            ),
                                          ),
                                        if (quickPaypalUri != null)
                                          OutlinedButton.icon(
                                            onPressed: _isMutating
                                                ? null
                                                : () =>
                                                      _openSettlementPaymentLink(
                                                        quickPaypalUri,
                                                      ),
                                            icon: const Icon(
                                              Icons.paypal_rounded,
                                              size: 17,
                                            ),
                                            label: Text(
                                              sheetContext
                                                  .l10n
                                                  .workspacePayWithPaypal,
                                            ),
                                          ),
                                        if (quickWiseUri != null)
                                          OutlinedButton.icon(
                                            onPressed: _isMutating
                                                ? null
                                                : () =>
                                                      _openSettlementPaymentLink(
                                                        quickWiseUri,
                                                      ),
                                            icon: const Icon(
                                              Icons.currency_exchange_rounded,
                                              size: 17,
                                            ),
                                            label: Text(
                                              sheetContext
                                                  .l10n
                                                  .workspacePayWithWise,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  if (canPrimaryAction)
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        onPressed: _isMutating
                                            ? null
                                            : () async {
                                                if (liveItem
                                                    .canConfirmReceived) {
                                                  await _onSettlementConfirmReceived(
                                                    liveItem,
                                                  );
                                                } else if (liveItem
                                                    .canMarkSent) {
                                                  await _onSettlementMarkSent(
                                                    liveItem,
                                                  );
                                                }
                                                if (!mounted ||
                                                    !sheetContext.mounted) {
                                                  return;
                                                }
                                                setSheetState(() {});
                                              },
                                        icon: Icon(primaryActionIcon),
                                        label: Text(primaryActionLabel),
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              semantic.flowStepCurrent,
                                          foregroundColor:
                                              AppDesign.darkForeground,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Text(
                                      isConfirmed
                                          ? sheetContext
                                                .l10n
                                                .workspaceTransferIsConfirmed
                                          : sheetContext
                                                .l10n
                                                .workspaceWaitingForTheOtherMemberToCompleteTheNextStep,
                                      style: Theme.of(sheetContext)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppDesign.mutedColor(
                                              sheetContext,
                                            ),
                                          ),
                                    ),
                                  if (canRemind) ...[
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: _isMutating
                                          ? null
                                          : () async {
                                              await _onSettlementRemind(
                                                liveItem,
                                              );
                                              if (!mounted ||
                                                  !sheetContext.mounted) {
                                                return;
                                              }
                                              setSheetState(() {});
                                            },
                                      icon: const Icon(
                                        Icons.notifications_active_outlined,
                                        size: 17,
                                      ),
                                      label: Text(
                                        context.l10n.workspaceSendReminder,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  SettlementItem _resolveLiveSettlement({
    required WorkspaceSnapshot snapshot,
    required SettlementItem fallback,
  }) {
    final targetId = fallback.id;
    if (targetId != null && targetId > 0) {
      for (final row in snapshot.settlements) {
        if (row.id == targetId) {
          return row;
        }
      }
    }

    for (final row in snapshot.settlements) {
      final samePair =
          row.fromUserId == fallback.fromUserId &&
          row.toUserId == fallback.toUserId;
      final sameAmount = (row.amount - fallback.amount).abs() < 0.001;
      if (samePair && sameAmount) {
        return row;
      }
    }

    return fallback;
  }

  String? _resolveSettledAtRaw(
    WorkspaceSnapshot snapshot,
    SettlementItem settlement,
  ) {
    final archivedAt = (snapshot.tripArchivedAt ?? '').trim();
    if (archivedAt.isNotEmpty) {
      return archivedAt;
    }
    final latestConfirmed = _latestConfirmedAtRaw(snapshot.settlements);
    if (latestConfirmed != null) {
      return latestConfirmed;
    }
    return settlement.confirmedAt;
  }

  String? _latestConfirmedAtRaw(List<SettlementItem> settlements) {
    String? latestRaw;
    DateTime? latestMoment;
    for (final item in settlements) {
      final raw = (item.confirmedAt ?? '').trim();
      if (raw.isEmpty) {
        continue;
      }
      final parsed = _parseSettlementMoment(raw);
      if (parsed == null) {
        continue;
      }
      if (latestMoment == null || parsed.isAfter(latestMoment)) {
        latestMoment = parsed;
        latestRaw = raw;
      }
    }
    return latestRaw;
  }

  DateTime? _parseSettlementMoment(String? raw) {
    final normalized = (raw ?? '').trim();
    if (normalized.isEmpty) {
      return null;
    }
    final direct = DateTime.tryParse(normalized);
    if (direct != null) {
      return direct.toLocal();
    }
    final withIsoSeparator = DateTime.tryParse(
      normalized.replaceFirst(' ', 'T'),
    );
    return withIsoSeparator?.toLocal();
  }

  String? _formatSettlementStepTime(BuildContext context, String? raw) {
    final moment = _parseSettlementMoment(raw);
    if (moment == null) {
      return null;
    }
    final now = DateTime.now();
    final hh = moment.hour.toString().padLeft(2, '0');
    final mm = moment.minute.toString().padLeft(2, '0');
    final time = '$hh:$mm';
    final isToday =
        moment.year == now.year &&
        moment.month == now.month &&
        moment.day == now.day;
    if (isToday) {
      return time;
    }
    return '${AppFormatters.shortDayMonth(context, moment)} $time';
  }

  Widget _buildSettlementPartyCard({
    required BuildContext context,
    required String label,
    required String name,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.light;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: semantic.sheetPanelSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: semantic.sheetBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: semantic.flowStepCurrent),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppDesign.mutedColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementFlowSteps({
    required BuildContext context,
    required List<_SettlementFlowStep> steps,
    required int highlightIndex,
  }) {
    return _AnimatedSettlementTimeline(
      steps: steps,
      highlightIndex: highlightIndex,
    );
  }

  Widget _buildSettlementFlowEventTile({
    required BuildContext context,
    required _SettlementFlowStep step,
    required bool isCurrent,
  }) {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.light;
    final stateLabel = step.isDone
        ? context.l10n.doneStatus
        : (isCurrent
              ? context.l10n.workspaceInProgress
              : context.l10n.statusPending);
    final stateColor = step.isDone
        ? semantic.flowStepDone
        : (isCurrent ? semantic.flowStepCurrent : semantic.flowStepPending);
    final completedAtLabel = step.isDone
        ? _formatSettlementStepTime(context, step.completedAtRaw)
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? semantic.sheetPanelSurfaceHighlighted
            : semantic.sheetPanelSurfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? stateColor.withValues(alpha: 0.36)
              : semantic.sheetBorder,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: semantic.flowHighlightShadow,
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              step.isDone ? Icons.check_rounded : step.icon,
              size: 17,
              color: stateColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  step.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  stateLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: stateColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (step.isDone) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      completedAtLabel ?? context.l10n.workspaceTimeUnknown,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openSettlementProgressDetails(
    WorkspaceSnapshot snapshot,
  ) async {
    var selectedUserId =
        _currentUserId > 0 &&
            snapshot.users.any((user) => user.id == _currentUserId)
        ? _currentUserId
        : 0;

    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final t = context.l10n;
            final liveSnapshot = _snapshot ?? snapshot;
            final settlements = selectedUserId > 0
                ? liveSnapshot.settlements
                      .where(
                        (row) =>
                            row.fromUserId == selectedUserId ||
                            row.toUserId == selectedUserId,
                      )
                      .toList(growable: false)
                : liveSnapshot.settlements;

            final pendingCount = settlements
                .where((row) => row.status.trim().toLowerCase() == 'pending')
                .length;
            final sentCount = settlements
                .where((row) => row.status.trim().toLowerCase() == 'sent')
                .length;
            final confirmedCount = settlements
                .where((row) => row.status.trim().toLowerCase() == 'confirmed')
                .length;
            final filterName = selectedUserId <= 0
                ? null
                : liveSnapshot.users
                      .where((user) => user.id == selectedUserId)
                      .map((user) => user.nickname)
                      .firstOrNull;

            final title = liveSnapshot.isArchived
                ? t.settlementCompletedTitle
                : (liveSnapshot.isActive
                      ? t.settlementPreviewTitle
                      : t.settlementInProgressTitle);
            final subtitle = liveSnapshot.isArchived
                ? t.settlementsAlreadyCompletedSubtitle
                : (liveSnapshot.isActive
                      ? t.suggestedTransfersSubtitle
                      : t.pendingPaymentsSubtitle);

            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.92,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetHeadlineCard(
                        icon: Icons.swap_horiz,
                        title: title,
                        subtitle: subtitle,
                        color: Theme.of(context).colorScheme.primary,
                        meta: [
                          _DetailChip(
                            icon: Icons.list_alt_outlined,
                            label: t.rowsLabel,
                            value: '${settlements.length}',
                          ),
                          _DetailChip(
                            icon: Icons.check_circle_outline,
                            label: t.confirmedLabel,
                            value: '$confirmedCount',
                          ),
                          _DetailChip(
                            icon: Icons.hourglass_bottom,
                            label: t.openLabel,
                            value: '${pendingCount + sentCount}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SheetSectionTitle(
                        title: t.viewByPersonTitle,
                        subtitle: t.filterSettlementByMemberSubtitle,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: Text(t.allFilter),
                            selected: selectedUserId == 0,
                            onSelected: (_) {
                              setSheetState(() {
                                selectedUserId = 0;
                              });
                            },
                          ),
                          if (_currentUserId > 0)
                            FilterChip(
                              label: Text(t.youLabel),
                              selected: selectedUserId == _currentUserId,
                              onSelected: (_) {
                                setSheetState(() {
                                  selectedUserId = _currentUserId;
                                });
                              },
                            ),
                          for (final user in liveSnapshot.users)
                            FilterChip(
                              label: Text(user.nickname),
                              selected: selectedUserId == user.id,
                              onSelected: (_) {
                                setSheetState(() {
                                  selectedUserId = user.id;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SheetSectionTitle(
                        title: selectedUserId > 0
                            ? t.whoOwesWhatWithFilter(
                                filterName ?? t.selectedLabel,
                              )
                            : t.whoOwesWhatTitle,
                        subtitle: t.whoOwesWhatSubtitle,
                      ),
                      const SizedBox(height: 8),
                      if (settlements.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              selectedUserId > 0
                                  ? t.noSettlementActivityForMember
                                  : t.noSettlementRowsYet,
                            ),
                          ),
                        )
                      else
                        Card(
                          child: Column(
                            children: [
                              for (var i = 0; i < settlements.length; i++) ...[
                                Builder(
                                  builder: (context) {
                                    final item = settlements[i];
                                    final normalizedStatus = item.status
                                        .trim()
                                        .toLowerCase();
                                    final canRemind =
                                        item.id != null &&
                                        ((normalizedStatus == 'pending' &&
                                                _currentUserId > 0 &&
                                                _currentUserId ==
                                                    item.toUserId) ||
                                            (normalizedStatus == 'sent' &&
                                                _currentUserId > 0 &&
                                                _currentUserId ==
                                                    item.fromUserId));

                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        10,
                                        8,
                                        10,
                                        8,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _settlementPairTitle(
                                                      context,
                                                      item.from,
                                                      item.to,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      item.id != null
                                                          ? t.settlementWithId(
                                                              item.id!,
                                                            )
                                                          : _settlementPairText(
                                                              item.from,
                                                              item.to,
                                                            ),
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.bodySmall,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatMoney(
                                                  context,
                                                  item.amount,
                                                  currencyCode:
                                                      widget.trip.currencyCode,
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 9,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _settlementStatusColor(
                                                    context,
                                                    item.status,
                                                  ).withValues(alpha: 0.14),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                  border: Border.all(
                                                    color:
                                                        _settlementStatusColor(
                                                          context,
                                                          item.status,
                                                        ).withValues(
                                                          alpha: 0.32,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  _settlementStatusLabel(
                                                    context,
                                                    item.status,
                                                  ),
                                                  style: TextStyle(
                                                    color:
                                                        _settlementStatusColor(
                                                          context,
                                                          item.status,
                                                        ),
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              if (canRemind)
                                                TextButton.icon(
                                                  onPressed: _isMutating
                                                      ? null
                                                      : () async {
                                                          await _onSettlementRemind(
                                                            item,
                                                          );
                                                          if (!mounted ||
                                                              !context
                                                                  .mounted) {
                                                            return;
                                                          }
                                                          setSheetState(() {});
                                                        },
                                                  icon: const Icon(
                                                    Icons
                                                        .notifications_active_outlined,
                                                    size: 17,
                                                  ),
                                                  label: Text(
                                                    context
                                                        .l10n
                                                        .workspaceRemind,
                                                  ),
                                                ),
                                              if (item.canMarkSent)
                                                TextButton.icon(
                                                  onPressed: _isMutating
                                                      ? null
                                                      : () async {
                                                          await _onSettlementMarkSent(
                                                            item,
                                                          );
                                                          if (!mounted ||
                                                              !context
                                                                  .mounted) {
                                                            return;
                                                          }
                                                          setSheetState(() {});
                                                        },
                                                  icon: const Icon(
                                                    Icons.send_outlined,
                                                    size: 17,
                                                  ),
                                                  label: Text(t.iSentAction),
                                                ),
                                              if (item.canConfirmReceived)
                                                TextButton.icon(
                                                  onPressed: _isMutating
                                                      ? null
                                                      : () async {
                                                          await _onSettlementConfirmReceived(
                                                            item,
                                                          );
                                                          if (!mounted ||
                                                              !context
                                                                  .mounted) {
                                                            return;
                                                          }
                                                          setSheetState(() {});
                                                        },
                                                  icon: const Icon(
                                                    Icons.check_circle_outline,
                                                    size: 17,
                                                  ),
                                                  label: Text(
                                                    t.confirmReceivedAction,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                if (i < settlements.length - 1)
                                  const Divider(height: 1),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                settlements.isEmpty
                                    ? t.noSettlements
                                    : t.settlementCountLabel(
                                        settlements.length,
                                      ),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _DetailChip(
                                    icon: Icons.hourglass_bottom,
                                    label: t.pendingLabel,
                                    value: t.breakdownPendingCount(
                                      pendingCount,
                                    ),
                                  ),
                                  _DetailChip(
                                    icon: Icons.send_outlined,
                                    label: t.statusSent,
                                    value: t.breakdownSentCount(sentCount),
                                  ),
                                  _DetailChip(
                                    icon: Icons.check_circle_outline,
                                    label: t.confirmedLabel,
                                    value: t.breakdownConfirmedCount(
                                      confirmedCount,
                                    ),
                                  ),
                                ],
                              ),
                              if (liveSnapshot.allSettled) ...[
                                const SizedBox(height: 8),
                                Text(
                                  t.allPaymentsConfirmed,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openSettlementPaymentLink(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !mounted) {
      return;
    }
    _showSnack(context.l10n.workspaceCouldNotOpenPaymentLink, isError: true);
  }

  Uri? _buildSettlementRevolutQuickPayUri({
    required SettlementItem settlement,
    required WorkspaceUser? payee,
    required String currencyCode,
  }) {
    if (!settlement.canMarkSent || payee == null) {
      return null;
    }

    final revolutMeRaw = (payee.revolutMeLink ?? '').trim();
    final revolutHandleRaw = (payee.revolutHandle ?? '').trim();
    final revolutBase =
        _revolutMeUriOrNull(revolutMeRaw) ??
        _revolutMeUriFromHandle(revolutHandleRaw);
    if (revolutBase == null) {
      return null;
    }

    final amountPart = _settlementAmountPathSegment(settlement.amount);
    final query = <String, String>{...revolutBase.queryParameters};
    final currency = currencyCode.trim().toUpperCase();
    if (currency.isNotEmpty) {
      query.putIfAbsent('currency', () => currency);
    }

    return _withSettlementAmountPath(
      revolutBase,
      amountPart,
      queryParameters: query,
    );
  }

  Uri? _buildSettlementPaypalQuickPayUri({
    required SettlementItem settlement,
    required WorkspaceUser? payee,
    required String currencyCode,
  }) {
    if (!settlement.canMarkSent || payee == null) {
      return null;
    }

    final paypalRaw = (payee.paypalMeLink ?? '').trim();
    final paypalBase = _paypalMeUriOrNull(paypalRaw);
    if (paypalBase == null) {
      return null;
    }

    final currency = currencyCode.trim().toUpperCase();
    final amountPart =
        '${_settlementAmountPathSegment(settlement.amount)}$currency';
    return _withSettlementAmountPath(paypalBase, amountPart);
  }

  Uri? _buildSettlementWiseQuickPayUri({
    required SettlementItem settlement,
    required WorkspaceUser? payee,
    required String currencyCode,
  }) {
    if (!settlement.canMarkSent || payee == null) {
      return null;
    }

    final wiseRaw = (payee.wisePayLink ?? '').trim();
    final wiseBase = _wisePayUriOrNull(wiseRaw);
    if (wiseBase == null) {
      return null;
    }

    final query = <String, String>{...wiseBase.queryParameters};
    query['amount'] = _settlementAmountPathSegment(settlement.amount);
    final currency = currencyCode.trim().toUpperCase();
    if (currency.isNotEmpty) {
      query['currency'] = currency;
    }
    return wiseBase.replace(queryParameters: query.isEmpty ? null : query);
  }

  Uri? _withSettlementAmountPath(
    Uri base,
    String amountPathSegment, {
    Map<String, String>? queryParameters,
  }) {
    final segments = base.pathSegments
        .where((segment) => segment.trim().isNotEmpty)
        .toList(growable: false);
    if (segments.isEmpty) {
      return null;
    }
    final account = segments.first;
    final query = queryParameters ?? base.queryParameters;
    return base.replace(
      pathSegments: [account, amountPathSegment],
      queryParameters: query.isEmpty ? null : query,
    );
  }

  Uri? _paypalMeUriOrNull(String rawValue) {
    final raw = rawValue.trim();
    if (raw.isEmpty) {
      return null;
    }

    if (!raw.contains('.') && !raw.contains('/') && !raw.contains('://')) {
      return Uri.parse('https://paypal.me/$raw');
    }

    final candidate = raw.contains('://') ? raw : 'https://$raw';
    final uri = Uri.tryParse(candidate);
    if (uri == null) {
      return null;
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return null;
    }

    final host = uri.host.toLowerCase().trim();
    if (host != 'paypal.me' && host != 'www.paypal.me') {
      return null;
    }
    if (uri.pathSegments.where((s) => s.trim().isNotEmpty).isEmpty) {
      return null;
    }
    return uri;
  }

  Uri? _revolutMeUriOrNull(String rawValue) {
    final raw = rawValue.trim();
    if (raw.isEmpty) {
      return null;
    }
    final candidate = raw.contains('://') ? raw : 'https://$raw';
    final uri = Uri.tryParse(candidate);
    if (uri == null) {
      return null;
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return null;
    }
    final host = uri.host.toLowerCase().trim();
    if (host != 'revolut.me' && host != 'www.revolut.me') {
      return null;
    }
    if (uri.pathSegments.where((s) => s.trim().isNotEmpty).isEmpty) {
      return null;
    }
    return uri;
  }

  Uri? _revolutMeUriFromHandle(String rawHandle) {
    final normalized = rawHandle.trim().replaceFirst(RegExp(r'^@+'), '');
    if (normalized.isEmpty) {
      return null;
    }
    if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(normalized)) {
      return null;
    }
    return Uri.parse('https://revolut.me/$normalized');
  }

  Uri? _wisePayUriOrNull(String rawValue) {
    final raw = rawValue.trim();
    if (raw.isEmpty) {
      return null;
    }

    if (!raw.contains('.') && !raw.contains('/') && !raw.contains('://')) {
      return Uri.parse('https://wise.com/pay/me/$raw');
    }

    final candidate = raw.contains('://') ? raw : 'https://$raw';
    final uri = Uri.tryParse(candidate);
    if (uri == null) {
      return null;
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return null;
    }
    final host = uri.host.toLowerCase().trim();
    if (host != 'wise.com' && host != 'www.wise.com') {
      return null;
    }
    if (uri.pathSegments.where((s) => s.trim().isNotEmpty).isEmpty) {
      return null;
    }
    return uri;
  }

  String _settlementAmountPathSegment(double amount) {
    final fixed = amount.toStringAsFixed(2);
    return fixed.endsWith('.00') ? fixed.substring(0, fixed.length - 3) : fixed;
  }
}

class _SettlementFlowStep {
  const _SettlementFlowStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDone,
    this.completedAtRaw,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDone;
  final String? completedAtRaw;
}

// ─── Animated step-by-step timeline ──────────────────────────────────────────

class _AnimatedSettlementTimeline extends StatefulWidget {
  const _AnimatedSettlementTimeline({
    required this.steps,
    required this.highlightIndex,
  });

  final List<_SettlementFlowStep> steps;
  final int highlightIndex;

  @override
  State<_AnimatedSettlementTimeline> createState() =>
      _AnimatedSettlementTimelineState();
}

class _AnimatedSettlementTimelineState
    extends State<_AnimatedSettlementTimeline>
    with TickerProviderStateMixin {
  // One scale controller per dot — elasticOut pop-in.
  late final List<AnimationController> _dotControllers;
  late final List<Animation<double>> _dotScales;
  // Separate easeOut curve for label opacity so elastic overshoot doesn't clip.
  late final List<Animation<double>> _dotFades;

  // One controller per connector segment — easeOut draw-in from left.
  late final List<AnimationController> _connectorControllers;

  // Looping pulse for the active (current) dot.
  AnimationController? _pulseController;
  Animation<double>? _pulseAnim;

  @override
  void initState() {
    super.initState();
    final n = widget.steps.length;

    _dotControllers = List.generate(
      n,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 420),
      ),
    );
    _dotScales = _dotControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.elasticOut))
        .toList();
    _dotFades = _dotControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _connectorControllers = List.generate(
      (n - 1).clamp(0, n),
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    // Pulse only when there is an active step that isn't finished yet.
    final hasActive = widget.steps.any((s) => !s.isDone);
    if (hasActive) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1300),
      );
      _pulseAnim = Tween<double>(begin: 1.0, end: 1.14).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
      _pulseController!.repeat(reverse: true);
    }

    _runEntrance();
  }

  /// Staggers the dot pop-ins and connector draw-ins.
  ///   dot[0]       → t = 60 ms
  ///   connector[0] → t = 130 ms
  ///   dot[1]       → t = 180 ms
  ///   connector[1] → t = 250 ms
  ///   …
  void _runEntrance() {
    const initialDelay = 60;
    const stagger = 120;
    const connectorOffset = 70;

    for (var i = 0; i < widget.steps.length; i++) {
      final t = initialDelay + i * stagger;
      Future<void>.delayed(Duration(milliseconds: t), () {
        if (mounted) _dotControllers[i].forward();
      });
      if (i < _connectorControllers.length) {
        Future<void>.delayed(Duration(milliseconds: t + connectorOffset), () {
          if (mounted) _connectorControllers[i].forward();
        });
      }
    }
  }

  @override
  void dispose() {
    for (final c in _dotControllers) {
      c.dispose();
    }
    for (final c in _connectorControllers) {
      c.dispose();
    }
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.light;
    final steps = widget.steps;
    final n = steps.length;
    final hi = widget.highlightIndex;

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < n; i++) ...[
              ScaleTransition(
                scale: _dotScales[i],
                child: _buildDot(context, steps[i], i, hi, semantic),
              ),
              if (i < n - 1)
                Expanded(
                  child: _buildConnector(
                    context,
                    index: i,
                    nextIsDone: steps[i + 1].isDone,
                    semantic: semantic,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < n; i++)
              Expanded(
                child: FadeTransition(
                  opacity: _dotFades[i],
                  child: Text(
                    steps[i].title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: steps[i].isDone
                          ? semantic.flowStepDone
                          : (i == hi
                                ? semantic.flowStepCurrent
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDot(
    BuildContext context,
    _SettlementFlowStep step,
    int index,
    int highlightIndex,
    AppSemanticColors semantic,
  ) {
    final isDone = step.isDone;
    final isCurrent = !isDone && index == highlightIndex;
    final baseColor = isDone
        ? semantic.flowStepDone
        : (isCurrent ? semantic.flowStepCurrent : semantic.flowStepPending);

    Widget dot = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: baseColor.withValues(alpha: isDone || isCurrent ? 0.18 : 0.12),
        border: Border.all(
          color: baseColor.withValues(alpha: isDone || isCurrent ? 0.88 : 0.44),
          width: isCurrent ? 1.8 : 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        isDone ? Icons.check_rounded : step.icon,
        size: 17,
        color: baseColor,
      ),
    );

    // Wrap the current dot in a looping pulse.
    final pulse = _pulseAnim;
    if (isCurrent && pulse != null) {
      dot = AnimatedBuilder(
        animation: pulse,
        builder: (_, child) =>
            Transform.scale(scale: pulse.value, child: child),
        child: dot,
      );
    }

    return dot;
  }

  Widget _buildConnector(
    BuildContext context, {
    required int index,
    required bool nextIsDone,
    required AppSemanticColors semantic,
  }) {
    final color = nextIsDone
        ? semantic.flowConnectorDone
        : semantic.flowConnectorPending;

    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _connectorControllers[index],
            builder: (_, child) {
              final fill = _connectorControllers[index].value;
              return Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: constraints.maxWidth * fill,
                  height: 2,
                  child: ColoredBox(color: color),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
