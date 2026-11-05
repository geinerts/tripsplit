import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/friend_user.dart';

class FriendAvatar extends StatelessWidget {
  const FriendAvatar({super.key, required this.user, this.size = 36});

  final FriendUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final name = user.preferredName.trim();
    final parts = (name.isEmpty ? context.l10n.friendsUser : name).split(
      RegExp(r'\s+'),
    );
    final initials = parts.length == 1
        ? parts.first.characters.first.toUpperCase()
        : '${parts.first.characters.first}${parts.last.characters.first}'
              .toUpperCase();
    final scheme = Theme.of(context).colorScheme;
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primaryContainer,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: size * .34,
          height: 1,
        ),
      ),
    );
    final url = (user.avatarThumbUrl ?? user.avatarUrl)?.trim();
    if (url == null || url.isEmpty) return fallback;
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        gaplessPlayback: true,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}
