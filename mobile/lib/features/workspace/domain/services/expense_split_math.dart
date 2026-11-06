import '../entities/expense_item.dart';

/// Everyone pays an equal part of what remains, plus their adjustment. Null when
/// the adjustments don't fit. Matches `expense_adjustment_owed_cents` on the server.
Map<int, int>? adjustmentOwedCents(
  int amountCents,
  List<int> participantIds,
  Map<int, int> adjustments,
) {
  if (participantIds.isEmpty) return null;
  var rest = amountCents;
  for (final id in participantIds) {
    rest -= adjustments[id] ?? 0;
  }
  if (rest < 0) return null;
  final base = rest ~/ participantIds.length;
  final remainder = rest % participantIds.length;
  final owed = <int, int>{};
  for (var i = 0; i < participantIds.length; i++) {
    final id = participantIds[i];
    final cents = base + (i < remainder ? 1 : 0) + (adjustments[id] ?? 0);
    if (cents < 0) return null;
    owed[id] = cents;
  }
  return owed;
}

/// Each item is shared equally among its people, and the extra in proportion to
/// their items. Matches `expense_itemized_owed_cents` on the server.
Map<int, int> itemizedOwedCents(List<ExpenseItem> items, int extraCents) {
  final owed = <int, int>{};
  for (final item in items) {
    final ids = item.participantIds;
    if (ids.isEmpty) continue;
    final cents = (item.amount * 100).round();
    final base = cents ~/ ids.length;
    final remainder = cents % ids.length;
    for (var i = 0; i < ids.length; i++) {
      owed[ids[i]] = (owed[ids[i]] ?? 0) + base + (i < remainder ? 1 : 0);
    }
  }
  final total = owed.values.fold<int>(0, (sum, cents) => sum + cents);
  if (extraCents <= 0 || total <= 0) return owed;

  var left = extraCents;
  final remainders = <int, int>{};
  for (final entry in owed.entries.toList()) {
    final share = extraCents * entry.value ~/ total;
    remainders[entry.key] = extraCents * entry.value % total;
    owed[entry.key] = entry.value + share;
    left -= share;
  }
  final order = remainders.keys.toList()
    ..sort((a, b) => remainders[b]!.compareTo(remainders[a]!));
  for (final id in order) {
    if (left <= 0) break;
    owed[id] = owed[id]! + 1;
    left--;
  }
  return owed;
}
