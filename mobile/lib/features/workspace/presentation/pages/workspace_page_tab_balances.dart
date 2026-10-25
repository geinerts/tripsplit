part of 'workspace_page.dart';

extension _WorkspacePageBalancesTab on _WorkspacePageState {
  String _balanceMoney(double value) => AppFormatters.displayCurrencyFromCents(
    context,
    (value * 100).round(),
    currencyCode: widget.trip.currencyCode,
  );

  String _balanceDescription(double net) => net.abs() < .005
      ? context.l10n.workspaceSettledWithTheGroup
      : net < 0
      ? context.l10n.workspaceOwesToTheGroup
      : context.l10n.workspaceGetsBackFromTheGroup;

  Widget _buildBalancesTab(WorkspaceSnapshot snapshot) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final users = {for (final user in snapshot.users) user.id: user};
    final balances = snapshot.balances.toList()
      ..sort((a, b) => b.net.abs().compareTo(a.net.abs()));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (balances.isEmpty)
            AppEmptyState(
              icon: Icons.balance_outlined,
              title: t.noBalancesYet,
              message: t.balanceEmptyBody,
              actionLabel: snapshot.isActive ? t.addExpensesAction : null,
              onAction: snapshot.isActive ? _onAddExpensePressed : null,
            ),
          for (final item in balances) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                key: ValueKey('balance-row-${item.id}'),
                onTap: () =>
                    _openBalanceDetails(snapshot: snapshot, item: item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final user = users[item.id];
                      final name = _paymentMemberName(
                        item.nickname,
                        item.id,
                        user,
                      );
                      final stacked =
                          constraints.maxWidth < 340 ||
                          MediaQuery.textScalerOf(context).scale(16) > 21;
                      final amount = Text(
                        '${item.net > .004 ? '+' : ''}${_balanceMoney(item.net)}',
                        key: ValueKey('balance-amount-${item.id}'),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: item.net.abs() < .005
                              ? theme.colorScheme.onSurface
                              : (item.net < 0
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      );
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _largeMemberAvatar(
                            id: item.id,
                            name: name,
                            avatarUrl: user?.avatarThumbUrl ?? user?.avatarUrl,
                            size: 44,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  _balanceDescription(item.net),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (stacked) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: amount,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!stacked) ...[
                            const SizedBox(width: 12),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * .45,
                              ),
                              child: amount,
                            ),
                          ],
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 20),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
          ],
          if (balances.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(t.balanceAfterPayments, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  bool _settlementsCompleted(WorkspaceSnapshot snapshot) =>
      !snapshot.isActive &&
      snapshot.allSettled &&
      snapshot.settlementRemaining == 0 &&
      !snapshot.payments.any((item) => item.reservesBalance) &&
      snapshot.settlements.every((item) => item.isConfirmed) &&
      (snapshot.settlements.isNotEmpty ||
          (snapshot.balances.isNotEmpty &&
              snapshot.balances.every((item) => item.net.abs() < .005)));

  Widget _buildSettleTab(WorkspaceSnapshot snapshot) {
    final colors = Theme.of(context).colorScheme;
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.light;
    final settlements = snapshot.settlements.toList(growable: false)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final usersById = <int, WorkspaceUser>{
      for (final user in snapshot.users) user.id: user,
    };
    final totalMembers = snapshot.readyToSettleMembersTotal;
    final readyMembers = snapshot.readyToSettleMembersReady;
    final allMembersReady = snapshot.allMembersReadyToSettle;
    final hasPendingPayments = snapshot.payments.any(
      (item) => item.reservesBalance,
    );
    final canFinishTrip =
        snapshot.isActive &&
        _canEditMembers &&
        !_isMutating &&
        allMembersReady &&
        !hasPendingPayments;
    WorkspaceUser? currentUser;
    for (final user in snapshot.users) {
      if (user.id == _currentUserId) {
        currentUser = user;
        break;
      }
    }
    final isCurrentUserReady = currentUser?.isReadyToSettle ?? false;
    final canToggleReady =
        snapshot.isActive && !_isMutating && _currentUserId > 0;
    final pendingSettlements = settlements
        .where((item) => !item.isConfirmed)
        .toList(growable: false);
    final paidSettlements = settlements
        .where((item) => item.isConfirmed)
        .toList(growable: false);
    final payments =
        snapshot.payments
            .where((item) => !item.isCancelled)
            .toList(growable: false)
          ..sort((a, b) {
            final aWeight = a.isRequested ? 0 : (a.isSent ? 1 : 2);
            final bWeight = b.isRequested ? 0 : (b.isSent ? 1 : 2);
            if (aWeight != bWeight) {
              return aWeight.compareTo(bWeight);
            }
            return b.id.compareTo(a.id);
          });

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (snapshot.isActive) ...[
          _buildFinishTripActionBlock(
            colors: colors,
            canFinishTrip: canFinishTrip,
            allMembersReady: allMembersReady,
            readyMembers: readyMembers,
            totalMembers: totalMembers,
            hasPendingPayments: hasPendingPayments,
            isCurrentUserReady: isCurrentUserReady,
            canToggleReady: canToggleReady,
            finishLabel: context.l10n.finishTripStartSettlementsAction,
            creatorMustFinishLabel: context.l10n.creatorMustFinishTripFirst,
          ),
          const SizedBox(height: 12),
        ],
        if (!snapshot.isActive && settlements.isNotEmpty) ...[
          _buildSettlementProgressOverview(
            snapshot: snapshot,
            settlements: settlements,
            usersById: usersById,
            semantic: semantic,
          ),
          const SizedBox(height: 12),
        ],
        if (payments.isNotEmpty) ...[
          _buildTripPaymentsSection(
            payments: payments,
            usersById: usersById,
            semantic: semantic,
          ),
          const SizedBox(height: 12),
        ],
        if (_settlementsCompleted(snapshot))
          _buildWorkspaceIllustratedState(
            asset: 'splyto_settlements_complete.svg',
            title: context.l10n.settledStatus,
            message: context.l10n.workspaceAllTripSettlementsAreFullyCompleted,
          ),
        if (!snapshot.isActive &&
            settlements.isEmpty &&
            !_settlementsCompleted(snapshot))
          AppEmptyState(
            icon: Icons.payments_outlined,
            title: context.l10n.noSettlements,
            message: snapshot.isActive
                ? context.l10n.settlementEmptyActive
                : context.l10n.settlementEmptyClosed,
          )
        else ...[
          if (pendingSettlements.isNotEmpty) ...[
            ...pendingSettlements.map(
              (item) => _buildSettlementFlowCard(
                snapshot: snapshot,
                item: item,
                usersById: usersById,
                semantic: semantic,
              ),
            ),
          ],
          if (paidSettlements.isNotEmpty) ...[
            if (pendingSettlements.isNotEmpty) const SizedBox(height: 8),
            ...paidSettlements.map(
              (item) => _buildSettlementFlowCard(
                snapshot: snapshot,
                item: item,
                usersById: usersById,
                semantic: semantic,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSettlementProgressOverview({
    required WorkspaceSnapshot snapshot,
    required List<SettlementItem> settlements,
    required Map<int, WorkspaceUser> usersById,
    required AppSemanticColors semantic,
  }) {
    final total = snapshot.settlementTotal > 0
        ? snapshot.settlementTotal
        : settlements.length;
    final confirmed = snapshot.settlementConfirmed.clamp(0, total);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.settlementConfirmedCount(confirmed, total),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: total == 0 ? 0 : confirmed / total,
            minHeight: 6,
            borderRadius: BorderRadius.circular(999),
            semanticsLabel: context.l10n.settlementConfirmedCount(
              confirmed,
              total,
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
    final fromUser = usersById[item.fromUserId];
    final toUser = usersById[item.toUserId];
    final isPositiveForCurrent =
        _currentUserId > 0 && item.toUserId == _currentUserId;
    final amountColor = isPositiveForCurrent
        ? AppDesign.successColor(context)
        : AppDesign.titleColor(context);
    final openFlowLabel = context.l10n.workspaceOpenFlow;

    final normalizedStatus = item.status.trim().toLowerCase();
    final isCompleted = normalizedStatus == 'confirmed';
    final statusForeground = isCompleted
        ? semantic.statusConfirmedForeground
        : (normalizedStatus == 'sent'
              ? semantic.statusSentForeground
              : semantic.statusPendingForeground);
    final statusBackground = isCompleted
        ? semantic.statusConfirmedBackground
        : (normalizedStatus == 'sent'
              ? semantic.statusSentBackground
              : semantic.statusPendingBackground);
    final statusBorder = isCompleted
        ? semantic.statusConfirmedBorder
        : (normalizedStatus == 'sent'
              ? semantic.statusSentBorder
              : semantic.statusPendingBorder);
    final statusLabel = isCompleted
        ? context.l10n.settledStatus
        : (normalizedStatus == 'sent'
              ? context.l10n.statusSent
              : context.l10n.statusPending);
    final payableAmount = _tripPaymentOutstandingAmount(snapshot, item);
    final canRecordPayment =
        snapshot.isActive &&
        item.isSuggested &&
        _currentUserId > 0 &&
        item.fromUserId == _currentUserId &&
        payableAmount > 0.004 &&
        !_isMutating;
    final canRequestPayment =
        snapshot.isActive &&
        item.isSuggested &&
        _currentUserId > 0 &&
        item.toUserId == _currentUserId &&
        payableAmount > 0.004 &&
        !_isMutating;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${_paymentMemberName(item.from, item.fromUserId, fromUser)} → ${_paymentMemberName(item.to, item.toUserId, toUser)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _balanceMoney(item.amount),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: amountColor),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildSettlementStatusPill(
                label: item.isSuggested
                    ? context.l10n.settlementSuggested
                    : statusLabel,
                foreground: statusForeground,
                background: statusBackground,
                border: statusBorder,
              ),
              TextButton.icon(
                onPressed: () => _openSettlementFlowTimelineSheet(
                  snapshot: snapshot,
                  item: item,
                  usersById: usersById,
                ),
                icon: const Icon(Icons.chevron_right),
                label: Text(openFlowLabel),
              ),
              if (canRecordPayment || canRequestPayment)
                OutlinedButton.icon(
                  onPressed: () => _openTripPaymentComposerSheet(
                    settlement: item,
                    maxAmount: payableAmount,
                    isRequest: canRequestPayment,
                  ),
                  icon: Icon(
                    canRequestPayment
                        ? Icons.notification_add_outlined
                        : Icons.payments_outlined,
                  ),
                  label: Text(
                    canRequestPayment
                        ? context.l10n.paymentRequestAction
                        : context.l10n.paymentRecordAction,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildTripPaymentsSection({
    required List<PaymentItem> payments,
    required Map<int, WorkspaceUser> usersById,
    required AppSemanticColors semantic,
  }) {
    final requestCount = payments.where((item) => item.isRequested).length;
    final sentCount = payments.where((item) => item.isSent).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                requestCount > 0
                    ? context.l10n.paymentOpenRequestsCount(requestCount)
                    : (sentCount > 0
                          ? context.l10n.paymentAwaitingConfirmationCount(
                              sentCount,
                            )
                          : context.l10n.paymentRecordedPaymentsTitle),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppDesign.titleColor(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < payments.length; i++) ...[
          _buildTripPaymentCard(
            payment: payments[i],
            usersById: usersById,
            semantic: semantic,
          ),
          if (i < payments.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildTripPaymentCard({
    required PaymentItem payment,
    required Map<int, WorkspaceUser> usersById,
    required AppSemanticColors semantic,
  }) {
    final fromUser = usersById[payment.fromUserId];
    final toUser = usersById[payment.toUserId];
    final fromName = _paymentMemberName(
      payment.from,
      payment.fromUserId,
      fromUser,
    );
    final toName = _paymentMemberName(payment.to, payment.toUserId, toUser);
    final isRequested = payment.isRequested;
    final isConfirmed = payment.isConfirmed;
    final statusForeground = isRequested
        ? semantic.statusPendingForeground
        : (isConfirmed
              ? semantic.statusConfirmedForeground
              : semantic.statusSentForeground);
    final statusLabel = isRequested
        ? context.l10n.paymentRequestPendingStatus
        : (isConfirmed
              ? context.l10n.statusConfirmed
              : context.l10n.paymentAwaitingConfirmationStatus);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _balanceAvatar(
                name: fromName,
                avatarUrl: fromUser?.avatarThumbUrl ?? fromUser?.avatarUrl,
                size: 38,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRequested
                          ? context.l10n.paymentRequestedFrom(toName, fromName)
                          : context.l10n.paymentPaidTo(fromName, toName),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppDesign.titleColor(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _balanceMoney(payment.amount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppDesign.mutedColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusLabel,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: statusForeground),
          ),
          if (payment.note.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              payment.note.trim(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppDesign.mutedColor(context),
              ),
            ),
          ],
          if (payment.isRequested &&
              (payment.canMarkRequestSent ||
                  payment.canCancelRequest ||
                  payment.canDeclineRequest)) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (payment.canMarkRequestSent)
                  FilledButton.icon(
                    onPressed: _isMutating
                        ? null
                        : () => _openTripPaymentRequestReviewSheet(
                            payment: payment,
                          ),
                    icon: const Icon(Icons.receipt_long_rounded, size: 17),
                    label: Text(context.l10n.paymentReviewRequestAction),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppDesign.successColor(context),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                if (payment.canCancelRequest)
                  TextButton.icon(
                    onPressed: _isMutating
                        ? null
                        : () => _onTripPaymentRequestCancel(payment),
                    icon: const Icon(Icons.close_rounded, size: 17),
                    label: Text(context.l10n.cancelAction),
                  ),
              ],
            ),
          ],
          if (payment.isSent &&
              (payment.canConfirmReceived ||
                  payment.canCancelSent ||
                  payment.canReportNotReceived)) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (payment.canConfirmReceived)
                  FilledButton.icon(
                    onPressed: _isMutating
                        ? null
                        : () => _onTripPaymentConfirmReceived(payment),
                    icon: const Icon(Icons.verified_rounded, size: 17),
                    label: Text(context.l10n.confirmReceivedAction),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppDesign.successColor(context),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                if (payment.canCancelSent)
                  TextButton.icon(
                    onPressed: _isMutating
                        ? null
                        : () => _onTripPaymentCancelSent(payment),
                    icon: const Icon(Icons.undo_rounded, size: 17),
                    label: Text(context.l10n.cancelAction),
                  ),
                if (payment.canReportNotReceived)
                  TextButton.icon(
                    onPressed: _isMutating
                        ? null
                        : () => _onTripPaymentReportNotReceived(payment),
                    icon: const Icon(Icons.report_problem_outlined, size: 17),
                    label: Text(context.l10n.settlementNotReceivedAction),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
        ],
      ),
    );
  }

  String _paymentMemberName(String fallback, int userId, WorkspaceUser? user) {
    final preferred = (user?.preferredName ?? fallback).trim();
    if (preferred.isNotEmpty) {
      return preferred;
    }
    return context.l10n.userWithId(userId);
  }

  double _tripPaymentOutstandingAmount(
    WorkspaceSnapshot snapshot,
    SettlementItem settlement,
  ) {
    final pendingAmount = snapshot.payments
        .where(
          (payment) =>
              payment.reservesBalance &&
              payment.fromUserId == settlement.fromUserId &&
              payment.toUserId == settlement.toUserId,
        )
        .fold<double>(0, (total, payment) => total + payment.amount);
    final outstanding = settlement.amount - pendingAmount;
    return outstanding <= 0 ? 0 : outstanding;
  }

  Future<void> _openTripPaymentComposerSheet({
    required SettlementItem settlement,
    required double maxAmount,
    required bool isRequest,
  }) async {
    if (maxAmount <= 0) {
      return;
    }
    final draft = await Navigator.of(context, rootNavigator: true)
        .push<TripPaymentDraft>(
          AppFormPageRoute(
            builder: (_) => TripPaymentComposerPage(
              memberName: isRequest ? settlement.from : settlement.to,
              maxAmount: maxAmount,
              maxAmountLabel: _formatMoney(
                context,
                maxAmount,
                currencyCode: widget.trip.currencyCode,
              ),
              isRequest: isRequest,
            ),
          ),
        );
    if (draft == null || !mounted) return;
    if (isRequest) {
      await _onTripPaymentRequestCreate(
        sharePaymentDetails: draft.sharePaymentDetails,
        settlement: settlement,
        amount: draft.amount,
        note: draft.note,
      );
    } else {
      await _onTripPaymentCreate(
        settlement: settlement,
        amount: draft.amount,
        note: draft.note,
      );
    }
  }

  Future<void> _openTripPaymentRequestReviewSheet({
    required PaymentItem payment,
  }) async {
    final amount = _formatMoney(
      context,
      payment.amount,
      currencyCode: widget.trip.currencyCode,
    );
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        return AppActionSheet(
          title: sheetContext.l10n.paymentRequestReviewTitle,
          children: [
            Text(
              sheetContext.l10n.paymentRequestReviewBody(payment.to, amount),
              style: Theme.of(
                sheetContext,
              ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (payment.note.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(payment.note.trim()),
              ),
            ],
            const SizedBox(height: 18),
            if (payment.canViewPaymentDetails) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    unawaited(
                      showAppBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => PaymentRequestDetailsSheet(
                          load: () => widget.workspaceController
                              .loadPaymentRequestDetails(
                                tripId: widget.trip.id,
                                paymentId: payment.id,
                              ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: Text(sheetContext.l10n.paymentViewDetailsAction),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isMutating
                    ? null
                    : () {
                        Navigator.of(sheetContext).pop();
                        unawaited(_onTripPaymentRequestMarkSent(payment));
                      },
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(sheetContext.l10n.paymentMarkPaidAction),
                style: FilledButton.styleFrom(
                  backgroundColor: AppDesign.successColor(sheetContext),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _isMutating
                    ? null
                    : () {
                        Navigator.of(sheetContext).pop();
                        unawaited(_onTripPaymentRequestDecline(payment));
                      },
                icon: const Icon(Icons.block_rounded),
                label: Text(sheetContext.l10n.paymentDeclineAction),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettlementStatusPill({
    required String label,
    required Color foreground,
    required Color background,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: background,
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: foreground,
          fontSize: 12,
        ),
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
    final readyTitle = context.l10n.workspaceReadyToSettle;
    final readySubtitle = hasPendingPayments
        ? context.l10n.paymentPendingBeforeFinish
        : (allMembersReady
              ? context.l10n.workspaceAllMembersAreReadyYouCanStartSettlements
              : context.l10n.workspaceWaitingForEveryoneToMarkReady);
    final markReadyTitle = context.l10n.workspaceIMReady;
    final markReadySubtitle =
        context.l10n.workspaceConfirmThatYouAddedAllYourExpenses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          children: [
            Text(readyTitle, style: Theme.of(context).textTheme.titleLarge),
            Text(
              '$readyMembers / $totalMembers',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: totalMembers == 0 ? 0 : readyMembers / totalMembers,
          minHeight: 6,
          borderRadius: BorderRadius.circular(999),
        ),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: isCurrentUserReady,
          onChanged: canToggleReady ? _onReadyToSettleChanged : null,
          secondary: MediaQuery.textScalerOf(context).scale(16) > 23
              ? null
              : _largeMemberAvatar(
                  id: _currentUserId,
                  name:
                      _snapshot!.users
                          .where((u) => u.id == _currentUserId)
                          .firstOrNull
                          ?.preferredName ??
                      context.l10n.youLabel,
                  avatarUrl: _snapshot!.users
                      .where((u) => u.id == _currentUserId)
                      .firstOrNull
                      ?.avatarThumbUrl,
                  size: 40,
                ),
          title: Text(markReadyTitle),
          subtitle: Text(markReadySubtitle),
        ),
        for (final member in _snapshot!.users.where(
          (user) => user.id != _currentUserId,
        )) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _largeMemberAvatar(
              id: member.id,
              name: member.preferredName,
              avatarUrl: member.avatarThumbUrl ?? member.avatarUrl,
              size: 40,
            ),
            title: Text(member.preferredName),
            subtitle: Text(
              member.isReadyToSettle
                  ? context.l10n.settlementMemberReady
                  : context.l10n.settlementMemberNotReady,
            ),
            trailing: Icon(
              member.isReadyToSettle
                  ? Icons.check_circle_outline
                  : Icons.schedule,
              color: member.isReadyToSettle
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),
          ),
          const Divider(height: 1),
        ],
        const SizedBox(height: 16),

        if (_canEditMembers)
          FilledButton.icon(
            onPressed: canFinishTrip ? _onEndTripPressed : null,
            icon: const Icon(Icons.flag_outlined),
            label: Text(finishLabel),
          )
        else
          Text(creatorMustFinishLabel),
        const SizedBox(height: 8),
        Text(
          readySubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _balanceAvatar({
    required String name,
    required String? avatarUrl,
    double size = 38,
  }) {
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
              _balanceAvatarFallback(name, size: size),
        ),
      );
    }
    return _balanceAvatarFallback(name, size: size);
  }

  Widget _balanceAvatarFallback(String name, {double size = 38}) {
    final letter = name.trim().isEmpty ? '?' : name.trim().characters.first;
    final fontSize = (size * 0.34).clamp(11, 14).toDouble();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _largeMemberAvatar({
    required int id,
    required String name,
    required String? avatarUrl,
    double size = 72,
  }) {
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
          errorBuilder: (context, error, stackTrace) =>
              _largeMemberFallback(id: id, name: name, size: size),
        ),
      );
    }
    return _largeMemberFallback(id: id, name: name, size: size);
  }

  Widget _largeMemberFallback({
    required int id,
    required String name,
    required double size,
  }) {
    final initials = _avatarInitials(name);
    final bg = Theme.of(context).colorScheme.primaryContainer;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.38,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _avatarInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      final first = parts.first;
      return first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
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
