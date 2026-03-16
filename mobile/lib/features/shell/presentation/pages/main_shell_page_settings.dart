part of 'main_shell_page.dart';

extension _MainShellPageSettings on _MainShellPageState {
  Future<void> _openSettingsSheet() async {
    if (_isLoggingOut) {
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
                leading: const Icon(Icons.bug_report_outlined),
                title: const Text('Report issue'),
                onTap: () => Navigator.of(sheetContext).pop('report_issue'),
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
      case 'report_issue':
        await _openReportIssueDialog();
        return;
      case 'logout':
        await _onLogoutPressed();
        return;
      default:
        return;
    }
  }

  Future<void> _onLogoutPressed() async {
    if (_isLoggingOut) {
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
      _isLoggingOut = true;
    });
    try {
      await widget.authController.logout();
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
    } finally {
      if (mounted) {
        _updateState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  Future<void> _openReportIssueDialog() async {
    final noteController = TextEditingController();
    final t = context.l10n;
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Report issue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Describe what happened (optional).'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                minLines: 3,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(hintText: 'What happened?'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t.cancelAction),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(noteController.text),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
    noteController.dispose();
    if (!mounted || note == null) {
      return;
    }

    final noteText = note.trim();
    await AppMonitoring.captureHandledException(
      StateError('User reported issue from app settings'),
      origin: 'user_report',
      extras: <String, Object?>{
        'note': noteText,
        'selected_tab_index': _selectedTabIndex,
        'opened_trip_id': _openedTrip?.id,
      },
    );
    if (!mounted) {
      return;
    }
    _showSnack('Thanks, issue report sent.', isError: false);
  }
}
