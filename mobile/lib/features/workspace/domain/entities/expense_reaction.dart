class ExpenseReaction {
  const ExpenseReaction({
    required this.emoji,
    required this.userId,
    required this.userNickname,
    required this.createdAt,
  });

  final String emoji;
  final int userId;
  final String userNickname;
  final String createdAt;
}
