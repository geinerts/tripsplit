import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/workspace/domain/entities/comment_mention_text.dart';
import 'package:tripsplit/features/workspace/domain/entities/expense_comment_mention.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_user.dart';
import 'package:tripsplit/features/workspace/presentation/widgets/comment_mention_input.dart';

void main() {
  test('positions follow the text as sent, one per person', () {
    final controller = CommentMentionTextController(
      text: '  Hi @Anna and @Anna again ',
      members: const [WorkspaceUser(id: 8, nickname: 'Anna')],
    );
    final sent = controller.text.trim();
    final spans = controller.mentionSpansFor(sent);
    expect(spans, hasLength(1));
    expect(spans.single.userId, 8);
    expect(sent.substring(spans.single.start, spans.single.end), '@Anna');
    controller.dispose();
  });

  testWidgets('a stored position is highlighted even when the name differs', (
    tester,
  ) async {
    const body = 'Thanks 🎉 @Annuška!';
    final start = body.indexOf('@');
    await tester.pumpWidget(
      MaterialApp(
        home: CommentBodyText(
          body: body,
          mentions: [
            ExpenseCommentMention(
              userId: 8,
              name: 'Anna',
              start: start,
              end: start + '@Annuška'.length,
            ),
          ],
        ),
      ),
    );
    final rich = tester.widget<RichText>(find.byType(RichText));
    final parts = <String>[];
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.text != null) parts.add(span.text!);
      return true;
    });
    expect(parts, ['Thanks 🎉 ', '@Annuška', '!']);
  });

  test('a position that does not point at @ is not trusted', () {
    final spans = findCommentMentionSpans('Hi Anna', const [
      CommentMentionCandidate(userId: 8, name: 'Anna'),
    ]);
    expect(spans, isEmpty);
  });
}
