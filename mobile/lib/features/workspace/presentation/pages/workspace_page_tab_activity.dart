part of 'workspace_page.dart';

extension _WorkspacePageActivityTab on _WorkspacePageState {
  Widget _buildActivityTab() {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final events = _activityEvents
        .where(_isVisibleTripActivityEvent)
        .toList(growable: false);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        Row(
          children: [
            Icon(Icons.history_rounded, color: colors.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.workspaceTripActivity,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? null : AppDesign.lightForeground,
                ),
              ),
            ),
            if (_activityLoaded)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppDesign.lightPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${events.length}',
                  style: const TextStyle(
                    color: AppDesign.lightPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingActivity && events.isEmpty)
          ...List<Widget>.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivitySkeletonCard(isDark: isDark),
            ),
          )
        else if (events.isEmpty)
          Card(
            color: isDark ? colors.surface : AppDesign.lightSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: isDark
                    ? colors.outlineVariant.withValues(alpha: 0.30)
                    : AppDesign.lightStroke,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.workspaceNoRecentActivityYet),
            ),
          )
        else
          for (final event in events)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildActivityEventCard(event),
            ),
        if (_activityHasMore) ...[
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _isLoadingActivity
                  ? null
                  : () => unawaited(_loadTripActivity(reset: false)),
              icon: _isLoadingActivity
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.keyboard_arrow_down_rounded),
              label: Text(context.l10n.tripsLoadMore),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActivityEventCard(WorkspaceActivityEvent event) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _activityColor(event.eventType);
    final actorName = event.actorName.trim().isEmpty
        ? 'Trip member'
        : event.actorName.trim();
    final actionText = _activityActionText(context, event);
    final meta = _activityMeta(context, event);

    final mutedColor = isDark ? colors.onSurfaceVariant : AppDesign.lightMuted;
    final isDestructive = _isDestructiveActivity(event.eventType);
    final metaColor = isDestructive
        ? AppDesign.lightDestructive.withValues(alpha: 0.92)
        : mutedColor;
    final metaLine = meta.join(' • ');
    final textDecoration = isDestructive
        ? TextDecoration.lineThrough
        : TextDecoration.none;
    final decorationColor = isDestructive
        ? AppDesign.lightDestructive.withValues(alpha: 0.86)
        : null;
    final decorationThickness = isDestructive ? 1.7 : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _largeMemberAvatar(
            id: event.actorUserId ?? event.id,
            name: actorName,
            avatarUrl: event.actorAvatarThumbUrl ?? event.actorAvatarUrl,
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actorName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    height: 1.18,
                    color: isDark ? null : AppDesign.lightForeground,
                    decoration: textDecoration,
                    decorationColor: decorationColor,
                    decorationThickness: decorationThickness,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  actionText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 15.2,
                    fontWeight: FontWeight.w400,
                    height: 1.22,
                    color: isDark
                        ? colors.onSurface.withValues(alpha: 0.92)
                        : AppDesign.lightForeground,
                    decoration: textDecoration,
                    decorationColor: decorationColor,
                    decorationThickness: decorationThickness,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metaLine.isEmpty
                      ? _activityRelativeTime(context, event.createdAt)
                      : '$metaLine • ${_activityRelativeTime(context, event.createdAt)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: metaColor,
                    fontWeight: FontWeight.w500,
                    height: 1.28,
                    decoration: textDecoration,
                    decorationColor: decorationColor,
                    decorationThickness: decorationThickness,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(_activityIcon(event.eventType), size: 18, color: accent),
        ],
      ),
    );
  }

  bool _isVisibleTripActivityEvent(WorkspaceActivityEvent event) {
    switch (event.eventType.trim().toLowerCase()) {
      case 'trip.all_members_ready':
      case 'settlement.reminder_sent':
        return false;
      default:
        return true;
    }
  }

  String _activityActionText(
    BuildContext context,
    WorkspaceActivityEvent event,
  ) {
    final language = Localizations.localeOf(context).languageCode;

    String en(String fallback) => fallback;

    switch (event.eventType.trim().toLowerCase()) {
      case 'expense.created':
        if (language == 'lv') {
          return 'pievienoja izdevumu';
        }
        if (language == 'es') {
          return 'añadió un gasto';
        }
        return en('added an expense');
      case 'expense.updated':
        if (language == 'lv') {
          return 'atjaunoja izdevumu';
        }
        if (language == 'es') {
          return 'actualizó un gasto';
        }
        return en('updated an expense');
      case 'expense.deleted':
        if (language == 'lv') {
          return 'izdzēsa izdevumu';
        }
        if (language == 'es') {
          return 'eliminó un gasto';
        }
        return en('deleted an expense');
      case 'trip.created':
        if (language == 'lv') {
          return 'izveidoja tripu';
        }
        if (language == 'es') {
          return 'creó el viaje';
        }
        return en('created the trip');
      case 'trip.updated':
        if (language == 'lv') {
          return 'atjaunoja tripa detaļas';
        }
        if (language == 'es') {
          return 'actualizó el viaje';
        }
        return en('updated trip details');
      case 'trip.members_added':
        final count = _payloadInt(event, 'members_added_count');
        if (language == 'lv') {
          return count > 0
              ? 'pievienoja $count dalībnieku(s)'
              : 'pievienoja dalībniekus';
        }
        if (language == 'es') {
          return count > 0 ? 'añadió $count miembro(s)' : 'añadió miembros';
        }
        return en(count > 0 ? 'added $count member(s)' : 'added members');
      case 'trip.member_removed':
        final name = _payloadString(event, 'removed_user_name') ?? '';
        if (language == 'lv') {
          return 'noņēma ${name.isEmpty ? 'dalībnieku' : name} no tripa';
        }
        if (language == 'es') {
          return 'quitó a ${name.isEmpty ? 'un miembro' : name} del viaje';
        }
        return en('removed ${name.isEmpty ? 'a member' : name}');
      case 'trip.member_left':
        if (language == 'lv') {
          return 'pameta tripu';
        }
        if (language == 'es') {
          return 'salió del viaje';
        }
        return en('left the trip');
      case 'trip.member_role_updated':
        final name = _payloadString(event, 'target_user_name') ?? '';
        final role = _payloadString(event, 'role') ?? 'member';
        if (language == 'lv') {
          return 'nomainīja ${name.isEmpty ? 'dalībnieka' : name} lomu uz $role';
        }
        if (language == 'es') {
          return 'cambió el rol de ${name.isEmpty ? 'un miembro' : name} a $role';
        }
        return en('changed ${name.isEmpty ? 'a member' : name} to $role');
      case 'trip.member_ready':
        if (language == 'lv') {
          return 'atzīmēja gatavību norēķiniem';
        }
        if (language == 'es') {
          return 'marcó que está listo para liquidar';
        }
        return en('marked ready to settle');
      case 'trip.member_not_ready':
        if (language == 'lv') {
          return 'noņēma gatavību norēķiniem';
        }
        if (language == 'es') {
          return 'quitó su estado listo';
        }
        return en('marked not ready');
      case 'trip.all_members_ready':
        if (language == 'lv') {
          return 'Visi dalībnieki ir gatavi norēķiniem';
        }
        if (language == 'es') {
          return 'Todos los miembros están listos para liquidar';
        }
        return en('All members are ready to settle');
      case 'trip.finished':
        if (language == 'lv') {
          return 'pabeidza tripu';
        }
        if (language == 'es') {
          return 'finalizó el viaje';
        }
        return en('finished the trip');
      case 'settlement.marked_sent':
        if (language == 'lv') {
          return 'atzīmēja pārskaitījumu kā nosūtītu';
        }
        if (language == 'es') {
          return 'marcó la transferencia como enviada';
        }
        return en('marked a transfer as sent');
      case 'settlement.confirmed':
        if (language == 'lv') {
          return 'apstiprināja pārskaitījumu';
        }
        if (language == 'es') {
          return 'confirmó la transferencia';
        }
        return en('confirmed a transfer');
      case 'settlement.sent_cancelled':
        if (language == 'lv') {
          return 'atcēla nosūtīšanas statusu';
        }
        if (language == 'es') {
          return 'canceló el estado enviado';
        }
        return en('cancelled sent status');
      case 'settlement.not_received':
        if (language == 'lv') {
          return 'atzīmēja, ka pārskaitījums nav saņemts';
        }
        if (language == 'es') {
          return 'marcó la transferencia como no recibida';
        }
        return en('marked a transfer as not received');
      case 'settlement.reminder_sent':
        if (language == 'lv') {
          return 'nosūtīja norēķina atgādinājumu';
        }
        if (language == 'es') {
          return 'envió un recordatorio';
        }
        return en('sent a settlement reminder');
      default:
        if (language == 'lv') {
          return 'veica izmaiņas';
        }
        if (language == 'es') {
          return 'hizo un cambio';
        }
        return en('made a change');
    }
  }

  List<String> _activityMeta(
    BuildContext context,
    WorkspaceActivityEvent event,
  ) {
    final items = <String>[];
    final amount = _activityAmount(context, event);
    if (amount.isNotEmpty) {
      items.add(amount);
    }
    final category = _payloadString(event, 'category');
    if (category != null && category.isNotEmpty) {
      items.add(
        ExpenseCategoryCatalog.labelFor(
          category,
          Localizations.localeOf(context),
        ),
      );
    }
    final splitMode = _payloadString(event, 'split_mode');
    if (splitMode != null && splitMode.isNotEmpty) {
      items.add(_splitModeShortLabel(context, splitMode));
    }
    final status = _payloadString(event, 'status');
    if (status != null && status.isNotEmpty) {
      items.add(status);
    }
    return items.take(3).toList(growable: false);
  }

  String _activityAmount(BuildContext context, WorkspaceActivityEvent event) {
    final amountCents = _payloadInt(event, 'amount_cents');
    if (amountCents <= 0) {
      return '';
    }
    final currencyCode =
        _payloadString(event, 'trip_currency_code') ?? widget.trip.currencyCode;
    return _formatMoney(context, amountCents / 100, currencyCode: currencyCode);
  }

  int _payloadInt(WorkspaceActivityEvent event, String key) {
    final value = event.payload[key];
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  String? _payloadString(WorkspaceActivityEvent event, String key) {
    final value = event.payload[key];
    if (value == null) {
      return null;
    }
    final result = value.toString().trim();
    return result.isEmpty ? null : result;
  }

  DateTime _activityDate(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final mysqlUtc = RegExp(
      r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$',
    ).hasMatch(value);
    if (mysqlUtc) {
      final parsedUtc = DateTime.tryParse('${value.replaceFirst(' ', 'T')}Z');
      if (parsedUtc != null) {
        return parsedUtc.toLocal();
      }
    }

    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed.toLocal();
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _activityRelativeTime(BuildContext context, String? raw) {
    final moment = _activityDate(raw);
    if (moment.millisecondsSinceEpoch == 0) {
      return context.l10n.workspaceUnknownTime;
    }
    final diff = DateTime.now().difference(moment);
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

  IconData _activityIcon(String type) {
    final normalized = type.trim().toLowerCase();
    if (normalized.contains('expense')) {
      return Icons.receipt_long_rounded;
    }
    if (normalized.contains('settlement')) {
      return Icons.payments_rounded;
    }
    if (normalized.contains('ready')) {
      return Icons.verified_rounded;
    }
    if (normalized.contains('member')) {
      return Icons.group_add_rounded;
    }
    if (normalized.contains('finished')) {
      return Icons.flag_rounded;
    }
    return Icons.history_rounded;
  }

  bool _isDestructiveActivity(String type) {
    final normalized = type.trim().toLowerCase();
    return normalized.contains('deleted');
  }

  Color _activityColor(String type) {
    final normalized = type.trim().toLowerCase();
    if (normalized.contains('deleted')) {
      return AppDesign.lightDestructive;
    }
    if (normalized.contains('settlement')) {
      return AppDesign.lightAccent;
    }
    if (normalized.contains('ready') || normalized.contains('finished')) {
      return AppDesign.lightSuccess;
    }
    return AppDesign.lightPrimary;
  }
}

class _ActivitySkeletonCard extends StatelessWidget {
  const _ActivitySkeletonCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: isDark ? colors.surface : AppDesign.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.30)
              : AppDesign.lightStroke,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            AppSkeletonBlock(width: 42, height: 42, radius: 999),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonBlock(height: 15),
                  SizedBox(height: 7),
                  AppSkeletonBlock(width: 120, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
