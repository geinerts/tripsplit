class ExpenseParticipant {
  const ExpenseParticipant({
    required this.id,
    required this.nickname,
    this.owedAmount,
    this.splitValue,
  });

  final int id;
  final String nickname;
  final double? owedAmount;
  final double? splitValue;
}
