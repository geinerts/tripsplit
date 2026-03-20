part of 'profile_page.dart';

extension _ProfilePageNavigation on _ProfilePageState {
  void _onBottomNavTapped(AppBottomNavItem item) {
    switch (item) {
      case AppBottomNavItem.home:
        unawaited(
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRouter.shell, (route) => false),
        );
        return;
      case AppBottomNavItem.analytics:
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.shell,
            (route) => false,
            arguments: const <String, Object>{'initial_tab': 1},
          ),
        );
        return;
      case AppBottomNavItem.expenses:
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.shell,
            (route) => false,
            arguments: const <String, Object>{'open_add_expense': true},
          ),
        );
        return;
      case AppBottomNavItem.friends:
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.shell,
            (route) => false,
            arguments: const <String, Object>{'initial_tab': 3},
          ),
        );
        return;
      case AppBottomNavItem.profile:
        return;
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    final displayName = (_user?.displayName ?? _user?.nickname ?? '').trim();
    final avatarLetter = displayName.isEmpty
        ? context.l10n.travelerFallbackName.substring(0, 1).toUpperCase()
        : displayName.substring(0, 1).toUpperCase();
    final avatarUrl = widget.controller.avatarUrlFor(_user, preferThumb: true);

    return AppBottomNavBar(
      selectedItem: AppBottomNavItem.profile,
      avatarBytes: _avatarBytes,
      avatarUrl: avatarUrl,
      avatarLetter: avatarLetter,
      onSelected: _onBottomNavTapped,
    );
  }
}
