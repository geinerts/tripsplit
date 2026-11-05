import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_design.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/comment_mention_text.dart';
import '../../domain/entities/expense_comment_mention.dart';
import '../../domain/entities/workspace_user.dart';

const _rowExtent = 48.0;
const _visibleRows = 3.5;

TextStyle? _mentionStyle(BuildContext context, TextStyle? base) {
  final theme = Theme.of(context);
  return (base ?? const TextStyle()).copyWith(
    fontWeight: FontWeight.w700,
    color: theme.brightness == Brightness.dark
        ? theme.colorScheme.primary
        : AppDesign.lightPrimary,
  );
}

/// Comment text field controller that highlights mentions and remembers which
/// member was picked, so two members with the same name stay apart.
class CommentMentionTextController extends TextEditingController {
  CommentMentionTextController({
    super.text,
    Iterable<WorkspaceUser> members = const <WorkspaceUser>[],
    Iterable<ExpenseCommentMention> existingMentions =
        const <ExpenseCommentMention>[],
  }) : _existing = commentMentionCandidatesFromMentions(existingMentions),
       _picked = existingMentions.map((mention) => mention.userId).toSet() {
    updateMembers(members);
  }

  final List<CommentMentionCandidate> _existing;
  final Set<int> _picked;
  List<CommentMentionCandidate> _candidates = const [];

  void updateMembers(Iterable<WorkspaceUser> members) {
    _candidates = <CommentMentionCandidate>[
      ..._existing,
      for (final member in members) ...[
        CommentMentionCandidate(userId: member.id, name: member.preferredName),
        if (member.nickname.trim() != member.preferredName.trim())
          CommentMentionCandidate(userId: member.id, name: member.nickname),
      ],
    ];
  }

  List<CommentMentionSpan> get _spans =>
      findCommentMentionSpans(text, _candidates, preferredUserIds: _picked);

  List<int> get mentionedUserIds =>
      _spans.map((span) => span.userId).toSet().toList(growable: false);

  /// Null when the mention would make the comment too long.
  VoidCallback? insertAction(CommentMentionQuery query, WorkspaceUser member) {
    final inserted = insertCommentMention(text, query, member.preferredName);
    if (inserted == null) {
      return null;
    }
    return () {
      _picked.add(member.id);
      value = TextEditingValue(
        text: inserted.text,
        selection: TextSelection.collapsed(offset: inserted.cursor),
      );
    };
  }

  @override
  void clear() {
    _picked.clear();
    super.clear();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final spans = _spans;
    if (spans.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final composing = withComposing && value.isComposingRangeValid
        ? value.composing
        : TextRange.empty;
    final cuts = <int>{
      0,
      text.length,
      if (composing.isValid) ...[composing.start, composing.end],
      for (final span in spans) ...[span.start, span.end],
    }.toList()..sort();
    final mentionStyle = _mentionStyle(context, style);
    return TextSpan(
      style: style,
      children: <InlineSpan>[
        for (var i = 0; i < cuts.length - 1; i++)
          () {
            final start = cuts[i];
            final isMention = spans.any(
              (span) => start >= span.start && start < span.end,
            );
            final isComposing =
                composing.isValid &&
                start >= composing.start &&
                start < composing.end;
            final base = isMention ? mentionStyle : style;
            return TextSpan(
              text: text.substring(start, cuts[i + 1]),
              style: isComposing
                  ? (base ?? const TextStyle()).copyWith(
                      decoration: TextDecoration.underline,
                    )
                  : base,
            );
          }(),
      ],
    );
  }
}

/// A published comment with its mentions highlighted.
class CommentBodyText extends StatelessWidget {
  const CommentBodyText({
    super.key,
    required this.body,
    required this.mentions,
    this.style,
  });

  final String body;
  final List<ExpenseCommentMention> mentions;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final spans = findCommentMentionSpans(
      body,
      commentMentionCandidatesFromMentions(mentions),
      preferredUserIds: mentions.map((mention) => mention.userId).toSet(),
    );
    if (spans.isEmpty) {
      return Text(body, style: style);
    }
    final mentionStyle = _mentionStyle(context, style);
    final children = <InlineSpan>[];
    var position = 0;
    for (final span in spans) {
      if (span.start > position) {
        children.add(TextSpan(text: body.substring(position, span.start)));
      }
      children.add(
        TextSpan(
          text: body.substring(span.start, span.end),
          style: mentionStyle,
        ),
      );
      position = span.end;
    }
    if (position < body.length) {
      children.add(TextSpan(text: body.substring(position)));
    }
    return Text.rich(TextSpan(children: children), style: style);
  }
}

/// Filterable member list shown while an `@` is being typed in [controller].
class CommentMentionSuggestions extends StatefulWidget {
  const CommentMentionSuggestions({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.members,
    required this.currentUserId,
    this.revealKey,
    this.spacing = 8,
    this.spaceBelow = true,
  });

  final CommentMentionTextController controller;
  final FocusNode focusNode;
  final List<WorkspaceUser> members;
  final int currentUserId;

  /// Scrolled into view when the list opens. Defaults to the list itself.
  final GlobalKey? revealKey;
  final double spacing;
  final bool spaceBelow;

  @override
  State<CommentMentionSuggestions> createState() =>
      _CommentMentionSuggestionsState();
}

class _CommentMentionSuggestionsState extends State<CommentMentionSuggestions> {
  bool _wasOpen = false;

  void _revealWhenOpened(bool isOpen) {
    if (isOpen && !_wasOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target =
            widget.revealKey?.currentContext ?? (mounted ? context : null);
        if (target != null && target.mounted) {
          Scrollable.ensureVisible(
            target,
            alignment: 1,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
          );
        }
      });
    }
    _wasOpen = isOpen;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        widget.controller,
        widget.focusNode,
      ]),
      builder: (context, _) {
        final content = _buildContent(context);
        _revealWhenOpened(content != null);
        return content ?? const SizedBox.shrink();
      },
    );
  }

  Widget? _buildContent(BuildContext context) {
    final selection = widget.controller.selection;
    if (!widget.focusNode.hasFocus || !selection.isCollapsed) {
      return null;
    }
    final query = findCommentMentionQuery(
      widget.controller.text,
      selection.baseOffset,
    );
    if (query == null) {
      return null;
    }
    final others = <int, WorkspaceUser>{
      for (final member in widget.members)
        if (member.id != widget.currentUserId) member.id: member,
    };
    final matches = filterCommentMentionCandidates(
      others.values.map(
        (member) => CommentMentionCandidate(
          userId: member.id,
          name: member.preferredName,
        ),
      ),
      query.text,
    );
    // Text after a space is most likely an ordinary sentence, not a search.
    if (matches.isEmpty &&
        (others.isEmpty || query.text.isEmpty || query.text.contains(' '))) {
      return null;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final media = MediaQuery.of(context);
    final rowExtent = math.max(_rowExtent, media.textScaler.scale(_rowExtent));
    final maxHeight = math.min(
      rowExtent * _visibleRows,
      math.max(
        rowExtent * 1.5,
        (media.size.height - media.viewInsets.bottom) * .35,
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: widget.spaceBelow ? 0 : widget.spacing,
        bottom: widget.spaceBelow ? widget.spacing : 0,
      ),
      // Tapping a row must not count as a tap outside the text field.
      child: TextFieldTapRegion(
        child: Semantics(
          container: true,
          label: context.l10n.expenseMentionMembersLabel,
          child: Container(
            key: const ValueKey('comment-mention-suggestions'),
            constraints: BoxConstraints(maxHeight: maxHeight),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : AppDesign.lightSurfaceMuted,
              borderRadius: AppDesign.cardRadius,
              border: Border.all(
                color: isDark
                    ? theme.colorScheme.outlineVariant.withValues(alpha: 0.34)
                    : AppDesign.lightStroke,
              ),
            ),
            child: matches.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      context.l10n.expenseMentionNoMatches,
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : Material(
                    type: MaterialType.transparency,
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final member = others[matches[index].userId]!;
                        return _MentionRow(
                          member: member,
                          onTap: widget.controller.insertAction(query, member),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _MentionRow extends StatelessWidget {
  const _MentionRow({required this.member, required this.onTap});

  final WorkspaceUser member;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('comment-mention-option-${member.id}'),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _rowExtent),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              ExcludeSemantics(child: _MentionAvatar(member: member)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  member.preferredName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MentionAvatar extends StatelessWidget {
  const _MentionAvatar({required this.member});

  static const _size = 32.0;
  final WorkspaceUser member;

  @override
  Widget build(BuildContext context) {
    final palette = AppDesign.memberPalette;
    final words = member.preferredName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2);
    final fallback = Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette[member.id.abs() % palette.length],
        shape: BoxShape.circle,
      ),
      child: Text(
        words.map((word) => word.characters.first).join().toUpperCase(),
        textScaler: TextScaler.noScaling,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    final url = (member.avatarThumbUrl ?? member.avatarUrl ?? '').trim();
    if (url.isEmpty) {
      return fallback;
    }
    return ClipOval(
      child: Image.network(
        url,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}
