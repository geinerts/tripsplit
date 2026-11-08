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
          ],
        ],
      ),
    );
  }

  Widget _buildProfileSettingsPanel(BuildContext context) {
    final t = context.l10n;
    Widget divider() =>
        Divider(height: 1, color: AppDesign.cardStroke(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.onTravelMapRequested != null) ...[
          _buildProfileSectionTile(
            context: context,
            title: t.travelMapTitle,
            subtitle: t.travelMapSubtitle,
            icon: Icons.travel_explore,
            onTap: _isBusy ? null : widget.onTravelMapRequested,
          ),
          divider(),
        ],
        if (widget.onYearSummaryRequested != null &&
            _user?.premiumAccess?.allows(PremiumFeatures.yearSummary) ==
                true) ...[
          _buildProfileSectionTile(
            context: context,
            title: t.yearSummaryTitle,
            subtitle: t.yearSummarySubtitle,
            icon: Icons.auto_awesome_outlined,
            onTap: _isBusy ? null : widget.onYearSummaryRequested,
          ),
          divider(),
        ],
        if (_user?.premiumAccess?.showsPlanStatus == true)
          PremiumStatusTile(
            access: _user?.premiumAccess,
            onRefresh: _isLoading || _isBusy
                ? null
                : () => unawaited(_loadProfile()),
          ),
        _buildProfileSectionLabel(context, t.profileAppSettingsSectionTitle),
        _buildProfileSectionTile(
          context: context,
          title: t.profileAppearance,
          icon: Icons.palette_outlined,
          valueText: _currentAppearanceLabel(context),
          subtitle: '',
          onTap: _isBusy ? null : () => showThemeModePicker(context),
        ),
        divider(),
        _buildProfileSectionTile(
          context: context,
          title: t.profileLanguage,
          icon: Icons.translate_outlined,
          valueText: _currentLanguageLabel(context),
          subtitle: '',
          onTap: _isBusy ? null : () => showAppLocalePicker(context),
        ),
        divider(),
        _buildProfileSectionTile(
          context: context,
          title: t.notificationsTitle,
          icon: Icons.notifications_none_rounded,
          subtitle: '',
          onTap: _isBusy ? null : _openNotificationSettings,
        ),
        _buildProfileSectionLabel(context, t.profileAccountSectionTitle),
        _buildProfileSectionTile(
          context: context,
          title: t.profileAccountAndSecurity,
          icon: Icons.shield_outlined,
          subtitle: '',
          onTap: _isBusy ? null : _openAccountAndSecurity,
        ),
        divider(),
        _buildProfileSectionTile(
          context: context,
          title: t.profileHelpTitle,
          icon: Icons.help_outline,
          subtitle: '',
          onTap: _isBusy ? null : _openHelp,
        ),
      ],
    );
  }

  Widget _buildProfileSectionLabel(BuildContext context, String label) =>
      Semantics(
        header: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppDesign.mutedColor(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
      );

  /// Verified is a quiet confirmation. Not verified can be fixed from right here.
  Widget _buildEmailStatus(BuildContext context) {
    final t = context.l10n;
    final verified = _user?.emailVerified;
    final hasEmail = (_user?.email ?? '').trim().isNotEmpty;
    if (verified == null || !hasEmail) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    if (verified) {
      final color = Theme.of(context).colorScheme.primary;
      return Padding(
        key: const ValueKey('profile-email-verified'),
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, size: 15, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                t.profileEmailVerified,
                style: textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final color = Theme.of(context).colorScheme.error;
    return Semantics(
      button: true,
      child: InkWell(
        key: const ValueKey('profile-email-not-verified'),
        borderRadius: BorderRadius.circular(8),
        onTap: _sendingVerification ? null : _sendEmailVerification,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              Icon(Icons.error_outline_rounded, size: 15, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: t.profileEmailNotVerified,
                    style: textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      const TextSpan(text: ' · '),
                      TextSpan(
                        text: t.profileEmailSendVerification,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_sendingVerification) ...[
                const SizedBox(width: 8),
                const SizedBox.square(
                  dimension: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendEmailVerification() async {
    final email = (_user?.email ?? '').trim();
    if (email.isEmpty || _sendingVerification) return;
    final t = context.l10n;
    _updateState(() => _sendingVerification = true);
    try {
      await widget.controller.requestEmailVerificationLink(email: email);
      if (mounted) _showSnack(t.profileEmailVerificationSent);
    } on ApiException catch (error) {
      if (mounted) _showSnack(error.message);
    } finally {
      if (mounted) _updateState(() => _sendingVerification = false);
    }
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
                    _buildEmailStatus(context),
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

  String _currentAppearanceLabel(BuildContext context) {
    final t = context.l10n;
    final controller = ThemeModeScope.maybeOf(context);
    final mode =
        controller?.themeMode ??
        (AppDesign.isDark(context) ? ThemeMode.dark : ThemeMode.light);
    if (mode == ThemeMode.system) return t.themeModeSystem;
    if (mode == ThemeMode.light) return t.themeModeLight;
    return t.themeModeDark;
  }

  String _currentLanguageLabel(BuildContext context) {
    final t = context.l10n;
    final controller = AppLocaleScope.maybeOf(context);
    final mode = controller?.mode;
    if (mode == AppLocaleMode.system) return t.languageSystem;
    return mode?.nativeName ?? t.languageEnglish;
  }

  bool get _isBusy => _isSubmitting || _isLoading;
}
