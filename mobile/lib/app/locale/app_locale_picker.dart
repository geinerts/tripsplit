import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/ui/app_components.dart';
import '../../core/ui/app_sheet.dart';
import 'app_locale_controller.dart';
import 'app_locale_scope.dart';

Future<void> showAppLocalePicker(BuildContext context) async {
  final controller = AppLocaleScope.maybeOf(context);
  if (controller == null) {
    return;
  }

  final current = controller.mode;
  final t = context.l10n;

  await showAppBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppActionSheetTile(
              icon: Icons.translate_outlined,
              title: t.languageEnglish,
              subtitle: _nativeLanguageName(AppLocaleMode.english),
              trailing: current == AppLocaleMode.english
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () async {
                await controller.setMode(AppLocaleMode.english);
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              },
            ),
            AppActionSheetTile(
              icon: Icons.translate,
              title: t.languageLatvian,
              subtitle: _nativeLanguageName(AppLocaleMode.latvian),
              trailing: current == AppLocaleMode.latvian
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () async {
                await controller.setMode(AppLocaleMode.latvian);
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              },
            ),
            AppActionSheetTile(
              icon: Icons.translate_rounded,
              title: t.languageSpanish,
              subtitle: _nativeLanguageName(AppLocaleMode.spanish),
              trailing: current == AppLocaleMode.spanish
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () async {
                await controller.setMode(AppLocaleMode.spanish);
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

String _nativeLanguageName(AppLocaleMode mode) {
  switch (mode) {
    case AppLocaleMode.english:
      return 'English';
    case AppLocaleMode.latvian:
      return 'Latviešu';
    case AppLocaleMode.spanish:
      return 'Español';
  }
}
