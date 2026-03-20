part of 'workspace_page.dart';

extension _WorkspacePageSettlementDetails on _WorkspacePageState {
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
                                                _formatMoney(item.amount),
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
