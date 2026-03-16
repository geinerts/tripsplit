part of 'workspace_page.dart';

extension _WorkspacePageLayoutNavigation on _WorkspacePageState {
  Widget _buildAppBottomNavigationBar(BuildContext context) {
    final t = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700);
    final user = widget.authController.currentUser;
    final avatarBytes = widget.authController.avatarBytesFor(user);
    final avatarUrl = widget.authController.avatarUrlFor(
      user,
      preferThumb: true,
    );
    final displayName = (user?.displayName ?? user?.nickname ?? '').trim();
    final avatarLetter = displayName.isEmpty
        ? t.travelerFallbackName.substring(0, 1).toUpperCase()
        : displayName.substring(0, 1).toUpperCase();

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return labelStyle?.copyWith(color: colorScheme.onPrimaryContainer);
          }
          return labelStyle?.copyWith(color: colorScheme.onSurfaceVariant);
        }),
      ),
      child: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: 0,
        onDestinationSelected: _onAppDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.currency_exchange_outlined, size: 26),
            selectedIcon: const Icon(Icons.currency_exchange, size: 26),
            label: t.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timeline_outlined, size: 26),
            selectedIcon: const Icon(Icons.timeline, size: 26),
            label: t.navActivities,
          ),
          NavigationDestination(
            icon: _buildAddTripNavIcon(selected: false),
            selectedIcon: _buildAddTripNavIcon(selected: true),
            label: t.navAddTrip,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline, size: 26),
            selectedIcon: const Icon(Icons.people, size: 26),
            label: t.navFriends,
          ),
          NavigationDestination(
            icon: _profileNavAvatar(
              avatarBytes: avatarBytes,
              avatarUrl: avatarUrl,
              avatarLetter: avatarLetter,
              color: colorScheme.onSurfaceVariant,
            ),
            selectedIcon: _profileNavAvatar(
              avatarBytes: avatarBytes,
              avatarUrl: avatarUrl,
              avatarLetter: avatarLetter,
              color: colorScheme.onPrimaryContainer,
            ),
            label: t.navProfile,
          ),
        ],
      ),
    );
  }

  void _onAppDestinationSelected(int index) {
    switch (index) {
      case 1:
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.shell,
            (route) => false,
            arguments: const <String, Object>{'initial_tab': 1},
          ),
        );
        return;
      case 2:
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.trips,
            (route) => false,
            arguments: const <String, Object>{'open_create_trip': true},
          ),
        );
        return;
      case 3:
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.shell,
            (route) => false,
            arguments: const <String, Object>{'initial_tab': 3},
          ),
        );
        return;
      case 4:
        unawaited(
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRouter.profile, (route) => false),
        );
        return;
      default:
        unawaited(
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRouter.trips, (route) => false),
        );
        return;
    }
  }

  Widget _buildAddTripNavIcon({required bool selected}) {
    const width = 64.0;
    const height = 34.0;
    const iconSize = 19.0;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: AppDesign.brandGradient,
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x4D5D6DFF),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.add_rounded, size: iconSize, color: Colors.white),
    );
  }

  Widget _profileNavAvatar({
    required Uint8List? avatarBytes,
    required String? avatarUrl,
    required String avatarLetter,
    required Color color,
  }) {
    const size = 26.0;
    final imageCacheSize = (size * MediaQuery.devicePixelRatioOf(context))
        .round();
    if (avatarBytes != null && avatarBytes.isNotEmpty) {
      return ClipOval(
        child: Image.memory(
          avatarBytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
    }
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          cacheWidth: imageCacheSize,
          cacheHeight: imageCacheSize,
          errorBuilder: (context, error, stackTrace) =>
              _profileNavAvatarLetter(avatarLetter: avatarLetter, color: color),
        ),
      );
    }
    return _profileNavAvatarLetter(avatarLetter: avatarLetter, color: color);
  }

  Widget _profileNavAvatarLetter({
    required String avatarLetter,
    required Color color,
  }) {
    const size = 26.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.16),
      ),
      alignment: Alignment.center,
      child: Text(
        avatarLetter,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
