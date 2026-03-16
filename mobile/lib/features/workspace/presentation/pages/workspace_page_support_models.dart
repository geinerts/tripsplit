part of 'workspace_page.dart';

class _ExpenseFormResult {
  const _ExpenseFormResult({
    required this.amount,
    required this.date,
    required this.category,
    required this.note,
    required this.participants,
    required this.splitMode,
    required this.splitValues,
    required this.receiptFileBytes,
    required this.receiptFileName,
    required this.removeReceipt,
  });

  final double amount;
  final String date;
  final String category;
  final String note;
  final List<int> participants;
  final String splitMode;
  final List<ExpenseSplitValue> splitValues;
  final Uint8List? receiptFileBytes;
  final String? receiptFileName;
  final bool removeReceipt;
}

class _PickedFile {
  const _PickedFile({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

class _ExpenseShareLine {
  const _ExpenseShareLine({
    required this.userId,
    required this.nickname,
    required this.paid,
    required this.owes,
    required this.isPayer,
  });

  final int userId;
  final String nickname;
  final double paid;
  final double owes;
  final bool isPayer;

  double get net => paid - owes;
}

class _ExpenseTransferLine {
  const _ExpenseTransferLine({
    required this.fromUserId,
    required this.fromNickname,
    required this.toUserId,
    required this.toNickname,
    required this.amount,
  });

  final int fromUserId;
  final String fromNickname;
  final int toUserId;
  final String toNickname;
  final double amount;
}
