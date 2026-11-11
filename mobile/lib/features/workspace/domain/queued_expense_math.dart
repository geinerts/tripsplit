import 'entities/expense_item.dart';
import 'services/expense_split_math.dart';

Map<int, double> queuedExpenseOwedByUser({
  required double amount,
  required List<int> participantIds,
  required String splitMode,
  required Map<int, double> splitValuesByUser,
  List<ExpenseItem> items = const [],
  double extraAmount = 0,
}) {
  if (participantIds.isEmpty) {
    return const <int, double>{};
  }

  final amountCents = (amount * 100).round();
  if (amountCents <= 0) {
    return const <int, double>{};
  }

  if (splitMode == 'itemized') {
    return itemizedOwedCents(
      items,
      (extraAmount * 100).round(),
    ).map((key, value) => MapEntry(key, value / 100));
  }
  if (splitMode == 'adjustment') {
    final owed = adjustmentOwedCents(amountCents, participantIds, {
      for (final id in participantIds)
        id: ((splitValuesByUser[id] ?? 0) * 100).round(),
    });
    if (owed != null) {
      return owed.map((key, value) => MapEntry(key, value / 100));
    }
  }

  final owedCents = <int, int>{for (final id in participantIds) id: 0};
  if (splitMode == 'exact') {
    for (final id in participantIds) {
      final value = splitValuesByUser[id] ?? 0;
      owedCents[id] = (value * 100).round();
    }
  } else if (splitMode == 'percent') {
    final basisPoints = <int, int>{
      for (final id in participantIds)
        id: ((splitValuesByUser[id] ?? 0) * 100).round(),
    };
    return _distributeByWeight(
      amountCents: amountCents,
      participantIds: participantIds,
      weightsByUser: basisPoints,
    ).map((key, value) => MapEntry(key, value / 100));
  } else if (splitMode == 'shares') {
    final shares = <int, int>{
      for (final id in participantIds) id: (splitValuesByUser[id] ?? 0).round(),
    };
    return _distributeByWeight(
      amountCents: amountCents,
      participantIds: participantIds,
      weightsByUser: shares,
    ).map((key, value) => MapEntry(key, value / 100));
  } else {
    final base = amountCents ~/ participantIds.length;
    final remainder = amountCents % participantIds.length;
    for (var i = 0; i < participantIds.length; i++) {
      owedCents[participantIds[i]] = base + (i < remainder ? 1 : 0);
    }
  }

  return owedCents.map((key, value) => MapEntry(key, value / 100));
}

Map<int, int> _distributeByWeight({
  required int amountCents,
  required List<int> participantIds,
  required Map<int, int> weightsByUser,
}) {
  final totalWeight = participantIds.fold<int>(
    0,
    (sum, id) =>
        sum + ((weightsByUser[id] ?? 0) > 0 ? (weightsByUser[id]!) : 0),
  );
  if (totalWeight <= 0) {
    return <int, int>{for (final id in participantIds) id: 0};
  }

  final out = <int, int>{for (final id in participantIds) id: 0};
  final remainders = <({int userId, int index, int remainder})>[];
  var allocated = 0;

  for (var i = 0; i < participantIds.length; i++) {
    final userId = participantIds[i];
    final rawWeight = weightsByUser[userId] ?? 0;
    final weight = rawWeight < 0
        ? 0
        : (rawWeight > (1 << 30) ? (1 << 30) : rawWeight);
    if (weight <= 0) {
      remainders.add((userId: userId, index: i, remainder: 0));
      continue;
    }
    final weighted = amountCents * weight;
    final base = weighted ~/ totalWeight;
    final remainder = weighted % totalWeight;
    out[userId] = base;
    allocated += base;
    remainders.add((userId: userId, index: i, remainder: remainder));
  }

  var left = amountCents - allocated;
  if (left <= 0) {
    return out;
  }
  remainders.sort((a, b) {
    final cmp = b.remainder.compareTo(a.remainder);
    if (cmp != 0) {
      return cmp;
    }
    return a.index.compareTo(b.index);
  });

  var idx = 0;
  while (left > 0 && remainders.isNotEmpty) {
    final row = remainders[idx % remainders.length];
    out[row.userId] = (out[row.userId] ?? 0) + 1;
    left -= 1;
    idx += 1;
  }

  return out;
}
