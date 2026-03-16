class BalanceItem {
  const BalanceItem({
    required this.id,
    required this.nickname,
    required this.paid,
    required this.owed,
    required this.net,
  });

  final int id;
  final String nickname;
  final double paid;
  final double owed;
  final double net;
}
