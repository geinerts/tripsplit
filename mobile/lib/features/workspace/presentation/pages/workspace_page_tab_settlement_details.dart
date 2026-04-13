part of 'workspace_page.dart';

extension _WorkspacePageSettlementDetails on _WorkspacePageState {
  Future<void> _openSettlementFlowTimelineSheet({
    required WorkspaceSnapshot snapshot,
    required SettlementItem item,
    required Map<int, WorkspaceUser> usersById,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
                title: _localizedText(
                  sheetContext,
                  en: 'Trip finished',
                  lv: 'Trip pabeigts',
                ),
                subtitle: isTripFinished
                    ? _localizedText(
                        sheetContext,
                        en: 'Settlements are unlocked for this trip.',
                        lv: 'Norēķini šim tripam ir atvērti.',
                      )
                    : _localizedText(
                        sheetContext,
                        en: 'Finish trip to start settlements.',
                        lv: 'Pabeidz trip, lai sāktu norēķinus.',
                      ),
                icon: Icons.flag_rounded,
                isDone: isTripFinished,
                completedAtRaw: isTripFinished ? tripFinishedAt : null,
              ),
              _SettlementFlowStep(
                title: _localizedText(
                  sheetContext,
                  en: 'Paid',
                  lv: 'Apmaksāts',
                ),
                subtitle: isPaid
                    ? _localizedText(
                        sheetContext,
                        en: '$fromName marked transfer as sent.',
                        lv: '$fromName atzīmēja pārskaitījumu kā nosūtītu.',
                      )
                    : _localizedText(
                        sheetContext,
                        en: 'Waiting for $fromName to mark as paid.',
                        lv: 'Gaida, kad $fromName atzīmēs kā apmaksātu.',
                      ),
                icon: Icons.payments_rounded,
                isDone: isPaid,
                completedAtRaw: isPaid ? paidAt : null,
              ),
              _SettlementFlowStep(
                title: _localizedText(
                  sheetContext,
                  en: 'Confirmed',
                  lv: 'Apstiprināts',
                ),
                subtitle: isConfirmed
                    ? _localizedText(
                        sheetContext,
                        en: '$toName confirmed receiving the payment.',
                        lv: '$toName apstiprināja maksājuma saņemšanu.',
                      )
                    : _localizedText(
                        sheetContext,
                        en: 'Waiting for $toName to confirm.',
                        lv: 'Gaida, kad $toName apstiprinās.',
                      ),
                icon: Icons.verified_rounded,
                isDone: isConfirmed,
                completedAtRaw: isConfirmed ? confirmedAt : null,
              ),
              _SettlementFlowStep(
                title: _localizedText(
                  sheetContext,
                  en: 'Settled',
                  lv: 'Norēķināts',
                ),
                subtitle: isSettled
                    ? _localizedText(
                        sheetContext,
                        en: 'All trip settlements are fully completed.',
                        lv: 'Visi trip norēķini ir pilnībā pabeigti.',
                      )
                    : _localizedText(
                        sheetContext,
                        en: 'Final state after all transfers are confirmed.',
                        lv: 'Gala stāvoklis, kad visi pārskaitījumi apstiprināti.',
                      ),
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
                                    _localizedText(
                                      sheetContext,
                                      en: 'Settlement flow',
                                      lv: 'Norēķina plūsma',
                                    ),
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
                                          label: _localizedText(
                                            sheetContext,
                                            en: 'From',
                                            lv: 'No',
                                          ),
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
                                          label: _localizedText(
                                            sheetContext,
                                            en: 'To',
                                            lv: 'Uz',
                                          ),
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
                                          _localizedText(
                                            sheetContext,
                                            en: 'Amount',
                                            lv: 'Summa',
                                          ),
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
                                    _localizedText(
                                      sheetContext,
                                      en: 'Actions',
                                      lv: 'Darbības',
                                    ),
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 8),
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
                                          ? _localizedText(
                                              sheetContext,
                                              en: 'Transfer is confirmed.',
                                              lv: 'Pārskaitījums ir apstiprināts.',
                                            )
                                          : _localizedText(
                                              sheetContext,
                                              en: 'Waiting for the other member to complete the next step.',
                                              lv: 'Gaida, kad otrs dalībnieks pabeigs nākamo soli.',
                                            ),
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
                                        _plainLocalizedText(
                                          en: 'Send reminder',
                                          lv: 'Nosūtīt atgādinājumu',
                                        ),
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
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.light;
    final inactiveColor = semantic.flowConnectorPending;

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              _buildSettlementFlowDot(
                context: context,
                icon: steps[i].icon,
                isDone: steps[i].isDone,
                isCurrent: !steps[i].isDone && i == highlightIndex,
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: steps[i + 1].isDone
                        ? semantic.flowConnectorDone
                        : inactiveColor,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < steps.length; i++)
              Expanded(
                child: Text(
                  steps[i].title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: steps[i].isDone
                        ? semantic.flowStepDone
                        : (!steps[i].isDone && i == highlightIndex
                              ? semantic.flowStepCurrent
                              : Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettlementFlowDot({
    required BuildContext context,
    required IconData icon,
    required bool isDone,
    required bool isCurrent,
  }) {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.light;
    final baseColor = isDone
        ? semantic.flowStepDone
        : (isCurrent ? semantic.flowStepCurrent : semantic.flowStepPending);
    return Container(
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
        isDone ? Icons.check_rounded : icon,
        size: 17,
        color: baseColor,
      ),
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
        ? _localizedText(context, en: 'Done', lv: 'Pabeigts')
        : (isCurrent
              ? _localizedText(context, en: 'In progress', lv: 'Procesā')
              : _localizedText(context, en: 'Pending', lv: 'Gaida'));
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
                      completedAtLabel ??
                          _localizedText(
                            context,
                            en: 'Time unknown',
                            lv: 'Laiks nav zināms',
                          ),
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

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
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
                                                    _plainLocalizedText(
                                                      en: 'Remind',
                                                      lv: 'Atgādināt',
                                                    ),
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
