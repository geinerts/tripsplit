part of 'workspace_page.dart';

// Emoji whitelist — must match backend ALLOWED_EXPENSE_REACTIONS.
// Unicode escapes guarantee correct encoding regardless of file handling.
final _kSocialEmojis = <String>[
  '\u{1F602}', // 😂
  '\u{1F44D}', // 👍
  '\u{1F624}', // 😤
  '\u{1F929}', // 🤩
  '\u{1F4B8}', // 💸
  '\u{1F605}', // 😅
  '\u{1F525}', // 🔥
  '\u{2764}\u{FE0F}', // ❤️
];

const _kExpenseSocialMaxConcurrentLoads = 4;
const _kInlinePopularEmojiLimit = 3;

TextStyle _emojiTextStyle(double size) => TextStyle(
  fontSize: size,
  height: 1.0,
  letterSpacing: 0,
  fontFamilyFallback: const <String>[
    'Apple Color Emoji',
    'Segoe UI Emoji',
    'Noto Color Emoji',
    'Noto Emoji',
  ],
);

class _InlineEmojiCount {
  const _InlineEmojiCount({
    required this.emoji,
    required this.count,
    required this.isMine,
  });

  final String emoji;
  final int count;
  final bool isMine;
}

enum _CommentQuickActionType { react, reply, edit, delete }

class _CommentQuickActionResult {
  const _CommentQuickActionResult._({required this.type, this.emoji});

  const _CommentQuickActionResult.react(String emoji)
    : this._(type: _CommentQuickActionType.react, emoji: emoji);

  const _CommentQuickActionResult.reply()
    : this._(type: _CommentQuickActionType.reply);

  const _CommentQuickActionResult.edit()
    : this._(type: _CommentQuickActionType.edit);

  const _CommentQuickActionResult.delete()
    : this._(type: _CommentQuickActionType.delete);

  final _CommentQuickActionType type;
  final String? emoji;
}

extension _WorkspacePageExpenseSocialInline on _WorkspacePageState {
  void _reconcileExpenseSocialPreviewState(List<TripExpense> expenses) {
    final expenseIds = expenses.map((expense) => expense.id).toSet();

    _expenseReactionsByExpenseId.removeWhere(
      (expenseId, _) => !expenseIds.contains(expenseId),
    );
    _expenseCommentsCountByExpenseId.removeWhere(
      (expenseId, _) => !expenseIds.contains(expenseId),
    );
    _expenseSocialLoadingIds.removeWhere(
      (expenseId) => !expenseIds.contains(expenseId),
    );
    _expenseSocialQueuedIds.removeWhere(
      (expenseId) => !expenseIds.contains(expenseId),
    );
    _expenseSocialTogglingIds.removeWhere(
      (expenseId) => !expenseIds.contains(expenseId),
    );
    _expenseSocialLoadQueue.removeWhere(
      (expenseId) => !expenseIds.contains(expenseId),
    );

    for (final expense in expenses) {
      if (expense.id <= 0) {
        continue;
      }
      final hasReactions = _expenseReactionsByExpenseId.containsKey(expense.id);
      final hasCommentsCount = _expenseCommentsCountByExpenseId.containsKey(
        expense.id,
      );
      if (hasReactions && hasCommentsCount) {
        continue;
      }
      if (_expenseSocialLoadingIds.contains(expense.id) ||
          _expenseSocialQueuedIds.contains(expense.id)) {
        continue;
      }
      _expenseSocialQueuedIds.add(expense.id);
      _expenseSocialLoadQueue.add(expense.id);
    }
    _drainExpenseSocialLoadQueue();
  }

  void _drainExpenseSocialLoadQueue() {
    if (!mounted) {
      return;
    }
    while (_expenseSocialLoadInFlight < _kExpenseSocialMaxConcurrentLoads &&
        _expenseSocialLoadQueue.isNotEmpty) {
      final expenseId = _expenseSocialLoadQueue.removeFirst();
      _expenseSocialQueuedIds.remove(expenseId);
      if (_expenseSocialLoadingIds.contains(expenseId)) {
        continue;
      }
      final hasReactions = _expenseReactionsByExpenseId.containsKey(expenseId);
      final hasComments = _expenseCommentsCountByExpenseId.containsKey(
        expenseId,
      );
      if (hasReactions && hasComments) {
        continue;
      }
      _expenseSocialLoadingIds.add(expenseId);
      _expenseSocialLoadInFlight += 1;
      unawaited(
        _fetchExpenseSocialPreview(expenseId).whenComplete(() {
          _expenseSocialLoadingIds.remove(expenseId);
          _expenseSocialLoadInFlight = math.max(
            0,
            _expenseSocialLoadInFlight - 1,
          );
          if (mounted) {
            _updateState(() {});
          }
          _drainExpenseSocialLoadQueue();
        }),
      );
    }
  }

  Future<void> _fetchExpenseSocialPreview(
    int expenseId, {
    bool force = false,
  }) async {
    try {
      final results = await Future.wait<dynamic>([
        widget.workspaceController.listExpenseReactions(
          expenseId: expenseId,
          tripId: widget.trip.id,
        ),
        widget.workspaceController.listExpenseComments(
          expenseId: expenseId,
          tripId: widget.trip.id,
        ),
      ]);
      if (!mounted) {
        return;
      }
      _updateState(() {
        _expenseReactionsByExpenseId[expenseId] = (results[0] as List)
            .cast<ExpenseReaction>();
        _expenseCommentsCountByExpenseId[expenseId] = (results[1] as List)
            .cast<ExpenseComment>()
            .length;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        if (force || !_expenseReactionsByExpenseId.containsKey(expenseId)) {
          _expenseReactionsByExpenseId[expenseId] = const <ExpenseReaction>[];
        }
        if (force || !_expenseCommentsCountByExpenseId.containsKey(expenseId)) {
          _expenseCommentsCountByExpenseId[expenseId] = 0;
        }
      });
    }
  }

  Future<void> _refreshExpenseSocialPreview(int expenseId) async {
    if (expenseId <= 0 || _expenseSocialLoadingIds.contains(expenseId)) {
      return;
    }
    _expenseSocialQueuedIds.remove(expenseId);
    _expenseSocialLoadQueue.remove(expenseId);
    _updateState(() {
      _expenseSocialLoadingIds.add(expenseId);
    });
    try {
      await _fetchExpenseSocialPreview(expenseId, force: true);
    } finally {
      if (mounted) {
        _updateState(() {
          _expenseSocialLoadingIds.remove(expenseId);
        });
      }
    }
  }

  Future<void> _toggleExpenseReactionInline({
    required int expenseId,
    required String emoji,
  }) async {
    if (expenseId <= 0 ||
        emoji.trim().isEmpty ||
        _expenseSocialTogglingIds.contains(expenseId)) {
      return;
    }
    _updateState(() {
      _expenseSocialTogglingIds.add(expenseId);
    });
    try {
      await widget.workspaceController.toggleExpenseReaction(
        expenseId: expenseId,
        tripId: widget.trip.id,
        emoji: emoji,
      );
      final fresh = await widget.workspaceController.listExpenseReactions(
        expenseId: expenseId,
        tripId: widget.trip.id,
      );
      if (!mounted) {
        return;
      }
      _updateState(() {
        _expenseReactionsByExpenseId[expenseId] = fresh;
      });
      if (!_expenseCommentsCountByExpenseId.containsKey(expenseId) &&
          !_expenseSocialLoadingIds.contains(expenseId) &&
          !_expenseSocialQueuedIds.contains(expenseId)) {
        _expenseSocialQueuedIds.add(expenseId);
        _expenseSocialLoadQueue.add(expenseId);
        _drainExpenseSocialLoadQueue();
      }
    } catch (_) {
      // Reactions are non-critical, fail silently.
    } finally {
      if (mounted) {
        _updateState(() {
          _expenseSocialTogglingIds.remove(expenseId);
        });
      }
    }
  }

  List<_InlineEmojiCount> _topExpenseReactions(List<ExpenseReaction>? raw) {
    if (raw == null || raw.isEmpty) {
      return const <_InlineEmojiCount>[];
    }

    final whitelistRank = <String, int>{
      for (var i = 0; i < _kSocialEmojis.length; i++) _kSocialEmojis[i]: i,
    };
    final counts = <String, int>{};
    final mine = <String>{};

    for (final reaction in raw) {
      final emoji = reaction.emoji.trim();
      if (emoji.isEmpty || !whitelistRank.containsKey(emoji)) {
        continue;
      }
      counts[emoji] = (counts[emoji] ?? 0) + 1;
      if (reaction.userId == _currentUserId) {
        mine.add(emoji);
      }
    }
    if (counts.isEmpty) {
      return const <_InlineEmojiCount>[];
    }

    final rows = counts.entries
        .map(
          (entry) => _InlineEmojiCount(
            emoji: entry.key,
            count: entry.value,
            isMine: mine.contains(entry.key),
          ),
        )
        .toList(growable: false);
    rows.sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      if (byCount != 0) {
        return byCount;
      }
      return (whitelistRank[a.emoji] ?? 999).compareTo(
        whitelistRank[b.emoji] ?? 999,
      );
    });

    return rows.take(_kInlinePopularEmojiLimit).toList(growable: false);
  }
}

class _ExpenseInlineSocialBar extends StatelessWidget {
  const _ExpenseInlineSocialBar({
    required this.popularReactions,
    required this.commentCount,
    required this.isLoading,
    required this.isBusy,
    required this.isDark,
    required this.onCommentsTap,
    required this.onQuickReactionTap,
  });

  final List<_InlineEmojiCount> popularReactions;
  final int? commentCount;
  final bool isLoading;
  final bool isBusy;
  final bool isDark;
  final VoidCallback onCommentsTap;
  final ValueChanged<String> onQuickReactionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final row in popularReactions) ...[
          _ExpenseInlineReactionChip(
            emoji: row.emoji,
            count: row.count,
            isMine: row.isMine,
            isDark: isDark,
            isDisabled: isBusy,
            onTap: () => onQuickReactionTap(row.emoji),
          ),
          const SizedBox(width: 2),
        ],
        _ExpenseInlineCommentsChip(
          isDark: isDark,
          count: commentCount ?? 0,
          isLoading: isLoading && commentCount == null,
          onTap: onCommentsTap,
        ),
      ],
    );
  }
}

class _ExpenseInlineReactionChip extends StatelessWidget {
  const _ExpenseInlineReactionChip({
    required this.emoji,
    required this.count,
    required this.isMine,
    required this.isDark,
    required this.isDisabled,
    required this.onTap,
  });

  final String emoji;
  final int count;
  final bool isMine;
  final bool isDark;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final displayEmoji = emoji.trim();
    if (displayEmoji.isEmpty) {
      return const SizedBox.shrink();
    }
    return Opacity(
      opacity: isDisabled ? 0.62 : 1,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(displayEmoji, style: _emojiTextStyle(16)),
              if (count > 0) ...[
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isMine
                        ? (isDark ? colors.primary : AppDesign.lightPrimary)
                        : (isDark
                              ? colors.onSurfaceVariant
                              : AppDesign.lightMuted),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseInlineCommentsChip extends StatelessWidget {
  const _ExpenseInlineCommentsChip({
    required this.isDark,
    required this.count,
    required this.isLoading,
    required this.onTap,
  });

  final bool isDark;
  final int count;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mode_comment_outlined,
              size: 13,
              color: isDark ? colors.onSurfaceVariant : AppDesign.lightMuted,
            ),
            const SizedBox(width: 1),
            Text(
              isLoading ? '…' : '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? colors.onSurfaceVariant : AppDesign.lightMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineEmojiPickerButton extends StatelessWidget {
  const _InlineEmojiPickerButton({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayEmoji = emoji.trim();
    if (displayEmoji.isEmpty) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox.square(
        dimension: 40,
        child: Center(child: Text(displayEmoji, style: _emojiTextStyle(28))),
      ),
    );
  }
}

class _EmojiPickerRow extends StatelessWidget {
  const _EmojiPickerRow({required this.emojis, required this.onSelect});

  final List<String> emojis;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final normalized = <String>[
      for (final raw in emojis)
        if (raw.trim().isNotEmpty) raw.trim(),
    ];
    if (normalized.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        for (final emoji in normalized)
          Expanded(
            child: Center(
              child: _InlineEmojiPickerButton(
                emoji: emoji,
                onTap: () => onSelect(emoji),
              ),
            ),
          ),
      ],
    );
  }
}

class _CommentActionRow extends StatelessWidget {
  const _CommentActionRow({
    required this.label,
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.isDestructive = false,
    this.showDivider = false,
  });

  final String label;
  final IconData icon;
  final bool isDark;
  final bool isDestructive;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textColor = isDestructive
        ? AppDesign.lightDestructive
        : (isDark ? colors.onSurface : AppDesign.lightForeground);
    final iconColor = isDestructive
        ? AppDesign.lightDestructive
        : (isDark ? colors.onSurfaceVariant : AppDesign.lightMuted);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: isDark
                        ? colors.outlineVariant.withValues(alpha: 0.20)
                        : AppDesign.lightStroke,
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Icon(icon, size: 20, color: iconColor),
          ],
        ),
      ),
    );
  }
}

// ── _ExpenseSocialSection ────────────────────────────────────────────────────

class _ExpenseSocialSection extends StatefulWidget {
  const _ExpenseSocialSection({
    required this.expenseId,
    required this.tripId,
    required this.currentUserId,
    required this.controller,
    required this.usersById,
  });

  final int expenseId;
  final int tripId;
  final int currentUserId;
  final WorkspaceController controller;
  final Map<int, WorkspaceUser> usersById;

  @override
  State<_ExpenseSocialSection> createState() => _ExpenseSocialSectionState();
}

class _ExpenseSocialSectionState extends State<_ExpenseSocialSection> {
  List<ExpenseCommentReaction>? _commentReactions;
  List<ExpenseComment>? _comments;
  ExpenseComment? _replyTarget;
  bool _isSubmittingComment = false;
  final Set<int> _commentReactionBusyIds = <int>{};
  final _commentController = TextEditingController();
  final _commentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  // ── Data loading ────────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final results = await Future.wait<dynamic>([
        widget.controller.listExpenseCommentReactions(
          expenseId: widget.expenseId,
          tripId: widget.tripId,
        ),
        widget.controller.listExpenseComments(
          expenseId: widget.expenseId,
          tripId: widget.tripId,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _commentReactions = (results[0] as List).cast<ExpenseCommentReaction>();
        _comments = (results[1] as List).cast<ExpenseComment>();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _commentReactions = const [];
        _comments = const [];
      });
    }
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Map<int, List<_InlineEmojiCount>> _commentReactionRowsByCommentId(
    List<ExpenseCommentReaction>? raw,
  ) {
    if (raw == null || raw.isEmpty) {
      return const <int, List<_InlineEmojiCount>>{};
    }

    final whitelistRank = <String, int>{
      for (var i = 0; i < _kSocialEmojis.length; i++) _kSocialEmojis[i]: i,
    };
    final countsByComment = <int, Map<String, int>>{};
    final mineByComment = <int, Set<String>>{};

    for (final reaction in raw) {
      final commentId = reaction.commentId;
      final emoji = reaction.emoji.trim();
      if (commentId <= 0 ||
          emoji.isEmpty ||
          !whitelistRank.containsKey(emoji)) {
        continue;
      }
      final counts = countsByComment.putIfAbsent(
        commentId,
        () => <String, int>{},
      );
      counts[emoji] = (counts[emoji] ?? 0) + 1;
      if (reaction.userId == widget.currentUserId) {
        mineByComment.putIfAbsent(commentId, () => <String>{}).add(emoji);
      }
    }

    final rowsByComment = <int, List<_InlineEmojiCount>>{};
    countsByComment.forEach((commentId, counts) {
      final mine = mineByComment[commentId] ?? const <String>{};
      final rows = counts.entries
          .map(
            (entry) => _InlineEmojiCount(
              emoji: entry.key,
              count: entry.value,
              isMine: mine.contains(entry.key),
            ),
          )
          .toList(growable: false);
      rows.sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        if (byCount != 0) {
          return byCount;
        }
        return (whitelistRank[a.emoji] ?? 999).compareTo(
          whitelistRank[b.emoji] ?? 999,
        );
      });
      rowsByComment[commentId] = rows;
    });

    return rowsByComment;
  }

  Future<void> _toggleCommentReaction({
    required int commentId,
    required String emoji,
  }) async {
    if (commentId <= 0 ||
        emoji.trim().isEmpty ||
        _commentReactionBusyIds.contains(commentId)) {
      return;
    }
    setState(() {
      _commentReactionBusyIds.add(commentId);
    });
    try {
      await widget.controller.toggleExpenseCommentReaction(
        commentId: commentId,
        expenseId: widget.expenseId,
        tripId: widget.tripId,
        emoji: emoji,
      );
      if (!mounted) return;
      final fresh = await widget.controller.listExpenseCommentReactions(
        expenseId: widget.expenseId,
        tripId: widget.tripId,
      );
      if (!mounted) return;
      setState(() {
        _commentReactions = fresh;
      });
    } catch (_) {
      // Reactions are non-critical, fail silently.
    } finally {
      if (mounted) {
        setState(() {
          _commentReactionBusyIds.remove(commentId);
        });
      }
    }
  }

  Future<void> _showCommentActionsSheet(ExpenseComment comment) async {
    if (comment.id <= 0 || _commentReactionBusyIds.contains(comment.id)) {
      return;
    }
    final isOwn = comment.userId == widget.currentUserId;
    final picked = await showAppBottomSheet<_CommentQuickActionResult>(
      context: context,
      isScrollControlled: false,
      showDragHandle: false,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? colors.surface : AppDesign.lightSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? colors.outlineVariant.withValues(alpha: 0.32)
                        : AppDesign.lightStroke,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: _EmojiPickerRow(
                  emojis: _kSocialEmojis,
                  onSelect: (emoji) {
                    Navigator.of(
                      context,
                    ).pop(_CommentQuickActionResult.react(emoji));
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? colors.surface : AppDesign.lightSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? colors.outlineVariant.withValues(alpha: 0.32)
                        : AppDesign.lightStroke,
                  ),
                ),
                child: Column(
                  children: [
                    _CommentActionRow(
                      label: 'Reply',
                      icon: Icons.reply_rounded,
                      isDark: isDark,
                      showDivider: isOwn,
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pop(const _CommentQuickActionResult.reply());
                      },
                    ),
                    if (isOwn)
                      _CommentActionRow(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                        isDark: isDark,
                        showDivider: true,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pop(const _CommentQuickActionResult.edit());
                        },
                      ),
                    if (isOwn)
                      _CommentActionRow(
                        label: context.l10n.deleteAction,
                        icon: Icons.delete_outline_rounded,
                        isDark: isDark,
                        isDestructive: true,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pop(const _CommentQuickActionResult.delete());
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || picked == null) {
      return;
    }
    switch (picked.type) {
      case _CommentQuickActionType.react:
        final emoji = (picked.emoji ?? '').trim();
        if (emoji.isEmpty) {
          return;
        }
        await _toggleCommentReaction(commentId: comment.id, emoji: emoji);
        return;
      case _CommentQuickActionType.reply:
        _startReplyTo(comment);
        return;
      case _CommentQuickActionType.edit:
        if (!isOwn) {
          return;
        }
        await _showEditCommentDialog(comment);
        return;
      case _CommentQuickActionType.delete:
        if (!isOwn) {
          return;
        }
        await _confirmDeleteComment(comment);
        return;
    }
  }

  Future<void> _showEditCommentDialog(ExpenseComment comment) async {
    final initial = comment.body.trim();
    final textController = TextEditingController(text: initial);
    String? edited;
    try {
      edited = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Edit comment'),
          content: TextField(
            controller: textController,
            autofocus: true,
            maxLength: 280,
            minLines: 1,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Write a comment...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(context.l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(textController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } finally {
      textController.dispose();
    }
    final next = (edited ?? '').trim();
    if (next.isEmpty || next == initial || !mounted) {
      return;
    }
    try {
      await widget.controller.updateExpenseComment(
        commentId: comment.id,
        expenseId: widget.expenseId,
        tripId: widget.tripId,
        body: next,
      );
      if (!mounted) return;
      final fresh = await widget.controller.listExpenseComments(
        expenseId: widget.expenseId,
        tripId: widget.tripId,
      );
      if (!mounted) return;
      setState(() {
        _comments = fresh;
        if (_replyTarget?.id == comment.id) {
          ExpenseComment? refreshed;
          for (final item in fresh) {
            if (item.id == comment.id) {
              refreshed = item;
              break;
            }
          }
          _replyTarget = refreshed;
        }
      });
    } catch (_) {
      // silent
    }
  }

  Future<void> _sendComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty || _isSubmittingComment) return;
    final replyTarget = _replyTarget;
    setState(() => _isSubmittingComment = true);
    try {
      await widget.controller.addExpenseComment(
        expenseId: widget.expenseId,
        tripId: widget.tripId,
        body: body,
        parentCommentId: replyTarget?.id,
      );
      if (!mounted) return;
      _commentController.clear();
      _commentFocus.unfocus();
      final fresh = await widget.controller.listExpenseComments(
        expenseId: widget.expenseId,
        tripId: widget.tripId,
      );
      if (!mounted) return;
      setState(() {
        _comments = fresh;
        _replyTarget = null;
      });
    } catch (_) {
      // silent
    } finally {
      if (mounted) setState(() => _isSubmittingComment = false);
    }
  }

  void _startReplyTo(ExpenseComment comment) {
    final body = comment.body.trim();
    if (body.isEmpty) {
      return;
    }
    setState(() {
      _replyTarget = comment;
    });
    _commentFocus.requestFocus();
  }

  void _clearReplyTarget() {
    if (_replyTarget == null) {
      return;
    }
    setState(() {
      _replyTarget = null;
    });
  }

  Future<void> _confirmDeleteComment(ExpenseComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.expenseDeleteCommentTitle),
        content: Text(
          comment.body,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppDesign.lightDestructive,
            ),
            child: Text(context.l10n.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.controller.deleteExpenseComment(
        commentId: comment.id,
        expenseId: widget.expenseId,
        tripId: widget.tripId,
      );
      if (!mounted) return;
      final results = await Future.wait<dynamic>([
        widget.controller.listExpenseComments(
          expenseId: widget.expenseId,
          tripId: widget.tripId,
        ),
        widget.controller.listExpenseCommentReactions(
          expenseId: widget.expenseId,
          tripId: widget.tripId,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _comments = (results[0] as List).cast<ExpenseComment>();
        _commentReactions = (results[1] as List).cast<ExpenseCommentReaction>();
        _commentReactionBusyIds.remove(comment.id);
        if (_replyTarget?.id == comment.id) {
          _replyTarget = null;
        }
      });
    } catch (_) {
      // silent
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 28),
        _buildCommentsSection(isDark, colors),
        const SizedBox(height: 10),
        if (_replyTarget != null) ...[
          _buildReplyTargetHeader(isDark, colors),
          const SizedBox(height: 8),
        ],
        _buildCommentInput(isDark, colors),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildCommentsSection(bool isDark, ColorScheme colors) {
    final comments = _comments;
    final count = comments?.length ?? 0;
    final reactionRowsByCommentId = _commentReactionRowsByCommentId(
      _commentReactions,
    );
    final commentsById = <int, ExpenseComment>{
      for (final comment in comments ?? const <ExpenseComment>[])
        comment.id: comment,
    };
    final sectionLabel = count > 0
        ? '${context.l10n.expenseCommentsTitle} ($count)'
        : context.l10n.expenseCommentsTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? null : AppDesign.lightForeground,
          ),
        ),
        const SizedBox(height: 10),
        if (comments == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          )
        else if (comments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              context.l10n.expenseNoComments,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? colors.onSurfaceVariant : AppDesign.lightMuted,
              ),
            ),
          )
        else
          ...comments.map((c) {
            final user = widget.usersById[c.userId];
            final avatarUrl = user?.avatarThumbUrl ?? user?.avatarUrl;
            final parentComment = c.parentCommentId == null
                ? null
                : commentsById[c.parentCommentId!];
            final replyToNickname =
                (c.parentUserNickname ?? parentComment?.userNickname)?.trim();
            final replyToBody = (c.parentBody ?? parentComment?.body)?.trim();
            final reactionRows =
                reactionRowsByCommentId[c.id] ?? const <_InlineEmojiCount>[];
            return _CommentTile(
              comment: c,
              isDark: isDark,
              avatarUrl: avatarUrl,
              onLongPress: () => _showCommentActionsSheet(c),
              onQuickReactionTap: (emoji) =>
                  _toggleCommentReaction(commentId: c.id, emoji: emoji),
              reactionRows: reactionRows,
              isReactionBusy: _commentReactionBusyIds.contains(c.id),
              replyToNickname: (replyToNickname?.isNotEmpty ?? false)
                  ? replyToNickname
                  : null,
              replyToBody: (replyToBody?.isNotEmpty ?? false)
                  ? replyToBody
                  : null,
            );
          }),
      ],
    );
  }

  Widget _buildReplyTargetHeader(bool isDark, ColorScheme colors) {
    final target = _replyTarget;
    if (target == null) {
      return const SizedBox.shrink();
    }
    final nickname = target.userNickname.trim().isEmpty
        ? context.l10n.userWithId(target.userId)
        : target.userNickname.trim();
    final preview = target.body.trim().replaceAll(RegExp(r'\s+'), ' ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerHighest.withValues(alpha: 0.55)
            : AppDesign.lightSurfaceMuted.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.34)
              : AppDesign.lightStroke,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.reply_rounded,
            size: 16,
            color: isDark ? colors.primary : AppDesign.lightPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to $nickname',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? colors.primary : AppDesign.lightPrimary,
                  ),
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? colors.onSurfaceVariant
                          : AppDesign.lightMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: _clearReplyTarget,
            icon: const Icon(Icons.close_rounded, size: 16),
            visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
            splashRadius: 16,
            tooltip: context.l10n.cancelAction,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(bool isDark, ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            focusNode: _commentFocus,
            maxLength: 280,
            maxLines: 4,
            minLines: 1,
            enabled: !_isSubmittingComment,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: _replyTarget == null
                  ? context.l10n.expenseAddCommentHint
                  : 'Write a reply...',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _commentController,
          builder: (context, value, child) {
            final canSend =
                value.text.trim().isNotEmpty && !_isSubmittingComment;
            return IconButton.filled(
              onPressed: canSend ? _sendComment : null,
              icon: _isSubmittingComment
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              tooltip: context.l10n.expenseCommentSend,
            );
          },
        ),
      ],
    );
  }
}

// ── _CommentTile ─────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.isDark,
    required this.onLongPress,
    required this.onQuickReactionTap,
    required this.reactionRows,
    required this.isReactionBusy,
    this.replyToNickname,
    this.replyToBody,
    this.avatarUrl,
  });

  final ExpenseComment comment;
  final bool isDark;
  final VoidCallback onLongPress;
  final ValueChanged<String> onQuickReactionTap;
  final List<_InlineEmojiCount> reactionRows;
  final bool isReactionBusy;
  final String? replyToNickname;
  final String? replyToBody;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = AppDesign.memberPalette;
    final avatarBg = palette[comment.userId.abs() % palette.length];
    final initials = _initials(comment.userNickname);
    final timeStr = _commentRelativeTime(context, comment.createdAt);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(avatarBg, initials),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          comment.userNickname,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? null
                                    : AppDesign.lightForeground,
                              ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeStr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? colors.onSurfaceVariant
                              : AppDesign.lightMuted,
                        ),
                      ),
                    ],
                  ),
                  if ((replyToNickname ?? '').trim().isNotEmpty ||
                      (replyToBody ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.surfaceContainerHighest.withValues(
                                alpha: 0.55,
                              )
                            : AppDesign.lightSurfaceMuted.withValues(
                                alpha: 0.72,
                              ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? colors.outlineVariant.withValues(alpha: 0.30)
                              : AppDesign.lightStroke,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((replyToNickname ?? '').trim().isNotEmpty)
                            Text(
                              'Reply to ${(replyToNickname ?? '').trim()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? colors.primary
                                        : AppDesign.lightPrimary,
                                  ),
                            ),
                          if ((replyToBody ?? '').trim().isNotEmpty)
                            Text(
                              (replyToBody ?? '').trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? colors.onSurfaceVariant
                                        : AppDesign.lightMuted,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    comment.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? null : AppDesign.lightForeground,
                    ),
                  ),
                  if (reactionRows.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 1,
                      runSpacing: 6,
                      children: [
                        for (final reaction in reactionRows)
                          _ExpenseInlineReactionChip(
                            emoji: reaction.emoji,
                            count: reaction.count,
                            isMine: reaction.isMine,
                            isDark: isDark,
                            isDisabled: isReactionBusy,
                            onTap: () => onQuickReactionTap(reaction.emoji),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Color bg, String initials) {
    final url = (avatarUrl ?? '').trim();
    if (url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          errorBuilder: (_, error, stackTrace) => _fallbackAvatar(bg, initials),
        ),
      );
    }
    return _fallbackAvatar(bg, initials);
  }

  Widget _fallbackAvatar(Color bg, String initials) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final first = parts.first;
      return (first.length >= 2 ? first.substring(0, 2) : first).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _commentRelativeTime(BuildContext context, String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '';
    // MySQL TIMESTAMP is stored/served as UTC but without a 'Z' suffix.
    // Replace the space separator and append 'Z' so Dart parses it as UTC,
    // then convert to device local time for display.
    final iso = s.replaceFirst(' ', 'T');
    final withTz = (iso.contains('Z') || iso.contains('+')) ? iso : '${iso}Z';
    final moment = DateTime.tryParse(withTz)?.toLocal();
    if (moment == null) return '';
    final diff = DateTime.now().difference(moment);
    if (diff.inMinutes < 1) return context.l10n.workspaceJustNow;
    if (diff.inMinutes < 60) {
      return context.l10n.workspaceMinAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) return context.l10n.workspaceHAgo(diff.inHours);
    if (diff.inDays < 7) return context.l10n.workspaceDAgo(diff.inDays);
    final day = moment.day.toString().padLeft(2, '0');
    final month = moment.month.toString().padLeft(2, '0');
    return '$day.$month';
  }
}
