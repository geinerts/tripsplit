part of 'profile_page.dart';

/// Master in-app and push switches, with a way into each detailed page.
class _ProfileNotificationSettingsPage extends StatefulWidget {
  const _ProfileNotificationSettingsPage({required this.controller});

  final AuthController controller;

  @override
  State<_ProfileNotificationSettingsPage> createState() =>
      _ProfileNotificationSettingsPageState();
}

class _ProfileNotificationSettingsPageState
    extends State<_ProfileNotificationSettingsPage> {
  bool _isSaving = false;
  late NotificationPreferences _prefs;

  bool get _inAppEnabled =>
      _prefs.inAppBannerEnabled &&
      (_prefs.inAppExpenseAddedEnabled ||
          _prefs.inAppFriendInvitesEnabled ||
          _prefs.inAppTripUpdatesEnabled ||
          _prefs.inAppSettlementUpdatesEnabled);

  bool get _pushEnabled =>
      _prefs.pushExpenseAddedEnabled ||
      _prefs.pushFriendInvitesEnabled ||
      _prefs.pushTripUpdatesEnabled ||
      _prefs.pushSettlementUpdatesEnabled;

  @override
  void initState() {
    super.initState();
    _prefs = widget.controller.notificationPreferences;
  }

  Future<void> _setAllInApp(bool value) => _save(
    optimistic: _prefs.copyWith(
      inAppBannerEnabled: value,
      inAppExpenseAddedEnabled: value,
      inAppFriendInvitesEnabled: value,
      inAppFriendInviteReceivedEnabled: value,
      inAppFriendInviteAcceptedEnabled: value,
      inAppTripUpdatesEnabled: value,
      inAppTripAddedEnabled: value,
      inAppTripMemberAddedEnabled: value,
      inAppTripFinishedEnabled: value,
      inAppMemberReadyToSettleEnabled: value,
      inAppTripReadyToSettleEnabled: value,
      inAppSettlementUpdatesEnabled: value,
      inAppSettlementReminderEnabled: value,
      inAppSettlementAutoReminderEnabled: value,
      inAppSettlementSentEnabled: value,
      inAppSettlementConfirmedEnabled: value,
    ),
    request: () => widget.controller.updateNotificationPreferences(
      inAppBannerEnabled: value,
      inAppExpenseAddedEnabled: value,
      inAppFriendInvitesEnabled: value,
      inAppFriendInviteReceivedEnabled: value,
      inAppFriendInviteAcceptedEnabled: value,
      inAppTripUpdatesEnabled: value,
      inAppTripAddedEnabled: value,
      inAppTripMemberAddedEnabled: value,
      inAppTripFinishedEnabled: value,
      inAppMemberReadyToSettleEnabled: value,
      inAppTripReadyToSettleEnabled: value,
      inAppSettlementUpdatesEnabled: value,
      inAppSettlementReminderEnabled: value,
      inAppSettlementAutoReminderEnabled: value,
      inAppSettlementSentEnabled: value,
      inAppSettlementConfirmedEnabled: value,
    ),
  );

  Future<void> _setAllPush(bool value) => _save(
    optimistic: _prefs.copyWith(
      pushExpenseAddedEnabled: value,
      pushFriendInvitesEnabled: value,
      pushTripUpdatesEnabled: value,
      pushSettlementUpdatesEnabled: value,
    ),
    request: () => widget.controller.updateNotificationPreferences(
      pushExpenseAddedEnabled: value,
      pushFriendInvitesEnabled: value,
      pushTripUpdatesEnabled: value,
      pushSettlementUpdatesEnabled: value,
    ),
  );

  Future<void> _save({
    required NotificationPreferences optimistic,
    required Future<NotificationPreferences> Function() request,
  }) async {
    if (_isSaving) {
      return;
    }
    final previous = _prefs;
    final fallbackMessage = context.l10n.profileFailedSaveNotificationSettings;
    setState(() {
      _isSaving = true;
      _prefs = optimistic;
    });
    try {
      final updated = await request();
      if (mounted) {
        setState(() => _prefs = updated);
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _prefs = previous);
        _showSnack(
          error.message.trim().isNotEmpty ? error.message : fallbackMessage,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _prefs = previous);
        _showSnack(fallbackMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnack(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openDetails(WidgetBuilder builder) async {
    await Navigator.of(
      context,
    ).push<void>(AppPageRoute<void>(builder: builder));
    if (mounted) {
      setState(() => _prefs = widget.controller.notificationPreferences);
    }
  }

  Widget _buildRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required VoidCallback onOpenDetails,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AppSettingsRow(
        title: title,
        subtitle: subtitle,
        icon: icon,
        onTap: _isSaving ? null : onOpenDetails,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: title,
              child: Switch.adaptive(
                value: value,
                onChanged: _isSaving ? null : onChanged,
                activeTrackColor: colorScheme.primary,
                activeThumbColor: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: AppDesign.mutedColor(context)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppPageScaffold(
      appBar: AppBar(title: Text(t.notificationsTitle)),
      body: _ProfileSubpageBody(
        builder: (padding) => ListView(
          padding: padding,
          children: [
            _buildRow(
              title: t.profileAppBanners,
              subtitle: t.profileShowNewNotificationBannersInsideApp,
              icon: Icons.chat_bubble_outline_rounded,
              value: _inAppEnabled,
              onOpenDetails: () => unawaited(
                _openDetails(
                  (_) => _InAppNotificationSettingsPage(
                    controller: widget.controller,
                  ),
                ),
              ),
              onChanged: (value) => unawaited(_setAllInApp(value)),
            ),
            Divider(height: 1, color: AppDesign.cardStroke(context)),
            _buildRow(
              title: t.profilePushNotificationsTitle,
              subtitle:
                  t.profilePhoneNotificationsExpensesFriendsTripsSettlements,
              icon: Icons.notifications_active_outlined,
              value: _pushEnabled,
              onOpenDetails: () => unawaited(
                _openDetails(
                  (_) => _PushNotificationSettingsPage(
                    controller: widget.controller,
                  ),
                ),
              ),
              onChanged: (value) => unawaited(_setAllPush(value)),
            ),
            Divider(height: 1, color: AppDesign.cardStroke(context)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AppSettingsRow(
                title: t.tripReportEmailSetting,
                subtitle: t.tripReportEmailSettingSubtitle,
                icon: Icons.picture_as_pdf_outlined,
                chevron: false,
                // Keep this switch in the same column as the rows above,
                // which reserve space for a chevron after their switch.
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: t.tripReportEmailSetting,
                      child: Switch.adaptive(
                        key: const ValueKey('email-trip-report-switch'),
                        value: _prefs.emailTripReportEnabled,
                        onChanged: _isSaving
                            ? null
                            : (value) => unawaited(
                                _save(
                                  optimistic: _prefs.copyWith(
                                    emailTripReportEnabled: value,
                                  ),
                                  request: () => widget.controller
                                      .updateNotificationPreferences(
                                        emailTripReportEnabled: value,
                                      ),
                                ),
                              ),
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        activeThumbColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const ExcludeSemantics(
                      child: Visibility.maintain(
                        visible: false,
                        child: Icon(Icons.chevron_right),
                      ),
                    ),
                  ],
                ),
              ),
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
    );
  }
}
