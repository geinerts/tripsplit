class SettlementItem {
  const SettlementItem({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.from,
    required this.to,
    required this.amount,
    required this.status,
    required this.canMarkSent,
    required this.canConfirmReceived,
    required this.isConfirmed,
  });

  final int? id;
  final int fromUserId;
  final int toUserId;
  final String from;
  final String to;
  final double amount;
  final String status;
  final bool canMarkSent;
  final bool canConfirmReceived;
  final bool isConfirmed;

  bool get isSuggested => status == 'suggested';
  bool get isPending => status == 'pending';
  bool get isSent => status == 'sent';
}
