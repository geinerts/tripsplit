part of 'workspace_page.dart';

extension _WorkspacePageLayoutNavigation on _WorkspacePageState {
  Widget _buildAppBottomNavigationBar(BuildContext context) {
    final user = widget.authController.currentUser;
    final avatarBytes = widget.authController.avatarBytesFor(user);
    final avatarUrl = widget.authController.avatarUrlFor(
      user,
      preferThumb: true,
    );
    final displayName = (user?.displayName ?? user?.nickname ?? '').trim();
    final avatarLetter = displayName.isEmpty
        ? context.l10n.travelerFallbackName.substring(0, 1).toUpperCase()
        : displayName.substring(0, 1).toUpperCase();

    return AppBottomNavBar(
      selectedItem: null,
      avatarBytes: avatarBytes,
      avatarUrl: avatarUrl,
      avatarLetter: avatarLetter,
      onSelected: _onAppDestinationSelected,
    );
  }

  void _onAppDestinationSelected(AppBottomNavItem item) {
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
        unawaited(_onAddExpensePressed());
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
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.shell,
            (route) => false,
            arguments: const <String, Object>{'initial_tab': 4},
          ),
        );
        return;
    }
  }
}
