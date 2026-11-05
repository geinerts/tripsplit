import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/workspace/domain/entities/comment_mention_text.dart';

const anna = CommentMentionCandidate(userId: 2, name: 'Anna Bērziņa');
const matiss = CommentMentionCandidate(userId: 3, name: 'Matīss Geinerts');

List<int> ids(
  String text,
  List<CommentMentionCandidate> candidates, {
  Set<int> preferred = const <int>{},
}) => findCommentMentionSpans(
  text,
  candidates,
  preferredUserIds: preferred,
).map((span) => span.userId).toList();

void main() {
  group('findCommentMentionQuery', () {
    test('opens at the start and after a space', () {
      expect(findCommentMentionQuery('@', 1)?.text, '');
      expect(findCommentMentionQuery('hi @An', 6)?.text, 'An');
      expect(findCommentMentionQuery('hi @An', 6)?.start, 3);
      expect(findCommentMentionQuery('@Anna B', 7)?.text, 'Anna B');
    });

    test('follows the cursor, not the end of the text', () {
      expect(findCommentMentionQuery('@An more', 3)?.text, 'An');
      expect(findCommentMentionQuery('hi @An', 2), isNull);
    });

    test(
      'stays closed for emails, new lines, a leading space and bad cursors',
      () {
        expect(findCommentMentionQuery('me@example', 10), isNull);
        expect(findCommentMentionQuery('@An\nna', 6), isNull);
        expect(findCommentMentionQuery('@ An', 4), isNull);
        expect(findCommentMentionQuery('@An', -1), isNull);
        expect(findCommentMentionQuery('@An', 0), isNull);
      },
    );
  });

  group('filterCommentMentionCandidates', () {
    test('matches any word and ignores case and diacritics', () {
      expect(filterCommentMentionCandidates([anna, matiss], ''), [
        anna,
        matiss,
      ]);
      expect(filterCommentMentionCandidates([anna, matiss], 'bērz'), [anna]);
      expect(filterCommentMentionCandidates([anna, matiss], 'BERZ'), [anna]);
      expect(filterCommentMentionCandidates([anna, matiss], 'matiss'), [
        matiss,
      ]);
      expect(filterCommentMentionCandidates([anna, matiss], 'anna b'), [anna]);
      expect(filterCommentMentionCandidates([anna, matiss], 'nna'), isEmpty);
    });

    test('a finished mention followed by a space does not reopen the list', () {
      expect(
        filterCommentMentionCandidates([anna, matiss], 'Anna Bērziņa '),
        isEmpty,
      );
    });
  });

  group('insertCommentMention', () {
    test('replaces only the query and places the cursor after the space', () {
      final inserted = insertCommentMention(
        'hi @An there',
        const CommentMentionQuery(start: 3, text: 'An'),
        'Anna Bērziņa',
      )!;
      expect(inserted.text, 'hi @Anna Bērziņa  there');
      expect(inserted.cursor, 'hi @Anna Bērziņa '.length);
    });

    test('refuses a mention that would exceed the limit', () {
      final text = '${'a' * 275} @';
      final query = CommentMentionQuery(start: text.length - 1, text: '');
      expect(insertCommentMention(text, query, 'Anna Bērziņa'), isNull);
      expect(insertCommentMention(text, query, 'Al'), isNotNull);
    });
  });

  group('findCommentMentionSpans', () {
    test('finds names case-insensitively with exact offsets', () {
      final spans = findCommentMentionSpans('hi @anna bērziņa!', [anna]);
      expect(spans.single.start, 3);
      expect(spans.single.end, 16);
      expect(spans.single.userId, 2);
    });

    test('ignores email-like text and longer words', () {
      expect(ids('me@Anna Bērziņa', [anna]), isEmpty);
      expect(ids('@Anna Bērziņas', [anna]), isEmpty);
    });

    test('prefers the longest name', () {
      const short = CommentMentionCandidate(userId: 9, name: 'Anna');
      expect(ids('@Anna Bērziņa', [short, anna]), [2]);
      expect(ids('@Anna hello', [short, anna]), [9]);
    });

    test('an unpicked shared name is left out; picked members stay apart', () {
      const first = CommentMentionCandidate(userId: 1, name: 'Anna');
      const second = CommentMentionCandidate(userId: 2, name: 'Anna');
      expect(ids('@Anna', [first, second]), isEmpty);
      expect(ids('@Anna', [first, second], preferred: {2}), [2]);
      expect(ids('@Anna @Anna', [first, second], preferred: {1, 2}), [1, 2]);
    });

    test('tolerates no candidates and a trailing @', () {
      expect(ids('@Anna', const []), isEmpty);
      expect(ids('@Anna Bērziņa @', [anna]), [2]);
    });
  });
}
