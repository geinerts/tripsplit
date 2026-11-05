import 'expense_comment_mention.dart';

const expenseCommentMaxLength = 280;
const _maxMentionQueryLength = 64;

final _wordCharacter = RegExp(r'[\p{L}\p{N}_]', unicode: true);
final _whitespace = RegExp(r'\s');

const _foldedLetters = <String, String>{
  'ā': 'a',
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'ã': 'a',
  'å': 'a',
  'ą': 'a',
  'æ': 'ae',
  'č': 'c',
  'ć': 'c',
  'ç': 'c',
  'ď': 'd',
  'ē': 'e',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'ě': 'e',
  'ę': 'e',
  'ģ': 'g',
  'ī': 'i',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ķ': 'k',
  'ļ': 'l',
  'ł': 'l',
  'ņ': 'n',
  'ń': 'n',
  'ñ': 'n',
  'ň': 'n',
  'ō': 'o',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ø': 'o',
  'œ': 'oe',
  'ŗ': 'r',
  'ř': 'r',
  'š': 's',
  'ś': 's',
  'ß': 'ss',
  'ť': 't',
  'ū': 'u',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ů': 'u',
  'ý': 'y',
  'ž': 'z',
  'ź': 'z',
  'ż': 'z',
};

String _foldForSearch(String value) => value
    .toLowerCase()
    .split('')
    .map((letter) => _foldedLetters[letter] ?? letter)
    .join();

class CommentMentionCandidate {
  const CommentMentionCandidate({required this.userId, required this.name});

  final int userId;
  final String name;
}

class CommentMentionSpan {
  const CommentMentionSpan({
    required this.start,
    required this.end,
    required this.userId,
  });

  /// Index of the `@`.
  final int start;
  final int end;
  final int userId;
}

/// The unfinished `@text` that ends at the cursor.
class CommentMentionQuery {
  const CommentMentionQuery({required this.start, required this.text});

  /// Index of the `@`.
  final int start;
  final String text;

  int get end => start + 1 + text.length;
}

bool _isWordCharacterAt(String text, int index) =>
    index >= 0 && index < text.length && _wordCharacter.hasMatch(text[index]);

CommentMentionQuery? findCommentMentionQuery(String text, int cursor) {
  if (cursor <= 0 || cursor > text.length) {
    return null;
  }
  final start = text.lastIndexOf('@', cursor - 1);
  if (start < 0 ||
      cursor - start - 1 > _maxMentionQueryLength ||
      _isWordCharacterAt(text, start - 1)) {
    return null;
  }
  final query = text.substring(start + 1, cursor);
  return query.contains('\n') || query.startsWith(' ')
      ? null
      : CommentMentionQuery(start: start, text: query);
}

/// Names matching the query, by the start of the name or of any word in it.
/// Latin diacritics are ignored, so `matiss` finds `Matīss`.
List<CommentMentionCandidate> filterCommentMentionCandidates(
  Iterable<CommentMentionCandidate> candidates,
  String query,
) {
  final folded = _foldForSearch(query);
  final isFinished = folded != folded.trimRight();
  final results = <CommentMentionCandidate>[];
  for (final candidate in candidates) {
    final name = _foldForSearch(candidate.name.trim());
    // A finished mention followed by a space must not reopen the list.
    if (isFinished && name == folded.trimRight()) {
      return const <CommentMentionCandidate>[];
    }
    if (name.startsWith(folded) ||
        name.split(_whitespace).any((word) => word.startsWith(folded))) {
      results.add(candidate);
    }
  }
  return results;
}

/// The value after replacing [query] with a mention, or null if it would not fit.
({String text, int cursor})? insertCommentMention(
  String text,
  CommentMentionQuery query,
  String name, {
  int maxLength = expenseCommentMaxLength,
}) {
  final mention = '@${name.trim()} ';
  final result = text.replaceRange(query.start, query.end, mention);
  return result.trimRight().length > maxLength
      ? null
      : (text: result, cursor: query.start + mention.length);
}

/// Finds mentions in [text], preferring the longest name at each `@`.
///
/// Members with the same name are told apart by [preferredUserIds]. Without a
/// preference such a name is left out, because it could mean either person.
List<CommentMentionSpan> findCommentMentionSpans(
  String text,
  Iterable<CommentMentionCandidate> candidates, {
  Set<int> preferredUserIds = const <int>{},
}) {
  final byName = <String, List<CommentMentionCandidate>>{};
  for (final candidate in candidates) {
    final name = candidate.name.trim().toLowerCase();
    if (name.isNotEmpty) {
      (byName[name] ??= <CommentMentionCandidate>[]).add(candidate);
    }
  }
  if (byName.isEmpty) {
    return const <CommentMentionSpan>[];
  }
  final names = byName.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  final spans = <CommentMentionSpan>[];
  final used = <int>{};

  var index = text.indexOf('@');
  while (index >= 0) {
    var next = index + 1;
    if (!_isWordCharacterAt(text, index - 1)) {
      for (final name in names) {
        final end = next + name.length;
        if (end > text.length ||
            text.substring(next, end).toLowerCase() != name ||
            _isWordCharacterAt(text, end)) {
          continue;
        }
        final userId = _pickMentionUser(byName[name]!, preferredUserIds, used);
        if (userId != null) {
          used.add(userId);
          spans.add(CommentMentionSpan(start: index, end: end, userId: userId));
          next = end;
          break;
        }
      }
    }
    index = next >= text.length ? -1 : text.indexOf('@', next);
  }
  return spans;
}

int? _pickMentionUser(
  List<CommentMentionCandidate> sameName,
  Set<int> preferred,
  Set<int> used,
) {
  final ids = sameName.map((candidate) => candidate.userId).toSet();
  final picked = ids.where(preferred.contains);
  for (final id in picked) {
    if (!used.contains(id)) {
      return id;
    }
  }
  if (ids.length == 1) {
    return ids.single;
  }
  return picked.isEmpty ? null : picked.first;
}

List<CommentMentionCandidate> commentMentionCandidatesFromMentions(
  Iterable<ExpenseCommentMention> mentions,
) => mentions
    .map(
      (mention) =>
          CommentMentionCandidate(userId: mention.userId, name: mention.name),
    )
    .toList(growable: false);
