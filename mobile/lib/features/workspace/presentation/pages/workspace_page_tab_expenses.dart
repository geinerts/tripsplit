part of 'workspace_page.dart';

enum _ExpenseCardQuickActionType { react, edit, delete }

class _ExpenseCardQuickActionResult {
  const _ExpenseCardQuickActionResult._({required this.type, this.emoji});

  const _ExpenseCardQuickActionResult.react(String emoji)
    : this._(type: _ExpenseCardQuickActionType.react, emoji: emoji);

  const _ExpenseCardQuickActionResult.edit()
    : this._(type: _ExpenseCardQuickActionType.edit);

  const _ExpenseCardQuickActionResult.delete()
    : this._(type: _ExpenseCardQuickActionType.delete);

  final _ExpenseCardQuickActionType type;
  final String? emoji;
}

extension _WorkspacePageExpensesTab on _WorkspacePageState {
  List<Widget> _buildExpensesSlivers(WorkspaceSnapshot snapshot) {
    final t = context.l10n;
    final source = _expensesFeed;
    final users = {for (final user in snapshot.users) user.id: user};
    final query = _expenseSearchQuery.trim().toLowerCase();
    final expenses = query.isEmpty
        ? source
        : source
              .where(
                (expense) => _expenseMatchesSearch(
                  expense,
                  users[expense.paidById],
                  query,
                ),
              )
              .toList(growable: false);
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expenseSearchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: t.workspaceSearchExpenses,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: t.workspaceClearSearch,
                                onPressed: _clearExpenseSearch,
                                icon: const Icon(Icons.close),
                              ),
                      ),
                      onChanged: (value) =>
                          _updateState(() => _expenseSearchQuery = value),
                    ),
                  ),
                  if (expenses.isNotEmpty &&
                      _refreshError == null &&
                      _pendingQueueCount == 0 &&
                      !_workspaceOffline) ...[
                    const SizedBox(width: 4),
                    _buildSyncStatusBadge(context, compact: true),
                  ],
                ],
              ),
              if (query.isNotEmpty && _expensesHasMore)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    t.workspaceSearchLoadedHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (expenses.isEmpty ||
                  _refreshError != null ||
                  _pendingQueueCount > 0 ||
                  _workspaceOffline)
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildSyncStatusBadge(context),
                ),
            ],
          ),
        ),
      ),
      if (expenses.isEmpty)
        SliverToBoxAdapter(
          child: _buildWorkspaceIllustratedState(
            asset: query.isNotEmpty
                ? 'splyto_no_results.svg'
                : 'splyto_empty_expenses.svg',
            title: query.isNotEmpty
                ? t.workspaceNoExpenseMatches
                : t.noExpensesYet,
            message: query.isNotEmpty
                ? t.workspaceNoExpenseMatchesBody
                : (!snapshot.isActive
                      ? t.tripClosedExpenseEditingDisabled
                      : (widget.trip.isSolo
                            ? t.workspaceEmptyPersonalExpenses
                            : t.workspaceEmptyGroupExpenses)),
            action: query.isNotEmpty
                ? TextButton(
                    onPressed: _clearExpenseSearch,
                    child: Text(t.workspaceClearSearch),
                  )
                : (snapshot.isActive
                      ? TextButton.icon(
                          onPressed: _isMutating ? null : _onAddExpensePressed,
                          icon: const Icon(Icons.add),
                          label: Text(t.addExpensesAction),
                        )
                      : null),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final sameDayBefore =
                  index > 0 &&
                  expenses[index - 1].expenseDate == expense.expenseDate;
              final sameDayAfter =
                  index + 1 < expenses.length &&
                  expenses[index + 1].expenseDate == expense.expenseDate;
              // A day earns a heading only when several expenses share it;
              // a lone expense carries its date in its own row instead.
              final showHeading = !sameDayBefore && sameDayAfter;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showHeading)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                      child: Semantics(
                        header: true,
                        child: Text(
                          _formatDisplayDate(context, expense.expenseDate),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),
                  _buildExpenseRow(
                    snapshot,
                    expense,
                    users[expense.paidById],
                    showDate: !sameDayBefore && !sameDayAfter,
                  ),
                  const Divider(height: 1),
                ],
              );
            },
          ),
        ),
      if (_expensesHasMore)
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: OutlinedButton.icon(
              onPressed: _isLoadingMoreExpenses ? null : _loadMoreExpensesPage,
              icon: _isLoadingMoreExpenses
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more),
              label: Text(
                _isLoadingMoreExpenses
                    ? t.workspaceLoadingMoreExpenses
                    : t.workspaceLoadMoreExpenses,
              ),
            ),
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }

  void _clearExpenseSearch() {
    _expenseSearchController.clear();
    _updateState(() => _expenseSearchQuery = '');
  }

  Widget _buildExpenseRow(
    WorkspaceSnapshot snapshot,
    TripExpense expense,
    WorkspaceUser? payer, {
    required bool showDate,
  }) {
    final theme = Theme.of(context);
    final category = ExpenseCategoryCatalog.labelFor(
      expense.category,
      Localizations.localeOf(context),
    );
    final title = expense.note.trim().isEmpty ? category : expense.note.trim();
    final payerName = (payer?.preferredName ?? expense.paidByNickname).trim();
    final details = [
      if (showDate && expense.expenseDate.trim().isNotEmpty)
        _formatDisplayDate(context, expense.expenseDate),
      if (widget.trip.isSolo && expense.note.trim().isNotEmpty) category,
      if (!widget.trip.isSolo && payerName.isNotEmpty)
        context.l10n.expensePaidByName(payerName),
      if (!widget.trip.isSolo && !_isEqualSplitMode(expense.splitMode))
        _splitModeShortLabel(context, expense.splitMode),
    ].join(' · ');
    final amount = AppFormatters.displayCurrencyFromCents(
      context,
      (expense.amount * 100).round(),
      currencyCode: expense.tripCurrencyCode,
    );
    final reactions = _topExpenseReactions(
      _expenseReactionsByExpenseId[expense.id],
    );
    final comments = _expenseCommentsCountByExpenseId[expense.id] ?? 0;
    void open() =>
        unawaited(_openExpenseDetails(snapshot: snapshot, expense: expense));
    return Material(
      key: ValueKey('expense-row-${expense.id}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: open,
        onLongPress: expense.id > 0
            ? () =>
                  _showExpenseQuickActions(snapshot: snapshot, expense: expense)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 300 ||
                  MediaQuery.textScalerOf(context).scale(16) > 21;
              final muted = theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              );
              final foreign =
                  expense.expenseCurrencyCode != expense.tripCurrencyCode;
              final originalAmount = AppFormatters.displayCurrencyFromCents(
                context,
                (expense.originalAmount * 100).round(),
                currencyCode: expense.expenseCurrencyCode,
              );
              final hasSocial =
                  expense.id > 0 && (reactions.isNotEmpty || comments > 0);
              // Everything about the amount sits under it, in one column, so
              // every row keeps the same shape.
              final amountColumn = <Widget>[
                Text(
                  amount,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (foreign)
                  Text(
                    originalAmount,
                    key: ValueKey('expense-original-${expense.id}'),
                    semanticsLabel: context.l10n.workspaceOriginalExpenseAmount(
                      originalAmount,
                    ),
                    style: muted,
                  ),
                if (hasSocial)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      key: ValueKey('expense-social-${expense.id}'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final reaction in reactions) ...[
                          Text(
                            '${reaction.emoji} ${reaction.count}',
                            style: muted?.copyWith(
                              color: reaction.isMine
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (comments > 0) ...[
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$comments',
                            semanticsLabel: context.l10n.workspaceCommentCount(
                              comments,
                            ),
                            style: muted,
                          ),
                        ],
                      ],
                    ),
                  ),
              ];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        ExpenseCategoryCatalog.iconFor(expense.category),
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (details.isNotEmpty) Text(details, style: muted),
                        if (expense.id <= 0)
                          Text(context.l10n.queuePendingStatus, style: muted),
                        if (stacked) ...[
                          const SizedBox(height: 2),
                          ...amountColumn,
                        ],
                      ],
                    ),
                  ),
                  if (!stacked) ...[
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * .4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: amountColumn,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showExpenseQuickActions({
    required WorkspaceSnapshot snapshot,
    required TripExpense expense,
  }) async {
    if (expense.id <= 0 || _isMutating) {
      return;
    }
    final canManage =
        snapshot.isActive && _canManageExpense(expense) && !_isMutating;
    final title = expense.note.trim().isEmpty
        ? ExpenseCategoryCatalog.labelFor(
            expense.category,
            Localizations.localeOf(context),
          )
        : expense.note.trim();
    final amount = _formatMoney(
      context,
      expense.amount,
      currencyCode: expense.tripCurrencyCode,
    );
    // Keep all supported reactions, with the six sketch reactions first.
    final emojis = [
      '😂',
      '👍',
      '🤩',
      '💸',
      '🔥',
      '❤️',
      ..._kSocialEmojis.where(
        (e) => !['😂', '👍', '🤩', '💸', '🔥', '❤️'].contains(e),
      ),
    ];
    final mine =
        (_expenseReactionsByExpenseId[expense.id] ?? <ExpenseReaction>[])
            .where((r) => r.userId == _currentUserId)
            .map((r) => r.emoji)
            .toSet();
    final picked = await showAppBottomSheet<_ExpenseCardQuickActionResult>(
      context: context,
      builder: (context) => AppActionSheet(
        key: const ValueKey('expense-actions-sheet'),
        title: '$title · $amount',
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final emoji in emojis)
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 8,
                      top: 4,
                      bottom: 12,
                    ),
                    child: Semantics(
                      button: true,
                      selected: mine.contains(emoji),
                      child: Tooltip(
                        message: emoji,
                        child: Material(
                          color: mine.contains(emoji)
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(
                              context,
                            ).pop(_ExpenseCardQuickActionResult.react(emoji)),
                            child: SizedBox.square(
                              dimension: 48,
                              child: Center(
                                child: Text(emoji, style: _emojiTextStyle(30)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (canManage) ...[
            const Divider(height: 1),
            AppPlainActionTile(
              icon: Icons.edit_outlined,
              title: context.l10n.editExpenseTitle,
              onTap: () => Navigator.of(
                context,
              ).pop(const _ExpenseCardQuickActionResult.edit()),
            ),
            const Divider(height: 1),
            AppPlainActionTile(
              icon: Icons.delete_outline,
              title: context.l10n.deleteExpenseTitle,
              destructive: true,
              onTap: () => Navigator.of(
                context,
              ).pop(const _ExpenseCardQuickActionResult.delete()),
            ),
          ],
        ],
      ),
    );

    if (!mounted || picked == null) {
      return;
    }
    switch (picked.type) {
      case _ExpenseCardQuickActionType.react:
        final emoji = (picked.emoji ?? '').trim();
        if (emoji.isEmpty) {
          return;
        }
        await _toggleExpenseReactionInline(expenseId: expense.id, emoji: emoji);
        return;
      case _ExpenseCardQuickActionType.edit:
        if (!canManage) {
          return;
        }
        await _onEditExpensePressed(expense);
        return;
      case _ExpenseCardQuickActionType.delete:
        if (!canManage) {
          return;
        }
        await _onDeleteExpensePressed(expense);
        return;
    }
  }

  bool _expenseMatchesSearch(
    TripExpense expense,
    WorkspaceUser? payer,
    String query,
  ) {
    if (query.trim().isEmpty) {
      return true;
    }
    final locale = Localizations.localeOf(context);
    final categoryLabel = ExpenseCategoryCatalog.labelFor(
      expense.category,
      locale,
    );
    final payerName = (payer?.preferredName ?? expense.paidByNickname).trim();
    final values = <String>[
      expense.note,
      expense.category,
      categoryLabel,
      expense.expenseDate,
      _formatDisplayDate(context, expense.expenseDate),
      payerName,
      expense.amount.toStringAsFixed(2),
      expense.originalAmount.toStringAsFixed(2),
      expense.tripCurrencyCode,
      expense.expenseCurrencyCode,
      _formatMoney(
        context,
        expense.amount,
        currencyCode: expense.tripCurrencyCode,
      ),
      _formatMoney(
        context,
        expense.originalAmount,
        currencyCode: expense.expenseCurrencyCode,
      ),
    ];

    return values.any((value) => value.toLowerCase().contains(query));
  }
}
