import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../currency/app_currency.dart';
import '../l10n/l10n.dart';
import 'app_sheet.dart';
import 'app_settings_widgets.dart';

Future<String?> showAppCurrencyPicker({
  required BuildContext context,
  required String selectedCode,
  required String title,
  Key? searchKey,
}) async {
  var query = '';
  return showAppBottomSheet<String>(
    context: context,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: SizedBox(
        height: math.min(
          MediaQuery.sizeOf(sheetContext).height * .7,
          MediaQuery.sizeOf(sheetContext).height -
              MediaQuery.viewInsetsOf(sheetContext).bottom -
              MediaQuery.paddingOf(sheetContext).vertical -
              32,
        ),
        child: StatefulBuilder(
          builder: (context, update) {
            final t = context.l10n;
            final items = AppCurrencyCatalog.supported
                .where(
                  (item) =>
                      '${item.code} ${item.symbol} ${AppCurrencyCatalog.labelForCode(item.code, t)}'
                          .toLowerCase()
                          .contains(query.trim().toLowerCase()),
                )
                .toList();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: TextField(
                    key: searchKey,
                    onChanged: (value) => update(() => query = value),
                    decoration: InputDecoration(
                      hintText: t.profileEditSearchCurrency,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(child: Text(t.profileEditNoCurrenciesFound))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return AppSettingsRow(
                              title:
                                  '${item.code} · ${AppCurrencyCatalog.labelForCode(item.code, t)}',
                              selected: item.code == selectedCode,
                              chevron: false,
                              trailing: item.code == selectedCode
                                  ? const Icon(Icons.check)
                                  : null,
                              onTap: () => Navigator.pop(context, item.code),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
