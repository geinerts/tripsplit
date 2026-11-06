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

  void _openNotificationSettings() {
    if (_isBusy) {
      return;
    }
    unawaited(
      Navigator.of(context).push<void>(
        AppPageRoute<void>(
          builder: (_) =>
              _ProfileNotificationSettingsPage(controller: widget.controller),
        ),
      ),
    );
  }

  void _openAccountAndSecurity() {
    if (_isBusy) {
      return;
    }
    unawaited(
      Navigator.of(context).push<void>(
        AppPageRoute<void>(
          builder: (_) => _ProfileAccountSecurityPage(
            passwordTitle: _passwordActionTitle,
            onPasswordTap: _openChangePasswordPage,
            onLogoutTap: () => unawaited(_onLogoutPressed()),
            onDeleteAccountTap: _openDangerZone,
          ),
        ),
      ),
    );
  }

  void _openHelp() {
    if (_isBusy) {
      return;
    }
    unawaited(
      Navigator.of(context).push<void>(
        AppPageRoute<void>(
          builder: (_) => _ProfileHelpPage(
            onQuickStartTap: widget.onQuickStartRequested ?? _openQuickStart,
            onContactTap: _openContactDialog,
            onRateTap: _openRateHint,
            appVersion: _appVersionLabel,
          ),
        ),
      ),
    );
  }

  void _openRateHint() {
    _showSnack(context.l10n.profileStoreRatingActionWillConnectedNextStep);
  }

  void _openDangerZone() {
    if (_isBusy) {
      return;
    }
    unawaited(
      Navigator.of(context).push<void>(
        AppFormPageRoute(
          builder: (_) => AccountDeletionPage(
            email: _user?.email ?? '',
            onRequest: (password, reasons) =>
                widget.controller.requestAccountDeletionLink(
                  password: password,
                  reasonCodes: reasons,
                ),
          ),
        ),
      ),
    );
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

/// Centers a profile sub-page and gives it the shared page gutters.
class _ProfileSubpageBody extends StatelessWidget {
  const _ProfileSubpageBody({required this.builder});

  final Widget Function(EdgeInsets padding) builder;

  @override
  Widget build(BuildContext context) {
    final gutter = context.responsive.pageHorizontalPadding;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.responsive.pageMaxWidth,
          ),
          child: builder(EdgeInsets.fromLTRB(gutter, 12, gutter, 20)),
        ),
      ),
    );
  }
}

class _ProfileAccountSecurityPage extends StatelessWidget {
  const _ProfileAccountSecurityPage({
    required this.passwordTitle,
    required this.onPasswordTap,
    required this.onLogoutTap,
    required this.onDeleteAccountTap,
  });

  final String passwordTitle;
  final VoidCallback onPasswordTap;
  final VoidCallback onLogoutTap;
  final VoidCallback onDeleteAccountTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppPageScaffold(
      appBar: AppBar(title: Text(t.profileAccountAndSecurity)),
      body: _ProfileSubpageBody(
        builder: (padding) => LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            padding: padding,
            child: ConstrainedBox(
              // The destructive action stays at the bottom of the screen and
              // simply scrolls with the page when large text needs more room.
              constraints: BoxConstraints(
                minHeight: viewport.maxHeight - padding.vertical,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      AppSettingsRow(
                        title: passwordTitle,
                        icon: Icons.lock_outline_rounded,
                        onTap: onPasswordTap,
                      ),
                      Divider(height: 1, color: AppDesign.cardStroke(context)),
                      AppSettingsRow(
                        title: t.logOutButton,
                        icon: Icons.logout_rounded,
                        chevron: false,
                        onTap: onLogoutTap,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Column(
                      children: [
                        const Divider(height: 1),
                        AppSettingsRow(
                          title: t.accountDeleteTitle,
                          icon: Icons.person_remove_outlined,
                          destructive: true,
                          onTap: onDeleteAccountTap,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHelpPage extends StatelessWidget {
  const _ProfileHelpPage({
    required this.onQuickStartTap,
    required this.onContactTap,
    required this.onRateTap,
    required this.appVersion,
  });

  final VoidCallback onQuickStartTap;
  final VoidCallback onContactTap;
  final VoidCallback onRateTap;
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppPageScaffold(
      appBar: AppBar(title: Text(t.profileHelpTitle)),
      body: _ProfileSubpageBody(
        builder: (padding) => ListView(
          padding: padding,
          children: [
            AppSettingsRow(
              title: t.quickStartTitle,
              icon: Icons.help_outline,
              onTap: onQuickStartTap,
            ),
            Divider(height: 1, color: AppDesign.cardStroke(context)),
            AppSettingsRow(
              title: t.profileContactUs,
              icon: Icons.support_agent_outlined,
              onTap: onContactTap,
            ),
            Divider(height: 1, color: AppDesign.cardStroke(context)),
            AppSettingsRow(
              title: t.profileRateSplyto,
              icon: Icons.star_outline_rounded,
              onTap: onRateTap,
            ),
            const SizedBox(height: 28),
            Center(
              child: Text(
                'v$appVersion',
                key: const ValueKey('profile-app-version'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppDesign.mutedColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
