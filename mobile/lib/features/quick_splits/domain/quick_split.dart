/// One bill split between people without a trip. A record only: no balances
/// or payments. See docs/api/quick-splits.md.
class QuickSplit {
  const QuickSplit({
    required this.id,
    required this.note,
    required this.category,
    required this.date,
    required this.amount,
    required this.currencyCode,
    required this.peopleCount,
    required this.myAmount,
    required this.paidByMe,
    required this.paidByName,
    required this.canEdit,
    this.subcategory,
    this.peoplePreview = const [],
    this.hasReceipt = false,
    this.splitMode = 'equal',
    this.createdBy = 0,
    this.people = const [],
    this.items = const [],
    this.extraAmount = 0,
    this.receiptPath,
    this.receiptUrl,
    this.receiptThumbUrl,
    this.addedToTripId,
  });

  final int id;
  final String note;
  final String category;
  final String? subcategory;

  /// `YYYY-MM-DD`.
  final String date;
  final double amount;
  final String currencyCode;
  final int peopleCount;

  /// The viewer's part; 0 when they only paid.
  final double myAmount;
  final bool paidByMe;
  final String paidByName;
  final List<QuickSplitPreviewPerson> peoplePreview;
  final bool hasReceipt;
  final bool canEdit;

  // Only in a full quick split (`get_quick_split`).
  final String splitMode;
  final int createdBy;
  final List<QuickSplitPerson> people;
  final List<QuickSplitItem> items;
  final double extraAmount;

  /// Sent back unchanged when the creator saves again.
  final String? receiptPath;
  final String? receiptUrl;
  final String? receiptThumbUrl;
  final int? addedToTripId;

  bool get isFull => people.isNotEmpty;

  QuickSplitPerson? get payer =>
      people.where((person) => person.isPayer).firstOrNull;

  factory QuickSplit.fromJson(Map<String, dynamic> json) {
    final added = json['added_to_trip'];
    return QuickSplit(
      id: _int(json['id']),
      note: _string(json['note']),
      category: _string(json['category'], fallback: 'other'),
      subcategory: _nullableString(json['subcategory']),
      date: _string(json['date']),
      amount: _double(json['amount']),
      currencyCode: _string(json['currency_code'], fallback: 'EUR'),
      peopleCount: _int(json['people_count']),
      myAmount: _double(json['my_amount']),
      paidByMe: json['paid_by_me'] == true,
      paidByName: _string(json['paid_by_name']),
      peoplePreview: [
        for (final raw in json['people_preview'] as List? ?? const [])
          if (raw is Map)
            QuickSplitPreviewPerson(
              name: _string(raw['name']),
              avatarThumbUrl: _nullableString(raw['avatar_thumb_url']),
            ),
      ],
      hasReceipt: json['has_receipt'] == true,
      canEdit: json['can_edit'] == true,
      splitMode: _string(json['split_mode'], fallback: 'equal'),
      createdBy: _int(json['created_by']),
      people: [
        for (final raw in json['people'] as List? ?? const [])
          if (raw is Map)
            QuickSplitPerson.fromJson(raw.cast<String, dynamic>()),
      ],
      items: [
        for (final raw in json['items'] as List? ?? const [])
          if (raw is Map)
            QuickSplitItem(
              name: _string(raw['name']),
              amount: _double(raw['amount']),
              personIds: [
                for (final id in raw['person_ids'] as List? ?? const [])
                  if (id is num) id.toInt(),
              ],
            ),
      ],
      extraAmount: _double(json['extra_amount']),
      receiptPath: _nullableString(json['receipt_path']),
      receiptUrl: _nullableString(json['receipt_url']),
      receiptThumbUrl: _nullableString(json['receipt_thumb_url']),
      addedToTripId: added is Map ? _int(added['trip_id']) : null,
    );
  }
}

class QuickSplitPreviewPerson {
  const QuickSplitPreviewPerson({required this.name, this.avatarThumbUrl});

  final String name;
  final String? avatarThumbUrl;
}

class QuickSplitPerson {
  const QuickSplitPerson({
    required this.id,
    required this.name,
    required this.amount,
    this.userId,
    this.avatarThumbUrl,
    this.isMe = false,
    this.isPayer = false,
    this.splitValue,
  });

  /// The stored person id, used by [QuickSplitItem.personIds].
  final int id;

  /// Set for a Splyto account, null for someone added by name.
  final int? userId;
  final String name;
  final String? avatarThumbUrl;
  final bool isMe;
  final bool isPayer;
  final double amount;

  /// Same meaning as an expense participant's split value; null for equal.
  final double? splitValue;

  bool get isAccount => userId != null;

  factory QuickSplitPerson.fromJson(Map<String, dynamic> json) =>
      QuickSplitPerson(
        id: _int(json['id']),
        userId: json['user_id'] is num
            ? (json['user_id'] as num).toInt()
            : null,
        name: _string(json['name']),
        avatarThumbUrl: _nullableString(json['avatar_thumb_url']),
        isMe: json['is_me'] == true,
        isPayer: json['is_payer'] == true,
        amount: _double(json['amount']),
        splitValue: (json['split_value'] as num?)?.toDouble(),
      );
}

class QuickSplitItem {
  const QuickSplitItem({
    required this.name,
    required this.amount,
    required this.personIds,
  });

  final String name;
  final double amount;
  final List<int> personIds;
}

/// A person in a saved request. [key] links the payer, splits and items.
class QuickSplitPersonInput {
  const QuickSplitPersonInput({required this.key, this.userId, this.name});

  final String key;
  final int? userId;
  final String? name;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'key': key,
    if (userId != null) 'user_id': userId else 'name': name ?? '',
  };
}

class QuickSplitItemInput {
  const QuickSplitItemInput({
    required this.name,
    required this.amount,
    required this.peopleKeys,
  });

  final String name;
  final double amount;
  final List<String> peopleKeys;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'amount': amount,
    'people': peopleKeys,
  };
}

/// Everything `add_quick_split` and `update_quick_split` take.
class QuickSplitInput {
  const QuickSplitInput({
    required this.amount,
    required this.currencyCode,
    required this.note,
    required this.category,
    required this.date,
    required this.people,
    required this.paidByKey,
    required this.splitMode,
    this.subcategory,
    this.participantKeys = const [],
    this.splitValues = const {},
    this.items = const [],
    this.extraAmount = 0,
    this.receiptPath,
    this.clientMutationId,
  });

  final double amount;
  final String currencyCode;
  final String note;
  final String category;
  final String? subcategory;
  final String date;
  final List<QuickSplitPersonInput> people;
  final String paidByKey;
  final String splitMode;
  final List<String> participantKeys;

  /// Person key to value, for every mode except `equal` and `itemized`.
  final Map<String, double> splitValues;
  final List<QuickSplitItemInput> items;
  final double extraAmount;
  final String? receiptPath;
  final String? clientMutationId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'amount': amount,
    'currency_code': currencyCode,
    'note': note,
    'category': category,
    'subcategory': subcategory,
    'date': date,
    'people': [for (final person in people) person.toJson()],
    'paid_by': paidByKey,
    'split_mode': splitMode,
    if (splitMode != 'itemized' && participantKeys.isNotEmpty)
      'participants': participantKeys,
    if (splitValues.isNotEmpty)
      'splits': [
        for (final entry in splitValues.entries)
          {'person': entry.key, 'value': entry.value},
      ],
    if (splitMode == 'itemized') ...{
      'items': [for (final item in items) item.toJson()],
      if (extraAmount > 0) 'extra_amount': extraAmount,
    },
    if (receiptPath != null && receiptPath!.trim().isNotEmpty)
      'receipt_path': receiptPath,
    'client_mutation_id': ?clientMutationId,
  };
}

class QuickSplitPage {
  const QuickSplitPage({required this.items, this.nextCursor});

  final List<QuickSplit> items;
  final String? nextCursor;
}

int _int(Object? raw) => raw is num ? raw.toInt() : int.tryParse('$raw') ?? 0;

double _double(Object? raw) =>
    raw is num ? raw.toDouble() : double.tryParse('$raw') ?? 0;

String _string(Object? raw, {String fallback = ''}) {
  final value = raw is String ? raw.trim() : '';
  return value.isEmpty ? fallback : value;
}

String? _nullableString(Object? raw) {
  final value = raw is String ? raw.trim() : '';
  return value.isEmpty ? null : value;
}

/// One line of the item list as people read it: the same item at the same
/// price, each for one person, shows once as "Beer ×2"; an item several
/// people had together stays its own line. Same rules as a trip expense.
class QuickSplitItemLine {
  QuickSplitItemLine(this.name, this.unitCents);

  final String name;
  final int unitCents;
  int qty = 0;

  /// Person ids, once per unit (a person with two beers is listed twice).
  final List<int> personIds = [];
  bool shared = false;

  int get totalCents => unitCents * qty;

  static List<QuickSplitItemLine> group(List<QuickSplitItem> items) {
    final lines = <QuickSplitItemLine>[];
    final byKey = <String, QuickSplitItemLine>{};
    for (final item in items) {
      final cents = (item.amount * 100).round();
      if (item.personIds.length != 1) {
        lines.add(
          QuickSplitItemLine(item.name.trim(), cents)
            ..qty = 1
            ..shared = true
            ..personIds.addAll(item.personIds),
        );
        continue;
      }
      final key = '${item.name.trim().toLowerCase()}|$cents';
      final line = byKey.putIfAbsent(key, () {
        final created = QuickSplitItemLine(item.name.trim(), cents);
        lines.add(created);
        return created;
      });
      line.qty++;
      line.personIds.add(item.personIds.single);
    }
    return lines;
  }
}
