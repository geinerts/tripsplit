part of 'workspace_page.dart';

extension _WorkspacePageBalancesTab on _WorkspacePageState {
  Widget _buildBalancesTab(WorkspaceSnapshot snapshot) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    final usersById = <int, WorkspaceUser>{
      for (final user in snapshot.users) user.id: user,
    };
    final balances = snapshot.balances.toList(growable: false)
      ..sort((a, b) => b.net.abs().compareTo(a.net.abs()));
    const previewBalanceCount = 4;
    final hasBalanceOverflow = balances.length > previewBalanceCount;
    final visibleBalances = _showAllBalances
        ? balances
        : balances.take(previewBalanceCount).toList(growable: false);
    final maxAbsNet = visibleBalances.fold<double>(
      1,
      (maxValue, item) => math.max(maxValue, item.net.abs()),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      children: [
        if (visibleBalances.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(t.noBalancesYet),
            ),
          )
        else
          ...visibleBalances.map((item) {
            final netColor = item.net < 0 ? _splytoDestructive : _splytoSuccess;
            final member = usersById[item.id];
            final preferredName = (member?.preferredName ?? item.nickname)
                .trim();
            final displayName = preferredName.isEmpty
                ? t.userWithId(item.id)
                : preferredName;
            final nickname = (member?.nickname ?? item.nickname).trim();
            final showNicknameSecondary =
                nickname.isNotEmpty &&
                displayName.toLowerCase() != nickname.toLowerCase();
            final differenceRatio = (item.net.abs() / maxAbsNet)
                .clamp(0.0, 1.0)
                .toDouble();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: isDark ? colors.surface : _splytoCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark
                        ? colors.outlineVariant.withValues(alpha: 0.32)
                        : _splytoStroke,
                  ),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
                child: _SplytoPressScale(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () =>
                      _openBalanceDetails(snapshot: snapshot, item: item),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _largeMemberAvatar(
                              id: item.id,
                              name: displayName,
                              avatarUrl:
                                  member?.avatarThumbUrl ?? member?.avatarUrl,
                              size: 62,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? null : _splytoFg,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (showNicknameSecondary)
                                    Text(
                                      nickname,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isDark
                                                ? colors.onSurfaceVariant
                                                : _splytoMuted,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.net < 0
                                        ? _localizedText(
                                            context,
                                            en: 'Owes to the group',
                                            lv: 'Parādā grupai',
                                          )
                                        : _localizedText(
                                            context,
                                            en: 'Gets back from group',
                                            lv: 'Jāsaņem no grupas',
                                          ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontSize: 15,
                                          color: isDark
                                              ? colors.onSurfaceVariant
                                              : _splytoMuted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _signedMoney(
                                context,
                                item.net,
                                currencyCode: widget.trip.currencyCode,
                              ),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 20,
                                    color: netColor,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            height: 10,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: isDark
                                        ? colors.surfaceContainerHighest
                                              .withValues(alpha: 0.45)
                                        : const Color(0xFFE8E2D9),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: differenceRatio,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: netColor,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        if (hasBalanceOverflow && !_showAllBalances)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _localizedText(
                context,
                en: 'Showing top 4 by balance difference.',
                lv: 'Parādīti 4 lielākie bilances ieraksti.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildSettleTab(WorkspaceSnapshot snapshot) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settlements = snapshot.settlements.toList(growable: false)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final usersById = <int, WorkspaceUser>{
      for (final user in snapshot.users) user.id: user,
    };
    final totalMembers = snapshot.readyToSettleMembersTotal;
    final readyMembers = snapshot.readyToSettleMembersReady;
    final allMembersReady = snapshot.allMembersReadyToSettle;
    final canFinishTrip =
        snapshot.isActive && _canEditMembers && !_isMutating && allMembersReady;
    WorkspaceUser? currentUser;
    for (final user in snapshot.users) {
      if (user.id == _currentUserId) {
        currentUser = user;
        break;
      }
    }
    final isCurrentUserReady = currentUser?.isReadyToSettle ?? false;
    final canToggleReady =
        snapshot.isActive && !_isMutating && _currentUserId > 0;
    final pendingSettlements = settlements
        .where((item) => !item.isConfirmed)
        .toList(growable: false);
    final paidSettlements = settlements
        .where((item) => item.isConfirmed)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 22),
      children: [
        if (snapshot.isActive) ...[
          _buildFinishTripActionBlock(
            colors: colors,
            canFinishTrip: canFinishTrip,
            allMembersReady: allMembersReady,
            readyMembers: readyMembers,
            totalMembers: totalMembers,
            isCurrentUserReady: isCurrentUserReady,
            canToggleReady: canToggleReady,
            finishLabel: context.l10n.finishTripStartSettlementsAction,
            creatorMustFinishLabel: context.l10n.creatorMustFinishTripFirst,
          ),
          const SizedBox(height: 12),
        ],
        if (settlements.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.noSettlements),
            ),
          )
        else ...[
          if (pendingSettlements.isNotEmpty) ...[
            _buildSettlementSectionLabel(
              _localizedText(context, en: 'Pending', lv: 'Gaida'),
            ),
            const SizedBox(height: 8),
            ...pendingSettlements.map(
              (item) => _buildSettlementFlowCard(
                snapshot: snapshot,
                item: item,
                usersById: usersById,
                colors: colors,
                isDark: isDark,
              ),
            ),
          ],
          if (paidSettlements.isNotEmpty) ...[
            if (pendingSettlements.isNotEmpty) const SizedBox(height: 8),
            _buildSettlementSectionLabel(
              _localizedText(context, en: 'Paid', lv: 'Apmaksāts'),
            ),
            const SizedBox(height: 8),
            ...paidSettlements.map(
              (item) => _buildSettlementFlowCard(
                snapshot: snapshot,
                item: item,
                usersById: usersById,
                colors: colors,
                isDark: isDark,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSettlementSectionLabel(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: isDark ? Theme.of(context).colorScheme.primary : _splytoMuted,
        ),
      ),
    );
  }

  Widget _buildSettlementFlowCard({
    required WorkspaceSnapshot snapshot,
    required SettlementItem item,
    required Map<int, WorkspaceUser> usersById,
    required ColorScheme colors,
    required bool isDark,
  }) {
    final fromUser = usersById[item.fromUserId];
    final toUser = usersById[item.toUserId];
    final isPositiveForCurrent =
        _currentUserId > 0 && item.toUserId == _currentUserId;
    final amountColor = isDark
        ? colors.onSurface
        : (isPositiveForCurrent ? _splytoSuccess : _splytoPrimary);
    final actionLabel = item.canConfirmReceived
        ? context.l10n.confirmReceivedAction
        : context.l10n.settleUpAction;
    final canPrimaryAction = item.canMarkSent || item.canConfirmReceived;

    final normalizedStatus = item.status.trim().toLowerCase();
    final isCompleted = normalizedStatus == 'confirmed';
    final statusColor = isCompleted
        ? _splytoSuccess
        : (normalizedStatus == 'sent' ? _splytoMuted : _splytoAccent);
    final statusLabel = isCompleted
        ? context.l10n.settledStatus
        : (normalizedStatus == 'sent'
              ? _localizedText(context, en: 'Sent', lv: 'Nosūtīts')
              : _localizedText(context, en: 'Pending', lv: 'Gaida'));

    final fromRole = item.fromUserId == _currentUserId
        ? _localizedText(context, en: 'You', lv: 'Tu')
        : _localizedText(context, en: 'Friend', lv: 'Draugs');
    final toRole = item.toUserId == _currentUserId
        ? _localizedText(context, en: 'You', lv: 'Tu')
        : _localizedText(context, en: 'Friend', lv: 'Draugs');
    final detailTitle = _localizedText(
      context,
      en: 'Settlement transfer',
      lv: 'Norēķina pārskaitījums',
    );
    final detailSubtitle = isCompleted
        ? _localizedText(context, en: 'Completed', lv: 'Pabeigts')
        : (normalizedStatus == 'sent'
              ? _localizedText(
                  context,
                  en: 'Waiting for confirmation',
                  lv: 'Gaida apstiprinājumu',
                )
              : _localizedText(
                  context,
                  en: 'Waiting for payment',
                  lv: 'Gaida maksājumu',
                ));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: isDark ? colors.surface : _splytoCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark
                ? colors.outlineVariant.withValues(alpha: 0.32)
                : _splytoStroke,
          ),
        ),
        child: _SplytoPressScale(
          borderRadius: BorderRadius.circular(24),
          enabled: !_isMutating && canPrimaryAction,
          onTap: () async {
            if (item.canConfirmReceived) {
              await _onSettlementConfirmReceived(item);
            } else if (item.canMarkSent) {
              await _onSettlementMarkSent(item);
            } else {
              await _openSettlementProgressDetails(snapshot);
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildSettlementPersonColumn(
                        userId: item.fromUserId,
                        name: item.from,
                        role: fromRole,
                        avatarUrl:
                            fromUser?.avatarThumbUrl ?? fromUser?.avatarUrl,
                        alignEnd: false,
                      ),
                    ),
                    SizedBox(
                      width: 98,
                      child: Column(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? colors.surfaceContainerHighest
                                  : const Color(0xFFE6EDE4),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: _splytoPrimary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatMoney(
                              context,
                              item.amount,
                              currencyCode: widget.trip.currencyCode,
                            ),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: amountColor,
                                  letterSpacing: -0.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildSettlementPersonColumn(
                        userId: item.toUserId,
                        name: item.to,
                        role: toRole,
                        avatarUrl: toUser?.avatarThumbUrl ?? toUser?.avatarUrl,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isDark
                      ? colors.outlineVariant.withValues(alpha: 0.35)
                      : _splytoStroke,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detailTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? null : _splytoPrimary,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            detailSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? colors.onSurfaceVariant
                                      : _splytoMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildSettlementStatusPill(
                          label: statusLabel,
                          color: statusColor,
                        ),
                        if (!item.isConfirmed) ...[
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: !_isMutating && canPrimaryAction
                                ? () async {
                                    if (item.canConfirmReceived) {
                                      await _onSettlementConfirmReceived(item);
                                    } else if (item.canMarkSent) {
                                      await _onSettlementMarkSent(item);
                                    } else {
                                      await _openSettlementProgressDetails(
                                        snapshot,
                                      );
                                    }
                                  }
                                : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: _splytoPrimary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(actionLabel),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettlementPersonColumn({
    required int userId,
    required String name,
    required String role,
    required String? avatarUrl,
    required bool alignEnd,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        _largeMemberAvatar(
          id: userId,
          name: name,
          avatarUrl: avatarUrl,
          size: 56,
        ),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? null
                : _splytoFg,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          role,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : _splytoMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSettlementStatusPill({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettlementActionNeededCard({
    required WorkspaceSnapshot snapshot,
    required int markSentCount,
    required int confirmReceivedCount,
  }) {
    final colors = Theme.of(context).colorScheme;
    final title = _plainLocalizedText(
      en: 'Action needed',
      lv: 'Nepieciešama darbība',
    );
    final subtitle = _plainLocalizedText(
      en: '$markSentCount payment(s) to mark as sent, $confirmReceivedCount to confirm as received.',
      lv: '$markSentCount maksājums(-i) jāatzīmē kā nosūtīts, $confirmReceivedCount jāapstiprina kā saņemts.',
    );

    return _WorkspaceSectionCard(
      accent: colors.tertiary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.tertiary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: colors.tertiary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _openSettlementProgressDetails(snapshot),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(context.l10n.openSettlements),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishTripActionBlock({
    required ColorScheme colors,
    required bool canFinishTrip,
    required bool allMembersReady,
    required int readyMembers,
    required int totalMembers,
    required bool isCurrentUserReady,
    required bool canToggleReady,
    required String finishLabel,
    required String creatorMustFinishLabel,
  }) {
    final readyTitle = _plainLocalizedText(
      en: 'Ready to settle',
      lv: 'Gatavi norēķiniem',
    );
    final readySubtitle = allMembersReady
        ? _plainLocalizedText(
            en: 'All members are ready. You can start settlements.',
            lv: 'Visi dalībnieki gatavi. Var sākt norēķinus.',
          )
        : _plainLocalizedText(
            en: 'Waiting for everyone to mark ready.',
            lv: 'Gaidām, kamēr visi atzīmē gatavību.',
          );
    final markReadyTitle = _plainLocalizedText(
      en: "I'm ready",
      lv: 'Esmu gatavs/-a',
    );
    final markReadySubtitle = _plainLocalizedText(
      en: 'Confirm that you added all your expenses.',
      lv: 'Apstiprini, ka visi tavi izdevumi ir pievienoti.',
    );

    final readyCard = _WorkspaceSectionCard(
      accent: allMembersReady ? colors.primary : colors.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allMembersReady
                    ? Icons.check_circle_outline
                    : Icons.pending_actions_outlined,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  readyTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (allMembersReady ? colors.primary : colors.tertiary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$readyMembers/$totalMembers',
                  style: TextStyle(
                    color: allMembersReady ? colors.primary : colors.tertiary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(readySubtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: isCurrentUserReady,
            onChanged: canToggleReady ? _onReadyToSettleChanged : null,
            title: Text(
              markReadyTitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(markReadySubtitle),
          ),
        ],
      ),
    );

    if (_canEditMembers) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          readyCard,
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: canFinishTrip
                  ? AppDesign.logoBackgroundGradient
                  : LinearGradient(
                      colors: [
                        colors.surfaceContainerHighest,
                        colors.surfaceContainerHighest,
                      ],
                    ),
            ),
            child: ElevatedButton.icon(
              onPressed: canFinishTrip ? _onEndTripPressed : null,
              icon: const Icon(Icons.flag_outlined),
              label: Text(finishLabel),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: canFinishTrip
                    ? Colors.white
                    : colors.onSurfaceVariant,
                disabledForegroundColor: colors.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          if (!allMembersReady)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _plainLocalizedText(
                  en: 'Finish button unlocks once everyone marks ready.',
                  lv: 'Poga aktivizēsies, kad visi atzīmēs gatavību.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        readyCard,
        const SizedBox(height: 8),
        _WorkspaceSectionCard(
          accent: colors.tertiary,
          child: Text(
            creatorMustFinishLabel,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _balanceAvatar({
    required String name,
    required String? avatarUrl,
    double size = 38,
  }) {
    final imageCacheSize = (size * MediaQuery.devicePixelRatioOf(context))
        .round();
    final normalizedUrl = (avatarUrl ?? '').trim();
    if (normalizedUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          normalizedUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          cacheWidth: imageCacheSize,
          cacheHeight: imageCacheSize,
          errorBuilder: (context, error, stackTrace) =>
              _balanceAvatarFallback(name, size: size),
        ),
      );
    }
    return _balanceAvatarFallback(name, size: size);
  }

  Widget _balanceAvatarFallback(String name, {double size = 38}) {
    final letter = name.trim().isEmpty ? '?' : name.trim().substring(0, 1);
    final fontSize = (size * 0.34).clamp(11, 14).toDouble();
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppDesign.brandGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _largeMemberAvatar({
    required int id,
    required String name,
    required String? avatarUrl,
    double size = 72,
  }) {
    final normalizedUrl = (avatarUrl ?? '').trim();
    if (normalizedUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          normalizedUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) =>
              _largeMemberFallback(id: id, name: name, size: size),
        ),
      );
    }
    return _largeMemberFallback(id: id, name: name, size: size);
  }

  Widget _largeMemberFallback({
    required int id,
    required String name,
    required double size,
  }) {
    final initials = _avatarInitials(name);
    final bg = _memberAvatarColorById(id);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _avatarInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      final first = parts.first;
      return (first.length >= 2 ? first.substring(0, 2) : first).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Color _memberAvatarColorById(int id) {
    const palette = <Color>[
      Color(0xFF6BC48E),
      Color(0xFFF48E57),
      Color(0xFFBE6EAF),
      Color(0xFF0E8E96),
      Color(0xFF4E96E8),
      Color(0xFF77A65A),
    ];
    final safeId = id < 0 ? -id : id;
    return palette[safeId % palette.length];
  }

  Widget _buildSettlementsOverviewCard(WorkspaceSnapshot snapshot) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final settlements = snapshot.settlements;
    final confirmedCount = settlements
        .where((item) => item.status.trim().toLowerCase() == 'confirmed')
        .length;
    final openCount = settlements.length - confirmedCount;
    final subtitle = snapshot.isActive
        ? t.settlementOverviewPreviewSubtitle
        : (snapshot.isArchived
              ? t.settlementOverviewArchivedSubtitle
              : t.settlementOverviewInProgressSubtitle);
    final canOpen = settlements.isNotEmpty;
    final title = snapshot.isArchived
        ? t.settlementsDone
        : (snapshot.isActive ? t.settlementPreview : t.settlementInProgress);
    final accentColor = snapshot.isArchived
        ? colors.secondary
        : (snapshot.isActive ? colors.primary : colors.tertiary);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: canOpen ? () => _openSettlementProgressDetails(snapshot) : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      snapshot.isArchived
                          ? Icons.check_circle_outline
                          : (snapshot.isActive
                                ? Icons.preview_outlined
                                : Icons.payments_outlined),
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${settlements.length}',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (canOpen) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _OverviewMetaPill(
                    icon: Icons.swap_horiz,
                    label: '${t.rowsLabel}: ${settlements.length}',
                    color: colors.secondary,
                  ),
                  _OverviewMetaPill(
                    icon: Icons.hourglass_bottom,
                    label: '${t.openLabel}: $openCount',
                    color: colors.tertiary,
                  ),
                  _OverviewMetaPill(
                    icon: Icons.check_circle_outline,
                    label: '${t.confirmedLabel}: $confirmedCount',
                    color: colors.primary,
                  ),
                  if (!canOpen)
                    _OverviewMetaPill(
                      icon: Icons.info_outline,
                      label: t.noSettlements,
                      color: colors.onSurfaceVariant,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _settlementStatusColor(BuildContext context, String status) {
    switch (status.trim().toLowerCase()) {
      case 'confirmed':
        return Theme.of(context).colorScheme.primary;
      case 'sent':
        return Theme.of(context).colorScheme.tertiary;
      case 'pending':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  String _settlementStatusLabel(BuildContext context, String status) {
    final t = context.l10n;
    switch (status.trim().toLowerCase()) {
      case 'confirmed':
        return t.statusConfirmed;
      case 'sent':
        return t.statusSent;
      case 'pending':
        return t.statusPending;
      case 'suggested':
        return t.statusSuggested;
      default:
        return status.trim();
    }
  }

  String _settlementPairText(String from, String to) => '$from • $to';

  Widget _settlementPairTitle(BuildContext context, String from, String to) {
    return Row(
      children: [
        Flexible(
          child: Text(from, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 15,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Flexible(child: Text(to, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
