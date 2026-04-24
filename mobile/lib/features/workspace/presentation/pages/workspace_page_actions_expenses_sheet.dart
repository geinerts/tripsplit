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
    final splitMode = expense.splitMode.trim().toLowerCase();
    final splitColor = splitMode == 'equal'
        ? AppDesign.lightSuccess
        : AppDesign.lightAccent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = expense.note.trim().isEmpty
        ? categoryLabel
        : expense.note.trim();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final maxOwed = lines.fold<double>(
          0,
          (maxValue, line) => math.max(maxValue, line.owes),
        );

        return SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.22 : 0.10,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: FractionallySizedBox(
                  heightFactor: 0.92,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? colors.surface : AppDesign.lightSurface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 46,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.28)
                                : const Color(0xFFD8D2C8),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 82,
                                    height: 82,
                                    decoration: BoxDecoration(
                                      color: splitColor.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      categoryIcon,
                                      color: splitColor,
                                      size: 42,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: isDark
                                                    ? null
                                                    : AppDesign.lightForeground,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatDisplayDate(
                                            context,
                                            expense.expenseDate,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
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
                                  IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: const Icon(Icons.close_rounded),
                                    tooltip: MaterialLocalizations.of(
                                      context,
                                    ).closeButtonTooltip,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  14,
                                  14,
                                  14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isDark
                                      ? colors.surfaceContainerHighest
                                      : const Color(0xFFF2EFE8),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                context
                                                    .l10n
                                                    .workspaceTotalAmount,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: isDark
                                                          ? colors
                                                                .onSurfaceVariant
                                                          : AppDesign
                                                                .lightMuted,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatMoney(
                                                  context,
                                                  expense.amount,
                                                  currencyCode:
                                                      expense.tripCurrencyCode,
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: isDark
                                                          ? null
                                                          : AppDesign
                                                                .lightForeground,
                                                    ),
                                              ),
                                              if (expense.expenseCurrencyCode !=
                                                  expense.tripCurrencyCode)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
                                                  child: Text(
                                                    '${context.l10n.workspaceOriginal}: ${_formatMoney(context, expense.originalAmount, currencyCode: expense.expenseCurrencyCode)}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: isDark
                                                              ? colors
                                                                    .onSurfaceVariant
                                                              : AppDesign
                                                                    .lightMuted,
                                                        ),
                                                  ),
                                                ),
                                              if (expense.expenseCurrencyCode !=
                                                  expense.tripCurrencyCode)
                                                Text(
                                                  '1 ${expense.expenseCurrencyCode} ≈ ${_formatMoney(context, expense.fxRateToTrip, currencyCode: expense.tripCurrencyCode)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: isDark
                                                            ? colors
                                                                  .onSurfaceVariant
                                                            : AppDesign
                                                                  .lightMuted,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              context.l10n.paidByLabel,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    color: isDark
                                                        ? colors
                                                              .onSurfaceVariant
                                                        : AppDesign.lightMuted,
                                                  ),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                _largeMemberAvatar(
                                                  id: expense.paidById,
                                                  name: payerName,
                                                  avatarUrl:
                                                      payerUser
                                                          ?.avatarThumbUrl ??
                                                      payerUser?.avatarUrl,
                                                  size: 38,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  payerName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 7,
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
                                        child: Text(
                                          splitLabel,
                                          style: TextStyle(
                                            color: splitColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (expense.receiptUrl != null) ...[
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _isMutating
                                      ? null
                                      : () => _openReceiptUrl(
                                          expense.receiptUrl!,
                                        ),
                                  icon: const Icon(Icons.receipt_long),
                                  label: Text(context.l10n.openReceiptAction),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Text(
                                context.l10n.splitBreakdownTitle,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? null
                                          : AppDesign.lightForeground,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              if (lines.isEmpty)
                                Text(context.l10n.noParticipantData)
                              else
                                ...lines.map((line) {
                                  final lineUser = usersById[line.userId];
                                  final lineName =
                                      (lineUser?.preferredName ?? line.nickname)
                                          .trim()
                                          .isEmpty
                                      ? line.nickname
                                      : (lineUser?.preferredName ??
                                                line.nickname)
                                            .trim();
                                  final ratio = maxOwed <= 0
                                      ? 0.0
                                      : (line.owes / maxOwed)
                                            .clamp(0.0, 1.0)
                                            .toDouble();
                                  final percentage = expense.amount <= 0
                                      ? 0.0
                                      : ((line.owes / expense.amount) * 100)
                                            .clamp(0.0, 100.0)
                                            .toDouble();

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        12,
                                        12,
                                        12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? colors.surfaceContainerHighest
                                            : AppDesign.lightSurface,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isDark
                                              ? colors.outlineVariant
                                                    .withValues(alpha: 0.30)
                                              : AppDesign.lightStroke,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              _largeMemberAvatar(
                                                id: line.userId,
                                                name: lineName,
                                                avatarUrl:
                                                    lineUser?.avatarThumbUrl ??
                                                    lineUser?.avatarUrl,
                                                size: 44,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      lineName,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: isDark
                                                                ? null
                                                                : AppDesign
                                                                      .lightForeground,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${percentage.toStringAsFixed(0)}%',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: isDark
                                                                ? colors
                                                                      .onSurfaceVariant
                                                                : AppDesign
                                                                      .lightMuted,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatMoney(
                                                  context,
                                                  line.owes,
                                                  currencyCode:
                                                      expense.tripCurrencyCode,
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: isDark
                                                          ? null
                                                          : AppDesign
                                                                .lightForeground,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 9),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            child: SizedBox(
                                              height: 10,
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: ColoredBox(
                                                      color: isDark
                                                          ? colors
                                                                .surfaceContainerHigh
                                                          : const Color(
                                                              0xFFE8E2D9,
                                                            ),
                                                    ),
                                                  ),
                                                  if (ratio > 0)
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: FractionallySizedBox(
                                                        widthFactor: ratio,
                                                        child: DecoratedBox(
                                                          decoration: BoxDecoration(
                                                            color: AppDesign
                                                                .lightPrimary,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  999,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              _ExpenseSocialSection(
                                expenseId: expense.id,
                                tripId: widget.trip.id,
                                currentUserId: _currentUserId,
                                controller: widget.workspaceController,
                                usersById: usersById,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (mounted) {
      unawaited(_refreshExpenseSocialPreview(expense.id));
    }
  }
}
