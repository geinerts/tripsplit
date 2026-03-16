part of 'workspace_page.dart';

extension _WorkspacePageExpenseSheetActions on _WorkspacePageState {
  Future<void> _openExpenseDetails({
    required WorkspaceSnapshot snapshot,
    required TripExpense expense,
  }) async {
    final hasCustomParticipants = expense.participants.isNotEmpty;
    final participants = expense.participants.isNotEmpty
        ? expense.participants
        : snapshot.users
              .map(
                (user) =>
                    ExpenseParticipant(id: user.id, nickname: user.nickname),
              )
              .toList(growable: false);

    final usersById = <int, String>{
      for (final user in snapshot.users) user.id: user.nickname,
    };
    final payerName =
        usersById[expense.paidById] ??
        (expense.paidByNickname.trim().isEmpty
            ? context.l10n.userWithId(expense.paidById)
            : expense.paidByNickname);
    final lines = _buildExpenseShareLines(
      expense: expense,
      participants: participants,
      payerName: payerName,
    );
    final transfers = _buildExpenseTransfers(
      lines: lines,
      payerId: expense.paidById,
      payerName: payerName,
    );
    final splitLabel = _splitModeSummaryLabel(
      splitMode: expense.splitMode,
      participantsCount: participants.length,
      hasCustomParticipants: hasCustomParticipants,
    );
    final categoryLabel = ExpenseCategoryCatalog.labelFor(
      expense.category,
      Localizations.localeOf(context),
    );
    final categoryIcon = ExpenseCategoryCatalog.iconFor(expense.category);
    final owedByUserId = <int, double>{
      for (final line in lines) line.userId: line.owes,
    };
    final currentUserLine = lines.where(
      (line) => line.userId == _currentUserId,
    );
    final myLine = currentUserLine.isNotEmpty ? currentUserLine.first : null;
    final initialFilterUserId = myLine != null ? myLine.userId : 0;
    var selectedUserId = initialFilterUserId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final t = context.l10n;
            final shownLines = selectedUserId > 0
                ? lines
                      .where((line) => line.userId == selectedUserId)
                      .toList(growable: false)
                : lines;
            final shownTransfers = selectedUserId > 0
                ? transfers
                      .where(
                        (item) =>
                            item.fromUserId == selectedUserId ||
                            item.toUserId == selectedUserId,
                      )
                      .toList(growable: false)
                : transfers;
            final filterLine = selectedUserId > 0
                ? lines
                      .where((line) => line.userId == selectedUserId)
                      .firstOrNull
                : null;
            final filterName = filterLine?.nickname;
            final colors = Theme.of(context).colorScheme;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: FractionallySizedBox(
                  heightFactor: 0.9,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SheetHeadlineCard(
                          icon: categoryIcon,
                          title: expense.note.isEmpty
                              ? categoryLabel
                              : expense.note,
                          subtitle: t.expenseIdDate(
                            expense.id,
                            expense.expenseDate,
                          ),
                          color: colors.primary,
                          meta: [
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
                              icon: Icons.payments_outlined,
                              label: t.amountLabel,
                              value: _formatMoney(expense.amount),
                            ),
                            _DetailChip(
                              icon: Icons.person_outline,
                              label: t.paidByLabel,
                              value: payerName,
                            ),
                            _DetailChip(
                              icon: Icons.group_outlined,
                              label: t.splitLabel,
                              value: splitLabel,
                            ),
                          ],
                        ),
                        if (myLine != null) ...[
                          const SizedBox(height: 10),
                          Card(
                            color: myLine.net < 0
                                ? colors.errorContainer.withValues(alpha: 0.35)
                                : colors.primaryContainer.withValues(
                                    alpha: 0.35,
                                  ),
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                myLine.net < 0
                                    ? Icons.call_made
                                    : Icons.call_received,
                              ),
                              title: Text(t.myImpactTitle),
                              subtitle: Text(
                                myLine.net < 0
                                    ? t.youShouldPay(
                                        _formatMoney(myLine.net.abs()),
                                      )
                                    : (myLine.net > 0
                                          ? t.youShouldReceive(
                                              _formatMoney(myLine.net),
                                            )
                                          : t.youSettledForExpense),
                              ),
                            ),
                          ),
                        ],
                        if (expense.receiptUrl != null) ...[
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _isMutating
                                ? null
                                : () => _openReceiptUrl(expense.receiptUrl!),
                            icon: const Icon(Icons.receipt_long),
                            label: Text(t.openReceiptAction),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _SheetSectionTitle(
                          title: t.participantsTitle,
                          subtitle: t.membersIncludedInExpense,
                        ),
                        const SizedBox(height: 8),
                        if (participants.isEmpty)
                          Text(t.noParticipantData)
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final participant in participants)
                                Chip(label: Text(participant.nickname)),
                            ],
                          ),
                        if (participants.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _SheetSectionTitle(
                            title: t.splitBreakdownTitle,
                            subtitle: t.splitBreakdownSubtitle,
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Column(
                              children: [
                                for (
                                  var i = 0;
                                  i < participants.length;
                                  i++
                                ) ...[
                                  ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      Icons.account_balance_wallet_outlined,
                                    ),
                                    title: Text(participants[i].nickname),
                                    subtitle: Text(
                                      _splitParticipantLabel(
                                        splitMode: expense.splitMode,
                                        participant: participants[i],
                                        owed:
                                            owedByUserId[participants[i].id] ??
                                            0,
                                      ),
                                    ),
                                    trailing: Text(
                                      _formatMoney(
                                        owedByUserId[participants[i].id] ?? 0,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (i < participants.length - 1)
                                    const Divider(height: 1),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _SheetSectionTitle(
                          title: t.viewByPersonTitle,
                          subtitle: t.filterSettlementByMemberSubtitle,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilterChip(
                              label: Text(t.allFilter),
                              selected: selectedUserId == 0,
                              onSelected: (_) {
                                setSheetState(() {
                                  selectedUserId = 0;
                                });
                              },
                            ),
                            if (myLine != null)
                              FilterChip(
                                label: Text(t.youLabel),
                                selected: selectedUserId == myLine.userId,
                                onSelected: (_) {
                                  setSheetState(() {
                                    selectedUserId = myLine.userId;
                                  });
                                },
                              ),
                            for (final line in lines)
                              FilterChip(
                                label: Text(line.nickname),
                                selected: selectedUserId == line.userId,
                                onSelected: (_) {
                                  setSheetState(() {
                                    selectedUserId = line.userId;
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SheetSectionTitle(
                          title: selectedUserId > 0
                              ? t.whoOwesWhatWithFilter(
                                  filterName ?? t.selectedLabel,
                                )
                              : t.whoOwesWhatTitle,
                          subtitle: t.whoOwesWhatSubtitle,
                        ),
                        const SizedBox(height: 8),
                        if (shownLines.isEmpty)
                          Text(t.noMatchingRows)
                        else
                          Card(
                            child: Column(
                              children: [
                                for (var i = 0; i < shownLines.length; i++) ...[
                                  ListTile(
                                    dense: true,
                                    leading: Icon(
                                      shownLines[i].isPayer
                                          ? Icons
                                                .account_balance_wallet_outlined
                                          : Icons.person_outline,
                                    ),
                                    title: Text(
                                      shownLines[i].isPayer
                                          ? t.payerName(shownLines[i].nickname)
                                          : shownLines[i].nickname,
                                    ),
                                    subtitle: Text(
                                      t.paidOwesLine(
                                        _formatMoney(shownLines[i].owes),
                                        _formatMoney(shownLines[i].paid),
                                      ),
                                    ),
                                    trailing: Text(
                                      _signedMoney(shownLines[i].net),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: shownLines[i].net < 0
                                            ? colors.error
                                            : colors.primary,
                                      ),
                                    ),
                                  ),
                                  if (i < shownLines.length - 1)
                                    const Divider(height: 1),
                                ],
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        _SheetSectionTitle(
                          title: selectedUserId > 0
                              ? t.settlementImpactWithFilter(
                                  filterName ?? t.selectedLabel,
                                )
                              : t.settlementImpactTitle,
                          subtitle: t.suggestedTransferDirections,
                        ),
                        const SizedBox(height: 8),
                        if (shownTransfers.isEmpty)
                          Text(t.noTransferNeededForFilter)
                        else
                          Card(
                            child: Column(
                              children: [
                                for (
                                  var i = 0;
                                  i < shownTransfers.length;
                                  i++
                                ) ...[
                                  ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.swap_horiz),
                                    title: Text(
                                      t.fromToLine(
                                        shownTransfers[i].fromNickname,
                                        shownTransfers[i].toNickname,
                                      ),
                                    ),
                                    subtitle: Text(
                                      t.suggestedTransferFromExpense,
                                    ),
                                    trailing: Text(
                                      _formatMoney(shownTransfers[i].amount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (i < shownTransfers.length - 1)
                                    const Divider(height: 1),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
