import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';
import '../l10n/l10n.dart';

enum AppBottomNavItem { home, analytics, expenses, friends, profile }

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedItem,
    required this.onSelected,
    required this.avatarLetter,
    this.avatarBytes,
    this.avatarUrl,
  });

  final AppBottomNavItem? selectedItem;
  final ValueChanged<AppBottomNavItem> onSelected;
  final Uint8List? avatarBytes;
  final String? avatarUrl;
  final String avatarLetter;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final neutralSelection = selectedItem == null;
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700);

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: neutralSelection ? Colors.transparent : null,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (neutralSelection) {
            return labelStyle?.copyWith(color: colorScheme.onSurfaceVariant);
          }
          if (states.contains(WidgetState.selected)) {
            return labelStyle?.copyWith(color: colorScheme.onPrimaryContainer);
          }
          return labelStyle?.copyWith(color: colorScheme.onSurfaceVariant);
        }),
      ),
      child: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: selectedItem?.index ?? AppBottomNavItem.home.index,
        onDestinationSelected: (index) =>
            onSelected(AppBottomNavItem.values[index]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined, size: 26),
            selectedIcon: neutralSelection
                ? const Icon(Icons.home_outlined, size: 26)
                : const Icon(Icons.home, size: 26),
            label: t.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.query_stats_outlined, size: 26),
            selectedIcon: const Icon(Icons.query_stats, size: 26),
            label: t.navActivities,
          ),
          NavigationDestination(
            icon: _buildExpensesNavIcon(selected: false),
            selectedIcon: _buildExpensesNavIcon(selected: true),
            label: t.navExpenses,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline, size: 26),
            selectedIcon: const Icon(Icons.people, size: 26),
            label: t.navFriends,
          ),
          NavigationDestination(
            icon: _profileNavAvatar(
              context,
              avatarBytes: avatarBytes,
              avatarUrl: avatarUrl,
              avatarLetter: avatarLetter,
              color: colorScheme.onSurfaceVariant,
            ),
            selectedIcon: _profileNavAvatar(
              context,
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

  Widget _buildExpensesNavIcon({required bool selected}) {
    const width = 70.0;
    const height = 36.0;
    const iconSize = 20.0;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppDesign.logoBackgroundGradient,
        border: Border.all(
          color: Colors.white.withValues(alpha: selected ? 0.55 : 0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x66141E30),
            blurRadius: selected ? 14 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.add_rounded, size: iconSize, color: Colors.white),
    );
  }

  Widget _profileNavAvatar(
    BuildContext context, {
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
