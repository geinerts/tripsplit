import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/ui/app_settings_widgets.dart';
import '../../core/ui/app_sheet.dart';
import 'theme_mode_scope.dart';

Future<void> showThemeModePicker(BuildContext context) async {
  final controller = ThemeModeScope.maybeOf(context);
  if (controller == null) {
    return;
  }

  final current = controller.themeMode;
  final t = context.l10n;

  await showAppBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return AppSettingsSheet(
        title: t.profileAppearance,
        children: [
          AppSettingsRow(
            icon: Icons.light_mode_outlined,
            title: t.themeModeLight,
            selected: current == ThemeMode.light,
            chevron: false,
            onTap: () async {
              await controller.setThemeMode(ThemeMode.light);
              if (sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
              }
            },
          ),
          AppSettingsRow(
            icon: Icons.dark_mode_outlined,
            title: t.themeModeDark,

            selected: current == ThemeMode.dark,
            chevron: false,
            onTap: () async {
              await controller.setThemeMode(ThemeMode.dark);
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
