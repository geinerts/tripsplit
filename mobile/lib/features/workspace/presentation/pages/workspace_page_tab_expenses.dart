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
  Widget _buildExpensesTab(WorkspaceSnapshot snapshot) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sourceExpenses = _expensesFeed.isNotEmpty
        ? _expensesFeed
        : snapshot.expenses;
    final hasAnyExpenses = sourceExpenses.isNotEmpty;
    final usersById = <int, WorkspaceUser>{
      for (final user in snapshot.users) user.id: user,
    };
    final searchQuery = _expenseSearchQuery.trim().toLowerCase();
    final expenses = searchQuery.isEmpty
        ? sourceExpenses
        : sourceExpenses
              .where(
                (expense) => _expenseMatchesSearch(
                  expense,
                  usersById[expense.paidById],
                  searchQuery,
                ),
              )
              .toList(growable: false);

    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  context.l10n.navExpenses,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? null : AppDesign.lightForeground,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppDesign.lightPrimary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${expenses.length}',
                    style: const TextStyle(
                      color: AppDesign.lightPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildSyncStatusBadge(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _expenseSearchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Search by name, category, date, payer, amount',
                suffixIcon: searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).deleteButtonTooltip,
                        onPressed: () {
                          _expenseSearchController.clear();
                          _updateState(() {
                            _expenseSearchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
              onChanged: (value) {
                _updateState(() {
                  _expenseSearchQuery = value;
                });
              },
            ),
            if (!snapshot.isActive) ...[
              const SizedBox(height: 8),
              Text(
                t.tripClosedExpenseEditingDisabled,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    ];

    if (expenses.isEmpty) {
      final hasActiveFilters = searchQuery.isNotEmpty;
      final emptyTitle = hasAnyExpenses
          ? 'No expenses match this view'
          : 'No expenses yet';
      final emptyMessage = hasAnyExpenses
          ? 'Try clearing search to see all trip expenses.'
          : 'Add the first shared cost so balances and settlements can start working.';
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: AppEmptyState(
            icon: hasAnyExpenses
                ? Icons.filter_alt_off_outlined
                : Icons.receipt_long_outlined,
            title: emptyTitle,
            message: emptyMessage,
            actionLabel: hasActiveFilters
                ? 'Clear search'
                : (snapshot.isActive ? 'Add first expense' : null),
            onAction: hasActiveFilters
                ? () {
                    _expenseSearchController.clear();
                    _updateState(() {
                      _expenseSearchQuery = '';
                    });
                  }
                : (snapshot.isActive ? _onAddExpensePressed : null),
          ),
        ),
      );
    } else {
      for (final expense in expenses) {
        final categoryLabel = ExpenseCategoryCatalog.labelFor(
          expense.category,
          Localizations.localeOf(context),
        );
        final categoryIcon = ExpenseCategoryCatalog.iconFor(expense.category);
        final payer = usersById[expense.paidById];
        final payerName = (payer?.preferredName ?? expense.paidByNickname)
            .trim();
        final splitMode = expense.splitMode.trim().toLowerCase();
        final splitColor = splitMode == 'equal'
            ? AppDesign.lightSuccess
            : AppDesign.lightAccent;
        final splitIcon = splitMode == 'equal'
            ? Icons.call_split_rounded
            : Icons.tune_rounded;

        final cardTitle = expense.note.trim().isEmpty
            ? categoryLabel
            : expense.note.trim();
        final subtitle = expense.note.trim().isEmpty
            ? context.l10n.workspaceExpense
            : categoryLabel;
        final inlineReactions = _expenseReactionsByExpenseId[expense.id];
        final inlineTopReactions = _topExpenseReactions(inlineReactions);
        final inlineCommentCount = _expenseCommentsCountByExpenseId[expense.id];
        final isInlineSocialLoading = _expenseSocialLoadingIds.contains(
          expense.id,
        );
        final isInlineSocialBusy = _expenseSocialTogglingIds.contains(
          expense.id,
        );

        Widget buildCard() {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Card(
              color: isDark ? colors.surface : AppDesign.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isDark
                      ? colors.outlineVariant.withValues(alpha: 0.30)
                      : AppDesign.lightStroke,
                ),
              ),
              child: _SplytoPressScale(
                borderRadius: BorderRadius.circular(24),
                onTap: () =>
                    _openExpenseDetails(snapshot: snapshot, expense: expense),
                onLongPress: () {
                  unawaited(
                    _showExpenseQuickActions(
                      snapshot: snapshot,
                      expense: expense,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: splitColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              categoryIcon,
                              color: splitColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cardTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? null
                                            : AppDesign.lightForeground,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? colors.onSurfaceVariant
                                            : AppDesign.lightMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatMoney(
                                  context,
                                  expense.amount,
                                  currencyCode: expense.tripCurrencyCode,
                                ),
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? null
                                          : AppDesign.lightForeground,
                                      letterSpacing: -0.25,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDisplayDate(
                                  context,
                                  expense.expenseDate,
                                ),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: isDark
                                          ? colors.onSurfaceVariant
                                          : AppDesign.lightMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              if (expense.expenseCurrencyCode !=
                                  expense.tripCurrencyCode)
                                Text(
                                  _formatMoney(
                                    context,
                                    expense.originalAmount,
                                    currencyCode: expense.expenseCurrencyCode,
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? colors.onSurfaceVariant
                                            : AppDesign.lightMuted,
                                      ),
                                ),
                              if (expense.expenseCurrencyCode !=
                                  expense.tripCurrencyCode)
                                Text(
                                  _formatFxRateSummary(context, expense),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? colors.onSurfaceVariant
                                            : AppDesign.lightMuted,
                                        fontSize: 11,
                                      ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _balanceAvatar(
                                  name: payerName.isEmpty
                                      ? expense.paidByNickname
                                      : payerName,
                                  avatarUrl:
                                      payer?.avatarThumbUrl ?? payer?.avatarUrl,
                                  size: 31,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    context.l10n.workspacePaid,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: isDark
                                              ? colors.onSurfaceVariant
                                              : AppDesign.lightMuted,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: splitColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: splitColor.withValues(
                                            alpha: 0.24,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            splitIcon,
                                            size: 12,
                                            color: splitColor,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            _splitModeShortLabel(
                                              context,
                                              expense.splitMode,
                                            ),
                                            style: TextStyle(
                                              color: splitColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ExpenseInlineSocialBar(
                            popularReactions: inlineTopReactions,
                            commentCount: inlineCommentCount,
                            isLoading: expense.id > 0 && isInlineSocialLoading,
                            isBusy:
                                expense.id <= 0 ||
                                isInlineSocialBusy ||
                                _isMutating,
                            isDark: isDark,
                            onQuickReactionTap: (emoji) {
                              unawaited(
                                _toggleExpenseReactionInline(
                                  expenseId: expense.id,
                                  emoji: emoji,
                                ),
                              );
                            },
                            onCommentsTap: () {
                              unawaited(
                                _openExpenseDetails(
                                  snapshot: snapshot,
                                  expense: expense,
                                ),
                              );
                            },
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

        children.add(buildCard());
      }
    }

    if (_expensesHasMore) {
      if (!_isLoadingMoreExpenses) {
        unawaited(_loadMoreExpensesPage());
      }
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoadingMoreExpenses)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (_isLoadingMoreExpenses) const SizedBox(width: 8),
                  Text(
                    _isLoadingMoreExpenses
                        ? context.l10n.workspaceLoadingMoreExpenses
                        : context.l10n.workspaceScrollDownToLoadMore,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      children: children,
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
    final picked = await showAppBottomSheet<_ExpenseCardQuickActionResult>(
      context: context,
      isScrollControlled: false,
      showDragHandle: false,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? colors.surface : AppDesign.lightSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? colors.outlineVariant.withValues(alpha: 0.32)
                        : AppDesign.lightStroke,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: _EmojiPickerRow(
                  emojis: _kSocialEmojis,
                  onSelect: (emoji) {
                    Navigator.of(
                      context,
                    ).pop(_ExpenseCardQuickActionResult.react(emoji));
                  },
                ),
              ),
              if (canManage) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? colors.surface : AppDesign.lightSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? colors.outlineVariant.withValues(alpha: 0.32)
                          : AppDesign.lightStroke,
                    ),
                  ),
                  child: Column(
                    children: [
                      _CommentActionRow(
                        label: context.l10n.editAction,
                        icon: Icons.edit_outlined,
                        isDark: isDark,
                        showDivider: true,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pop(const _ExpenseCardQuickActionResult.edit());
                        },
                      ),
                      _CommentActionRow(
                        label: context.l10n.deleteAction,
                        icon: Icons.delete_outline_rounded,
                        isDark: isDark,
                        isDestructive: true,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pop(const _ExpenseCardQuickActionResult.delete());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
