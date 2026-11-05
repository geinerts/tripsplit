import '../../domain/entities/comment_mention_text.dart';

/// Shortens member names to the first name wherever that still tells people
/// apart within a trip.
///
/// Diacritics are ignored when comparing, so `Matiss` and `Matīss` count as the
/// same first name and both keep their full name.
class WorkspaceMemberShortNames {
  WorkspaceMemberShortNames(Iterable<({int? id, String name})> members) {
    for (final member in members) {
      final first = _firstName(member.name);
      if (first.isNotEmpty) {
        (_ownersByFirstName[foldMemberName(first)] ??= <Object>{}).add(
          member.id ?? member.name.trim(),
        );
      }
    }
  }

  final Map<String, Set<Object>> _ownersByFirstName = {};

  String labelFor(int? id, String name) {
    final first = _firstName(name);
    if (first.isEmpty) {
      return name.trim();
    }
    final owners = _ownersByFirstName[foldMemberName(first)];
    final isUnique = owners == null || owners.length <= 1;
    return isUnique ? first : name.trim();
  }

  static String _firstName(String name) =>
      name.trim().split(RegExp(r'\s+')).first;
}
