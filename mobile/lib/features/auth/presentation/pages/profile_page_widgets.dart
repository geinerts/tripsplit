part of 'profile_page.dart';

extension _ProfilePageWidgets on _ProfilePageState {
  Widget _profileAvatarLetter(String value) {
    return Text(
      value,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    );
  }

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
    final avatarLetter = displayName.substring(0, 1).toUpperCase();
    final avatarUrl = widget.controller.avatarUrlFor(_user);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(context.l10n.profileTitle))
          : null,
      body: AppBackground(
        child: SafeArea(
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
        ),
      ),
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
    final responsive = context.responsive;
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        if (_isEditMode || _isSubmitting || _isLoading || _isSendingFeedback) {
          return;
        }
        await _loadProfile();
      },
      child: ListView(
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
              responsive: responsive,
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
            const SizedBox(height: 16),
            _buildProfileSectionHeading(
              context: context,
              title: _profileText(
                en: 'APP SETTINGS',
                lv: 'LIETOTNES IESTATĪJUMI',
              ),
            ),
            const SizedBox(height: 8),
            _buildProfileSectionCard(
              context: context,
              children: [
                _buildProfileSectionTile(
                  context: context,
                  title: _profileText(en: 'Appearance', lv: 'Izskats'),
                  icon: Icons.palette_outlined,
                  valueText: _currentAppearanceLabel(context),
                  subtitle: _profileText(
                    en: 'Theme & display mode',
                    lv: 'Tēma un attēlošanas režīms',
                  ),
                  onTap: _isBusy ? null : () => showThemeModePicker(context),
                ),
                _buildProfileSectionTile(
                  context: context,
                  title: _profileText(en: 'Language', lv: 'Valoda'),
                  icon: Icons.translate_outlined,
                  valueText: _currentLanguageLabel(context),
                  subtitle: _profileText(
                    en: 'Display language',
                    lv: 'Lietotnes valoda',
                  ),
                  onTap: _isBusy ? null : () => showAppLocalePicker(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileSectionHeading(
              context: context,
              title: _profileText(en: 'NOTIFICATIONS', lv: 'PAZIŅOJUMI'),
            ),
            const SizedBox(height: 8),
            _buildProfileSectionCard(
              context: context,
              children: [
                _buildProfileSwitchTile(
                  context: context,
                  title: _profileText(
                    en: 'In-app banners',
                    lv: 'Baneri lietotnē',
                  ),
                  subtitle: _profileText(
                    en: 'Show new notification banners inside app',
                    lv: 'Rādīt jaunus paziņojumu banerus lietotnē',
                  ),
                  icon: Icons.chat_bubble_outline_rounded,
                  value: _inAppNotificationsEnabled,
                  onChanged: (value) {
                    unawaited(_setInAppNotificationsEnabled(value));
                  },
                ),
                _buildProfileSwitchTile(
                  context: context,
                  title: _profileText(
                    en: 'Push: expense updates',
                    lv: 'Push: tēriņu atjauninājumi',
                  ),
                  subtitle: _profileText(
                    en: 'Expense added notifications to phone',
                    lv: 'Paziņojumi telefonā par pievienotiem tēriņiem',
                  ),
                  icon: Icons.receipt_long_outlined,
                  value: _pushExpenseUpdatesEnabled,
                  onChanged: (value) {
                    unawaited(_setPushExpenseUpdatesEnabled(value));
                  },
                ),
                _buildProfileSwitchTile(
                  context: context,
                  title: _profileText(
                    en: 'Push: friend invites',
                    lv: 'Push: draugu uzaicinājumi',
                  ),
                  subtitle: _profileText(
                    en: 'Friend request and response notifications',
                    lv: 'Paziņojumi par draugu pieprasījumiem un atbildēm',
                  ),
                  icon: Icons.group_add_outlined,
                  value: _pushFriendInvitesEnabled,
                  onChanged: (value) {
                    unawaited(_setPushFriendInvitesEnabled(value));
                  },
                ),
                _buildProfileSwitchTile(
                  context: context,
                  title: _profileText(
                    en: 'Push: trip updates',
                    lv: 'Push: ceļojumu atjauninājumi',
                  ),
                  subtitle: _profileText(
                    en: 'Trip lifecycle and member status changes',
                    lv: 'Ceļojuma statusa un dalībnieku izmaiņas',
                  ),
                  icon: Icons.flag_outlined,
                  value: _pushTripUpdatesEnabled,
                  onChanged: (value) {
                    unawaited(_setPushTripUpdatesEnabled(value));
                  },
                ),
                _buildProfileSwitchTile(
                  context: context,
                  title: _profileText(
                    en: 'Push: settlement updates',
                    lv: 'Push: norēķinu atjauninājumi',
                  ),
                  subtitle: _profileText(
                    en: 'Marked sent and confirmed payment updates',
                    lv: 'Atzīmēts kā nosūtīts un apstiprināts saņemts',
                  ),
                  icon: Icons.task_alt_outlined,
                  value: _pushSettlementUpdatesEnabled,
                  onChanged: (value) {
                    unawaited(_setPushSettlementUpdatesEnabled(value));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileSectionHeading(
              context: context,
              title: _profileText(en: 'SUPPORT', lv: 'ATBALSTS'),
            ),
            const SizedBox(height: 8),
            _buildProfileSectionCard(
              context: context,
              children: [
                _buildProfileSectionTile(
                  context: context,
                  title: _profileText(
                    en: 'Contact us',
                    lv: 'Sazināties ar mums',
                  ),
                  icon: Icons.support_agent_outlined,
                  subtitle: _profileText(
                    en: 'Report bug / Suggestion',
                    lv: 'Ziņot par kļūdu / Ieteikums',
                  ),
                  onTap: _isBusy ? null : _openFeedbackDialog,
                ),
                _buildProfileSectionTile(
                  context: context,
                  title: _profileText(en: 'Rate Splyto', lv: 'Novērtēt Splyto'),
                  icon: Icons.star_outline_rounded,
                  subtitle: _profileText(
                    en: 'Leave a store rating',
                    lv: 'Atstāt vērtējumu veikalā',
                  ),
                  onTap: _isBusy ? null : _openRateHint,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileSectionHeading(
              context: context,
              title: _profileText(en: 'SECURITY', lv: 'DROŠĪBA'),
            ),
            const SizedBox(height: 8),
            _buildProfileSectionCard(
              context: context,
              children: [
                _buildProfileSectionTile(
                  context: context,
                  title: _profileText(
                    en: 'Change password',
                    lv: 'Mainīt paroli',
                  ),
                  icon: Icons.lock_outline_rounded,
                  subtitle: _profileText(
                    en: 'Update account password',
                    lv: 'Atjaunināt konta paroli',
                  ),
                  onTap: _isBusy ? null : _openChangePasswordDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileSectionHeading(
              context: context,
              title: _profileText(en: 'DANGER ZONE', lv: 'BĪSTAMĀ ZONA'),
              isDanger: true,
            ),
            const SizedBox(height: 8),
            _buildProfileSectionCard(
              context: context,
              children: [
                _buildProfileSectionTile(
                  context: context,
                  title: _profileText(
                    en: 'Deactivate account',
                    lv: 'Deaktivēt kontu',
                  ),
                  icon: Icons.warning_amber_rounded,
                  subtitle: _profileText(
                    en: 'Manage account access',
                    lv: 'Pārvaldīt konta piekļuvi',
                  ),
                  onTap: _isBusy ? null : _openDangerZone,
                  isDanger: true,
                ),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProfileLogoutCard(BuildContext context) {
    final textColor = AppDesign.titleColor(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDesign.radiusSm),
        onTap: _isBusy ? null : _onLogoutPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Center(
            child: Text(
              context.l10n.logOutButton,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileFooter(BuildContext context) {
    final muted = AppDesign.mutedColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Text(
            _profileText(en: 'Made with', lv: 'Veidots ar'),
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

  Widget _buildProfileSectionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String subtitle,
    String? valueText,
    required VoidCallback? onTap,
    bool isDanger = false,
  }) {
    final muted = AppDesign.mutedColor(context);
    final danger = AppDesign.destructiveColor(context);
    final titleColor = isDanger ? danger : AppDesign.titleColor(context);
    final subtitleColor = isDanger ? danger.withValues(alpha: 0.72) : muted;
    final trailColor = isDanger ? danger.withValues(alpha: 0.66) : muted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesign.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: isDanger ? danger : muted),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    if (subtitle.trim().isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: subtitleColor),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (valueText != null) ...[
                Text(
                  valueText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: trailColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Icon(Icons.chevron_right_rounded, color: trailColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileIdentityCard({
    required BuildContext context,
    required ResponsiveSpec responsive,
    required String displayName,
    required String avatarLetter,
    required String? avatarUrl,
  }) {
    final t = context.l10n;
    final email = (_initialEmail ?? '').isEmpty
        ? t.notSetValue
        : _initialEmail!;

    return AppSurfaceCard(
      padding: EdgeInsets.all(
        responsive.pick(compact: 14, medium: 18, expanded: 20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDesign.radiusMd),
          onTap: _isSubmitting ? null : _openEditProfilePage,
          child: Padding(
            padding: const EdgeInsets.all(10),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppDesign.titleColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildProfileAvatar({
    required BuildContext context,
    required String avatarLetter,
    required String? avatarUrl,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppDesign.brandGradient,
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
                                  (56 * MediaQuery.devicePixelRatioOf(context))
                                      .round(),
                              cacheHeight:
                                  (56 * MediaQuery.devicePixelRatioOf(context))
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
            onChanged: _isBusy ? null : onChanged,
            activeThumbColor: AppDesign.successColor(context),
          ),
        ],
      ),
    );
  }

  String _currentAppearanceLabel(BuildContext context) {
    final t = context.l10n;
    final controller = ThemeModeScope.maybeOf(context);
    final mode = controller?.themeMode ?? ThemeMode.system;
    if (mode == ThemeMode.light) return t.themeModeLight;
    if (mode == ThemeMode.dark) return t.themeModeDark;
    return t.themeModeSystem;
  }

  String _currentLanguageLabel(BuildContext context) {
    final t = context.l10n;
    final controller = AppLocaleScope.maybeOf(context);
    final mode = controller?.mode;
    if (mode == AppLocaleMode.english) return t.languageEnglish;
    if (mode == AppLocaleMode.latvian) return t.languageLatvian;
    return t.languageSystem;
  }

  void _openRateHint() {
    _showSnack(
      _profileText(
        en: 'Store rating action will be connected in the next step.',
        lv: 'Vērtēšanas darbība veikalā tiks pieslēgta nākamajā solī.',
      ),
    );
  }

  void _openDangerZone() {
    if (_isBusy) {
      return;
    }
    _openDeactivateAccountPage();
  }

  bool get _isBusy => _isSubmitting || _isLoading || _isSendingFeedback;
}
