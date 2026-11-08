import 'comment_mention_text.dart';

class WorkspaceUser {
  const WorkspaceUser({
    required this.id,
    required this.nickname,
    this.role = 'member',
    this.displayName,
    this.firstName,
    this.lastName,
    this.tripName,
    this.avatarUrl,
    this.avatarThumbUrl,
    this.bankAccountHolder,
    this.bankIban,
    this.bankBic,
    this.revolutHandle,
    this.revolutMeLink,
    this.paypalMeLink,
    this.wisePayLink,
    this.isReadyToSettle = false,
    this.readyToSettleAt,
    this.isGuest = false,
  });

  final int id;
  final String nickname;
  final String role;
  final String? displayName;
  final String? firstName;
  final String? lastName;

  /// The name shown everywhere in the trip, from [withTripNames].
  final String? tripName;
  final String? avatarUrl;
  final String? avatarThumbUrl;
  final String? bankAccountHolder;
  final String? bankIban;
  final String? bankBic;
  final String? revolutHandle;
  final String? revolutMeLink;
  final String? paypalMeLink;
  final String? wisePayLink;
  final bool isReadyToSettle;
  final String? readyToSettleAt;

  /// A person added by name, with no account. The trip owner acts for them.
  final bool isGuest;

  /// The trip name when known, otherwise the full name.
  String get preferredName {
    final short = (tripName ?? '').trim();
    return short.isNotEmpty ? short : fullName;
  }

  String get fullName {
    final full = (displayName ?? '').trim();
    return full.isNotEmpty ? full : nickname;
  }

  /// Gives everyone in a trip the shortest name that still tells them apart:
  /// the first name, then the first name and last initial, then the full name.
  static List<WorkspaceUser> withTripNames(List<WorkspaceUser> users) {
    String firstOf(WorkspaceUser user) {
      final first = (user.firstName ?? '').trim();
      if (first.isNotEmpty) return first;
      final words = user.fullName.trim().split(RegExp(r'\s+'));
      return words.first;
    }

    String? lastOf(WorkspaceUser user) {
      final last = (user.lastName ?? '').trim();
      if (last.isNotEmpty) return last;
      final words = user.fullName.trim().split(RegExp(r'\s+'));
      return words.length > 1 ? words.last : null;
    }

    // Diacritics are ignored, so Matiss and Matīss count as the same name.
    String key(String value) => foldMemberName(value.trim());
    int count(Iterable<String> values, String value) =>
        values.where((other) => key(other) == key(value)).length;

    final firsts = users.map(firstOf).toList();
    final names = <String>[];
    for (var i = 0; i < users.length; i++) {
      if (count(firsts, firsts[i]) < 2) {
        names.add(firsts[i]);
        continue;
      }
      final last = lastOf(users[i]);
      if (last == null || last.isEmpty) {
        names.add(users[i].fullName);
        continue;
      }
      final initial =
          '${firsts[i]} ${String.fromCharCode(last.runes.first).toUpperCase()}.';
      final sameFirst = [
        for (var j = 0; j < users.length; j++)
          if (key(firsts[j]) == key(firsts[i])) j,
      ];
      final initials = [
        for (final j in sameFirst)
          if (lastOf(users[j]) case final other? when other.isNotEmpty)
            '${firsts[j]} ${String.fromCharCode(other.runes.first).toUpperCase()}.'
          else
            users[j].fullName,
      ];
      names.add(count(initials, initial) < 2 ? initial : users[i].fullName);
    }
    return [
      for (var i = 0; i < users.length; i++) users[i]._withTripName(names[i]),
    ];
  }

  WorkspaceUser _withTripName(String name) => WorkspaceUser(
    id: id,
    nickname: nickname,
    role: role,
    displayName: displayName,
    firstName: firstName,
    lastName: lastName,
    tripName: name,
    avatarUrl: avatarUrl,
    avatarThumbUrl: avatarThumbUrl,
    bankAccountHolder: bankAccountHolder,
    bankIban: bankIban,
    bankBic: bankBic,
    revolutHandle: revolutHandle,
    revolutMeLink: revolutMeLink,
    paypalMeLink: paypalMeLink,
    wisePayLink: wisePayLink,
    isReadyToSettle: isReadyToSettle,
    readyToSettleAt: readyToSettleAt,
    isGuest: isGuest,
  );

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';
  bool get canManageTrip => isOwner || isAdmin;

  bool get hasPaymentDetails => <String?>[
    bankIban,
    bankBic,
    revolutHandle,
    revolutMeLink,
    paypalMeLink,
    wisePayLink,
  ].any((value) => (value ?? '').trim().isNotEmpty);
}
