part of 'profile_page.dart';

const _contactEmail = 'support@splyto.eu';

extension _ProfilePageSettings on _ProfilePageState {
  Future<void> _onLogoutPressed() async {
    if (_isSubmitting || _isLoading) {
      return;
    }

    final t = context.l10n;
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: t.logOutButton,
      message: t.logoutFromDeviceQuestion,
      confirmLabel: t.logOutButton,
      cancelLabel: t.cancelAction,
      icon: Icons.logout_rounded,
      destructive: true,
    );

    if (!mounted || !confirmed) {
      return;
    }

    _updateState(() {
      _isSubmitting = true;
    });
    try {
      final revocationConfirmed = await widget.controller.logout();
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.authIntro, (route) => false);
      if (!revocationConfirmed) {
        _showSnack(t.logoutRevocationUnconfirmed);
      }
    } on ApiException catch (error) {
      if (mounted) {
        _showSnack(error.message);
      }
    } finally {
      if (mounted) {
        _updateState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _openChangePasswordDialog() async {
    _openChangePasswordPage();
  }

  Future<void> _openContactDialog() async {
    if (_isBusy) return;
    await showAppBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final t = sheetContext.l10n;
        String? statusMessage;
        return StatefulBuilder(
          builder: (stateContext, setSheetState) {
            void showStatus(String message) {
              if (stateContext.mounted) {
                setSheetState(() => statusMessage = message);
              }
            }

            return AppActionSheet(
              title: t.profileContactUs,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  child: Text(t.profileContactDescription),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: SelectableText(_contactEmail),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      var opened = false;
                      try {
                        opened = await launchUrl(
                          Uri(scheme: 'mailto', path: _contactEmail),
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (_) {
                        // Keep the address available when no email app can open.
                      }
                      if (!opened) showStatus(t.profileContactEmailUnavailable);
                    },
                    icon: const Icon(Icons.mail_outline),
                    label: Text(t.profileContactEmailAction),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    try {
                      await Clipboard.setData(
                        const ClipboardData(text: _contactEmail),
                      );
                      showStatus(t.paymentCopied);
                    } catch (_) {
                      showStatus(t.paymentCouldNotCopyToClipboard);
                    }
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: Text(t.copyAction),
                ),
                if (statusMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(statusMessage!),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
