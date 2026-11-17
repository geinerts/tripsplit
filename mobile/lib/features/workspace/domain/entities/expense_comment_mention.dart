class ExpenseCommentMention {
  const ExpenseCommentMention({
    required this.userId,
    required this.name,
    this.start,
    this.end,
  });

  final int userId;

  /// The name as written in the comment body, without the leading `@`.
  final String name;

  /// Where `@name` is in the body, in UTF-16 units, when the server stored it.
  final int? start;
  final int? end;
}
