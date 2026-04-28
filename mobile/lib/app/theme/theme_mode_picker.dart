import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/ui/app_components.dart';
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
            AppActionSheetTile(
              icon: Icons.light_mode_outlined,
              title: t.themeModeLight,
              trailing: current == ThemeMode.light
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () async {
                await controller.setThemeMode(ThemeMode.light);
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              },
            ),
            AppActionSheetTile(
              icon: Icons.dark_mode_outlined,
              title: t.themeModeDark,
              subtitle: t.themeModeDarkSubtitle,
              trailing: current == ThemeMode.dark
                  ? const Icon(Icons.check_rounded)
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
