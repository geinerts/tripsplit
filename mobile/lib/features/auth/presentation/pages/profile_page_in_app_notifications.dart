part of 'profile_page.dart';

class _InAppNotificationSettingsPage extends StatefulWidget {
  const _InAppNotificationSettingsPage({required this.controller});

  final AuthController controller;

  @override
  State<_InAppNotificationSettingsPage> createState() =>
      _InAppNotificationSettingsPageState();
}

class _InAppNotificationSettingsPageState
    extends State<_InAppNotificationSettingsPage> {
  bool _isSaving = false;
  late NotificationPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = widget.controller.notificationPreferences;
  }

  Future<void> _setPreference({
    bool? inAppExpenseAddedEnabled,
    bool? inAppFriendInvitesEnabled,
    bool? inAppTripUpdatesEnabled,
    bool? inAppSettlementUpdatesEnabled,
  }) async {
    if (_isSaving) {
      return;
    }

    final previous = _prefs;
    final nextExpense =
        inAppExpenseAddedEnabled ?? _prefs.inAppExpenseAddedEnabled;
    final nextFriends =
        inAppFriendInvitesEnabled ?? _prefs.inAppFriendInvitesEnabled;
    final nextTrip = inAppTripUpdatesEnabled ?? _prefs.inAppTripUpdatesEnabled;
    final nextSettlement =
        inAppSettlementUpdatesEnabled ?? _prefs.inAppSettlementUpdatesEnabled;
    final nextAnyEnabled =
        nextExpense || nextFriends || nextTrip || nextSettlement;

    setState(() {
      _isSaving = true;
      _prefs = _prefs.copyWith(
        inAppBannerEnabled: nextAnyEnabled,
        inAppExpenseAddedEnabled: nextExpense,
        inAppFriendInvitesEnabled: nextFriends,
        inAppTripUpdatesEnabled: nextTrip,
        inAppSettlementUpdatesEnabled: nextSettlement,
      );
    });

    try {
      final updated = await widget.controller.updateNotificationPreferences(
        inAppBannerEnabled: nextAnyEnabled,
        inAppExpenseAddedEnabled: inAppExpenseAddedEnabled,
        inAppFriendInvitesEnabled: inAppFriendInvitesEnabled,
        inAppTripUpdatesEnabled: inAppTripUpdatesEnabled,
        inAppSettlementUpdatesEnabled: inAppSettlementUpdatesEnabled,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _prefs = updated;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _prefs = previous;
      });
      _showSnack(
        error.message.trim().isNotEmpty
            ? error.message
            : context.l10n.profileFailedSaveNotificationSettings,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _prefs = previous;
      });
      _showSnack(context.l10n.profileFailedSaveNotificationSettings);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSnack(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileAppBanners)),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.responsive.pageMaxWidth,
              ),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  context.responsive.pageHorizontalPadding,
                  12,
                  context.responsive.pageHorizontalPadding,
                  20,
                ),
                children: [
                  _buildSectionHeading(
                    context,
                    context.l10n.profileInAppBannersSectionTitle,
                  ),
                  const SizedBox(height: 8),
                  _buildProfileSectionCard(
                    context: context,
                    children: [
                      _buildProfileSwitchTile(
                        context: context,
                        title: context.l10n.profileExpenseUpdates,
                        subtitle:
                            context.l10n.profileExpenseAddedBannersInsideApp,
                        icon: Icons.receipt_long_outlined,
                        value: _prefs.inAppExpenseAddedEnabled,
                        onChanged: (value) {
                          unawaited(
                            _setPreference(inAppExpenseAddedEnabled: value),
                          );
                        },
                      ),
                      _buildProfileSwitchTile(
                        context: context,
                        title: context.l10n.profileFriendInvites,
                        subtitle:
                            context.l10n.profileFriendInvitesBannersInsideApp,
                        icon: Icons.group_add_outlined,
                        value: _prefs.inAppFriendInvitesEnabled,
                        onChanged: (value) {
                          unawaited(
                            _setPreference(inAppFriendInvitesEnabled: value),
                          );
                        },
                      ),
                      _buildProfileSwitchTile(
                        context: context,
                        title: context.l10n.profileTripUpdates,
                        subtitle:
                            context.l10n.profileTripUpdatesBannersInsideApp,
                        icon: Icons.flag_outlined,
                        value: _prefs.inAppTripUpdatesEnabled,
                        onChanged: (value) {
                          unawaited(
                            _setPreference(inAppTripUpdatesEnabled: value),
                          );
                        },
                      ),
                      _buildProfileSwitchTile(
                        context: context,
                        title: context.l10n.profileSettlementUpdates,
                        subtitle: context
                            .l10n
                            .profileSettlementUpdatesBannersInsideApp,
                        icon: Icons.task_alt_outlined,
                        value: _prefs.inAppSettlementUpdatesEnabled,
                        onChanged: (value) {
                          unawaited(
                            _setPreference(
                              inAppSettlementUpdatesEnabled: value,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (_isSaving) ...[
                    const SizedBox(height: 14),
                    const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeading(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
          color: AppDesign.mutedColor(context),
        ),
      ),
    );
  }

  Widget _buildProfileSectionCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final content = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      content.add(children[i]);
      if (i < children.length - 1) {
        content.add(
          Divider(
            height: 1,
            indent: 8,
            endIndent: 8,
            color: AppDesign.cardStroke(context),
          ),
        );
      }
    }

    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [...content],
      ),
    );
  }

  Widget _buildProfileSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: AppDesign.mutedColor(context)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppDesign.titleColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppDesign.mutedColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: _isSaving ? null : onChanged,
            activeThumbColor: AppDesign.successColor(context),
          ),
        ],
      ),
    );
  }
}
