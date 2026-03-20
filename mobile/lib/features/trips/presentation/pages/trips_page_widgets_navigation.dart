part of 'trips_page.dart';

extension _TripsPageNavigationWidgets on _TripsPageState {
  Widget _buildBottomNav(BuildContext context) {
    final user = widget.authController.currentUser;
    final avatarBytes = widget.authController.avatarBytesFor(user);
    final avatarUrl = widget.authController.avatarUrlFor(
      user,
      preferThumb: true,
    );
    final nickname = user?.nickname.trim();
    final avatarLetter = (nickname == null || nickname.isEmpty)
        ? context.l10n.travelerFallbackName.substring(0, 1).toUpperCase()
        : nickname.substring(0, 1).toUpperCase();

    return AppBottomNavBar(
      selectedItem: AppBottomNavItem.home,
      avatarBytes: avatarBytes,
      avatarUrl: avatarUrl,
      avatarLetter: avatarLetter,
      onSelected: _onBottomNavTapped,
    );
  }
}
