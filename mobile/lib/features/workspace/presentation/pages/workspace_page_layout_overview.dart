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
    final unsettledAmount = snapshot.settlements
        .where((item) => !item.isConfirmed)
        .fold<double>(0, (sum, item) => sum + item.amount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          _buildTripHeroCard(
            context,
            snapshot: snapshot,
            totalAmount: totalAmount,
          ),
          const SizedBox(height: 10),
          _buildQuickStatsRow(
            context,
            totalAmount: totalAmount,
            yourShare: yourShare,
            unsettledAmount: unsettledAmount,
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
  }) {
    final t = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coverUrl = (widget.trip.imageThumbUrl ?? widget.trip.imageUrl ?? '')
        .trim();
    final hasCover = coverUrl.isNotEmpty;
    final title = widget.trip.name.trim().isEmpty
        ? t.tripWithId(widget.trip.id)
        : widget.trip.name.trim();

    final glassBgColor = isDark
        ? Colors.black.withValues(alpha: 0.34)
        : Colors.white.withValues(alpha: 0.86);
    final glassBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.20)
        : Colors.white.withValues(alpha: 0.74);
    final glassTitle = isDark ? Colors.white : _splytoFg;
    final statusText = snapshot.isArchived
        ? t.archivedStatus
        : (snapshot.isSettling
              ? t.settlingStatus
              : (snapshot.allSettled ? t.settledStatus : t.activeStatus));

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
                    ? const [Color(0xFF1A2E2A), Color(0xFF0E1D18)]
                    : const [Color(0xFF2D7A5E), Color(0xFF215A45)],
              ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
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
                              Colors.black.withValues(alpha: 0.18),
                              Colors.black.withValues(
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
                            ? const [Color(0xFF1A2E2A), Color(0xFF0E1D18)]
                            : const [Color(0xFF2D7A5E), Color(0xFF215A45)],
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
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: _splytoAccent.withValues(alpha: 0.92),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.24),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        snapshot.isArchived
                            ? Icons.archive_outlined
                            : (snapshot.isSettling
                                  ? Icons.payments_outlined
                                  : Icons.play_circle_outline),
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.1,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Align(
                      alignment: Alignment.topRight,
                      child: _buildTripHeroMemberStack(snapshot.users),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(
                        height: 1,
                        color: glassBorderColor,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _formatMoney(context, totalAmount),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: glassTitle,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripHeroMemberStack(List<WorkspaceUser> users) {
    if (users.isEmpty) {
      return const SizedBox.shrink();
    }
    final visible = users.take(4).toList(growable: false);
    final extraCount = users.length - visible.length;
    final itemCount = visible.length + (extraCount > 0 ? 1 : 0);
    const avatarSize = 36.0;
    const step = 28.0;
    const stroke = 2.0;

    return SizedBox(
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
                  border: Border.all(color: Colors.white, width: stroke),
                ),
                child: _largeMemberAvatar(
                  id: visible[i].id,
                  name: visible[i].preferredName,
                  avatarUrl: visible[i].avatarThumbUrl ?? visible[i].avatarUrl,
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
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(color: Colors.white, width: stroke),
                ),
                child: Text(
                  '+$extraCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow(
    BuildContext context, {
    required double totalAmount,
    required double yourShare,
    required double unsettledAmount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? Theme.of(context).colorScheme.surface
        : _splytoCard;

    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            context,
            icon: Icons.account_balance_wallet_outlined,
            label: _localizedText(
              context,
              en: 'Total cost',
              lv: 'Kopējās izmaksas',
            ),
            value: _formatMoney(context, totalAmount),
            iconColor: _splytoPrimary,
            cardColor: cardColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickStatCard(
            context,
            icon: Icons.credit_card_outlined,
            label: _localizedText(context, en: 'Your share', lv: 'Tava daļa'),
            value: _formatMoney(context, yourShare),
            iconColor: _splytoAccent,
            cardColor: cardColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickStatCard(
            context,
            icon: Icons.arrow_forward_rounded,
            label: _localizedText(context, en: 'Unsettled', lv: 'Atlikums'),
            value: _formatMoney(context, unsettledAmount),
            iconColor: _splytoDestructive,
            cardColor: cardColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color cardColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelText = label.toUpperCase();
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.30)
              : _splytoStroke,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(height: 9),
          Text(
            labelText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isDark
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : _splytoMuted,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark ? null : _splytoFg,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _heroDateLabel(BuildContext context, WorkspaceSnapshot snapshot) {
    final created = _parseIsoDate(widget.trip.createdAt);
    final ended = _parseIsoDate(widget.trip.endedAt ?? snapshot.tripEndedAt);
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
