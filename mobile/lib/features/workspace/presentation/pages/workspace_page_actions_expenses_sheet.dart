part of 'workspace_page.dart';

extension _WorkspacePageExpenseSheetActions on _WorkspacePageState {
  Future<void> _openExpenseDetails({
    required WorkspaceSnapshot snapshot,
    required TripExpense expense,
  }) async {
    final participants = expense.participants.isNotEmpty
        ? expense.participants
        : snapshot.users
              .map(
                (user) =>
                    ExpenseParticipant(id: user.id, nickname: user.nickname),
              )
              .toList(growable: false);

    final usersById = <int, WorkspaceUser>{
      for (final user in snapshot.users) user.id: user,
    };
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

    final splitLabel = _splitModeShortLabel(context, expense.splitMode);
    final splitIcon = switch (expense.splitMode.trim().toLowerCase()) {
      'exact' => Icons.payments_outlined,
      'percent' => Icons.percent_rounded,
      'shares' => Icons.pie_chart_outline_rounded,
      _ => Icons.drag_handle_rounded,
    };
    final categoryLabel = ExpenseCategoryCatalog.labelFor(
      expense.category,
      Localizations.localeOf(context),
    );
    final categoryIcon = ExpenseCategoryCatalog.iconFor(expense.category);
    final title = expense.note.trim().isEmpty
        ? categoryLabel
        : expense.note.trim();
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
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
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerLow,
                                borderRadius: AppDesign.cardRadius,
                              ),
                              child: Icon(categoryIcon),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatDisplayDate(context, expense.expenseDate)} · $categoryLabel',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        money(expense.amount, expense.tripCurrencyCode),
                        key: const ValueKey('expense-detail-total'),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (expense.expenseCurrencyCode !=
                          expense.tripCurrencyCode) ...[
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.workspaceOriginalExpenseAmount(
                            money(
                              expense.originalAmount,
                              expense.expenseCurrencyCode,
                            ),
                          ),
                        ),
                        Text(
                          _formatFxRateSummary(context, expense),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      if (expense.id <= 0) ...[
                        const SizedBox(height: 8),
                        Text(context.l10n.queuePendingStatus),
                      ],
                      if (!widget.trip.isSolo) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _largeMemberAvatar(
                              id: expense.paidById,
                              name: payerName,
                              avatarUrl:
                                  payerUser?.avatarThumbUrl ??
                                  payerUser?.avatarUrl,
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${context.l10n.paidByLabel} $payerName',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            key: const ValueKey('expense-split-mode'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ExcludeSemantics(
                                  child: Icon(
                                    splitIcon,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    splitLabel,
                                    style: theme.textTheme.labelLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        Semantics(
                          header: true,
                          child: Text(
                            context.l10n.splitBreakdownTitle,
                            style: theme.textTheme.titleLarge,
                          ),
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
                                          Text(
                                            name,
                                            style: theme.textTheme.titleMedium,
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
                      if (expense.receiptUrl != null) ...[
                        const SizedBox(height: 16),
                        ReceiptOpenAction(
                          load: () async {
                            final userId =
                                widget.authController.currentUser?.id;
                            final uri = await widget.workspaceController
                                .loadReceiptUri(
                                  tripId: widget.trip.id,
                                  expenseId: expense.id,
                                );
                            if (!mounted ||
                                widget.authController.currentUser?.id !=
                                    userId) {
                              return null;
                            }
                            return uri;
                          },
                          open: (uri) =>
                              launchUrl(uri, mode: LaunchMode.inAppBrowserView),
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
