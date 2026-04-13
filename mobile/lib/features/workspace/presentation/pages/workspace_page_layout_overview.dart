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
          if (_pendingQueueCount > 0) ...[
            const SizedBox(height: 8),
            _buildOfflineQueueBanner(context, padding: EdgeInsets.zero),
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
    final coverUrl = (widget.trip.imageThumbUrl ?? widget.trip.imageUrl ?? '')
        .trim();
    final hasCover = coverUrl.isNotEmpty;
    final title = widget.trip.name.trim().isEmpty
        ? t.tripWithId(widget.trip.id)
        : widget.trip.name.trim();

    final glassBgColor = semantic.heroGlassBackground;
    final glassBorderColor = semantic.heroGlassBorder;
    final glassTitle = AppDesign.titleColor(context);
    final statusIcon = snapshot.isArchived
        ? Icons.archive_outlined
        : (snapshot.isSettling
              ? Icons.payments_outlined
              : Icons.play_circle_outline);
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
    final statusChipBackground = snapshot.isSettling
        ? semantic.statusSettlingBackground
        : (isSettledState
              ? semantic.statusSettledBackground
              : semantic.statusActiveBackground);
    final statusChipBorder = snapshot.isSettling
        ? semantic.statusSettlingBorder
        : (isSettledState
              ? semantic.statusSettledBorder
              : semantic.statusActiveBorder);

    final currentNet = currentBalance?.net ?? 0;
    final showsPositive = currentNet > 0.004;
    final showsNegative = currentNet < -0.004;
    final primaryLabel = isSettledState
        ? _localizedText(context, en: 'Settled', lv: 'Norēķināts')
        : (showsNegative
              ? _localizedText(context, en: 'You owe', lv: 'Tu esi parādā')
              : (showsPositive
                    ? _localizedText(
                        context,
                        en: 'They owe you',
                        lv: 'Tev ir parādā',
                      )
                    : _localizedText(
                        context,
                        en: 'Settled',
                        lv: 'Norēķināts',
                      )));
    final primaryValue = _formatMoney(
      context,
      currentNet.abs(),
      currencyCode: widget.trip.currencyCode,
    );
    final primaryIcon = isSettledState
        ? Icons.check_circle_outline
        : (showsNegative
              ? Icons.arrow_upward_rounded
              : (showsPositive
                    ? Icons.arrow_downward_rounded
                    : Icons.check_circle_outline));
    final primaryIconColor = isSettledState
        ? AppDesign.lightPrimary
        : (showsNegative
              ? AppDesign.lightDestructive
              : (showsPositive
                    ? AppDesign.lightPrimary
                    : AppDesign.lightPrimary));

    return Container(
      width: double.infinity,
      height: 244,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: hasCover
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        AppDesign.darkPrimaryContainer,
                        AppDesign.darkSurface,
                      ]
                    : const [
                        AppDesign.lightPrimary,
                        AppDesign.lightPrimaryDeep,
                      ],
              ),
        boxShadow: AppDesign.heroShadow(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (hasCover)
            Positioned.fill(
              child: Image.network(
                coverUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                gaplessPlayback: true,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      child,
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppDesign.darkCanvas.withValues(alpha: 0.18),
                              AppDesign.darkCanvas.withValues(
                                alpha: isDark ? 0.52 : 0.40,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? const [
                                AppDesign.darkPrimaryContainer,
                                AppDesign.darkSurface,
                              ]
                            : const [
                                AppDesign.lightPrimary,
                                AppDesign.lightPrimaryDeep,
                              ],
                      ),
                    ),
                  );
                },
              ),
            ),
          Positioned(
            right: -26,
            top: -24,
            child: Container(
              width: 106,
              height: 106,
              decoration: BoxDecoration(
                color: semantic.heroAvatarOverflowBackground.withValues(
                  alpha: 0.30,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: semantic.heroAvatarStroke,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.1,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildTripHeroMemberStack(snapshot.users),
                ),
                const SizedBox(height: 8),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: glassBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: glassBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 15,
                            color: glassTitle.withValues(alpha: 0.90),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _heroDateLabel(context, snapshot),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: glassTitle,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 148),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: statusChipBackground,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: statusChipBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    size: 13,
                                    color: statusChipForeground,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      statusText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: statusChipForeground,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(height: 1, color: glassBorderColor),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildHeroStatItem(
                              context,
                              icon: Icons.account_balance_wallet_outlined,
                              label: _localizedText(
                                context,
                                en: 'Total cost',
                                lv: 'Kopējās izmaksas',
                              ),
                              value: _formatMoney(
                                context,
                                totalAmount,
                                currencyCode: widget.trip.currencyCode,
                              ),
                              iconColor: AppDesign.lightPrimary,
                              textColor: glassTitle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildHeroStatItem(
                              context,
                              icon: Icons.credit_card_outlined,
                              label: _localizedText(
                                context,
                                en: 'Your share',
                                lv: 'Tava daļa',
                              ),
                              value: _formatMoney(
                                context,
                                yourShare,
                                currencyCode: widget.trip.currencyCode,
                              ),
                              iconColor: AppDesign.lightAccent,
                              textColor: glassTitle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildHeroStatItem(
                              context,
                              icon: primaryIcon,
                              label: primaryLabel,
                              value: primaryValue,
                              iconColor: primaryIconColor,
                              textColor: glassTitle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isCurrentTripOwner())
            Positioned(
              right: 12,
              top: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: semantic.heroMenuBackground,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _openTripActionsSheet,
                  icon: const Icon(Icons.more_vert),
                  color: semantic.heroAvatarStroke,
                  visualDensity: VisualDensity.compact,
                  tooltip: context.l10n.settings,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.25,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.15,
          ),
        ),
      ],
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

  String _heroDateLabel(BuildContext context, WorkspaceSnapshot snapshot) {
    final created = _parseIsoDate(
      widget.trip.dateFrom ?? widget.trip.createdAt,
    );
    final ended = _parseIsoDate(
      widget.trip.dateTo ?? widget.trip.endedAt ?? snapshot.tripEndedAt,
    );
    if (created != null && ended != null) {
      return '${_formatHeroDay(created)} - ${_formatHeroDay(ended)}';
    }
    if (created != null) {
      return _localizedText(
        context,
        en: 'Started ${_formatHeroDay(created)}',
        lv: 'Sākts ${_formatHeroDay(created)}',
      );
    }
    if (ended != null) {
      return _localizedText(
        context,
        en: 'Ended ${_formatHeroDay(ended)}',
        lv: 'Noslēgts ${_formatHeroDay(ended)}',
      );
    }
    if (snapshot.isSettling) {
      return _localizedText(
        context,
        en: 'Settlement in progress',
        lv: 'Norēķini procesā',
      );
    }
    if (snapshot.isArchived) {
      return _localizedText(
        context,
        en: 'Archived trip',
        lv: 'Arhivēts ceļojums',
      );
    }
    return _localizedText(context, en: 'Active trip', lv: 'Aktīvs ceļojums');
  }

  DateTime? _parseIsoDate(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(raw);
    return parsed?.toLocal();
  }

  String _formatHeroDay(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd.$mm';
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

  Widget _buildOfflineQueueBanner(
    BuildContext context, {
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(12, 0, 12, 8),
  }) {
    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.tertiaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          context.l10n.offlineQueuePendingChanges(_pendingQueueCount),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
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
