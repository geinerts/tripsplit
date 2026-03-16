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
    final colorScheme = Theme.of(context).colorScheme;
    final horizontalPadding = responsive.pageHorizontalPadding;
    final fullName = _fullNameController.text.trim();
    final displayName = fullName.isNotEmpty
        ? fullName
        : (_nicknameController.text.trim().isEmpty
              ? (_user?.nickname.trim().isNotEmpty ?? false)
                    ? _user!.nickname
                    : t.travelerFallbackName
              : _nicknameController.text.trim());
    final avatarLetter = displayName.substring(0, 1).toUpperCase();
    final avatarUrl = widget.controller.avatarUrlFor(_user);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(t.profileTitle),
              actions: [
                IconButton(
                  onPressed: _isSubmitting ? null : _loadProfile,
                  icon: const Icon(Icons.refresh),
                  tooltip: t.reloadProfile,
                ),
                IconButton(
                  onPressed: _isSubmitting ? null : _openSettingsSheet,
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: t.settings,
                ),
              ],
            )
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
                          colorScheme: colorScheme,
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
    required ColorScheme colorScheme,
    required String displayName,
    required String avatarLetter,
    required String? avatarUrl,
  }) {
    final t = context.l10n;
    final responsive = context.responsive;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        24,
      ),
      children: [
        if (_isEditMode) ...[
          _buildInlineEditProfilePage(context),
          if (!_isDeactivateAccountPage) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _isSubmitting ? null : _openDeactivateAccountPage,
                icon: const Icon(Icons.person_off_outlined),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
                label: const Text('Deactivate Account'),
              ),
            ),
          ],
        ] else ...[
          Card(
            child: Padding(
              padding: EdgeInsets.all(
                responsive.pick(
                  compact: 14,
                  medium: 18,
                  expanded: 20,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _profileAvatarLetter(
                                                  avatarLetter,
                                                ),
                                      ),
                                    )
                                  : _profileAvatarLetter(avatarLetter)),
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
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (_initialEmail ?? '').isEmpty
                                  ? t.notSetValue
                                  : _initialEmail!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colorScheme.outline),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: _isSubmitting ? null : _openEditProfilePage,
                        icon: const Icon(Icons.edit, size: 18),
                        label: Text(t.editAction),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : _onPickAvatarPressed,
                        icon: const Icon(Icons.upload_outlined),
                        label: Text(t.uploadAvatarAction),
                      ),
                      if ((_avatarBytes != null && _avatarBytes!.isNotEmpty) ||
                          avatarUrl != null) ...[
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : _onRemoveAvatarPressed,
                          icon: const Icon(Icons.delete_outline),
                          label: Text(t.removeAvatarAction),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorText!,
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildProfileSectionCard(
            context: context,
            title: 'Preferences',
            children: [
              _buildProfileSectionTile(
                context: context,
                title: 'Security',
                icon: Icons.security_outlined,
                trailing: const Icon(Icons.edit_outlined),
              ),
              _buildProfileSectionTile(
                context: context,
                title: 'Notifications',
                icon: Icons.notifications_outlined,
                trailing: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProfileSectionCard(
            context: context,
            title: 'Feedback',
            children: [
              _buildProfileSectionTile(
                context: context,
                title: 'Contact Us',
                icon: Icons.support_agent_outlined,
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
              _buildProfileSectionTile(
                context: context,
                title: 'Rate Splyto',
                icon: Icons.star_outline_rounded,
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProfileSectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSectionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: trailing,
      onTap: () {},
    );
  }
}
