part of 'workspace_page.dart';

extension _WorkspacePageExpensesDetailsActions on _WorkspacePageState {
  List<_ExpenseShareLine> _buildExpenseShareLines({
    required TripExpense expense,
    required List<ExpenseParticipant> participants,
    required String payerName,
  }) {
    final lines = ExpenseMath.buildShareLines(
      amount: expense.amount,
      payerId: expense.paidById,
      payerName: payerName,
      participants: participants,
      fallbackUserName: (userId) => context.l10n.userWithId(userId),
    );
    return lines
        .map(
          (line) => _ExpenseShareLine(
            userId: line.userId,
            nickname: line.nickname,
            paid: line.paid,
            owes: line.owes,
            isPayer: line.isPayer,
          ),
        )
        .toList(growable: false);
  }

  String _splitModeSummaryLabel({
    required String splitMode,
    required int participantsCount,
    required bool hasCustomParticipants,
  }) {
    final t = context.l10n;
    final mode = splitMode.trim().toLowerCase();
    final target = hasCustomParticipants
        ? '$participantsCount'
        : t.allMembersLabel;
    switch (mode) {
      case 'exact':
        return t.splitModeExact(target);
      case 'percent':
        return t.splitModePercent(target);
      case 'shares':
        return t.splitModeShares(target);
      default:
        return t.splitModeEqual(target);
    }
  }

  List<_ExpenseTransferLine> _buildExpenseTransfers({
    required List<_ExpenseShareLine> lines,
    required int payerId,
    required String payerName,
  }) {
    final transferLines = ExpenseMath.buildTransfers(
      lines: lines
          .map(
            (line) => ExpenseShareLineMath(
              userId: line.userId,
              nickname: line.nickname,
              paid: line.paid,
              owes: line.owes,
              isPayer: line.isPayer,
            ),
          )
          .toList(growable: false),
      payerId: payerId,
      payerName: payerName,
    );
    return transferLines
        .map(
          (line) => _ExpenseTransferLine(
            fromUserId: line.fromUserId,
            fromNickname: line.fromNickname,
            toUserId: line.toUserId,
            toNickname: line.toNickname,
            amount: line.amount,
          ),
        )
        .toList(growable: false);
  }

  String _splitParticipantLabel({
    required String splitMode,
    required ExpenseParticipant participant,
    required double owed,
  }) {
    final t = context.l10n;
    switch (splitMode.trim().toLowerCase()) {
      case 'exact':
        final exact = participant.splitValue ?? participant.owedAmount ?? owed;
        return t.exactAmountWithValue(
          _formatMoney(context, exact, currencyCode: widget.trip.currencyCode),
        );
      case 'percent':
        final percent = participant.splitValue ?? 0;
        return t.percentWithValue('${_formatCompactNumber(percent)}%');
      case 'shares':
        final shares = participant.splitValue ?? 0;
        return t.sharesWithValue(_formatCompactNumber(shares));
      default:
        return t.equalSplitLabel;
    }
  }
}
