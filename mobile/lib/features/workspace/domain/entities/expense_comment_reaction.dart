class ExpenseCommentReaction {
  const ExpenseCommentReaction({
    required this.commentId,
    required this.emoji,
    required this.userId,
    required this.userNickname,
    required this.createdAt,
  });

  final int commentId;
  final String emoji;
  final int userId;
  final String userNickname;
  final String createdAt;
}
