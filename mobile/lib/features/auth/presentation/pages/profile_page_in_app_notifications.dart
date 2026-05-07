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
    bool? inAppFriendInviteReceivedEnabled,
    bool? inAppFriendInviteAcceptedEnabled,
    bool? inAppTripAddedEnabled,
    bool? inAppTripMemberAddedEnabled,
    bool? inAppTripFinishedEnabled,
    bool? inAppMemberReadyToSettleEnabled,
    bool? inAppTripReadyToSettleEnabled,
    bool? inAppSettlementReminderEnabled,
    bool? inAppSettlementAutoReminderEnabled,
    bool? inAppSettlementSentEnabled,
    bool? inAppSettlementConfirmedEnabled,
  }) async {
    if (_isSaving) {
      return;
    }

    final previous = _prefs;

    final nextExpense =
        inAppExpenseAddedEnabled ?? _prefs.inAppExpenseAddedEnabled;
    final nextFriendReceived =
        inAppFriendInviteReceivedEnabled ??
        _prefs.inAppFriendInviteReceivedEnabled;
    final nextFriendAccepted =
        inAppFriendInviteAcceptedEnabled ??
        _prefs.inAppFriendInviteAcceptedEnabled;
    final nextTripAdded = inAppTripAddedEnabled ?? _prefs.inAppTripAddedEnabled;
    final nextTripMemberAdded =
        inAppTripMemberAddedEnabled ?? _prefs.inAppTripMemberAddedEnabled;
    final nextTripFinished =
        inAppTripFinishedEnabled ?? _prefs.inAppTripFinishedEnabled;
    final nextMemberReady =
        inAppMemberReadyToSettleEnabled ??
        _prefs.inAppMemberReadyToSettleEnabled;
    final nextTripReady =
        inAppTripReadyToSettleEnabled ?? _prefs.inAppTripReadyToSettleEnabled;
    final nextSettlementReminder =
        inAppSettlementReminderEnabled ?? _prefs.inAppSettlementReminderEnabled;
    final nextSettlementAutoReminder =
        inAppSettlementAutoReminderEnabled ??
        _prefs.inAppSettlementAutoReminderEnabled;
    final nextSettlementSent =
        inAppSettlementSentEnabled ?? _prefs.inAppSettlementSentEnabled;
    final nextSettlementConfirmed =
        inAppSettlementConfirmedEnabled ??
        _prefs.inAppSettlementConfirmedEnabled;

    final nextFriendGroup = nextFriendReceived || nextFriendAccepted;
    final nextTripGroup =
        nextTripAdded ||
        nextTripMemberAdded ||
        nextTripFinished ||
        nextMemberReady ||
        nextTripReady;
    final nextSettlementGroup =
        nextSettlementReminder ||
        nextSettlementAutoReminder ||
        nextSettlementSent ||
        nextSettlementConfirmed;
    final nextAnyEnabled =
        nextExpense || nextFriendGroup || nextTripGroup || nextSettlementGroup;

    setState(() {
      _isSaving = true;
      _prefs = _prefs.copyWith(
        inAppBannerEnabled: nextAnyEnabled,
        inAppExpenseAddedEnabled: nextExpense,
        inAppFriendInvitesEnabled: nextFriendGroup,
        inAppFriendInviteReceivedEnabled: nextFriendReceived,
        inAppFriendInviteAcceptedEnabled: nextFriendAccepted,
        inAppTripUpdatesEnabled: nextTripGroup,
        inAppTripAddedEnabled: nextTripAdded,
        inAppTripMemberAddedEnabled: nextTripMemberAdded,
        inAppTripFinishedEnabled: nextTripFinished,
        inAppMemberReadyToSettleEnabled: nextMemberReady,
        inAppTripReadyToSettleEnabled: nextTripReady,
        inAppSettlementUpdatesEnabled: nextSettlementGroup,
        inAppSettlementReminderEnabled: nextSettlementReminder,
        inAppSettlementAutoReminderEnabled: nextSettlementAutoReminder,
        inAppSettlementSentEnabled: nextSettlementSent,
        inAppSettlementConfirmedEnabled: nextSettlementConfirmed,
      );
    });

    try {
      final updated = await widget.controller.updateNotificationPreferences(
        inAppBannerEnabled: nextAnyEnabled,
        inAppExpenseAddedEnabled: nextExpense,
        inAppFriendInvitesEnabled: nextFriendGroup,
        inAppFriendInviteReceivedEnabled: nextFriendReceived,
        inAppFriendInviteAcceptedEnabled: nextFriendAccepted,
        inAppTripUpdatesEnabled: nextTripGroup,
        inAppTripAddedEnabled: nextTripAdded,
        inAppTripMemberAddedEnabled: nextTripMemberAdded,
        inAppTripFinishedEnabled: nextTripFinished,
        inAppMemberReadyToSettleEnabled: nextMemberReady,
        inAppTripReadyToSettleEnabled: nextTripReady,
        inAppSettlementUpdatesEnabled: nextSettlementGroup,
        inAppSettlementReminderEnabled: nextSettlementReminder,
        inAppSettlementAutoReminderEnabled: nextSettlementAutoReminder,
        inAppSettlementSentEnabled: nextSettlementSent,
        inAppSettlementConfirmedEnabled: nextSettlementConfirmed,
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
    return AppPageScaffold(
      appBar: AppBar(title: Text(context.l10n.profileAppBanners)),
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
                  context.l10n.profileInAppBannersSectionTitle,
                ),
                const SizedBox(height: 8),
                _buildProfileSectionCard(
                  context: context,
                  children: [
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.notificationExpenseAddedTitle,
                      subtitle:
                          context.l10n.notificationExpenseAddedBodyGeneric,
                      icon: Icons.receipt_long_outlined,
                      value: _prefs.inAppExpenseAddedEnabled,
                      onChanged: (value) {
                        unawaited(
                          _setPreference(inAppExpenseAddedEnabled: value),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSectionHeading(
                  context,
                  context.l10n.profileFriendInvites,
                ),
                const SizedBox(height: 8),
                _buildProfileSectionCard(
                  context: context,
                  children: [
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.notificationFriendInviteTitle,
                      subtitle:
                          context.l10n.notificationFriendInviteBodyGeneric,
                      icon: Icons.person_add_alt_1_outlined,
                      value: _prefs.inAppFriendInviteReceivedEnabled,
                      onChanged: (value) {
                        unawaited(
                          _setPreference(
                            inAppFriendInviteReceivedEnabled: value,
                          ),
                        );
                      },
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.notificationFriendInviteAcceptedTitle,
                      subtitle: context
                          .l10n
                          .notificationFriendInviteAcceptedBodyGeneric,
                      icon: Icons.how_to_reg_outlined,
                      value: _prefs.inAppFriendInviteAcceptedEnabled,
                      onChanged: (value) {
                        unawaited(
                          _setPreference(
                            inAppFriendInviteAcceptedEnabled: value,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSectionHeading(context, context.l10n.profileTripUpdates),
                const SizedBox(height: 8),
                _buildProfileSectionCard(
                  context: context,
                  children: [
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.notificationTripAddedTitle,
                      subtitle: context.l10n.notificationTripAddedBodyGeneric,
                      icon: Icons.group_add_outlined,
                      value: _prefs.inAppTripAddedEnabled,
                      onChanged: (value) {
                        unawaited(_setPreference(inAppTripAddedEnabled: value));
                      },
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.profileInAppTripMemberAddedTitle,
                      subtitle: context.l10n.notificationTripAddedBodyGeneric,
                      icon: Icons.group_add_outlined,
                      value: _prefs.inAppTripMemberAddedEnabled,
                      onChanged: (value) {
                        unawaited(
                          _setPreference(inAppTripMemberAddedEnabled: value),
                        );
                      },
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.notificationTripFinishedTitle,
                      subtitle:
                          context.l10n.notificationTripFinishedBodyGeneric,
                      icon: Icons.flag_outlined,
                      value: _prefs.inAppTripFinishedEnabled,
                      onChanged: (value) {
                        unawaited(
                          _setPreference(inAppTripFinishedEnabled: value),
                        );
                      },
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.notificationMemberReadyToSettleTitle,
                      subtitle: context
                          .l10n
                          .notificationMemberReadyToSettleBodyGeneric,
                      icon: Icons.person_pin_circle_outlined,
                      value: _prefs.inAppMemberReadyToSettleEnabled,
                      onChanged: (value) {
                        unawaited(
                          _setPreference(
                            inAppMemberReadyToSettleEnabled: value,
                          ),
                        );
                      },
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.notificationTripReadyToSettleTitle,
                      subtitle:
                          context.l10n.notificationTripReadyToSettleBodyGeneric,
                      icon: Icons.task_alt_outlined,
                      value: _prefs.inAppTripReadyToSettleEnabled,
                      onChanged: (value) {
                        unawaited(
                          _setPreference(inAppTripReadyToSettleEnabled: value),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSectionHeading(
                  context,
                  context.l10n.profileSettlementUpdates,
                ),
                const SizedBox(height: 8),
                _buildProfileSectionCard(
                  context: context,
                  children: [
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.notificationSettlementReminderTitle,
                      subtitle: context
                          .l10n
                          .notificationSettlementReminderBodyGeneric,
                      icon: Icons.notifications_active_outlined,
                      value: _prefs.inAppSettlementReminderEnabled,
                      onChanged: (value) {
                        unawaited(
                          _setPreference(inAppSettlementReminderEnabled: value),
                        );
                      },
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title:
                          context.l10n.profileInAppAutoSettlementReminderTitle,
                      subtitle:
                          context.l10n.notificationPaymentReminderBodyGeneric,
                      icon: Icons.alarm_on_outlined,
                      value: _prefs.inAppSettlementAutoReminderEnabled,
                      onChanged: (value) {
                        unawaited(
                          _setPreference(
                            inAppSettlementAutoReminderEnabled: value,
                          ),
                        );
                      },
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.notificationSettlementSentTitle,
                      subtitle:
                          context.l10n.notificationSettlementSentBodyGeneric,
                      icon: Icons.send_outlined,
                      value: _prefs.inAppSettlementSentEnabled,
                      onChanged: (value) {
                        unawaited(
                          _setPreference(inAppSettlementSentEnabled: value),
                        );
                      },
                    ),
                    _buildProfileSwitchTile(
                      context: context,
                      title: context.l10n.notificationSettlementConfirmedTitle,
                      subtitle: context
                          .l10n
                          .notificationSettlementConfirmedBodyGeneric,
                      icon: Icons.verified_outlined,
                      value: _prefs.inAppSettlementConfirmedEnabled,
                      onChanged: (value) {
                        unawaited(
                          _setPreference(
                            inAppSettlementConfirmedEnabled: value,
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

    return Padding(
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
