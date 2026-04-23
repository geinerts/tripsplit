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
    final expenses = _expenseFilterUserId > 0
        ? sourceExpenses
              .where((expense) => expense.paidById == _expenseFilterUserId)
              .toList(growable: false)
        : sourceExpenses;

    WorkspaceUser? selectedUser;
    for (final user in snapshot.users) {
      if (user.id == _expenseFilterUserId) {
        selectedUser = user;
        break;
      }
    }

    final usersById = <int, WorkspaceUser>{
      for (final user in snapshot.users) user.id: user,
    };
    final filterUsers = snapshot.users
        .where((user) => user.id != _currentUserId)
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
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text(t.allFilter),
                    selected: _expenseFilterUserId == 0,
                    onSelected: (_) {
                      _updateState(() {
                        _expenseFilterUserId = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(t.myFilter),
                    selected: _expenseFilterUserId == _currentUserId,
                    onSelected: (_) {
                      _updateState(() {
                        _expenseFilterUserId = _currentUserId > 0
                            ? _currentUserId
                            : 0;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  for (final user in filterUsers) ...[
                    FilterChip(
                      label: Text(user.nickname),
                      selected: _expenseFilterUserId == user.id,
                      onSelected: (_) {
                        _updateState(() {
                          _expenseFilterUserId = user.id;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
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
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _expenseFilterUserId > 0
                    ? t.noExpensesByUserYet(
                        selectedUser?.nickname ?? t.selectedUserFallback,
                      )
                    : t.noExpensesYet,
              ),
            ),
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
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
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
                          Text(
                            context.l10n.workspacePaid,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: isDark
                                      ? colors.onSurfaceVariant
                                      : AppDesign.lightMuted,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: splitColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: splitColor.withValues(alpha: 0.24),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(splitIcon, size: 12, color: splitColor),
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _ExpenseInlineSocialBar(
                                popularReactions: inlineTopReactions,
                                commentCount: inlineCommentCount,
                                isLoading:
                                    expense.id > 0 && isInlineSocialLoading,
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
                                onPickReactionTap: () {
                                  unawaited(
                                    _showExpenseInlineEmojiPicker(
                                      expenseId: expense.id,
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
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: isDark
                                ? colors.onSurfaceVariant
                                : AppDesign.lightMuted,
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
    final picked = await showModalBottomSheet<_ExpenseCardQuickActionResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final emoji in _kSocialEmojis)
                        _InlineEmojiPickerButton(
                          emoji: emoji,
                          isDark: isDark,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pop(_ExpenseCardQuickActionResult.react(emoji));
                          },
                        ),
                    ],
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
}
