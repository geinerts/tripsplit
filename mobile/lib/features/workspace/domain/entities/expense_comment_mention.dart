class ExpenseCommentMention {
  const ExpenseCommentMention({required this.userId, required this.name});

  final int userId;

  /// The name as written in the comment body, without the leading `@`.
  final String name;
}
