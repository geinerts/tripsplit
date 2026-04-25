import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
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
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode_outlined),
              title: Text(t.themeModeLight),
              trailing: current == ThemeMode.light
                  ? const Icon(Icons.check)
                  : null,
              onTap: () async {
                await controller.setThemeMode(ThemeMode.light);
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: Text(t.themeModeDark),
              subtitle: Text(t.themeModeDarkSubtitle),
              trailing: current == ThemeMode.dark
                  ? const Icon(Icons.check)
                  : null,
              onTap: () async {
                await controller.setThemeMode(ThemeMode.dark);
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
