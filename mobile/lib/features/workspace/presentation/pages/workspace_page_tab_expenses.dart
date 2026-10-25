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
              TextField(
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
              final newDay =
                  index == 0 ||
                  expenses[index - 1].expenseDate != expense.expenseDate;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (newDay)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              header: true,
                              child: Text(
                                _formatDisplayDate(
                                  context,
                                  expense.expenseDate,
                                ),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ),
                          if (index == 0 &&
                              _refreshError == null &&
                              _pendingQueueCount == 0 &&
                              !_workspaceOffline)
                            _buildSyncStatusBadge(context, compact: true),
                        ],
                      ),
                    ),
                  _buildExpenseRow(snapshot, expense, users[expense.paidById]),
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
    WorkspaceUser? payer,
  ) {
    final theme = Theme.of(context);
    final category = ExpenseCategoryCatalog.labelFor(
      expense.category,
      Localizations.localeOf(context),
    );
    final title = expense.note.trim().isEmpty ? category : expense.note.trim();
    final payerName = (payer?.preferredName ?? expense.paidByNickname).trim();
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 340 ||
                  MediaQuery.textScalerOf(context).scale(16) > 21;
              final amountText = Text(
                amount,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          child: Icon(
                            ExpenseCategoryCatalog.iconFor(expense.category),
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
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.trip.isSolo
                                  ? category
                                  : '$payerName · ${_splitModeShortLabel(context, expense.splitMode)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (stacked) ...[
                              const SizedBox(height: 8),
                              amountText,
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
                          child: amountText,
                        ),
                      ],
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                  if (expense.expenseCurrencyCode != expense.tripCurrencyCode)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        context.l10n.workspaceOriginalExpenseAmount(
                          AppFormatters.displayCurrencyFromCents(
                            context,
                            (expense.originalAmount * 100).round(),
                            currencyCode: expense.expenseCurrencyCode,
                          ),
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  if (expense.id <= 0)
                    Text(
                      context.l10n.queuePendingStatus,
                      style: theme.textTheme.bodySmall,
                    ),
                  if (expense.id > 0 && (reactions.isNotEmpty || comments > 0))
                    Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        for (final reaction in reactions)
                          Semantics(
                            selected: reaction.isMine,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 48),
                              ),
                              onPressed:
                                  _isMutating ||
                                      _expenseSocialTogglingIds.contains(
                                        expense.id,
                                      )
                                  ? null
                                  : () => _toggleExpenseReactionInline(
                                      expenseId: expense.id,
                                      emoji: reaction.emoji,
                                    ),
                              child: Text(
                                '${reaction.emoji} ${reaction.count}',
                              ),
                            ),
                          ),
                        if (comments > 0)
                          TextButton.icon(
                            onPressed: open,
                            style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48),
                            ),
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              size: 20,
                            ),
                            label: Text(
                              context.l10n.workspaceCommentCount(comments),
                            ),
                          ),
                      ],
                    ),
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
        snapshot.isActive && expense.paidById == _currentUserId && !_isMutating;
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
