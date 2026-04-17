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
    final positiveColor = AppDesign.lightSuccess;
    final negativeColor = AppDesign.lightDestructive;
    final netColor = item.net < 0 ? negativeColor : positiveColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusText = item.net > 0
        ? context.l10n.workspaceGetsBackFromTheGroup
        : item.net < 0
        ? context.l10n.workspaceOwesToTheGroup
        : context.l10n.workspaceSettledWithTheGroup;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.22 : 0.10,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: FractionallySizedBox(
                  heightFactor: 0.92,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? colors.surface : AppDesign.lightSurface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.24)
                                : const Color(0xFFD8D2C8),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  tooltip: MaterialLocalizations.of(
                                    context,
                                  ).closeButtonTooltip,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: _largeMemberAvatar(
                                  id: item.id,
                                  name: memberName,
                                  avatarUrl:
                                      member?.avatarThumbUrl ??
                                      member?.avatarUrl,
                                  size: 96,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Text(
                                  memberName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? null
                                            : AppDesign.lightForeground,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  statusText,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? colors.onSurfaceVariant
                                            : AppDesign.lightMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  _signedMoney(
                                    context,
                                    item.net,
                                    currencyCode: widget.trip.currencyCode,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        color: netColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildBalanceStatCard(
                                      context,
                                      label: context.l10n.workspaceTotalPaid,
                                      value: _formatMoney(
                                        context,
                                        item.paid,
                                        currencyCode: widget.trip.currencyCode,
                                      ),
                                      color: positiveColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildBalanceStatCard(
                                      context,
                                      label: context.l10n.workspaceTotalOwes,
                                      value: _formatMoney(
                                        context,
                                        item.owed,
                                        currencyCode: widget.trip.currencyCode,
                                      ),
                                      color: negativeColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.l10n.workspaceTransactionHistory,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? null
                                          : AppDesign.lightForeground,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              if (transactions.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? colors.surfaceContainerHighest
                                        : const Color(0xFFF2EFE8),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    context
                                        .l10n
                                        .workspaceNoTransactionsYetForThisMember,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                )
                              else
                                ...transactions.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        12,
                                        12,
                                        12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? colors.surfaceContainerHighest
                                            : const Color(0xFFF6F3ED),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isDark
                                              ? colors.outlineVariant
                                                    .withValues(alpha: 0.30)
                                              : AppDesign.lightStroke,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: entry.isPositive
                                                  ? AppDesign.lightSuccess
                                                        .withValues(alpha: 0.18)
                                                  : AppDesign.lightDestructive
                                                        .withValues(
                                                          alpha: 0.16,
                                                        ),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              entry.icon,
                                              color: entry.isPositive
                                                  ? AppDesign.lightSuccess
                                                  : AppDesign.lightDestructive,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  entry.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: isDark
                                                            ? null
                                                            : AppDesign
                                                                  .lightForeground,
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  entry.subtitle,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: isDark
                                                            ? colors
                                                                  .onSurfaceVariant
                                                            : AppDesign
                                                                  .lightMuted,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${entry.isPositive ? '+' : '-'}${_formatMoney(context, entry.amount, currencyCode: widget.trip.currencyCode)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: entry.isPositive
                                                      ? AppDesign.lightSuccess
                                                      : AppDesign
                                                            .lightDestructive,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              if (linkedSettlements.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _OverviewMetaPill(
                                      icon: Icons.swap_horiz_rounded,
                                      label: context.l10n.workspaceSettlements(
                                        linkedSettlements.length,
                                      ),
                                      color: AppDesign.lightPrimary,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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

    return transactions;
  }

  Widget _buildBalanceStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : AppDesign.lightForeground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.24 : 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.86)
                  : AppDesign.lightMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
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
