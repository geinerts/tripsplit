import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import 'app_locale_controller.dart';
import 'app_locale_scope.dart';

Future<void> showAppLocalePicker(BuildContext context) async {
  final controller = AppLocaleScope.maybeOf(context);
  if (controller == null) {
    return;
  }

  final current = controller.mode;
  final t = context.l10n;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(t.languageSystem),
                subtitle: Text(t.languageSystemSubtitle),
                trailing: current == AppLocaleMode.system
                    ? const Icon(Icons.check)
                    : null,
                onTap: () async {
                  await controller.setMode(AppLocaleMode.system);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate_outlined),
                title: Text(t.languageEnglish),
                trailing: current == AppLocaleMode.english
                    ? const Icon(Icons.check)
                    : null,
                onTap: () async {
                  await controller.setMode(AppLocaleMode.english);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text(t.languageLatvian),
                trailing: current == AppLocaleMode.latvian
                    ? const Icon(Icons.check)
                    : null,
                onTap: () async {
                  await controller.setMode(AppLocaleMode.latvian);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
