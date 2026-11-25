part of 'workspace_page.dart';

extension _WorkspacePageExpenseSheetActions on _WorkspacePageState {
  Future<void> _openExpenseDetails({
    required WorkspaceSnapshot snapshot,
    required TripExpense expense,
  }) async {
    // Only its payer opens a personal expense; others get the reason.
    if (expense.isLocked) {
      _showSnack(context.l10n.expenseLockedExplain);
      return;
    }
    final usersById = <int, WorkspaceUser>{
      for (final user in snapshot.users) user.id: user,
    };
    final participants = expense.participants.isNotEmpty
        ? [
            for (final person in expense.participants)
              ExpenseParticipant(
                id: person.id,
                nickname:
                    usersById[person.id]?.preferredName ?? person.nickname,
                owedAmount: person.owedAmount,
                splitValue: person.splitValue,
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
    final payerName =
        (payerUser?.preferredName ?? expense.paidByNickname).trim().isEmpty
        ? context.l10n.userWithId(expense.paidById)
        : (payerUser?.preferredName ?? expense.paidByNickname).trim();

    final lines = _buildExpenseShareLines(
      expense: expense,
      participants: participants,
      payerName: payerName,
    )..sort((a, b) => b.owes.compareTo(a.owes));

    final splitLabel = expense.isPersonal
        ? context.l10n.expenseSplitPersonal
        : _splitModeShortLabel(context, expense.splitMode);
    final splitIcon = switch (expense.splitMode.trim().toLowerCase()) {
      _ when expense.isPersonal => Icons.person_outline_rounded,
      'exact' => Icons.payments_outlined,
      'percent' => Icons.percent_rounded,
      'shares' => Icons.pie_chart_outline_rounded,
      'adjustment' => Icons.exposure_rounded,
      'itemized' => Icons.receipt_long_rounded,
      _ => Icons.drag_handle_rounded,
    };
    final note = expense.note.trim();
    final foreign = expense.expenseCurrencyCode != expense.tripCurrencyCode;
    final hasReceipt = expense.receiptUrl != null;
    final receiptAccount = widget.authController.currentUser?.id;
    bool isReceiptAccountCurrent() =>
        mounted &&
        receiptAccount != null &&
        widget.authController.currentUser?.id == receiptAccount;
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        Widget detailChip({
          required Key key,
          required Widget leading,
          required List<InlineSpan> children,
        }) => Container(
          key: key,
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(child: leading),
              const SizedBox(width: 6),
              Flexible(
                child: Text.rich(
                  TextSpan(children: children),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
        Widget receiptChip() => ReceiptOpenAction(
          key: ValueKey('receipt-$receiptAccount-${expense.id}'),
          compactLabel: context.l10n.expenseReceiptChip,
          isCurrentAccount: isReceiptAccountCurrent,
          loadPreview: () => widget.workspaceController.loadReceiptUri(
            tripId: widget.trip.id,
            expenseId: expense.id,
            thumbnail: true,
          ),
          load: () async {
            final userId = widget.authController.currentUser?.id;
            final uri = await widget.workspaceController.loadReceiptUri(
              tripId: widget.trip.id,
              expenseId: expense.id,
            );
            if (!mounted || widget.authController.currentUser?.id != userId) {
              return null;
            }
            return uri;
          },
          open: (uri) async {
            final account = widget.authController.currentUser?.id;
            if (!mounted || account == null) return false;
            await Navigator.of(context).push<void>(
              AppFormPageRoute(
                builder: (_) => ReceiptViewerPage(
                  initialUri: uri,
                  isCurrentAccount: () =>
                      mounted &&
                      widget.authController.currentUser?.id == account,
                  reload: () => widget.workspaceController.loadReceiptUri(
                    tripId: widget.trip.id,
                    expenseId: expense.id,
                  ),
                ),
              ),
            );
            return true;
          },
        );
        String money(double amount, String currency) =>
            AppFormatters.displayCurrencyFromCents(
              context,
              (amount * 100).round(),
              currencyCode: currency,
            );
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SizedBox(
            height: math.min(
              MediaQuery.sizeOf(context).height * .85,
              MediaQuery.sizeOf(context).height -
                  MediaQuery.viewInsetsOf(context).bottom -
                  MediaQuery.paddingOf(context).vertical -
                  32,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.expenseDetailsTitle,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        icon: const Icon(Icons.close),
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExcludeSemantics(
                            child: _expenseIconWithPayer(
                              expense,
                              payerUser,
                              size: 48,
                              showPayer: !widget.trip.isSolo,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _withQuickSplitMark(
                                  context,
                                  expense,
                                  size: 20,
                                  child: _expenseCategoryTitle(
                                    context,
                                    expense,
                                    key: const ValueKey('expense-detail-title'),
                                    maxLines: 2,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (note.isNotEmpty)
                                  Text(
                                    note,
                                    key: const ValueKey('expense-detail-note'),
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDisplayDate(
                                    context,
                                    expense.expenseDate,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            money(expense.amount, expense.tripCurrencyCode),
                            key: const ValueKey('expense-detail-total'),
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          if (foreign)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                money(
                                  expense.originalAmount,
                                  expense.expenseCurrencyCode,
                                ),
                                semanticsLabel: context.l10n
                                    .workspaceOriginalExpenseAmount(
                                      money(
                                        expense.originalAmount,
                                        expense.expenseCurrencyCode,
                                      ),
                                    ),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (foreign)
                        Text(
                          _formatFxRateSummary(context, expense),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (expense.id <= 0) ...[
                        const SizedBox(height: 8),
                        Text(context.l10n.queuePendingStatus),
                      ],
                      if (!widget.trip.isSolo || hasReceipt) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (!widget.trip.isSolo)
                              detailChip(
                                key: const ValueKey('expense-paid-by'),
                                leading: _largeMemberAvatar(
                                  id: expense.paidById,
                                  name: payerName,
                                  avatarUrl:
                                      payerUser?.avatarThumbUrl ??
                                      payerUser?.avatarUrl,
                                  size: 22,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${context.l10n.paidByLabel} ',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(text: payerName),
                                ],
                              ),
                            if (!widget.trip.isSolo)
                              detailChip(
                                key: const ValueKey('expense-split-mode'),
                                leading: Icon(
                                  splitIcon,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                children: [TextSpan(text: splitLabel)],
                              ),
                            if (hasReceipt) receiptChip(),
                          ],
                        ),
                      ],
                      if (expense.isPersonal) ...[
                        const SizedBox(height: 10),
                        Text(
                          context.l10n.expensePersonalDetailsNote,
                          key: const ValueKey('expense-personal-note'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (!widget.trip.isSolo) ...[
                        if (expense.items.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _ExpenseItemsSummary(
                            expense: expense,
                            nameFor: (id) {
                              for (final person in participants) {
                                if (person.id == id) return person.nickname;
                              }
                              return context.l10n.userWithId(id);
                            },
                          ),
                        ],
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                context.l10n.splitBreakdownTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                context.l10n.homePeople(lines.length),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final line in lines)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final user = usersById[line.userId];
                              final name = user?.preferredName ?? line.nickname;
                              final amount = Text(
                                money(line.owes, expense.tripCurrencyCode),
                                key: ValueKey(
                                  'expense-share-amount-${line.userId}',
                                ),
                                textAlign: TextAlign.end,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              );
                              final stacked =
                                  constraints.maxWidth < 340 ||
                                  MediaQuery.textScalerOf(context).scale(16) >
                                      21;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _largeMemberAvatar(
                                      id: line.userId,
                                      name: name,
                                      avatarUrl:
                                          user?.avatarThumbUrl ??
                                          user?.avatarUrl,
                                      size: 40,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            spacing: 6,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                name,
                                                style:
                                                    theme.textTheme.titleMedium,
                                              ),
                                              if (!widget.trip.isSolo &&
                                                  line.userId ==
                                                      expense.paidById)
                                                Container(
                                                  key: ValueKey(
                                                    'expense-share-paid-${line.userId}',
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 1,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: .12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    context.l10n
                                                        .memberHistoryPaid(
                                                          money(
                                                            expense.amount,
                                                            expense
                                                                .tripCurrencyCode,
                                                          ),
                                                        ),
                                                    style: theme
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (line.userId == _currentUserId)
                                            Text(
                                              context.l10n.youLabel,
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          if (stacked) ...[
                                            const SizedBox(height: 4),
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
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                      if (expense.id > 0) ...[
                        const SizedBox(height: 16),
                        _ExpenseSocialSection(
                          expenseId: expense.id,
                          tripId: widget.trip.id,
                          currentUserId: _currentUserId,
                          controller: widget.workspaceController,
                          usersById: usersById,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (mounted && expense.id > 0) {
      unawaited(_refreshExpenseSocialPreview(expense.id));
    }
  }
}
