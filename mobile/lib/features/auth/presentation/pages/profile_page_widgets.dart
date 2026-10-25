part of 'profile_page.dart';

extension _ProfilePageWidgets on _ProfilePageState {
  Widget _profileAvatarLetter(String value) => Text(
    value,
    textScaler: TextScaler.noScaling,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimaryContainer,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _buildProfileScaffold(BuildContext context) {
    final t = context.l10n;
    final responsive = context.responsive;
    final horizontalPadding = responsive.pageHorizontalPadding;
    final fullName = _fullNameController.text.trim();
    final rawPreferredName = (_user?.displayName ?? _user?.nickname ?? '')
        .trim();
    final displayName = fullName.isNotEmpty
        ? fullName
        : (rawPreferredName.isNotEmpty
              ? rawPreferredName
              : t.travelerFallbackName);
    final words = displayName
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    final avatarLetter = words
        .take(2)
        .map((s) => s.characters.first)
        .join()
        .toUpperCase();
    final avatarUrl = widget.controller.avatarUrlFor(_user);

    final body = SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: responsive.pageMaxWidth,
                      minHeight: constraints.maxHeight,
                    ),
                    child: _buildProfileScrollableContent(
                      context: context,
                      horizontalPadding: horizontalPadding,
                      displayName: displayName,
                      avatarLetter: avatarLetter,
                      avatarUrl: avatarUrl,
                    ),
                  ),
                );
              },
            ),
    );

    if (!widget.showAppBar && !widget.showBottomNav) {
      return AppBackground(child: body);
    }

    return AppPageScaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(context.l10n.profileTitle))
          : null,
      body: body,
      bottomNavigationBar: widget.showBottomNav
          ? _buildBottomNav(context)
          : null,
    );
  }

  Widget _buildProfileScrollableContent({
    required BuildContext context,
    required double horizontalPadding,
    required String displayName,
    required String avatarLetter,
    required String? avatarUrl,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        if (_isEditMode || _isSubmitting || _isLoading) {
          return;
        }
        await _loadProfile();
      },
      child: ListView(
        key: const ValueKey('profile-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          12,
          horizontalPadding,
          24,
        ),
        children: [
          if (_isEditMode) ...[
            _buildInlineEditProfilePage(context),
          ] else ...[
            _buildProfileIdentityCard(
              context: context,
              displayName: displayName,
              avatarLetter: avatarLetter,
              avatarUrl: avatarUrl,
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            _buildProfileSettingsPanel(context),
            const SizedBox(height: 12),
            _buildProfileLogoutCard(context),
            const SizedBox(height: 16),
            _buildProfileFooter(context),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileSectionHeading({
    required BuildContext context,
    required String title,
    bool isDanger = false,
  }) {
    final color = isDanger
        ? AppDesign.destructiveColor(context)
        : AppDesign.mutedColor(context);
    return Padding(
      padding: EdgeInsets.zero,
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.9,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProfileSettingsPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumStatusTile(
          access: _user?.premiumAccess,
          onRefresh: _isLoading || _isBusy
              ? null
              : () => unawaited(_loadProfile()),
        ),
        const SizedBox(height: 8),
        _buildProfileSectionGroup(
          context: context,
          title: context.l10n.profileAppSettingsSectionTitle,
          children: [
            _buildProfileSectionTile(
              context: context,
              title: context.l10n.profileAppearance,
              icon: Icons.palette_outlined,
              valueText: _currentAppearanceLabel(context),
              subtitle: '',
              onTap: _isBusy ? null : () => showThemeModePicker(context),
            ),
            _buildProfileSectionTile(
              context: context,
              title: context.l10n.profileLanguage,
              icon: Icons.translate_outlined,
              valueText: _currentLanguageLabel(context),
              subtitle: '',
              onTap: _isBusy ? null : () => showAppLocalePicker(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildProfileSectionGroup(
          context: context,
          title: context.l10n.profileNotificationsSectionHeading,
          children: [
            _buildProfileSwitchNavigationTile(
              context: context,
              title: context.l10n.profileAppBanners,
              subtitle: context.l10n.profileShowNewNotificationBannersInsideApp,
              icon: Icons.chat_bubble_outline_rounded,
              value: _inAppNotificationsEnabled,
              onTap: () {
                unawaited(_openInAppNotificationSettingsPage());
              },
              onChanged: (value) {
                unawaited(_setAllInAppNotificationsEnabled(value));
              },
            ),
            _buildProfileSwitchNavigationTile(
              context: context,
              title: context.l10n.profilePushNotificationsTitle,
              subtitle: context
                  .l10n
                  .profilePhoneNotificationsExpensesFriendsTripsSettlements,
              icon: Icons.notifications_active_outlined,
              value: _pushNotificationsEnabled,
              onTap: () {
                unawaited(_openPushNotificationSettingsPage());
              },
              onChanged: (value) {
                unawaited(_setAllPushNotificationsEnabled(value));
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildProfileSectionGroup(
          context: context,
          title: context.l10n.profileSupportSectionHeading,
          children: [
            _buildProfileSectionTile(
              context: context,
              title: context.l10n.quickStartTitle,
              subtitle: '',
              icon: Icons.help_outline,
              onTap: _isBusy
                  ? null
                  : (widget.onQuickStartRequested ?? _openQuickStart),
            ),
            _buildProfileSectionTile(
              context: context,
              title: context.l10n.profileContactUs,
              icon: Icons.support_agent_outlined,
              subtitle: '',
              onTap: _isBusy ? null : _openContactDialog,
            ),
            _buildProfileSectionTile(
              context: context,
              title: context.l10n.profilePrivacyPolicy,
              icon: Icons.privacy_tip_outlined,
              subtitle: '',
              onTap: _isBusy ? null : _openPrivacyPolicy,
            ),
            _buildProfileSectionTile(
              context: context,
              title: context.l10n.profileRateSplyto,
              icon: Icons.star_outline_rounded,
              subtitle: '',
              onTap: _isBusy ? null : _openRateHint,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildProfileSectionGroup(
          context: context,
          title: context.l10n.profileSecuritySectionHeading,
          children: [
            _buildProfileSectionTile(
              context: context,
              title: context.l10n.profileChangePassword,
              icon: Icons.lock_outline_rounded,
              subtitle: '',
              onTap: _isBusy ? null : _openChangePasswordDialog,
            ),
          ],
        ),
        const Divider(height: 1),
        _buildProfileSectionTile(
          context: context,
          title: context.l10n.profileAccountSettings,
          icon: Icons.manage_accounts_outlined,
          subtitle: '',
          onTap: _isBusy ? null : _openDangerZone,
        ),
      ],
    );
  }

  Widget _buildProfileSectionGroup({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    bool isDanger = false,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileSectionHeading(
          context: context,
          title: title,
          isDanger: isDanger,
        ),
        const SizedBox(height: 8),
        ...content,
      ],
    );
  }

  Widget _buildProfileLogoutCard(BuildContext context) => Column(
    children: [
      const Divider(height: 1),
      AppSettingsRow(
        title: context.l10n.logOutButton,
        icon: Icons.logout_rounded,
        destructive: true,
        chevron: false,
        onTap: _isBusy ? null : _onLogoutPressed,
      ),
    ],
  );

  Widget _buildProfileFooter(BuildContext context) {
    final muted = AppDesign.mutedColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Text(
            context.l10n.profileMadeWithLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _onFooterLogoTap,
            child: Transform.translate(
              offset: const Offset(-3, 0),
              child: SizedBox(
                width: 54,
                child: SvgPicture.asset(
                  'assets/branding/egmlogo.svg',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _onFooterVersionTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                'v$_appVersionLabel',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: muted.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSectionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String subtitle,
    String? valueText,
    required VoidCallback? onTap,
    bool isDanger = false,
  }) => AppSettingsRow(
    title: title,
    icon: icon,
    subtitle: subtitle,
    value: valueText,
    onTap: onTap,
    destructive: isDanger,
  );

  Widget _buildProfileIdentityCard({
    required BuildContext context,
    required String displayName,
    required String avatarLetter,
    required String? avatarUrl,
  }) {
    final t = context.l10n;
    final email = (_initialEmail ?? '').isEmpty
        ? t.notSetValue
        : _initialEmail!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _isSubmitting ? null : _openEditProfilePage,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileAvatar(
                context: context,
                avatarLetter: avatarLetter,
                avatarUrl: avatarUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,

                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppDesign.titleColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,

                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppDesign.mutedColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppDesign.mutedColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar({
    required BuildContext context,
    required String avatarLetter,
    required String? avatarUrl,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: context.l10n.profileChangePhoto,
      button: true,
      child: GestureDetector(
        onTap: _isSubmitting || _isLoading ? null : _onAvatarTapped,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 62,
          height: 62,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer,
                ),
                alignment: Alignment.center,
                child: _avatarBytes != null && _avatarBytes!.isNotEmpty
                    ? ClipOval(
                        child: Image.memory(
                          _avatarBytes!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                      )
                    : (avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                avatarUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.low,
                                gaplessPlayback: true,
                                cacheWidth:
                                    (56 *
                                            MediaQuery.devicePixelRatioOf(
                                              context,
                                            ))
                                        .round(),
                                cacheHeight:
                                    (56 *
                                            MediaQuery.devicePixelRatioOf(
                                              context,
                                            ))
                                        .round(),
                                errorBuilder: (context, error, stackTrace) =>
                                    _profileAvatarLetter(avatarLetter),
                              ),
                            )
                          : _profileAvatarLetter(avatarLetter)),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppDesign.cardStroke(context)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.photo_camera_rounded,
                    size: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSwitchNavigationTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required VoidCallback onTap,
    required ValueChanged<bool> onChanged,
  }) => AppSettingsRow(
    title: title,
    icon: icon,
    onTap: _isBusy ? null : onTap,
    trailing: Semantics(
      label: title,
      child: Switch.adaptive(
        value: value,
        onChanged: _isBusy ? null : onChanged,
        activeTrackColor: Theme.of(context).colorScheme.primary,
        activeThumbColor: Theme.of(context).colorScheme.onPrimary,
      ),
    ),
  );

  String _currentAppearanceLabel(BuildContext context) {
    final t = context.l10n;
    final controller = ThemeModeScope.maybeOf(context);
    final mode =
        controller?.themeMode ??
        (AppDesign.isDark(context) ? ThemeMode.dark : ThemeMode.light);
    if (mode == ThemeMode.light) return t.themeModeLight;
    return t.themeModeDark;
  }

  String _currentLanguageLabel(BuildContext context) {
    final t = context.l10n;
    final controller = AppLocaleScope.maybeOf(context);
    final mode = controller?.mode;
    if (mode == AppLocaleMode.english) return t.languageEnglish;
    if (mode == AppLocaleMode.latvian) return t.languageLatvian;
    if (mode == AppLocaleMode.spanish) return t.languageSpanish;
    return t.languageEnglish;
  }

  void _openRateHint() {
    _showSnack(context.l10n.profileStoreRatingActionWillConnectedNextStep);
  }

  void _openDangerZone() {
    if (_isBusy) {
      return;
    }
    _openDeactivateAccountPage();
  }

  bool get _isBusy => _isSubmitting || _isLoading;
}
