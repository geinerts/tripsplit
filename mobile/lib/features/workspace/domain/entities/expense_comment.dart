class ExpenseComment {
  const ExpenseComment({
    required this.id,
    required this.userId,
    required this.userNickname,
    required this.body,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String userNickname;
  final String body;
  final String createdAt;
}
