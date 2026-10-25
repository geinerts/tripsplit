import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/ui/app_settings_widgets.dart';
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
      return AppSettingsSheet(
        title: t.profileLanguage,
        children: [
          AppSettingsRow(
            icon: Icons.translate_outlined,
            title: t.languageEnglish,
            subtitle: _nativeLanguageName(AppLocaleMode.english),
            selected: current == AppLocaleMode.english,
            chevron: false,
            onTap: () async {
              await controller.setMode(AppLocaleMode.english);
              if (sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
              }
            },
          ),
          AppSettingsRow(
            icon: Icons.translate,
            title: t.languageLatvian,
            subtitle: _nativeLanguageName(AppLocaleMode.latvian),
            selected: current == AppLocaleMode.latvian,
            chevron: false,
            onTap: () async {
              await controller.setMode(AppLocaleMode.latvian);
              if (sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
              }
            },
          ),
          AppSettingsRow(
            icon: Icons.translate_rounded,
            title: t.languageSpanish,
            subtitle: _nativeLanguageName(AppLocaleMode.spanish),
            selected: current == AppLocaleMode.spanish,
            chevron: false,
            onTap: () async {
              await controller.setMode(AppLocaleMode.spanish);
              if (sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
              }
            },
          ),
        ],
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
