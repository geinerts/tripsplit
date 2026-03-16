part of 'trips_page.dart';

extension _TripsPageNavigationWidgets on _TripsPageState {
  Widget _buildBottomNav(BuildContext context) {
    final t = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final user = widget.authController.currentUser;
    final avatarBytes = widget.authController.avatarBytesFor(user);
    final avatarUrl = widget.authController.avatarUrlFor(
      user,
      preferThumb: true,
    );
    final nickname = user?.nickname.trim();
    final avatarLetter = (nickname == null || nickname.isEmpty)
        ? t.travelerFallbackName.substring(0, 1).toUpperCase()
        : nickname.substring(0, 1).toUpperCase();

    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: _onBottomNavTapped,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.currency_exchange_outlined, size: 26),
          selectedIcon: const Icon(Icons.currency_exchange, size: 28),
          label: t.navHome,
        ),
        NavigationDestination(
          icon: _buildAddTripNavIcon(selected: false),
          selectedIcon: _buildAddTripNavIcon(selected: true),
          label: t.navAddTrip,
        ),
        NavigationDestination(
          icon: const Icon(Icons.people_outline, size: 26),
          selectedIcon: const Icon(Icons.people, size: 28),
          label: t.navFriends,
        ),
        NavigationDestination(
          icon: _profileNavAvatar(
            context,
            avatarBytes: avatarBytes,
            avatarUrl: avatarUrl,
            avatarLetter: avatarLetter,
            color: colorScheme.onSurfaceVariant,
            selected: false,
          ),
          selectedIcon: _profileNavAvatar(
            context,
            avatarBytes: avatarBytes,
            avatarUrl: avatarUrl,
            avatarLetter: avatarLetter,
            color: colorScheme.onPrimaryContainer,
            selected: true,
          ),
          label: t.navProfile,
        ),
      ],
    );
  }

  Widget _buildAddTripNavIcon({required bool selected}) {
    final size = selected ? 32.0 : 30.0;
    final iconSize = selected ? 22.0 : 20.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppDesign.brandGradient,
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
      child: Icon(Icons.add_rounded, size: iconSize, color: Colors.white),
    );
  }

  Widget _profileNavAvatar(
    BuildContext context, {
    required Uint8List? avatarBytes,
    required String? avatarUrl,
    required String avatarLetter,
    required Color color,
    required bool selected,
  }) {
    final size = selected ? 28.0 : 26.0;
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
          errorBuilder: (context, error, stackTrace) => _profileNavAvatarLetter(
            avatarLetter: avatarLetter,
            color: color,
            selected: selected,
          ),
        ),
      );
    }

    return _profileNavAvatarLetter(
      avatarLetter: avatarLetter,
      color: color,
      selected: selected,
    );
  }

  Widget _profileNavAvatarLetter({
    required String avatarLetter,
    required Color color,
    required bool selected,
  }) {
    final size = selected ? 28.0 : 26.0;
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
          fontSize: selected ? 12 : 11,
        ),
      ),
    );
  }
}
