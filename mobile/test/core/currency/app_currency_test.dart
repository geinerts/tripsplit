import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/currency/app_currency.dart';
import 'package:tripsplit/core/ui/app_formatters.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

void main() {
  test('120 distinct currencies, all usable in the profile too', () {
    final codes = AppCurrencyCatalog.supported.map((item) => item.code).toSet();
    expect(codes.length, 120);
    expect(AppCurrencyCatalog.profilePreferredSupported.length, 120);
    expect(AppCurrencyCatalog.normalizeProfilePreferred('VND'), 'VND');
    expect(AppCurrencyCatalog.normalize('BTC'), 'EUR');
  });

  test('the server offers exactly the same currencies and decimals', () {
    final php = File(
      '../api/lib/helpers/helper_currency_catalog.php',
    ).readAsStringSync();
    List<String> list(String name) {
      final block = RegExp(
        'const $name = \\[(.*?)\\];',
        dotAll: true,
      ).firstMatch(php)!.group(1)!;
      return RegExp(
        r"'([A-Z]{3})'",
      ).allMatches(block).map((match) => match.group(1)!).toList();
    }

    expect(
      list('TRIP_SUPPORTED_CURRENCY_CODES'),
      AppCurrencyCatalog.supported.map((item) => item.code).toList(),
    );
    expect(
      list('CURRENCY_CODES_WITHOUT_DECIMALS').toSet(),
      AppCurrencyCatalog.supported
          .where((item) => item.decimalDigits == 0)
          .map((item) => item.code)
          .toSet(),
    );
  });

  test('every catalog has a name for every currency', () {
    final directory = Directory('lib/l10n');
    final catalogs = directory.listSync().whereType<File>().where(
      (file) => file.path.endsWith('.arb'),
    );
    expect(catalogs.length, 15);
    for (final catalog in catalogs) {
      final data = jsonDecode(catalog.readAsStringSync()) as Map;
      for (final item in AppCurrencyCatalog.supported) {
        final key =
            'currencyName${item.code[0]}${item.code.substring(1).toLowerCase()}';
        expect(
          (data[key] as String?)?.trim(),
          isNotEmpty,
          reason: '${catalog.path} $key',
        );
      }
    }
  });

  test('decimals follow how each currency is written', () {
    int digits(String code) => AppCurrencyCatalog.decimalDigitsForCode(code);
    for (final code in [
      'JPY',
      'KRW',
      'VND',
      'IDR',
      'HUF',
      'ISK',
      'CLP',
      'XOF',
    ]) {
      expect(digits(code), 0, reason: code);
    }
    for (final code in ['EUR', 'USD', 'GBP', 'THB']) {
      expect(digits(code), 2, reason: code);
    }
    // Stored in hundredths, so three-decimal currencies show two.
    expect(digits('KWD'), 2);
    expect(digits('OMR'), 2);
  });

  test('amount fields keep exact shares', () {
    expect(AppCurrencyCatalog.amountInputText(1500, 'JPY'), '1500');
    expect(AppCurrencyCatalog.amountInputText(33.33, 'JPY'), '33.33');
    expect(AppCurrencyCatalog.amountInputText(12.5, 'EUR'), '12.50');
    expect(AppCurrencyCatalog.amountInputText(12, 'EUR'), '12.00');
    expect(AppCurrencyCatalog.amountInputText(50000000, 'VND'), '50000000');
  });

  testWidgets('money shows the right decimals, and large amounts stay exact', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    String code(int cents, String currency) =>
        AppFormatters.currencyCodeFromCents(
          context,
          cents,
          currencyCode: currency,
        );
    expect(code(150000, 'JPY'), contains('1,500'));
    expect(code(150000, 'JPY'), isNot(contains('.')));
    expect(code(150050, 'EUR'), contains('1,500.50'));
    expect(code(500000000000, 'VND'), contains('5,000,000,000'));
    expect(
      AppFormatters.currencyFromCents(context, 150000, currencyCode: 'THB'),
      contains('฿'),
    );
    final t = AppLocalizations.of(context)!;
    expect(AppCurrencyCatalog.labelForCode('THB', t), 'Thai Baht');
  });
}
