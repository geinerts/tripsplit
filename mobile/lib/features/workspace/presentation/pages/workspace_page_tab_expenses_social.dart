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
  List<ExpenseReaction>? _reactions;
  List<ExpenseComment>? _comments;
  bool _isTogglingReaction = false;
  bool _isSubmittingComment = false;
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
        widget.controller.listExpenseReactions(
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
        _reactions = (results[0] as List).cast<ExpenseReaction>();
        _comments = (results[1] as List).cast<ExpenseComment>();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reactions = const [];
        _comments = const [];
      });
    }
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _toggleReaction(String emoji) async {
    if (_isTogglingReaction) return;
    setState(() => _isTogglingReaction = true);
    try {
      await widget.controller.toggleExpenseReaction(
        expenseId: widget.expenseId,
        tripId: widget.tripId,
        emoji: emoji,
      );
      if (!mounted) return;
      final fresh = await widget.controller.listExpenseReactions(
        expenseId: widget.expenseId,
        tripId: widget.tripId,
      );
      if (!mounted) return;
      setState(() => _reactions = fresh);
    } catch (_) {
      // reactions are non-critical, fail silently
    } finally {
      if (mounted) setState(() => _isTogglingReaction = false);
    }
  }

  Future<void> _sendComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty || _isSubmittingComment) return;
    setState(() => _isSubmittingComment = true);
    try {
      await widget.controller.addExpenseComment(
        expenseId: widget.expenseId,
        tripId: widget.tripId,
        body: body,
      );
      if (!mounted) return;
      _commentController.clear();
      _commentFocus.unfocus();
      final fresh = await widget.controller.listExpenseComments(
        expenseId: widget.expenseId,
        tripId: widget.tripId,
      );
      if (!mounted) return;
      setState(() => _comments = fresh);
    } catch (_) {
      // silent
    } finally {
      if (mounted) setState(() => _isSubmittingComment = false);
    }
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
      setState(() {
        _comments = _comments?.where((c) => c.id != comment.id).toList();
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
        _buildReactionsSection(isDark, colors),
        const SizedBox(height: 18),
        _buildCommentsSection(isDark, colors),
        const SizedBox(height: 10),
        _buildCommentInput(isDark, colors),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildReactionsSection(bool isDark, ColorScheme colors) {
    final reactions = _reactions;

    // Aggregate counts and find current user's choice
    final counts = <String, int>{};
    final myEmojis = <String>{};
    if (reactions != null) {
      for (final r in reactions) {
        counts[r.emoji] = (counts[r.emoji] ?? 0) + 1;
        if (r.userId == widget.currentUserId) myEmojis.add(r.emoji);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.expenseReactionsTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? null : AppDesign.lightForeground,
          ),
        ),
        const SizedBox(height: 10),
        if (reactions == null)
          const SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          _buildEmojiGrid(counts, myEmojis, isDark, colors),
      ],
    );
  }

  Widget _buildCommentsSection(bool isDark, ColorScheme colors) {
    final comments = _comments;
    final count = comments?.length ?? 0;
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
            return _CommentTile(
              comment: c,
              isOwn: c.userId == widget.currentUserId,
              isDark: isDark,
              avatarUrl: avatarUrl,
              onLongPress: () => _confirmDeleteComment(c),
            );
          }),
      ],
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
              hintText: context.l10n.expenseAddCommentHint,
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

  Widget _buildEmojiGrid(
    Map<String, int> counts,
    Set<String> myEmojis,
    bool isDark,
    ColorScheme colors,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _kSocialEmojis.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        mainAxisExtent: 42,
      ),
      itemBuilder: (context, index) {
        final emoji = _kSocialEmojis[index];
        return _EmojiPill(
          emoji: emoji,
          count: counts[emoji] ?? 0,
          isActive: myEmojis.contains(emoji),
          isDisabled: _isTogglingReaction,
          isDark: isDark,
          onTap: () => _toggleReaction(emoji),
        );
      },
    );
  }
}

// ── _EmojiPill ───────────────────────────────────────────────────────────────

class _EmojiPill extends StatelessWidget {
  const _EmojiPill({
    required this.emoji,
    required this.count,
    required this.isActive,
    required this.isDisabled,
    required this.isDark,
    required this.onTap,
  });

  final String emoji;
  final int count;
  final bool isActive;
  final bool isDisabled;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Opacity(
      opacity: isDisabled ? 0.55 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Render emoji without any explicit TextStyle so the platform's
                // default font + emoji fallback chain is used unmodified.
                Text(emoji, style: const TextStyle(fontSize: 22)),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isActive
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
      ),
    );
  }
}

// ── _CommentTile ─────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.isOwn,
    required this.isDark,
    required this.onLongPress,
    this.avatarUrl,
  });

  final ExpenseComment comment;
  final bool isOwn;
  final bool isDark;
  final VoidCallback onLongPress;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = AppDesign.memberPalette;
    final avatarBg = palette[comment.userId.abs() % palette.length];
    final initials = _initials(comment.userNickname);
    final timeStr = _commentRelativeTime(context, comment.createdAt);

    return GestureDetector(
      onLongPress: isOwn ? onLongPress : null,
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
                      if (isOwn) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.more_horiz_rounded,
                          size: 14,
                          color: isDark
                              ? colors.onSurfaceVariant
                              : AppDesign.lightMuted,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    comment.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? null : AppDesign.lightForeground,
                    ),
                  ),
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
