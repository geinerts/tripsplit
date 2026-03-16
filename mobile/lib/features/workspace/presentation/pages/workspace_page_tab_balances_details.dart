part of 'workspace_page.dart';

extension _WorkspacePageBalancesDetails on _WorkspacePageState {
  Future<void> _openBalanceDetails({
    required WorkspaceSnapshot snapshot,
    required BalanceItem item,
  }) async {
    final linkedSettlements = snapshot.settlements
        .where((row) => row.fromUserId == item.id || row.toUserId == item.id)
        .toList(growable: false);
    final confirmedCount = linkedSettlements
        .where((row) => row.status.trim().toLowerCase() == 'confirmed')
        .length;
    final waitingCount = linkedSettlements.length - confirmedCount;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final t = context.l10n;
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.9,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SheetHeadlineCard(
                    icon: Icons.person_outline,
                    title: item.nickname,
                    subtitle: t.userPaidOwesNetLine(
                      _signedMoney(item.net),
                      _formatMoney(item.owed),
                      _formatMoney(item.paid),
                    ),
                    color: item.net < 0
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                    meta: [
                      _DetailChip(
                        icon: Icons.account_balance_wallet_outlined,
                        label: t.paidLabel,
                        value: _formatMoney(item.paid),
                      ),
                      _DetailChip(
                        icon: Icons.payments_outlined,
                        label: t.owesLabel,
                        value: _formatMoney(item.owed),
                      ),
                      _DetailChip(
                        icon: Icons.swap_horiz,
                        label: t.netLabel,
                        value: _signedMoney(item.net),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SheetSectionTitle(
                    title: t.settlementActivityTitle,
                    subtitle: t.settlementActivitySubtitle,
                  ),
                  const SizedBox(height: 8),
                  if (linkedSettlements.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(t.noSettlementActivityForMember),
                      ),
                    )
                  else
                    Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < linkedSettlements.length; i++) ...[
                            ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.swap_horiz,
                                color: _settlementStatusColor(
                                  context,
                                  linkedSettlements[i].status,
                                ),
                              ),
                              title: _settlementPairTitle(
                                context,
                                linkedSettlements[i].from,
                                linkedSettlements[i].to,
                              ),
                              subtitle: Text(
                                _settlementStatusLabel(
                                  context,
                                  linkedSettlements[i].status,
                                ),
                              ),
                              trailing: Text(
                                _formatMoney(linkedSettlements[i].amount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (i < linkedSettlements.length - 1)
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
                            t.memberToPaySummary(
                              confirmedCount,
                              linkedSettlements.length,
                              waitingCount,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _DetailChip(
                                icon: Icons.check_circle_outline,
                                label: t.confirmedLabel,
                                value: '$confirmedCount',
                              ),
                              _DetailChip(
                                icon: Icons.hourglass_bottom,
                                label: t.pendingLabel,
                                value: '$waitingCount',
                              ),
                            ],
                          ),
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
  }

}
