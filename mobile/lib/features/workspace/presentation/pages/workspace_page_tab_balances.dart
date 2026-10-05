part of 'workspace_page.dart';

extension _WorkspacePageBalancesTab on _WorkspacePageState {
  Widget _buildBalancesTab(WorkspaceSnapshot snapshot) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    final usersById = <int, WorkspaceUser>{
      for (final user in snapshot.users) user.id: user,
    };
    final balances = snapshot.balances.toList(growable: false)
      ..sort((a, b) => b.net.abs().compareTo(a.net.abs()));
    const previewBalanceCount = 4;
    final hasBalanceOverflow = balances.length > previewBalanceCount;
    final visibleBalances = _showAllBalances
        ? balances
        : balances.take(previewBalanceCount).toList(growable: false);
    final maxAbsNet = visibleBalances.fold<double>(
      1,
      (maxValue, item) => math.max(maxValue, item.net.abs()),
    );

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      children: [
        if (visibleBalances.isEmpty)
          AppEmptyState(
            icon: Icons.balance_outlined,
            title: t.noBalancesYet,
            message:
                'Balances appear after the first expense. Add one shared cost to see who owes what.',
            actionLabel: snapshot.isActive ? 'Add first expense' : null,
            onAction: snapshot.isActive ? _onAddExpensePressed : null,
          )
        else
          ...visibleBalances.map((item) {
            final netColor = item.net < 0
                ? AppDesign.lightDestructive
                : AppDesign.lightSuccess;
            final member = usersById[item.id];
            final preferredName = (member?.preferredName ?? item.nickname)
                .trim();
            final displayName = preferredName.isEmpty
                ? t.userWithId(item.id)
                : preferredName;
            final nickname = (member?.nickname ?? item.nickname).trim();
            final showNicknameSecondary =
                nickname.isNotEmpty &&
                displayName.toLowerCase() != nickname.toLowerCase();
            final differenceRatio = (item.net.abs() / maxAbsNet)
                .clamp(0.0, 1.0)
                .toDouble();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: isDark ? colors.surface : AppDesign.lightSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark
                        ? colors.outlineVariant.withValues(alpha: 0.32)
                        : AppDesign.lightStroke,
                  ),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
                child: _SplytoPressScale(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () =>
                      _openBalanceDetails(snapshot: snapshot, item: item),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _largeMemberAvatar(
                              id: item.id,
                              name: displayName,
                              avatarUrl:
                                  member?.avatarThumbUrl ?? member?.avatarUrl,
                              size: 62,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? null
                                              : AppDesign.lightForeground,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (showNicknameSecondary)
                                    Text(
                                      nickname,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isDark
                                                ? colors.onSurfaceVariant
                                                : AppDesign.lightMuted,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.net < 0
                                        ? context.l10n.workspaceOwesToTheGroup
                                        : context
                                              .l10n
                                              .workspaceGetsBackFromGroup,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontSize: 15,
                                          color: isDark
                                              ? colors.onSurfaceVariant
                                              : AppDesign.lightMuted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _signedMoney(
                                context,
                                item.net,
                                currencyCode: widget.trip.currencyCode,
                              ),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 20,
                                    color: netColor,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            height: 10,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: isDark
                                        ? colors.surfaceContainerHighest
                                              .withValues(alpha: 0.45)
                                        : AppDesign.lightSurfaceTrack,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: differenceRatio,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: netColor,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        if (hasBalanceOverflow && !_showAllBalances)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              context.l10n.workspaceShowingTop4ByBalanceDifference,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 22),
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
        if (settlements.isEmpty)
          AppEmptyState(
            icon: Icons.payments_outlined,
            title: context.l10n.noSettlements,
            message: snapshot.isActive
                ? 'Mark everyone ready, then the trip owner can start settlements.'
                : 'There are no payments needed for this trip.',
            actionLabel: snapshot.isActive && canToggleReady
                ? (isCurrentUserReady ? 'You are ready' : 'Mark me ready')
                : null,
            onAction: snapshot.isActive && canToggleReady && !isCurrentUserReady
                ? () => _onReadyToSettleChanged(true)
                : null,
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
    final confirmed = snapshot.settlementConfirmed.clamp(0, total).toInt();
    final ratio = total <= 0 ? 0.0 : confirmed / total;
    final waitingLabel = _settlementWaitingLabel(
      settlements: settlements,
      usersById: usersById,
    );
    final colors = Theme.of(context).colorScheme;

    return _WorkspaceSectionCard(
      accent: confirmed >= total ? colors.primary : colors.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: semantic.statusActiveBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  confirmed >= total
                      ? Icons.check_circle_outline_rounded
                      : Icons.timeline_rounded,
                  color: semantic.flowStepCurrent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$confirmed of $total payments confirmed',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppDesign.titleColor(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      waitingLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppDesign.mutedColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: colors.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _settlementWaitingLabel({
    required List<SettlementItem> settlements,
    required Map<int, WorkspaceUser> usersById,
  }) {
    for (final item in settlements) {
      if (item.canConfirmReceived) {
        return 'You need to confirm receiving ${_formatMoney(context, item.amount, currencyCode: widget.trip.currencyCode)} from ${item.from}.';
      }
      if (item.canMarkSent) {
        return 'You need to mark payment sent to ${item.to}.';
      }
    }

    final waitingNames = <String>{};
    for (final item in settlements) {
      if (item.isConfirmed) {
        continue;
      }
      final waitingUserId = item.isSent ? item.toUserId : item.fromUserId;
      final user = usersById[waitingUserId];
      final name = (user?.preferredName ?? user?.nickname ?? '').trim();
      waitingNames.add(name.isEmpty ? item.to : name);
      if (waitingNames.length >= 2) {
        break;
      }
    }

    if (waitingNames.isEmpty) {
      return 'All payments are confirmed.';
    }
    if (waitingNames.length == 1) {
      return 'Waiting for ${waitingNames.first}.';
    }
    return 'Waiting for ${waitingNames.join(', ')}.';
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: AppDesign.cardSurface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppDesign.cardStroke(context)),
        ),
        child: _SplytoPressScale(
          borderRadius: BorderRadius.circular(24),
          enabled: true,
          onTap: () => _openSettlementFlowTimelineSheet(
            snapshot: snapshot,
            item: item,
            usersById: usersById,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildSettlementPersonColumn(
                        userId: item.fromUserId,
                        name: item.from,
                        avatarUrl:
                            fromUser?.avatarThumbUrl ?? fromUser?.avatarUrl,
                        alignEnd: false,
                      ),
                    ),
                    SizedBox(
                      width: 78,
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: semantic.statusActiveBackground,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: semantic.flowStepCurrent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            _formatMoney(
                              context,
                              item.amount,
                              currencyCode: widget.trip.currencyCode,
                            ),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: amountColor,
                                  letterSpacing: -0.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildSettlementPersonColumn(
                        userId: item.toUserId,
                        name: item.to,
                        avatarUrl: toUser?.avatarThumbUrl ?? toUser?.avatarUrl,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: AppDesign.cardStroke(context)),
                const SizedBox(height: 14),
                if (canRecordPayment || canRequestPayment) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openTripPaymentComposerSheet(
                        settlement: item,
                        maxAmount: payableAmount,
                        isRequest: canRequestPayment,
                      ),
                      icon: Icon(
                        canRequestPayment
                            ? Icons.notification_add_outlined
                            : Icons.payments_rounded,
                        size: 18,
                      ),
                      label: Text(
                        canRequestPayment
                            ? context.l10n.paymentRequestAction
                            : context.l10n.paymentRecordAction,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppDesign.successColor(context),
                        foregroundColor: AppDesign.darkForeground,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  const SizedBox(height: 38),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildSettlementStatusPill(
                      label: statusLabel,
                      foreground: statusForeground,
                      background: statusBackground,
                      border: statusBorder,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _openSettlementFlowTimelineSheet(
                        snapshot: snapshot,
                        item: item,
                        usersById: usersById,
                      ),
                      icon: const Icon(Icons.timeline_rounded, size: 16),
                      label: Text(openFlowLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
    final hasOpenItems = requestCount > 0 || sentCount > 0;
    return _WorkspaceSectionCard(
      accent: hasOpenItems
          ? semantic.statusSentForeground
          : AppDesign.successColor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: semantic.statusActiveBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: semantic.flowStepCurrent,
                  size: 20,
                ),
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
                    fontWeight: FontWeight.w800,
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
      ),
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
    final statusBackground = isRequested
        ? semantic.statusPendingBackground
        : (isConfirmed
              ? semantic.statusConfirmedBackground
              : semantic.statusSentBackground);
    final statusBorder = isRequested
        ? semantic.statusPendingBorder
        : (isConfirmed
              ? semantic.statusConfirmedBorder
              : semantic.statusSentBorder);
    final statusLabel = isRequested
        ? context.l10n.paymentRequestPendingStatus
        : (isConfirmed
              ? context.l10n.statusConfirmed
              : context.l10n.paymentAwaitingConfirmationStatus);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppDesign.cardSurface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppDesign.cardStroke(context)),
      ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppDesign.titleColor(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatMoney(
                        context,
                        payment.amount,
                        currencyCode: widget.trip.currencyCode,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppDesign.mutedColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildSettlementStatusPill(
                label: statusLabel,
                foreground: statusForeground,
                background: statusBackground,
                border: statusBorder,
              ),
            ],
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
                      foregroundColor: AppDesign.darkForeground,
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
                      foregroundColor: AppDesign.darkForeground,
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
    final amountController = TextEditingController(
      text: maxAmount.toStringAsFixed(2),
    );
    final noteController = TextEditingController();
    var errorText = '';
    var sharePaymentDetails = false;

    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
            final bottomSafePadding = MediaQuery.paddingOf(sheetContext).bottom;
            final colors = Theme.of(sheetContext).colorScheme;
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    18 + bottomSafePadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isRequest
                                  ? sheetContext.l10n.paymentRequestSheetTitle
                                  : sheetContext.l10n.paymentRecordSheetTitle,
                              style: Theme.of(sheetContext).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      Text(
                        isRequest
                            ? sheetContext.l10n.paymentRequestSheetBody(
                                settlement.from,
                              )
                            : sheetContext.l10n.paymentRecordSheetBody(
                                settlement.to,
                              ),
                        style: Theme.of(sheetContext).textTheme.bodyMedium
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: sheetContext.l10n.amountLabel,
                          helperText: sheetContext.l10n.paymentMaxAmount(
                            _formatMoney(
                              sheetContext,
                              maxAmount,
                              currencyCode: widget.trip.currencyCode,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: noteController,
                        maxLength: 120,
                        decoration: InputDecoration(
                          labelText: sheetContext.l10n.noteLabel,
                          hintText: sheetContext.l10n.paymentNoteHint,
                          counterText: '',
                        ),
                      ),
                      if (isRequest)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: sharePaymentDetails,
                          title: Text(
                            sheetContext.l10n.paymentShareDetailsConsent(
                              settlement.from,
                            ),
                          ),
                          subtitle: Text(
                            sheetContext.l10n.paymentShareDetailsScope,
                          ),
                          onChanged: (value) => setSheetState(() {
                            sharePaymentDetails = value == true;
                          }),
                        ),
                      if (errorText.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorText,
                          style: Theme.of(
                            sheetContext,
                          ).textTheme.bodySmall?.copyWith(color: colors.error),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isMutating
                              ? null
                              : () async {
                                  final amount = _parseAmount(
                                    amountController.text,
                                  );
                                  if (amount <= 0) {
                                    setSheetState(() {
                                      errorText = sheetContext
                                          .l10n
                                          .paymentAmountPositiveError;
                                    });
                                    return;
                                  }
                                  if (amount - maxAmount > 0.005) {
                                    setSheetState(() {
                                      errorText = sheetContext
                                          .l10n
                                          .paymentAmountTooHighError;
                                    });
                                    return;
                                  }
                                  Navigator.of(sheetContext).pop();
                                  if (isRequest) {
                                    await _onTripPaymentRequestCreate(
                                      sharePaymentDetails: sharePaymentDetails,
                                      settlement: settlement,
                                      amount: amount,
                                      note: noteController.text,
                                    );
                                  } else {
                                    await _onTripPaymentCreate(
                                      settlement: settlement,
                                      amount: amount,
                                      note: noteController.text,
                                    );
                                  }
                                },
                          icon: Icon(
                            isRequest
                                ? Icons.notification_add_outlined
                                : Icons.payments_rounded,
                          ),
                          label: Text(
                            isRequest
                                ? sheetContext.l10n.paymentRequestAction
                                : sheetContext.l10n.paymentMarkPaidAction,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppDesign.successColor(context),
                            foregroundColor: AppDesign.darkForeground,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
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

    amountController.dispose();
    noteController.dispose();
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
        final bottomSafePadding = MediaQuery.paddingOf(sheetContext).bottom;
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 18 + bottomSafePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sheetContext.l10n.paymentRequestReviewTitle,
                        style: Theme.of(sheetContext).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  sheetContext.l10n.paymentRequestReviewBody(
                    payment.to,
                    amount,
                  ),
                  style: Theme.of(sheetContext).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (payment.note.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                      foregroundColor: AppDesign.darkForeground,
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettlementPersonColumn({
    required int userId,
    required String name,
    required String? avatarUrl,
    required bool alignEnd,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        _largeMemberAvatar(
          id: userId,
          name: name,
          avatarUrl: avatarUrl,
          size: 56,
        ),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            height: 1.04,
            color: AppDesign.titleColor(context),
          ),
        ),
      ],
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

    final readyCard = _WorkspaceSectionCard(
      accent: allMembersReady ? colors.primary : colors.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allMembersReady
                    ? Icons.check_circle_outline
                    : Icons.pending_actions_outlined,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  readyTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (allMembersReady ? colors.primary : colors.tertiary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$readyMembers/$totalMembers',
                  style: TextStyle(
                    color: allMembersReady ? colors.primary : colors.tertiary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(readySubtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: isCurrentUserReady,
            onChanged: canToggleReady ? _onReadyToSettleChanged : null,
            title: Text(
              markReadyTitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(markReadySubtitle),
          ),
        ],
      ),
    );

    if (_canEditMembers) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          readyCard,
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: canFinishTrip
                  ? AppDesign.actionGradient(context)
                  : LinearGradient(
                      colors: [
                        colors.surfaceContainerHighest,
                        colors.surfaceContainerHighest,
                      ],
                    ),
            ),
            child: ElevatedButton.icon(
              onPressed: canFinishTrip ? _onEndTripPressed : null,
              icon: const Icon(Icons.flag_outlined),
              label: Text(finishLabel),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: canFinishTrip
                    ? AppDesign.darkForeground
                    : colors.onSurfaceVariant,
                disabledForegroundColor: colors.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          if (!allMembersReady || hasPendingPayments)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                hasPendingPayments
                    ? context.l10n.paymentFinishBlockedByPending
                    : context
                          .l10n
                          .workspaceFinishButtonUnlocksOnceEveryoneMarksReady,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        readyCard,
        const SizedBox(height: 8),
        _WorkspaceSectionCard(
          accent: colors.tertiary,
          child: Text(
            creatorMustFinishLabel,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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
    final letter = name.trim().isEmpty ? '?' : name.trim().substring(0, 1);
    final fontSize = (size * 0.34).clamp(11, 14).toDouble();
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppDesign.brandGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          color: AppDesign.darkForeground,
          fontWeight: FontWeight.w700,
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
    final bg = _memberAvatarColorById(id);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: AppDesign.avatarShadow(context),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppDesign.darkForeground,
          fontWeight: FontWeight.w800,
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
      return (first.length >= 2 ? first.substring(0, 2) : first).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Color _memberAvatarColorById(int id) {
    final palette = AppDesign.memberPalette;
    final safeId = id < 0 ? -id : id;
    return palette[safeId % palette.length];
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
