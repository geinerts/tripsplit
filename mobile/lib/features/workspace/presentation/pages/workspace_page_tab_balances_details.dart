part of 'workspace_page.dart';

extension _WorkspacePageBalancesDetails on _WorkspacePageState {
  Future<void> _openBalanceDetails({
    required WorkspaceSnapshot snapshot,
    required BalanceItem item,
  }) async {
    final usersById = <int, WorkspaceUser>{
      for (final user in snapshot.users) user.id: user,
    };
    final member = usersById[item.id];
    final memberName = (member?.preferredName ?? item.nickname).trim().isEmpty
        ? context.l10n.userWithId(item.id)
        : (member?.preferredName ?? item.nickname).trim();
    final linkedSettlements = snapshot.settlements
        .where((row) => row.fromUserId == item.id || row.toUserId == item.id)
        .toList(growable: false);
    final transactions = _buildMemberTransactionHistory(
      snapshot: snapshot,
      memberId: item.id,
      usersById: usersById,
    );
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        Widget stat(String label, double value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(_balanceMoney(value), style: theme.textTheme.headlineSmall),
          ],
        );
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * .74,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: const Icon(Icons.close),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    Center(
                      child: _largeMemberAvatar(
                        id: item.id,
                        name: memberName,
                        avatarUrl: member?.avatarThumbUrl ?? member?.avatarUrl,
                        size: 76,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      memberName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _balanceDescription(item.net),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _balanceMoney(item.net.abs()),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: item.net < -.004
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final metrics = [
                          stat(context.l10n.workspaceTotalPaid, item.paid),
                          stat(context.l10n.balanceExpenseShare, item.owed),
                        ];
                        if (constraints.maxWidth < 340 ||
                            MediaQuery.textScalerOf(context).scale(16) > 21) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              metrics[0],
                              const SizedBox(height: 16),
                              metrics[1],
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: metrics[0]),
                            const SizedBox(width: 16),
                            Expanded(child: metrics[1]),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.workspaceTransactionHistory,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.balanceHistoryScope,
                      style: theme.textTheme.bodySmall,
                    ),
                    for (final entry in transactions) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final amount = Text(
                              '${entry.isPositive ? '+' : '−'}${_balanceMoney(entry.amount)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: entry.isPositive
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.error,
                              ),
                            );
                            final stacked =
                                MediaQuery.textScalerOf(context).scale(16) >
                                    23 ||
                                constraints.maxWidth < 300;
                            return Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color:
                                        theme.colorScheme.surfaceContainerLow,
                                    borderRadius: AppDesign.cardRadius,
                                  ),
                                  child: Icon(
                                    entry.icon,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.title,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      Text(
                                        entry.subtitle,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      if (stacked) amount,
                                    ],
                                  ),
                                ),
                                if (!stacked) ...[
                                  const SizedBox(width: 12),
                                  amount,
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                    if (linkedSettlements.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.workspaceSettle,
                        style: theme.textTheme.titleLarge,
                      ),
                      for (final settlement in linkedSettlements)
                        TextButton(
                          onPressed: () => _openSettlementFlowTimelineSheet(
                            snapshot: snapshot,
                            item: settlement,
                            usersById: usersById,
                          ),
                          child: Text(
                            '${settlement.from} → ${settlement.to} · ${_balanceMoney(settlement.amount)}',
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_MemberTransactionEntry> _buildMemberTransactionHistory({
    required WorkspaceSnapshot snapshot,
    required int memberId,
    required Map<int, WorkspaceUser> usersById,
  }) {
    final transactions = <_MemberTransactionEntry>[];
    final locale = Localizations.localeOf(context);

    for (final expense in snapshot.expenses) {
      final categoryLabel = ExpenseCategoryCatalog.labelFor(
        expense.category,
        locale,
      );
      final title = expense.note.trim().isEmpty ? categoryLabel : expense.note;
      final date = _formatDisplayDate(context, expense.expenseDate);

      if (expense.paidById == memberId) {
        transactions.add(
          _MemberTransactionEntry(
            title: title,
            subtitle: date.isEmpty
                ? context.l10n.workspacePaidForGroup
                : context.l10n.workspacePaidForGroupDate(date),
            amount: expense.amount,
            isPositive: true,
            icon: Icons.account_balance_wallet_outlined,
          ),
        );
      }

      final participants = expense.participants.isNotEmpty
          ? expense.participants
          : snapshot.users
                .map(
                  (user) =>
                      ExpenseParticipant(id: user.id, nickname: user.nickname),
                )
                .toList(growable: false);
      final payerUser = usersById[expense.paidById];
      final payerName = (payerUser?.preferredName ?? expense.paidByNickname)
          .trim();
      final lines = _buildExpenseShareLines(
        expense: expense,
        participants: participants,
        payerName: payerName.isEmpty
            ? context.l10n.userWithId(expense.paidById)
            : payerName,
      );

      for (final line in lines) {
        if (line.userId != memberId || line.isPayer || line.owes <= 0) {
          continue;
        }
        transactions.add(
          _MemberTransactionEntry(
            title: title,
            subtitle: date.isEmpty
                ? context.l10n.workspaceShareOfExpense
                : context.l10n.workspaceShareOfExpenseDate(date),
            amount: line.owes,
            isPositive: false,
            icon: Icons.call_received_rounded,
          ),
        );
      }
    }

    for (final payment in snapshot.payments) {
      if (!payment.isConfirmed) {
        continue;
      }
      final fromUser = usersById[payment.fromUserId];
      final toUser = usersById[payment.toUserId];
      final fromName = (fromUser?.preferredName ?? payment.from).trim();
      final toName = (toUser?.preferredName ?? payment.to).trim();
      final date = _formatDisplayDate(
        context,
        (payment.confirmedAt ?? payment.markedSentAt ?? '').split(' ').first,
      );
      if (payment.fromUserId == memberId) {
        transactions.add(
          _MemberTransactionEntry(
            title: context.l10n.balancePaymentTo(
              toName.isEmpty
                  ? context.l10n.userWithId(payment.toUserId)
                  : toName,
            ),
            subtitle: '${context.l10n.statusConfirmed} $date'.trim(),
            amount: payment.amount,
            isPositive: true,
            icon: Icons.payments_rounded,
          ),
        );
      } else if (payment.toUserId == memberId) {
        transactions.add(
          _MemberTransactionEntry(
            title: context.l10n.balancePaymentFrom(
              fromName.isEmpty
                  ? context.l10n.userWithId(payment.fromUserId)
                  : fromName,
            ),
            subtitle: '${context.l10n.statusConfirmed} $date'.trim(),
            amount: payment.amount,
            isPositive: false,
            icon: Icons.payments_rounded,
          ),
        );
      }
    }

    return transactions;
  }
}

class _MemberTransactionEntry {
  const _MemberTransactionEntry({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final double amount;
  final bool isPositive;
  final IconData icon;
}
