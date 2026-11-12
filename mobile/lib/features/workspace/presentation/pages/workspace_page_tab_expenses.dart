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
    final hasFilters =
        _expenseFilterCategory != null || _expenseFilterUserId != 0;
    final isSearching = query.isNotEmpty || hasFilters;
    final expenses = source
        .where((expense) {
          return (_expenseFilterCategory == null ||
                  ExpenseCategoryCatalog.normalizeStored(expense.category) ==
                      _expenseFilterCategory) &&
              (_expenseFilterUserId == 0 ||
                  expense.paidById == _expenseFilterUserId) &&
              (query.isEmpty ||
                  _expenseMatchesSearch(
                    expense,
                    users[expense.paidById],
                    query,
                  ));
        })
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
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (query.isNotEmpty)
                              IconButton(
                                tooltip: t.workspaceClearSearch,
                                onPressed: _clearExpenseSearch,
                                icon: const Icon(Icons.close),
                              ),
                            CompositedTransformTarget(
                              link: _expenseFilterLink,
                              child: Builder(
                                builder: (anchorContext) => IconButton(
                                  key: const ValueKey('expense-filters'),
                                  tooltip: t.workspaceExpenseFilters,
                                  onPressed: () => _showExpenseFilters(
                                    snapshot,
                                    anchorContext,
                                  ),
                                  icon: Badge(
                                    isLabelVisible: hasFilters,
                                    child: Icon(
                                      Icons.tune_rounded,
                                      color: hasFilters
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onChanged: (value) =>
                          _updateState(() => _expenseSearchQuery = value),
                    ),
                  ),
                  // Always shown: a cloud with a tick when everything is
                  // synced online, otherwise what waits or failed.
                  const SizedBox(width: 4),
                  _buildSyncStatusBadge(context),
                ],
              ),
              if (isSearching && _expensesHasMore)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    hasFilters
                        ? t.workspaceFiltersLoadedHint
                        : t.workspaceSearchLoadedHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
      if (expenses.isEmpty)
        SliverToBoxAdapter(
          child: _buildWorkspaceIllustratedState(
            asset: isSearching
                ? 'splyto_no_results.svg'
                : 'splyto_empty_expenses.svg',
            title: isSearching ? t.workspaceNoExpenseMatches : t.noExpensesYet,
            message: isSearching
                ? (hasFilters
                      ? t.workspaceFiltersNoMatchesHint
                      : t.workspaceNoExpenseMatchesBody)
                : (!snapshot.isActive
                      ? t.tripClosedExpenseEditingDisabled
                      : (widget.trip.isSolo
                            ? t.workspaceEmptyPersonalExpenses
                            : t.workspaceEmptyGroupExpenses)),
            action: isSearching
                ? TextButton(
                    onPressed: () {
                      _clearExpenseSearch();
                      _updateState(() {
                        _expenseFilterCategory = null;
                        _expenseFilterUserId = 0;
                      });
                    },
                    child: Text(
                      hasFilters
                          ? t.workspaceClearFilters
                          : t.workspaceClearSearch,
                    ),
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
              // Every day gets a heading, also a day with a single expense,
              // so today's expenses sit under "Today" at the top.
              final showHeading =
                  !sameDayBefore && expense.expenseDate.trim().isNotEmpty;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showHeading)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                      child: Semantics(
                        header: true,
                        child: Text(
                          _expenseDayHeading(context, expense.expenseDate),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
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

  LayerLink get _expenseFilterLink => _expenseFilterLinks[this] ??= LayerLink();

  /// Opens a small dropdown under the filter button. Choices apply at once;
  /// there is no Save, only Clear filters.
  Future<void> _showExpenseFilters(
    WorkspaceSnapshot snapshot,
    BuildContext anchorContext,
  ) async {
    FocusScope.of(context).unfocus();
    final box = anchorContext.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final anchor = box.localToGlobal(Offset.zero) & box.size;
    final categories = <String>{
      for (final option in ExpenseCategoryCatalog.builtIn) option.key,
      for (final expense in _expensesFeed)
        ExpenseCategoryCatalog.normalizeStored(expense.category),
      ?_expenseFilterCategory,
    }.toList(growable: false);
    final payers = <int, String>{
      for (final user in snapshot.users) user.id: user.preferredName,
      for (final expense in _expensesFeed)
        if (!snapshot.users.any((user) => user.id == expense.paidById))
          expense.paidById: expense.paidByNickname,
    };
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 140),
      transitionBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
      pageBuilder: (_, _, _) => _ExpenseFilterMenu(
        link: _expenseFilterLink,
        anchor: anchor,
        categories: categories,
        payers: payers,
        category: _expenseFilterCategory,
        payerId: _expenseFilterUserId,
        onChanged: (category, payerId) {
          if (!mounted) return;
          _updateState(() {
            _expenseFilterCategory = category;
            _expenseFilterUserId = payerId;
          });
        },
      ),
    );
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
    final details = [
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

/// Keeps the filter dropdown attached to its button while the page moves.
final _expenseFilterLinks = Expando<LayerLink>();

enum _ExpenseFilterMenuPage { root, category, payer }

/// The expense filter dropdown: two rows (category, payer) that each open a
/// list in place. Picking an option applies it immediately.
class _ExpenseFilterMenu extends StatefulWidget {
  const _ExpenseFilterMenu({
    required this.link,
    required this.anchor,
    required this.categories,
    required this.payers,
    required this.category,
    required this.payerId,
    required this.onChanged,
  });

  final LayerLink link;
  final Rect anchor;
  final List<String> categories;
  final Map<int, String> payers;
  final String? category;
  final int payerId;
  final void Function(String? category, int payerId) onChanged;

  @override
  State<_ExpenseFilterMenu> createState() => _ExpenseFilterMenuState();
}

class _ExpenseFilterMenuState extends State<_ExpenseFilterMenu> {
  var _page = _ExpenseFilterMenuPage.root;
  late String? _category = widget.category;
  late int _payerId = widget.payerId;

  void _apply({required String? category, required int payerId}) {
    setState(() {
      _category = category;
      _payerId = payerId;
      _page = _ExpenseFilterMenuPage.root;
    });
    widget.onChanged(category, payerId);
  }

  String _categoryLabel(String value) =>
      ExpenseCategoryCatalog.labelFor(value, Localizations.localeOf(context));

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final width = math.min(288.0, size.width - 32);
    final spaceBelow =
        size.height -
        widget.anchor.bottom -
        math.max(media.padding.bottom, media.viewInsets.bottom) -
        16;
    final spaceAbove = widget.anchor.top - media.padding.top - 16;
    final below = spaceBelow >= 280 || spaceBelow >= spaceAbove;
    final right = (size.width - widget.anchor.right)
        .clamp(16.0, math.max(16.0, size.width - width - 16))
        .toDouble();
    final menu = Material(
      key: const ValueKey('expense-filters-menu'),
      elevation: 8,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width,
          minWidth: width,
          maxHeight: math.max(160, below ? spaceBelow : spaceAbove),
        ),
        child: switch (_page) {
          _ExpenseFilterMenuPage.root => _buildRoot(context),
          _ExpenseFilterMenuPage.category => _buildCategoryList(context),
          _ExpenseFilterMenuPage.payer => _buildPayerList(context),
        },
      ),
    );
    // Follows the button, so the menu stays attached when the list under
    // it shrinks after a filter is applied.
    return Align(
      alignment: Alignment.topLeft,
      child: CompositedTransformFollower(
        link: widget.link,
        showWhenUnlinked: false,
        targetAnchor: below ? Alignment.bottomRight : Alignment.topRight,
        followerAnchor: below ? Alignment.topRight : Alignment.bottomRight,
        offset: Offset(
          size.width - right - widget.anchor.right,
          below ? 4 : -4,
        ),
        child: menu,
      ),
    );
  }

  Widget _buildRoot(BuildContext context) {
    final t = context.l10n;
    final category = _category;
    final payerName = widget.payers[_payerId];
    final active = category != null || _payerId != 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilterMenuRow(
            key: const ValueKey('expense-filter-category-row'),
            icon: category == null
                ? Icons.category_outlined
                : ExpenseCategoryCatalog.iconFor(category),
            title: t.workspaceCategory,
            value: category == null ? t.allFilter : _categoryLabel(category),
            highlighted: category != null,
            onTap: () =>
                setState(() => _page = _ExpenseFilterMenuPage.category),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _FilterMenuRow(
            key: const ValueKey('expense-filter-payer-row'),
            icon: Icons.person_outline,
            title: t.paidByLabel,
            value: _payerId == 0 || payerName == null ? t.allFilter : payerName,
            highlighted: _payerId != 0,
            onTap: () => setState(() => _page = _ExpenseFilterMenuPage.payer),
          ),
          if (active) ...[
            const Divider(height: 1),
            TextButton(
              key: const ValueKey('expense-filters-clear'),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                shape: const RoundedRectangleBorder(),
              ),
              onPressed: () => _apply(category: null, payerId: 0),
              child: Text(t.workspaceClearFilters),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListPage(
    BuildContext context, {
    required String title,
    required List<Widget> options,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
          child: Row(
            children: [
              IconButton(
                key: const ValueKey('expense-filters-back'),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () =>
                    setState(() => _page = _ExpenseFilterMenuPage.root),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            children: options,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    final t = context.l10n;
    return _buildListPage(
      context,
      title: t.workspaceCategory,
      options: [
        _FilterMenuOption(
          key: const ValueKey('expense-filter-category-all'),
          icon: Icons.category_outlined,
          label: t.allFilter,
          selected: _category == null,
          onTap: () => _apply(category: null, payerId: _payerId),
        ),
        for (final value in widget.categories)
          _FilterMenuOption(
            key: ValueKey('expense-filter-category-$value'),
            icon: ExpenseCategoryCatalog.iconFor(value),
            label: _categoryLabel(value),
            selected: _category == value,
            onTap: () => _apply(category: value, payerId: _payerId),
          ),
      ],
    );
  }

  Widget _buildPayerList(BuildContext context) {
    final t = context.l10n;
    return _buildListPage(
      context,
      title: t.paidByLabel,
      options: [
        _FilterMenuOption(
          key: const ValueKey('expense-filter-payer-all'),
          icon: Icons.groups_outlined,
          label: t.allFilter,
          selected: _payerId == 0,
          onTap: () => _apply(category: _category, payerId: 0),
        ),
        for (final payer in widget.payers.entries)
          _FilterMenuOption(
            key: ValueKey('expense-filter-payer-${payer.key}'),
            icon: Icons.person_outline,
            label: payer.value,
            selected: _payerId == payer.key,
            onTap: () => _apply(category: _category, payerId: payer.key),
          ),
      ],
    );
  }
}

class _FilterMenuRow extends StatelessWidget {
  const _FilterMenuRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.highlighted,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Semantics(
      button: true,
      label: '$title, $value',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 22, color: colors.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: theme.textTheme.bodyLarge),
                      Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: highlighted
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          fontWeight: highlighted ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterMenuOption extends StatelessWidget {
  const _FilterMenuOption({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final color = selected ? colors.primary : null;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color ?? colors.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : null,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_rounded, size: 20, color: colors.primary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
