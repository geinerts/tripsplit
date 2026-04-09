part of 'workspace_page.dart';

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
                  _localizedText(context, en: 'Expenses', lv: 'Izdevumi'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? null : _splytoFg,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _splytoPrimary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${expenses.length}',
                    style: const TextStyle(
                      color: _splytoPrimary,
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
            color: isDark ? colors.surface : _splytoCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: isDark
                    ? colors.outlineVariant.withValues(alpha: 0.30)
                    : _splytoStroke,
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
            ? _splytoSuccess
            : _splytoAccent;
        final splitIcon = splitMode == 'equal'
            ? Icons.call_split_rounded
            : Icons.tune_rounded;

        final cardTitle = expense.note.trim().isEmpty
            ? categoryLabel
            : expense.note.trim();
        final subtitle = expense.note.trim().isEmpty
            ? _localizedText(context, en: 'Expense', lv: 'Izdevums')
            : categoryLabel;

        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Card(
              color: isDark ? colors.surface : _splytoCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isDark
                      ? colors.outlineVariant.withValues(alpha: 0.30)
                      : _splytoStroke,
                ),
              ),
              child: _SplytoPressScale(
                borderRadius: BorderRadius.circular(24),
                onTap: () =>
                    _openExpenseDetails(snapshot: snapshot, expense: expense),
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
                                        color: isDark ? null : _splytoFg,
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
                                            : _splytoMuted,
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
                                      color: isDark ? null : _splytoFg,
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
                                          : _splytoMuted,
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
                                            : _splytoMuted,
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
                            _localizedText(
                              context,
                              en: 'paid',
                              lv: 'apmaksāja',
                            ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: isDark
                                      ? colors.onSurfaceVariant
                                      : _splytoMuted,
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
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: isDark
                                ? colors.onSurfaceVariant
                                : _splytoMuted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
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
                        ? _localizedText(
                            context,
                            en: 'Loading more expenses...',
                            lv: 'Ielādē vēl izdevumus...',
                          )
                        : _localizedText(
                            context,
                            en: 'Scroll down to load more',
                            lv: 'Ritini uz leju, lai ielādētu vairāk',
                          ),
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
}
