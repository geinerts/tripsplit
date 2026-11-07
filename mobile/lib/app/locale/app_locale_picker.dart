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
            title: t.languageSystem,
            subtitle: t.languageSystemSubtitle,
            selected: current == AppLocaleMode.system,
            chevron: false,
            onTap: () async {
              await controller.setMode(AppLocaleMode.system);
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            },
          ),
          for (final mode in AppLocaleMode.values.where(
            (mode) => mode != AppLocaleMode.system,
          ))
            AppSettingsRow(
              key: ValueKey('language-${mode.languageCode}'),
              title: mode.nativeName,
              selected: current == mode,
              chevron: false,
              onTap: () async {
                await controller.setMode(mode);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
        ],
      );
    },
  );
}
