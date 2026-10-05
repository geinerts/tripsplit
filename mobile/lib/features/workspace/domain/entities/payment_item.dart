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
    required this.requesterUserId,
    required this.requestedAt,
    required this.createdAt,
    required this.markedSentAt,
    required this.confirmedAt,
    required this.cancelledAt,
    required this.cancelReason,
    required this.canMarkRequestSent,
    this.canViewPaymentDetails = false,
    required this.canCancelRequest,
    required this.canDeclineRequest,
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
  final int? requesterUserId;
  final String? requestedAt;
  final String? createdAt;
  final String? markedSentAt;
  final String? confirmedAt;
  final String? cancelledAt;
  final String? cancelReason;
  final bool canMarkRequestSent;
  final bool canViewPaymentDetails;
  final bool canCancelRequest;
  final bool canDeclineRequest;
  final bool canConfirmReceived;
  final bool canCancelSent;
  final bool canReportNotReceived;
  final bool isConfirmed;

  bool get isRequested => status == 'requested';
  bool get isSent => status == 'sent';
  bool get isCancelled => status == 'cancelled';
  bool get originatedAsRequest => requesterUserId != null;
  bool get reservesBalance => isRequested || isSent;
}
