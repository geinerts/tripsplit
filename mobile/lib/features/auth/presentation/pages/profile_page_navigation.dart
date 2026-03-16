part of 'profile_page.dart';

extension _ProfilePageNavigation on _ProfilePageState {
  Future<void> _onBottomNavTapped(int index) async {
    switch (index) {
      case 0:
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRouter.trips, (route) => false);
        return;
      case 1:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.trips,
          (route) => false,
          arguments: const {'open_create_trip': true},
        );
        return;
      case 2:
        _showSnack(context.l10n.friendsSectionComingSoon);
        return;
      case 3:
        return;
      default:
        return;
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    final t = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = (_user?.displayName ?? _user?.nickname ?? '').trim();
    final avatarLetter = displayName.isEmpty
        ? t.travelerFallbackName.substring(0, 1).toUpperCase()
        : displayName.substring(0, 1).toUpperCase();
    final avatarUrl = widget.controller.avatarUrlFor(
      _user,
      preferThumb: true,
    );

    return NavigationBar(
      selectedIndex: 3,
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
          icon: _navProfileAvatar(
            avatarBytes: _avatarBytes,
            avatarUrl: avatarUrl,
            avatarLetter: avatarLetter,
            color: colorScheme.onSurfaceVariant,
            selected: false,
          ),
          selectedIcon: _navProfileAvatar(
            avatarBytes: _avatarBytes,
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

  Widget _navProfileAvatar({
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
          errorBuilder: (context, error, stackTrace) => _navProfileAvatarLetter(
            avatarLetter: avatarLetter,
            color: color,
            selected: selected,
          ),
        ),
      );
    }
    return _navProfileAvatarLetter(
      avatarLetter: avatarLetter,
      color: color,
      selected: selected,
    );
  }

  Widget _navProfileAvatarLetter({
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
