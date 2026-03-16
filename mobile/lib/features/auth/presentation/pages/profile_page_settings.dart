part of 'profile_page.dart';

extension _ProfilePageSettings on _ProfilePageState {
  Future<void> _openSettingsSheet() async {
    if (_isSubmitting) {
      return;
    }

    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final t = sheetContext.l10n;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: Text(t.appearance),
                onTap: () => Navigator.of(sheetContext).pop('appearance'),
              ),
              ListTile(
                leading: const Icon(Icons.translate_outlined),
                title: Text(t.languageAction),
                onTap: () => Navigator.of(sheetContext).pop('language'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(t.logOutButton),
                onTap: () => Navigator.of(sheetContext).pop('logout'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || choice == null) {
      return;
    }

    switch (choice) {
      case 'appearance':
        showThemeModePicker(context);
        return;
      case 'language':
        showAppLocalePicker(context);
        return;
      case 'logout':
        await _onLogoutPressed();
        return;
      default:
        return;
    }
  }

  Future<void> _onLogoutPressed() async {
    if (_isSubmitting || _isLoading) {
      return;
    }

    final t = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.logOutButton),
          content: Text(t.logoutFromDeviceQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.cancelAction),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.logOutButton),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    _updateState(() {
      _isSubmitting = true;
    });
    try {
      await widget.controller.logout();
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
    } finally {
      if (mounted) {
        _updateState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
