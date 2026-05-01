part of 'workspace_page.dart';

extension _WorkspacePageLayoutOverview on _WorkspacePageState {
  Widget _buildOverviewPanel(BuildContext context, WorkspaceSnapshot snapshot) {
    final totalAmount = snapshot.expenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    BalanceItem? currentBalance;
    for (final item in snapshot.balances) {
      if (item.id == _currentUserId) {
        currentBalance = item;
        break;
      }
    }
    final yourShare = currentBalance?.owed ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          _buildTripHeroCard(
            context,
            snapshot: snapshot,
            totalAmount: totalAmount,
            yourShare: yourShare,
            currentBalance: currentBalance,
          ),
          if (!snapshot.isActive) ...[
            const SizedBox(height: 8),
            _buildClosedTripBanner(context, snapshot, padding: EdgeInsets.zero),
          ],
          if (_queuedMutations.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildQueuedChangesCard(context, padding: EdgeInsets.zero),
          ],
        ],
      ),
    );
  }

  Widget _buildTripHeroCard(
    BuildContext context, {
    required WorkspaceSnapshot snapshot,
    required double totalAmount,
    required double yourShare,
    required BalanceItem? currentBalance,
  }) {
    final t = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.light;
    final statusText = snapshot.isArchived
        ? t.archivedStatus
        : (snapshot.isSettling
              ? t.settlingStatus
              : (snapshot.allSettled ? t.settledStatus : t.activeStatus));
    final isSettledState = snapshot.isArchived || snapshot.allSettled;
    final statusChipForeground = snapshot.isSettling
        ? semantic.statusSettlingForeground
        : (isSettledState
              ? semantic.statusSettledForeground
              : semantic.statusActiveForeground);
    final coverUrl = (widget.trip.imageThumbUrl ?? widget.trip.imageUrl ?? '')
        .trim();
    final hasCoverImage = coverUrl.isNotEmpty;

    final currentNet = currentBalance?.net ?? 0;
    final showsNegative = currentNet < -0.004;
    final netValue = _formatMoney(
      context,
      currentNet.abs(),
      currencyCode: widget.trip.currencyCode,
    );
    final netAccent = showsNegative
        ? AppDesign.lightDestructive
        : statusChipForeground;
    final shareRatio = totalAmount <= 0
        ? 0.0
        : (yourShare / totalAmount).clamp(0.0, 1.0).toDouble();

    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: semantic.heroGlassBorder.withValues(
            alpha: isDark ? 0.48 : 0.58,
          ),
          width: 1.2,
        ),
        color: AppDesign.darkCanvas.withValues(alpha: isDark ? 0.30 : 0.42),
        boxShadow: AppDesign.heroShadow(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (hasCoverImage)
            Positioned.fill(
              child: Image.network(
                coverUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.expand(),
              ),
            )
          else
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: const SizedBox.expand(),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: hasCoverImage
                      ? [
                          Colors.black.withValues(alpha: 0.72),
                          AppDesign.darkPrimary.withValues(alpha: 0.46),
                          Colors.black.withValues(alpha: 0.18),
                        ]
                      : [
                          Colors.white.withValues(alpha: isDark ? 0.045 : 0.12),
                          AppDesign.darkPrimary.withValues(
                            alpha: isDark ? 0.055 : 0.08,
                          ),
                          Colors.black.withValues(alpha: isDark ? 0.10 : 0.16),
                        ],
                  stops: const [0, 0.52, 1],
                ),
              ),
            ),
          ),
          if (hasCoverImage)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.26),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.50),
                    ],
                    stops: const [0, 0.48, 1],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildHeroStatusPill(
                        context,
                        statusText: statusText,
                        statusColor: statusChipForeground,
                      ),
                    ),
                    const SizedBox(width: 28),
                    _buildTripHeroMemberStack(snapshot.users),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'NET BALANCE',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: semantic.heroAvatarStroke.withValues(alpha: 0.66),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 5),
                _buildHeroNetBalanceAmount(
                  context,
                  value: netValue,
                  accentColor: netAccent,
                ),
                const SizedBox(height: 22),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: shareRatio,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.11),
                    valueColor: AlwaysStoppedAnimation<Color>(netAccent),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildHeroFooterAmount(
                        context,
                        label: context.l10n.yourShare,
                        value: _formatMoney(
                          context,
                          yourShare,
                          currencyCode: widget.trip.currencyCode,
                        ),
                        alignEnd: false,
                      ),
                    ),
                    Expanded(
                      child: _buildHeroFooterAmount(
                        context,
                        label: context.l10n.workspaceTotalCost,
                        value: _formatMoney(
                          context,
                          totalAmount,
                          currencyCode: widget.trip.currencyCode,
                        ),
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatusPill(
    BuildContext context, {
    required String statusText,
    required Color statusColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.72),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const SizedBox(width: 9, height: 9),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            statusText.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroNetBalanceAmount(
    BuildContext context, {
    required String value,
    required Color accentColor,
  }) {
    final match = RegExp(r'^([^\d\-+]*)([\d\s,.]+)(.*)$').firstMatch(value);
    final symbol = (match?.group(1) ?? '').trim();
    final amount = (match?.group(2) ?? value).trim();
    final suffix = (match?.group(3) ?? '').trim();
    final amountParts = amount.split(RegExp(r'(?=[,.])'));
    final mainAmount = amountParts.isEmpty ? amount : amountParts.first;
    final cents = amountParts.length > 1 ? amountParts.sublist(1).join() : '';
    const mainFontSize = 56.0;
    const sideFontSize = 32.0;
    const sideLineHeight = 1.0;
    const mainLineHeight = 1.0;
    const symbolTopOffset = mainFontSize * 0.10;
    const centsTopOffset = mainFontSize - sideFontSize;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (symbol.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: symbolTopOffset),
              child: Text(
                symbol,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: accentColor,
                  fontSize: sideFontSize,
                  fontWeight: FontWeight.w900,
                  height: sideLineHeight,
                  letterSpacing: -1.5,
                ),
              ),
            ),
          Text(
            mainAmount,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppDesign.darkForeground,
              fontSize: mainFontSize,
              fontWeight: FontWeight.w900,
              height: mainLineHeight,
              letterSpacing: -3.4,
            ),
          ),
          if (cents.isNotEmpty || suffix.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: centsTopOffset),
              child: Text(
                '$cents$suffix',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppDesign.darkMuted,
                  fontSize: sideFontSize,
                  fontWeight: FontWeight.w900,
                  height: sideLineHeight,
                  letterSpacing: -1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroFooterAmount(
    BuildContext context, {
    required String label,
    required String value,
    required bool alignEnd,
  }) {
    final textAlign = alignEnd ? TextAlign.right : TextAlign.left;
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      text: TextSpan(
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppDesign.darkMuted,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: AppDesign.darkForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripHeroMemberStack(List<WorkspaceUser> users) {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.light;
    if (users.isEmpty) {
      return const SizedBox.shrink();
    }
    final visible = users.take(4).toList(growable: false);
    final extraCount = users.length - visible.length;
    final itemCount = visible.length + (extraCount > 0 ? 1 : 0);
    const avatarSize = 36.0;
    const step = 28.0;
    const stroke = 2.0;

    return GestureDetector(
      onTap: () => _openTripMembersListSheet(users),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: avatarSize + 4,
        width: (itemCount * step) + (avatarSize - step) + 2,
        child: Stack(
          children: [
            for (var i = 0; i < visible.length; i++)
              Positioned(
                left: i * step,
                top: 2,
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: semantic.heroAvatarStroke,
                      width: stroke,
                    ),
                  ),
                  child: _largeMemberAvatar(
                    id: visible[i].id,
                    name: visible[i].preferredName,
                    avatarUrl:
                        visible[i].avatarThumbUrl ?? visible[i].avatarUrl,
                    size: avatarSize,
                  ),
                ),
              ),
            if (extraCount > 0)
              Positioned(
                left: visible.length * step,
                top: 2,
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: semantic.heroAvatarOverflowBackground,
                    border: Border.all(
                      color: semantic.heroAvatarStroke,
                      width: stroke,
                    ),
                  ),
                  child: Text(
                    '+$extraCount',
                    style: TextStyle(
                      color: semantic.heroAvatarStroke,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClosedTripBanner(
    BuildContext context,
    WorkspaceSnapshot snapshot, {
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(12, 0, 12, 8),
  }) {
    return Padding(
      padding: padding,
      child: Card(
        color: snapshot.isArchived
            ? Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.4)
            : Theme.of(
                context,
              ).colorScheme.tertiaryContainer.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            snapshot.isArchived
                ? context.l10n.tripArchivedReadOnly
                : context.l10n.tripFinishedCompleteSettlements,
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusBadge(BuildContext context) {
    final visual = _syncVisual(context, _syncState);
    final label = _syncStatusLabel(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: _isMutating ? null : _onRefreshPressed,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 178),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: visual.background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: visual.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(visual.icon, size: 14, color: visual.foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: visual.foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_syncState != _SyncState.online || _pendingQueueCount > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 14,
                    color: visual.foreground.withValues(alpha: 0.80),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _syncStatusLabel(BuildContext context) {
    if (_pendingQueueCount > 0) {
      return context.l10n.syncChangesWaiting(_pendingQueueCount);
    }
    switch (_syncState) {
      case _SyncState.syncing:
        return context.l10n.syncingStatus;
      case _SyncState.online:
        return context.l10n.syncAllSynced;
      case _SyncState.onlineQueue:
        return context.l10n.syncAllSynced;
      case _SyncState.offline:
        return context.l10n.syncFailedTapToRetry;
      case _SyncState.offlineQueue:
        return context.l10n.syncFailedTapToRetry;
    }
  }

  Widget _buildQueuedChangesCard(
    BuildContext context, {
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(12, 0, 12, 8),
  }) {
    final preview = _queuedMutations.take(3).toList(growable: false);
    return Padding(
      padding: padding,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.queuedChangesTitle(_queuedMutations.length),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              for (var i = 0; i < preview.length; i++) ...[
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  minLeadingWidth: 20,
                  leading: Icon(_queuedMutationIcon(preview[i].type), size: 18),
                  title: Text(_queuedMutationTitle(preview[i])),
                  subtitle: Text(
                    '${_queuedMutationSubtitle(preview[i])} • ${_formatQueueTimestamp(preview[i].createdAtMillis)}',
                  ),
                ),
                if (i < preview.length - 1) const Divider(height: 1),
              ],
              if (_queuedMutations.length > preview.length) ...[
                const SizedBox(height: 4),
                Text(
                  context.l10n.moreCount(
                    _queuedMutations.length - preview.length,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewMetaPill extends StatelessWidget {
  const _OverviewMetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bg = color.withValues(alpha: 0.12);
    final fg = color;
    final border = color.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
