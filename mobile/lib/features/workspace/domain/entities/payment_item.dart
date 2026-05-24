class PaymentItem {
  const PaymentItem({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.from,
    required this.to,
    required this.amount,
    required this.status,
    required this.note,
    required this.createdAt,
    required this.markedSentAt,
    required this.confirmedAt,
    required this.cancelledAt,
    required this.cancelReason,
    required this.canConfirmReceived,
    required this.canCancelSent,
    required this.canReportNotReceived,
    required this.isConfirmed,
  });

  final int id;
  final int fromUserId;
  final int toUserId;
  final String from;
  final String to;
  final double amount;
  final String status;
  final String note;
  final String? createdAt;
  final String? markedSentAt;
  final String? confirmedAt;
  final String? cancelledAt;
  final String? cancelReason;
  final bool canConfirmReceived;
  final bool canCancelSent;
  final bool canReportNotReceived;
  final bool isConfirmed;

  bool get isSent => status == 'sent';
  bool get isCancelled => status == 'cancelled';
}
