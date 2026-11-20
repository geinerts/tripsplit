/// One line read from a receipt by `scan_receipt` (docs/api/receipt-scan.md).
class ReceiptScanItem {
  const ReceiptScanItem({
    required this.name,
    required this.totalCents,
    this.quantity,
    this.unitPriceCents,
    this.uncertain = false,
  });

  final String name;
  final int totalCents;
  final double? quantity;
  final int? unitPriceCents;

  /// The AI could not read this line with confidence; the user should check it.
  final bool uncertain;

  static ReceiptScanItem? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final name = (raw['name'] as String?)?.trim() ?? '';
    final total = raw['total_cents'];
    if (name.isEmpty || total is! num) return null;
    return ReceiptScanItem(
      name: name,
      totalCents: total.toInt(),
      quantity: (raw['quantity'] as num?)?.toDouble(),
      unitPriceCents: (raw['unit_price_cents'] as num?)?.toInt(),
      uncertain: raw['uncertain'] == true,
    );
  }
}

/// A receipt read with AI. Amounts are cents in [currencyCode]; the server
/// already checked them. Nothing is saved until the user saves the expense.
class ReceiptScan {
  const ReceiptScan({
    required this.isReceipt,
    required this.items,
    required this.totalCents,
    this.merchant,
    this.date,
    this.currencyCode,
    this.discountCents = 0,
    this.taxCents = 0,
    this.tipCents = 0,
    this.serviceCents = 0,
    this.sumMatches = false,
    this.differenceCents = 0,
  });

  final bool isReceipt;
  final String? merchant;

  /// ISO date (yyyy-MM-dd) or null when unreadable.
  final String? date;
  final String? currencyCode;
  final List<ReceiptScanItem> items;
  final int discountCents;
  final int taxCents;
  final int tipCents;
  final int serviceCents;
  final int totalCents;
  final bool sumMatches;
  final int differenceCents;

  /// Lines with a positive amount; discount lines move into [extraCents].
  List<ReceiptScanItem> get chargeItems =>
      items.where((item) => item.totalCents > 0).toList(growable: false);

  /// Everything that is not a charged line: tax, tip and service, minus
  /// discounts (separate or printed as negative lines).
  int get extraCents =>
      taxCents +
      tipCents +
      serviceCents -
      discountCents +
      items
          .where((item) => item.totalCents < 0)
          .fold<int>(0, (sum, item) => sum + item.totalCents);

  bool get hasUncertainItems => items.any((item) => item.uncertain);

  /// Lines and extra for the "By item" editor, which takes only positive
  /// amounts: discounts (separate or as negative lines) are spread over the
  /// lines in proportion to their price, cent-exact; tax, tip and service
  /// become the extra. Null when the discount is not smaller than the lines.
  ReceiptSplitDraft? splitDraft() {
    final lines = chargeItems;
    final linesCents = lines.fold<int>(0, (sum, item) => sum + item.totalCents);
    if (lines.isEmpty || linesCents <= 0) return null;
    final discount =
        discountCents +
        items
            .where((item) => item.totalCents < 0)
            .fold<int>(0, (sum, item) => sum - item.totalCents);
    if (discount >= linesCents) return null;
    final cuts = List<int>.generate(
      lines.length,
      (i) => discount * lines[i].totalCents ~/ linesCents,
    );
    // Largest lines take the cents left over by rounding down.
    var left = discount - cuts.fold<int>(0, (sum, cut) => sum + cut);
    final order = List<int>.generate(lines.length, (i) => i)
      ..sort((a, b) => lines[b].totalCents.compareTo(lines[a].totalCents));
    for (final i in order) {
      if (left == 0) break;
      if (lines[i].totalCents - cuts[i] > 1) {
        cuts[i] += 1;
        left -= 1;
      }
    }
    if (left != 0) return null;
    ({int qty, int unitCents}) units(ReceiptScanItem line, int cut) {
      final qty = line.quantity;
      final unit = line.unitPriceCents;
      // "3 × 1.20" stays three units when nothing was taken off it.
      if (cut == 0 &&
          qty != null &&
          unit != null &&
          qty >= 2 &&
          qty <= 100 &&
          qty == qty.roundToDouble() &&
          unit * qty.round() == line.totalCents) {
        return (qty: qty.round(), unitCents: unit);
      }
      return (qty: 1, unitCents: line.totalCents - cut);
    }

    return ReceiptSplitDraft(
      lines: [
        for (var i = 0; i < lines.length; i++)
          (
            name: lines[i].name,
            cents: lines[i].totalCents - cuts[i],
            qty: units(lines[i], cuts[i]).qty,
            unitCents: units(lines[i], cuts[i]).unitCents,
            uncertain: lines[i].uncertain,
          ),
      ],
      extraCents: taxCents + tipCents + serviceCents,
    );
  }

  static ReceiptScan fromJson(Map<String, dynamic> json) {
    int cents(String key) => (json[key] as num?)?.toInt() ?? 0;
    String? text(String key) {
      final value = (json[key] as String?)?.trim();
      return value == null || value.isEmpty ? null : value;
    }

    return ReceiptScan(
      isReceipt: json['is_receipt'] == true,
      merchant: text('merchant'),
      date: text('date'),
      currencyCode: text('currency'),
      items: (json['items'] as List? ?? const [])
          .map(ReceiptScanItem.fromJson)
          .whereType<ReceiptScanItem>()
          .toList(growable: false),
      discountCents: cents('discount_cents'),
      taxCents: cents('tax_cents'),
      tipCents: cents('tip_cents'),
      serviceCents: cents('service_cents'),
      totalCents: cents('total_cents'),
      sumMatches: json['sum_matches'] == true,
      differenceCents: cents('difference_cents'),
    );
  }
}

/// What the expense form fills from a [ReceiptScan].
class ReceiptSplitDraft {
  const ReceiptSplitDraft({required this.lines, required this.extraCents});

  /// [cents] is the line total; [qty] × [unitCents] equals it.
  final List<({String name, int cents, int qty, int unitCents, bool uncertain})>
  lines;
  final int extraCents;

  int get totalCents =>
      lines.fold<int>(extraCents, (sum, line) => sum + line.cents);
}
