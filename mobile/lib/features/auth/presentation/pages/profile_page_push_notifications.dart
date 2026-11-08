part of 'profile_page.dart';

class _PushNotificationSettingsPage extends StatefulWidget {
  const _PushNotificationSettingsPage({required this.controller});

  final AuthController controller;

  @override
  State<_PushNotificationSettingsPage> createState() =>
      _PushNotificationSettingsPageState();
}

class _PushNotificationSettingsPageState
    extends State<_PushNotificationSettingsPage> {
  bool _isSaving = false;
  late NotificationPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = widget.controller.notificationPreferences;
  }

  Future<void> _setPreference(
    NotificationPreferences optimistic,
    Future<NotificationPreferences> Function() request,
  ) async {
    if (_isSaving) {
      return;
    }

    final previous = _prefs;
    setState(() {
      _isSaving = true;
      _prefs = optimistic;
    });

    try {
      final updated = await request();
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
    return AppPageScaffold(
      appBar: AppBar(title: Text(context.l10n.profilePushNotificationsTitle)),
      body: SafeArea(
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
                  context.l10n.profilePushNotificationsSectionTitle,
                ),
                const SizedBox(height: 8),
                _buildProfileSectionCard(
                  context: context,
                  children: [
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.profileExpenseUpdates,
                      subtitle:
                          context.l10n.profileExpenseAddedNotificationsPhone,
                      icon: Icons.receipt_long_outlined,
                      value: _prefs.pushExpenseAddedEnabled,
                      onChanged: (value) => unawaited(
                        _setPreference(
                          _prefs.copyWith(pushExpenseAddedEnabled: value),
                          () => widget.controller.updateNotificationPreferences(
                            pushExpenseAddedEnabled: value,
                          ),
                        ),
                      ),
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.profilePushCommentsTitle,
                      subtitle: context.l10n.profilePushCommentsSubtitle,
                      icon: Icons.chat_bubble_outline_rounded,
                      value: _prefs.pushCommentsEnabled,
                      onChanged: (value) => unawaited(
                        _setPreference(
                          _prefs.copyWith(pushCommentsEnabled: value),
                          () => widget.controller.updateNotificationPreferences(
                            pushCommentsEnabled: value,
                          ),
                        ),
                      ),
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.profilePushTripInvitesTitle,
                      subtitle: context.l10n.profilePushTripInvitesSubtitle,
                      icon: Icons.person_add_alt_outlined,
                      value: _prefs.pushTripInvitesEnabled,
                      onChanged: (value) => unawaited(
                        _setPreference(
                          _prefs.copyWith(pushTripInvitesEnabled: value),
                          () => widget.controller.updateNotificationPreferences(
                            pushTripInvitesEnabled: value,
                          ),
                        ),
                      ),
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.profilePushTripStatusTitle,
                      subtitle: context.l10n.profilePushTripStatusSubtitle,
                      icon: Icons.flag_outlined,
                      value: _prefs.pushTripStatusEnabled,
                      onChanged: (value) => unawaited(
                        _setPreference(
                          _prefs.copyWith(pushTripStatusEnabled: value),
                          () => widget.controller.updateNotificationPreferences(
                            pushTripStatusEnabled: value,
                          ),
                        ),
                      ),
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.profilePushPaymentRequestsTitle,
                      subtitle: context.l10n.profilePushPaymentRequestsSubtitle,
                      icon: Icons.request_quote_outlined,
                      value: _prefs.pushPaymentRequestsEnabled,
                      onChanged: (value) => unawaited(
                        _setPreference(
                          _prefs.copyWith(pushPaymentRequestsEnabled: value),
                          () => widget.controller.updateNotificationPreferences(
                            pushPaymentRequestsEnabled: value,
                          ),
                        ),
                      ),
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.profilePushPaymentsTitle,
                      subtitle: context.l10n.profilePushPaymentsSubtitle,
                      icon: Icons.task_alt_outlined,
                      value: _prefs.pushPaymentsEnabled,
                      onChanged: (value) => unawaited(
                        _setPreference(
                          _prefs.copyWith(pushPaymentsEnabled: value),
                          () => widget.controller.updateNotificationPreferences(
                            pushPaymentsEnabled: value,
                          ),
                        ),
                      ),
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.profilePushRemindersTitle,
                      subtitle: context.l10n.profilePushRemindersSubtitle,
                      icon: Icons.alarm_outlined,
                      value: _prefs.pushRemindersEnabled,
                      onChanged: (value) => unawaited(
                        _setPreference(
                          _prefs.copyWith(pushRemindersEnabled: value),
                          () => widget.controller.updateNotificationPreferences(
                            pushRemindersEnabled: value,
                          ),
                        ),
                      ),
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.profilePushLocationTitle,
                      subtitle: context.l10n.profilePushLocationSubtitle,
                      icon: Icons.location_on_outlined,
                      value: _prefs.pushLocationEnabled,
                      onChanged: (value) => unawaited(
                        _setPreference(
                          _prefs.copyWith(pushLocationEnabled: value),
                          () => widget.controller.updateNotificationPreferences(
                            pushLocationEnabled: value,
                          ),
                        ),
                      ),
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.profileFriendInvites,
                      subtitle: context
                          .l10n
                          .profileFriendRequestResponseNotifications,
                      icon: Icons.group_add_outlined,
                      value: _prefs.pushFriendInvitesEnabled,
                      onChanged: (value) => unawaited(
                        _setPreference(
                          _prefs.copyWith(pushFriendInvitesEnabled: value),
                          () => widget.controller.updateNotificationPreferences(
                            pushFriendInvitesEnabled: value,
                          ),
                        ),
                      ),
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
    );
  }

  Widget _buildSectionHeading(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
            indent: 0,
            endIndent: 0,
            color: AppDesign.cardStroke(context),
          ),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.zero,
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
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: AppSettingsRow(
      title: title,
      subtitle: subtitle,
      icon: icon,
      chevron: false,
      trailing: Semantics(
        label: title,
        child: Switch.adaptive(
          value: value,
          onChanged: _isSaving ? null : onChanged,
          activeTrackColor: Theme.of(context).colorScheme.primary,
          activeThumbColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    ),
  );
}
