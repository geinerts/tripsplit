import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/auth/data/models/auth_user_model.dart';
import 'package:tripsplit/features/workspace/domain/entities/receipt_scan.dart';

/// docs/api/receipt-scan.md: how a scan becomes "By item" lines.
void main() {
  Map<String, dynamic> item(String name, int cents, {bool uncertain = false}) =>
      {'name': name, 'total_cents': cents, 'uncertain': uncertain};

  ReceiptScan scan(
    List<Map<String, dynamic>> items, {
    int discount = 0,
    int tax = 0,
    int tip = 0,
    int service = 0,
  }) => ReceiptScan.fromJson({
    'is_receipt': true,
    'merchant': ' Rimi ',
    'date': '2026-11-19',
    'currency': 'EUR',
    'items': items,
    'discount_cents': discount,
    'tax_cents': tax,
    'tip_cents': tip,
    'service_cents': service,
    'total_cents': 0,
    'sum_matches': true,
  });

  test('parses the server answer and drops broken lines', () {
    final s = ReceiptScan.fromJson({
      'is_receipt': true,
      'merchant': '  ',
      'date': null,
      'currency': 'EUR',
      'items': [
        item('Milk', 129, uncertain: true),
        {'name': '', 'total_cents': 50},
        {'name': 'No price'},
        'junk',
      ],
      'total_cents': 129,
      'sum_matches': true,
    });
    expect(s.isReceipt, isTrue);
    expect(s.merchant, isNull);
    expect(s.date, isNull);
    expect(s.items.map((i) => i.name), ['Milk']);
    expect(s.hasUncertainItems, isTrue);
    expect(s.sumMatches, isTrue);
  });

  test(
    'reads optional category and accepts old or malformed responses safely',
    () {
      final base = {
        'is_receipt': true,
        'items': [item('Milk', 129)],
        'total_cents': 129,
      };
      expect(
        ReceiptScan.fromJson({...base, 'category': 'groceries'}).category,
        'groceries',
      );
      expect(ReceiptScan.fromJson(base).category, isNull);
      expect(
        ReceiptScan.fromJson({...base, 'category': null}).category,
        isNull,
      );
      expect(ReceiptScan.fromJson({...base, 'category': 123}).category, isNull);
      expect(
        ReceiptScan.fromJson({
          ...base,
          'category': ['groceries'],
        }).category,
        isNull,
      );
    },
  );

  test('reads optional subcategory and ignores absent or malformed values', () {
    final base = {
      'is_receipt': true,
      'items': [item('Lunch', 129)],
      'total_cents': 129,
      'category': 'food',
    };
    expect(
      ReceiptScan.fromJson({...base, 'subcategory': 'restaurant'}).subcategory,
      'restaurant',
    );
    for (final value in [
      null,
      123,
      ['restaurant'],
    ]) {
      expect(
        ReceiptScan.fromJson({...base, 'subcategory': value}).subcategory,
        isNull,
      );
    }
    expect(ReceiptScan.fromJson(base).subcategory, isNull);
  });

  test('without discounts the lines stay and tax, tip, service are extra', () {
    final draft = scan(
      [item('Pizza', 1200), item('Cola', 300)],
      tax: 100,
      tip: 150,
      service: 50,
    ).splitDraft()!;
    expect(draft.lines.map((l) => l.cents), [1200, 300]);
    expect(draft.extraCents, 300);
    expect(draft.totalCents, 1800);
  });

  test('discounts are spread over the lines by price, cent-exact', () {
    final draft = scan([
      item('A', 1000),
      item('B', 500),
      item('C', 1),
      item('Promo', -100),
    ], discount: 50).splitDraft()!;
    expect(draft.lines.map((l) => l.name), ['A', 'B', 'C']);
    final cents = draft.lines.map((l) => l.cents).toList();
    expect(cents.reduce((a, b) => a + b), 1501 - 150);
    expect(cents.every((c) => c > 0), isTrue);
    expect(cents[0], lessThan(1000));
    expect(cents[1], lessThan(500));
    expect(draft.extraCents, 0);
  });

  test('quantities stay as units unless a discount was taken off', () {
    Map<String, dynamic> units(String name, int qty, int unit) => {
      'name': name,
      'quantity': qty,
      'unit_price_cents': unit,
      'total_cents': qty * unit,
    };
    final plain = scan([units('Beer', 3, 450)]).splitDraft()!.lines.single;
    expect((plain.qty, plain.unitCents, plain.cents), (3, 450, 1350));
    final cut = scan([
      units('Beer', 3, 450),
    ], discount: 100).splitDraft()!.lines.single;
    expect((cut.qty, cut.unitCents, cut.cents), (1, 1250, 1250));
  });

  for (final discount in [0, 1]) {
    test(
      'keeps separate deposits in receipt order with discount $discount',
      () {
        final draft = scan([
          {
            ...item('Non-alcoholic beer', 894),
            'quantity': 6,
            'unit_price_cents': 149,
          },
          {...item('Depozīts', 60), 'quantity': 6, 'unit_price_cents': 10},
          item('Bread', 135),
          item('Water', 49),
          {...item('Depozīts', 10), 'quantity': 1, 'unit_price_cents': 10},
        ], discount: discount).splitDraft()!;
        expect(draft.lines.map((line) => line.name), [
          'Non-alcoholic beer',
          'Depozīts',
          'Bread',
          'Water',
          'Depozīts',
        ]);
        expect(draft.lines[1].qty, 6);
        expect(draft.lines[1].unitCents, 10);
        expect(draft.lines[1].cents, 60);
        expect(draft.lines[4].cents, 10);
        expect(draft.extraCents, 0);
        expect(draft.totalCents, 1148 - discount);
      },
    );
  }

  test('nothing to fill when there are no lines or the discount eats them', () {
    expect(scan(const []).splitDraft(), isNull);
    expect(scan([item('A', 100)], discount: 100).splitDraft(), isNull);
    expect(scan([item('A', 100), item('Promo', -150)]).splitDraft(), isNull);
  });

  test('receipt_ai comes from the account features', () {
    Map<String, dynamic> user(Object? features) => {
      'id': 7,
      'nickname': 'Ann',
      'features': features,
    };
    expect(
      AuthUserModel.fromLegacyMap(user({'receipt_ai': true})).receiptAi,
      isTrue,
    );
    expect(
      AuthUserModel.fromLegacyMap(user({'receipt_ai': 'yes'})).receiptAi,
      isFalse,
    );
    expect(AuthUserModel.fromLegacyMap(user(null)).receiptAi, isFalse);
  });
}
