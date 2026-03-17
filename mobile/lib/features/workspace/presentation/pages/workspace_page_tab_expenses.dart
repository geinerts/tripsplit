part of 'workspace_page.dart';

extension _WorkspacePageExpensesTab on _WorkspacePageState {
  Widget _buildExpensesTab(WorkspaceSnapshot snapshot) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final sourceExpenses = _expensesFeed.isNotEmpty
        ? _expensesFeed
        : snapshot.expenses;
    final expenses = _expenseFilterUserId > 0
        ? sourceExpenses
              .where((expense) => expense.paidById == _expenseFilterUserId)
              .toList(growable: false)
        : sourceExpenses;
    final showLoadMoreFooter = _expensesHasMore;
    final canAddExpense = !_isMutating && snapshot.isActive;
    WorkspaceUser? selectedUser;
    for (final user in snapshot.users) {
      if (user.id == _expenseFilterUserId) {
        selectedUser = user;
        break;
      }
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
      itemCount: expenses.isEmpty
          ? 2
          : expenses.length + 1 + (showLoadMoreFooter ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withValues(
                              alpha: 0.55,
                            ),
                            border: Border.all(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.35,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${t.expensesCount(expenses.length)}${_expensesHasMore ? '+' : ''}',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Spacer(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: canAddExpense
                                ? AppDesign.logoBackgroundGradient
                                : LinearGradient(
                                    colors: [
                                      colors.surfaceContainerHighest,
                                      colors.surfaceContainerHighest,
                                    ],
                                  ),
                            border: Border.all(
                              color: canAddExpense
                                  ? Colors.white.withValues(alpha: 0.34)
                                  : colors.outlineVariant.withValues(
                                      alpha: 0.35,
                                    ),
                            ),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: canAddExpense ? _onAddExpensePressed : null,
                            icon: const Icon(Icons.add),
                            label: Text(t.addAction),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: canAddExpense
                                  ? Colors.white
                                  : colors.onSurfaceVariant,
                              disabledForegroundColor: colors.onSurfaceVariant,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
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
                          for (final user in snapshot.users) ...[
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
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          t.tripClosedExpenseEditingDisabled,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        if (expenses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: _WorkspaceSectionCard(
              accent: colors.secondary,
              child: Text(
                _expenseFilterUserId > 0
                    ? t.noExpensesByUserYet(
                        selectedUser?.nickname ?? t.selectedUserFallback,
                      )
                    : t.noExpensesYet,
              ),
            ),
          );
        }

        final expenseIndex = index - 1;
        if (expenseIndex >= expenses.length) {
          if (!_isLoadingMoreExpenses) {
            unawaited(_loadMoreExpensesPage());
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
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
          );
        }

        final expense = expenses[expenseIndex];
        final categoryLabel = ExpenseCategoryCatalog.labelFor(
          expense.category,
          Localizations.localeOf(context),
        );
        final categoryIcon = ExpenseCategoryCatalog.iconFor(expense.category);
        final participantNames = expense.participants
            .map((participant) => participant.nickname)
            .join(', ');
        final participantCount = expense.participants.isNotEmpty
            ? expense.participants.length
            : snapshot.users.length;
        final canEdit = snapshot.isActive && expense.paidById == _currentUserId;
        final paidColor = expense.paidById == _currentUserId
            ? colors.primary
            : colors.secondary;

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () =>
                  _openExpenseDetails(snapshot: snapshot, expense: expense),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: paidColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(categoryIcon, color: paidColor, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoryLabel,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (expense.note.trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    expense.note.trim(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatMoney(expense.amount),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DetailChip(
                          icon: Icons.calendar_today_outlined,
                          label: t.dateLabel,
                          value: expense.expenseDate,
                        ),
                        _DetailChip(
                          icon: categoryIcon,
                          label: _localizedText(
                            context,
                            en: 'Category',
                            lv: 'Kategorija',
                          ),
                          value: categoryLabel,
                        ),
                        _DetailChip(
                          icon: Icons.person_outline,
                          label: t.paidByLabel,
                          value: expense.paidByNickname,
                        ),
                        _DetailChip(
                          icon: Icons.group_outlined,
                          label: t.membersLabel,
                          value: '$participantCount',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.forParticipants(
                        participantNames.isEmpty
                            ? t.allMembersLabel
                            : participantNames,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      t.splitLabelValue(
                        _splitModeShortLabel(context, expense.splitMode),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      t.tapToViewDetails,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (expense.receiptUrl != null) ...[
                      const SizedBox(height: 4),
                      TextButton.icon(
                        onPressed: _isMutating
                            ? null
                            : () => _openReceiptUrl(expense.receiptUrl!),
                        icon: const Icon(Icons.receipt_long),
                        label: Text(t.openReceiptAction),
                      ),
                    ],
                    if (canEdit) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: _isMutating
                                ? null
                                : () => _onEditExpensePressed(expense),
                            icon: const Icon(Icons.edit),
                            label: Text(t.editAction),
                          ),
                          TextButton.icon(
                            onPressed: _isMutating
                                ? null
                                : () => _onDeleteExpensePressed(expense),
                            icon: const Icon(Icons.delete_outline),
                            label: Text(t.deleteAction),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
