part of 'workspace_page.dart';

enum _SyncState { syncing, online, onlineQueue, offline, offlineQueue }

class _SyncVisual {
  const _SyncVisual({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final Color border;
}

_SyncVisual _syncVisual(BuildContext context, _SyncState state) {
  final t = context.l10n;
  final colors = Theme.of(context).colorScheme;
  switch (state) {
    case _SyncState.syncing:
      return _SyncVisual(
        label: t.syncingStatus,
        icon: Icons.sync,
        foreground: colors.primary,
        background: colors.primaryContainer.withValues(alpha: 0.35),
        border: colors.primary.withValues(alpha: 0.35),
      );
    case _SyncState.online:
      return _SyncVisual(
        label: t.onlineStatus,
        icon: Icons.cloud_done_outlined,
        foreground: colors.primary,
        background: colors.primaryContainer.withValues(alpha: 0.28),
        border: colors.primary.withValues(alpha: 0.35),
      );
    case _SyncState.onlineQueue:
      return _SyncVisual(
        label: t.queuePendingStatus,
        icon: Icons.cloud_upload_outlined,
        foreground: colors.tertiary,
        background: colors.tertiaryContainer.withValues(alpha: 0.3),
        border: colors.tertiary.withValues(alpha: 0.35),
      );
    case _SyncState.offline:
      return _SyncVisual(
        label: t.offlineStatus,
        icon: Icons.cloud_off_outlined,
        foreground: colors.error,
        background: colors.errorContainer.withValues(alpha: 0.26),
        border: colors.error.withValues(alpha: 0.35),
      );
    case _SyncState.offlineQueue:
      return _SyncVisual(
        label: t.offlineQueueStatus,
        icon: Icons.cloud_off,
        foreground: colors.error,
        background: colors.errorContainer.withValues(alpha: 0.35),
        border: colors.error.withValues(alpha: 0.45),
      );
  }
}
