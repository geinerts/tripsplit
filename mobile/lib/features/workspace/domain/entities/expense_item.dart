/// One line of an itemized bill, in the expense's own currency.
class ExpenseItem {
  const ExpenseItem({
    required this.name,
    required this.amount,
    required this.participantIds,
  });

  final String name;
  final double amount;
  final List<int> participantIds;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'amount': amount,
    'participant_ids': participantIds,
  };

  static List<ExpenseItem> listFromJson(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (item) => ExpenseItem(
            name: item['name'] as String? ?? '',
            amount: (item['amount'] as num?)?.toDouble() ?? 0,
            participantIds: (item['participant_ids'] as List? ?? const [])
                .whereType<num>()
                .map((id) => id.toInt())
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
  }
}
