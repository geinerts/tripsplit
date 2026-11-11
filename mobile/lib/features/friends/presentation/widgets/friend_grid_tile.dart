import 'package:flutter/material.dart';

import '../../../../app/theme/app_design.dart';
import '../../domain/entities/friend_user.dart';
import 'friend_avatar.dart';

/// A friend in the Friends grid: a large avatar with the name under it, the
/// same layout as the member picker in the trip form, only bigger.
class FriendGridTile extends StatelessWidget {
  const FriendGridTile({
    super.key,
    required this.user,
    required this.name,
    required this.onTap,
    this.onLongPress,
    this.longPressHint,
  });

  static const double avatarSize = 72;
  static const double _gap = 8;
  static const double _verticalPadding = 8;
  static const int _maxNameLines = 2;

  final FriendUser user;
  final String name;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? longPressHint;

  /// Tile height for the grid, so two lines of the name fit at any text size.
  static double extent(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final fontSize = MediaQuery.textScalerOf(
      context,
    ).scale(style?.fontSize ?? 14);
    final lineHeight = fontSize * (style?.height ?? 1.35).clamp(1.2, 2.0);
    return avatarSize +
        _gap +
        lineHeight * _maxNameLines +
        _verticalPadding * 2 +
        4;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: name,
      onLongPressHint: onLongPress == null ? null : longPressHint,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: _verticalPadding,
          ),
          child: Column(
            children: [
              MediaQuery.withNoTextScaling(
                child: FriendAvatar(user: user, size: avatarSize),
              ),
              const SizedBox(height: _gap),
              Text(
                name,
                maxLines: _maxNameLines,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppDesign.titleColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
