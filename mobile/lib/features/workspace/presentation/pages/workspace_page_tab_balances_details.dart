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
    final history = _buildMemberHistory(
      snapshot: snapshot,
      memberId: item.id,
      usersById: usersById,
    );
    // Positive: this person sent more than they received.
    final paymentsNet = history
        .where((entry) => entry.payment != null)
        .fold<double>(0, (sum, entry) => sum + entry.effect);
    var filter = 0;
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          final t = context.l10n;
          final theme = Theme.of(context);
          final colors = theme.colorScheme;
          final settled = item.net.abs() < .005;
          final owes = item.net < -.004;
          final tone = settled
              ? colors.onSurfaceVariant
              : owes
              ? colors.error
              : colors.primary;
          final shown = history
              .where(
                (entry) =>
                    filter == 0 ||
                    (filter == 1 && entry.expense != null) ||
                    (filter == 2 && entry.payment != null),
              )
              .toList(growable: false);
          return SizedBox(
            height: MediaQuery.sizeOf(context).height * .8,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
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
                          avatarUrl:
                              member?.avatarThumbUrl ?? member?.avatarUrl,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        memberName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Container(
                          key: const ValueKey('member-balance-status'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: tone.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _balanceDescription(item.net),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: tone,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (!settled) ...[
                        const SizedBox(height: 4),
                        Text(
                          _balanceMoney(item.net.abs()),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: tone,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      _memberStatsRow(
                        paid: item.paid,
                        share: item.owed,
                        payments: paymentsNet,
                      ),
                      const SizedBox(height: 18),
                      _memberFilterTabs(
                        selected: filter,
                        onSelected: (value) => setSheet(() => filter = value),
                      ),
                      const SizedBox(height: 4),
                      ..._memberHistoryRows(
                        snapshot: snapshot,
                        entries: shown,
                        usersById: usersById,
                      ),
                      if (linkedSettlements.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          t.workspaceSettle,
                          style: theme.textTheme.titleMedium,
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
      ),
    );
  }

  /// Paid · Share · Payments in one row with thin lines between them.
  Widget _memberStatsRow({
    required double paid,
    required double share,
    required double payments,
  }) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    Widget stat(String label, double value) {
      final zero = value.abs() < .005;
      final text = _balanceMoney(value.abs());
      return Expanded(
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: zero ? colors.onSurfaceVariant : null,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget line() =>
        Container(width: 1, height: 32, color: colors.outlineVariant);
    return Row(
      key: const ValueKey('member-balance-stats'),
      children: [
        stat(t.paidLabel, paid),
        line(),
        stat(t.tripReportShare, share),
        line(),
        // Sent or received, without a sign: receiving money is not a loss.
        stat(
          payments.abs() < .005
              ? t.tripReportPayments
              : payments > 0
              ? t.memberPaymentsSent
              : t.memberPaymentsReceived,
          payments,
        ),
      ],
    );
  }

  Widget _memberFilterTabs({
    required int selected,
    required ValueChanged<int> onSelected,
  }) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final labels = [t.allFilter, t.expensesLabel, t.tripReportPayments];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: selected == i,
                child: Material(
                  color: selected == i ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    key: ValueKey('member-history-filter-$i'),
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onSelected(i),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 38),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          child: Text(
                            labels[i],
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: selected == i
                                  ? colors.onPrimary
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _signedBalanceMoney(double value) => value.abs() < .005
      ? _balanceMoney(0)
      : '${value > 0 ? '+' : '−'}${_balanceMoney(value.abs())}';

  Color _effectColor(double value) {
    final colors = Theme.of(context).colorScheme;
    return value.abs() < .005
        ? colors.onSurfaceVariant
        : value > 0
        ? colors.primary
        : colors.error;
  }

  /// Rows grouped by day, newest first; each day shows its total effect.
  List<Widget> _memberHistoryRows({
    required WorkspaceSnapshot snapshot,
    required List<_MemberHistoryEntry> entries,
    required Map<int, WorkspaceUser> usersById,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final rows = <Widget>[];
    String? day;
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (entry.date != day) {
        day = entry.date;
        // Payments settle the balance, so the day total counts expenses only.
        final dayExpenses = entries
            .where((other) => other.date == day && other.expense != null)
            .toList(growable: false);
        final total = dayExpenses.fold<double>(
          0,
          (sum, other) => sum + other.effect,
        );
        rows.add(
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    day.isEmpty ? '' : _formatDisplayDate(context, day),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                if (dayExpenses.isNotEmpty)
                  Text(
                    _signedBalanceMoney(total),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _effectColor(total),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        );
      }
      rows.add(
        entry.expense != null
            ? _memberExpenseRow(snapshot, entry, usersById)
            : _memberPaymentRow(entry, usersById),
      );
    }
    return rows;
  }

  Widget _memberAmountColumn(_MemberHistoryEntry entry) {
    final theme = Theme.of(context);
    // A payment shows its amount with "sent" or "received", in the text
    // colour: money received is not a loss even though the balance drops.
    final isPayment = entry.payment != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          isPayment
              ? _balanceMoney(entry.effect.abs())
              : _signedBalanceMoney(entry.effect),
          textAlign: TextAlign.end,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: isPayment
                ? theme.colorScheme.onSurface
                : _effectColor(entry.effect),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (entry.hint.isNotEmpty)
          Text(
            entry.hint,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _memberExpenseRow(
    WorkspaceSnapshot snapshot,
    _MemberHistoryEntry entry,
    Map<int, WorkspaceUser> usersById,
  ) {
    final theme = Theme.of(context);
    final expense = entry.expense!;
    final note = expense.note.trim();
    return InkWell(
      key: ValueKey('member-history-expense-${expense.id}'),
      onTap: () =>
          unawaited(_openExpenseDetails(snapshot: snapshot, expense: expense)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            _expenseIconWithPayer(
              expense,
              usersById[expense.paidById],
              showPayer: !widget.trip.isSolo,
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _expenseCategoryTitle(
                    context,
                    expense,
                    maxLines: 2,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (note.isNotEmpty)
                    Text(
                      note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(flex: 2, child: _memberAmountColumn(entry)),
          ],
        ),
      ),
    );
  }

  Widget _memberPaymentRow(
    _MemberHistoryEntry entry,
    Map<int, WorkspaceUser> usersById,
  ) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final payment = entry.payment!;
    final from = usersById[payment.fromUserId];
    final to = usersById[payment.toUserId];
    final fromName = _paymentMemberName(payment.from, payment.fromUserId, from);
    final toName = _paymentMemberName(payment.to, payment.toUserId, to);
    return Container(
      key: ValueKey('member-history-payment-${payment.id}'),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.swap_horiz_rounded, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.memberHistoryPayment,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$fromName → $toName · ${t.statusConfirmed.toLowerCase()}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(flex: 2, child: _memberAmountColumn(entry)),
        ],
      ),
    );
  }

  /// What each expense and confirmed payment did to this person's balance.
  List<_MemberHistoryEntry> _buildMemberHistory({
    required WorkspaceSnapshot snapshot,
    required int memberId,
    required Map<int, WorkspaceUser> usersById,
  }) {
    final t = context.l10n;
    final entries = <_MemberHistoryEntry>[];
    for (final expense in snapshot.expenses) {
      final participants = expense.participants.isNotEmpty
          ? [
              for (final person in expense.participants)
                ExpenseParticipant(
                  id: person.id,
                  nickname:
                      usersById[person.id]?.preferredName ?? person.nickname,
                ),
            ]
          : snapshot.users
                .map(
                  (user) => ExpenseParticipant(
                    id: user.id,
                    nickname: user.preferredName,
                  ),
                )
                .toList(growable: false);
      final payerUser = usersById[expense.paidById];
      final payerName = (payerUser?.preferredName ?? expense.paidByNickname)
          .trim();
      final lines = _buildExpenseShareLines(
        expense: expense,
        participants: participants,
        payerName: payerName.isEmpty
            ? t.userWithId(expense.paidById)
            : payerName,
      );
      final share = lines
          .where((line) => line.userId == memberId)
          .fold<double>(0, (sum, line) => sum + line.owes);
      final paid = expense.paidById == memberId ? expense.amount : 0.0;
      if (paid <= 0 && share <= 0) continue;
      entries.add(
        _MemberHistoryEntry(
          date: expense.expenseDate.trim(),
          expense: expense,
          effect: paid - share,
          hint: paid > 0
              ? t.memberHistoryPaid(_balanceMoney(paid))
              : t.memberHistoryShare,
        ),
      );
    }
    for (final payment in snapshot.payments) {
      if (!payment.isConfirmed) continue;
      final sent = payment.fromUserId == memberId;
      if (!sent && payment.toUserId != memberId) continue;
      entries.add(
        _MemberHistoryEntry(
          date: (payment.confirmedAt ?? payment.markedSentAt ?? '')
              .split(' ')
              .first
              .split('T')
              .first,
          payment: payment,
          effect: sent ? payment.amount : -payment.amount,
          hint: sent ? t.memberHistorySent : t.memberHistoryReceived,
        ),
      );
    }
    // Newest day first; the order within a day stays as loaded.
    final indexed = entries.indexed.toList()
      ..sort((a, b) {
        final byDate = b.$2.date.compareTo(a.$2.date);
        return byDate != 0 ? byDate : a.$1.compareTo(b.$1);
      });
    return [for (final pair in indexed) pair.$2];
  }
}

class _MemberHistoryEntry {
  const _MemberHistoryEntry({
    required this.date,
    required this.effect,
    required this.hint,
    this.expense,
    this.payment,
  });

  final String date;
  final double effect;
  final String hint;
  final TripExpense? expense;
  final PaymentItem? payment;
}
