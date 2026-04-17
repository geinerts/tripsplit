part of 'workspace_page.dart';

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.snapshot,
    required this.currentUserId,
    required this.canEditMembers,
    required this.isBusy,
    required this.onOpenSettlements,
    required this.onOpenAddMembers,
  });

  final WorkspaceSnapshot snapshot;
  final int currentUserId;
  final bool canEditMembers;
  final bool isBusy;
  final VoidCallback onOpenSettlements;
  final VoidCallback onOpenAddMembers;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final currentBalance = _findCurrentUserBalance();
    final net = currentBalance?.net ?? 0;
    final paid = currentBalance?.paid ?? 0;
    final owed = currentBalance?.owed ?? 0;
    final actionState = _buildActionState(context);
    final recentNotifications = _recentNotifications();
    final netColor = net < 0 ? colors.error : colors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer.withValues(alpha: 0.24),
            colors.surface.withValues(alpha: 0.96),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OverviewSectionHeading(
            icon: Icons.account_balance_wallet_outlined,
            title: context.l10n.workspaceYourPosition,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: netColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: netColor.withValues(alpha: 0.32)),
                ),
                child: Text(
                  _signedMoney(
                    context,
                    net,
                    currencyCode: AppCurrencyCatalog.defaultCode,
                  ),
                  style: TextStyle(
                    color: netColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _positionMessage(context, net),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DetailChip(
                  icon: Icons.account_balance_wallet_outlined,
                  label: t.paidLabel,
                  value: _formatMoney(
                    context,
                    paid,
                    currencyCode: AppCurrencyCatalog.defaultCode,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DetailChip(
                  icon: Icons.payments_outlined,
                  label: t.owesLabel,
                  value: _formatMoney(
                    context,
                    owed,
                    currencyCode: AppCurrencyCatalog.defaultCode,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            color: colors.outlineVariant.withValues(alpha: 0.25),
            height: 1,
          ),
          const SizedBox(height: 12),
          _OverviewSectionHeading(
            icon: Icons.notifications_active_outlined,
            title: context.l10n.workspaceActionNeeded,
          ),
          const SizedBox(height: 8),
          Text(
            actionState.message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (actionState.ctaLabel != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: isBusy ? null : actionState.onTap,
                icon: Icon(actionState.ctaIcon),
                label: Text(actionState.ctaLabel!),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Divider(
            color: colors.outlineVariant.withValues(alpha: 0.25),
            height: 1,
          ),
          const SizedBox(height: 12),
          _OverviewSectionHeading(
            icon: Icons.history_outlined,
            title: context.l10n.workspaceRecentActivity,
          ),
          const SizedBox(height: 8),
          if (recentNotifications.isEmpty)
            Text(
              context.l10n.workspaceNoRecentActivityYet,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            for (var i = 0; i < recentNotifications.length; i++) ...[
              _OverviewActivityRow(
                icon: _notificationIcon(recentNotifications[i].type),
                title: _notificationTitle(context, recentNotifications[i]),
                subtitle: _relativeTime(
                  context,
                  recentNotifications[i].createdAt,
                ),
                unread: !recentNotifications[i].isRead,
              ),
              if (i < recentNotifications.length - 1) const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  BalanceItem? _findCurrentUserBalance() {
    if (currentUserId <= 0) {
      return null;
    }
    for (final item in snapshot.balances) {
      if (item.id == currentUserId) {
        return item;
      }
    }
    return null;
  }

  _OverviewActionState _buildActionState(BuildContext context) {
    final t = context.l10n;
    final markSentCount = snapshot.settlements
        .where((item) => item.canMarkSent)
        .length;
    final confirmReceivedCount = snapshot.settlements
        .where((item) => item.canConfirmReceived)
        .length;

    if (markSentCount + confirmReceivedCount > 0) {
      final message = context.l10n
          .workspacePaymentSToMarkAsSentToConfirmAsReceived(
            markSentCount,
            confirmReceivedCount,
          );
      return _OverviewActionState(
        message: message,
        ctaLabel: t.openSettlements,
        ctaIcon: Icons.payments_outlined,
        onTap: onOpenSettlements,
      );
    }

    if (snapshot.isActive) {
      if (canEditMembers && snapshot.users.length < 2) {
        return _OverviewActionState(
          message:
              context.l10n.workspaceAddAtLeastOneMemberToStartSplittingExpenses,
          ctaLabel: t.addMembersAction,
          ctaIcon: Icons.group_add_outlined,
          onTap: onOpenAddMembers,
        );
      }

      WorkspaceUser? currentUser;
      if (currentUserId > 0) {
        for (final user in snapshot.users) {
          if (user.id == currentUserId) {
            currentUser = user;
            break;
          }
        }
      }

      if (currentUser != null && !currentUser.isReadyToSettle) {
        return _OverviewActionState(
          message: context
              .l10n
              .workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses,
        );
      }

      if (!snapshot.allMembersReadyToSettle) {
        final waitingCount =
            (snapshot.readyToSettleMembersTotal -
                    snapshot.readyToSettleMembersReady)
                .clamp(0, snapshot.readyToSettleMembersTotal);
        return _OverviewActionState(
          message: context.l10n.workspaceWaitingForMemberSToMarkReady(
            waitingCount,
          ),
        );
      }

      if (canEditMembers) {
        return _OverviewActionState(
          message:
              context.l10n.workspaceAllMembersAreReadyYouCanFinishTheTripAnd,
        );
      }

      return _OverviewActionState(
        message:
            context.l10n.workspaceAllMembersAreReadyWaitingForTheTripOwnerTo,
      );
    }

    if (snapshot.isSettling && snapshot.settlementRemaining > 0) {
      return _OverviewActionState(
        message: context.l10n.workspaceSettlementInProgressConfirmed(
          snapshot.settlementConfirmed,
          snapshot.settlementTotal,
        ),
        ctaLabel: t.openSettlements,
        ctaIcon: Icons.open_in_new,
        onTap: onOpenSettlements,
      );
    }

    if (snapshot.isArchived || snapshot.allSettled) {
      return _OverviewActionState(
        message: context.l10n.workspaceNoActionsPendingThisTripIsSettled,
      );
    }

    return _OverviewActionState(
      message: context.l10n.workspaceNoActionsNeededRightNow,
    );
  }

  List<WorkspaceNotification> _recentNotifications() {
    final items = snapshot.notifications.toList(growable: false);
    items.sort((a, b) {
      final first = _tryParseDate(a.createdAt);
      final second = _tryParseDate(b.createdAt);
      return second.compareTo(first);
    });
    return items.take(3).toList(growable: false);
  }

  String _positionMessage(BuildContext context, double net) {
    final absolute = _formatMoney(
      context,
      net.abs(),
      currencyCode: AppCurrencyCatalog.defaultCode,
    );
    if (net > 0.004) {
      return context.l10n.workspaceYouShouldReceive(absolute);
    }
    if (net < -0.004) {
      return context.l10n.workspaceYouShouldPay(absolute);
    }
    return context.l10n.workspaceYouAreCurrentlySettledInThisTrip;
  }

  DateTime _tryParseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return parsed.toLocal();
  }

  String _relativeTime(BuildContext context, String? raw) {
    final moment = _tryParseDate(raw);
    if (moment.millisecondsSinceEpoch == 0) {
      return context.l10n.workspaceUnknownTime;
    }

    final now = DateTime.now();
    final diff = now.difference(moment);
    if (diff.inMinutes < 1) {
      return context.l10n.workspaceJustNow;
    }
    if (diff.inMinutes < 60) {
      return context.l10n.workspaceMinAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return context.l10n.workspaceHAgo(diff.inHours);
    }
    if (diff.inDays < 7) {
      return context.l10n.workspaceDAgo(diff.inDays);
    }

    final day = moment.day.toString().padLeft(2, '0');
    final month = moment.month.toString().padLeft(2, '0');
    final hour = moment.hour.toString().padLeft(2, '0');
    final minute = moment.minute.toString().padLeft(2, '0');
    return '$day.$month $hour:$minute';
  }

  IconData _notificationIcon(String type) {
    final normalized = type.trim().toLowerCase();
    if (normalized.contains('expense')) {
      return Icons.receipt_long_outlined;
    }
    if (normalized.contains('friend')) {
      return Icons.group_outlined;
    }
    if (normalized.contains('trip')) {
      return Icons.luggage_outlined;
    }
    if (normalized.contains('settlement') ||
        normalized.contains('payment') ||
        normalized.contains('ready')) {
      return Icons.payments_outlined;
    }
    return Icons.notifications_none;
  }

  String _notificationTitle(
    BuildContext context,
    WorkspaceNotification notification,
  ) {
    final localized = localizeWorkspaceNotification(context, notification);
    final title = localized.title.trim();
    return title.isEmpty ? context.l10n.notificationFallbackTitle : title;
  }
}

class _OverviewSectionHeading extends StatelessWidget {
  const _OverviewSectionHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _OverviewActivityRow extends StatelessWidget {
  const _OverviewActivityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.unread,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (unread)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ),
    );
  }
}

class _OverviewActionState {
  const _OverviewActionState({
    required this.message,
    this.ctaLabel,
    this.ctaIcon = Icons.open_in_new,
    this.onTap,
  });

  final String message;
  final String? ctaLabel;
  final IconData ctaIcon;
  final VoidCallback? onTap;
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceSectionCard extends StatelessWidget {
  const _WorkspaceSectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.accent,
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tone = accent ?? colors.primary;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: tone.withValues(alpha: 0.22)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tone.withValues(alpha: 0.12),
            colors.surface.withValues(alpha: 0.96),
          ],
        ),
      ),
      child: child,
    );
  }
}

class _SheetHeadlineCard extends StatelessWidget {
  const _SheetHeadlineCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.meta = const <Widget>[],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final List<Widget> meta;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = color ?? colors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.16),
            colors.surface.withValues(alpha: 0.98),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: meta),
          ],
        ],
      ),
    );
  }
}

class _SheetSectionTitle extends StatelessWidget {
  const _SheetSectionTitle({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}
