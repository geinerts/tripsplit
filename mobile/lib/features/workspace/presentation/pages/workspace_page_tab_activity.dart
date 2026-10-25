part of 'workspace_page.dart';

extension _WorkspacePageActivityTab on _WorkspacePageState {
  List<Widget> _buildActivitySlivers() {
    final events = _activityEvents
        .where(_isVisibleTripActivityEvent)
        .toList(growable: false);
    final t = context.l10n;
    return [
      if (_activityError != null)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(liveRegion: true, child: Text(t.activityLoadFailed)),
                TextButton.icon(
                  onPressed: _isLoadingActivity
                      ? null
                      : () => _loadTripActivity(reset: _activityFailedReset),
                  icon: const Icon(Icons.refresh),
                  label: Text(t.retryAction),
                ),
              ],
            ),
          ),
        ),
      if (_isLoadingActivity && events.isEmpty)
        const SliverPadding(
          padding: EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                AppSkeletonBlock(height: 60),
                SizedBox(height: 16),
                AppSkeletonBlock(height: 60),
              ],
            ),
          ),
        )
      else if (events.isEmpty && _activityError == null && _activityLoaded)
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Text(t.workspaceNoRecentActivityYet),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final day = (event.createdAt ?? '').split(RegExp('[ T]')).first;
              final previous = index == 0
                  ? null
                  : (events[index - 1].createdAt ?? '')
                        .split(RegExp('[ T]'))
                        .first;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (day.isNotEmpty && day != previous)
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 12),
                      child: Semantics(
                        header: true,
                        child: Text(
                          _formatDisplayDate(context, day),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  _buildActivityEventCard(event),
                ],
              );
            },
          ),
        ),
      if (_activityHasMore)
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: OutlinedButton.icon(
              onPressed: _isLoadingActivity
                  ? null
                  : () => _loadTripActivity(reset: false),
              icon: const Icon(Icons.expand_more),
              label: Text(
                _isLoadingActivity
                    ? t.workspaceLoadingMoreExpenses
                    : t.tripsLoadMore,
              ),
            ),
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }

  Widget _buildActivityEventCard(WorkspaceActivityEvent event) {
    final theme = Theme.of(context);
    final actor = event.actorName.trim().isEmpty
        ? context.l10n.activityMember
        : event.actorName.trim();
    final meta = _activityMeta(context, event);
    final note = _payloadString(event, 'note');
    return Padding(
      key: ValueKey('activity-row-${event.id}'),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _largeMemberAvatar(
            id: event.actorUserId ?? event.id,
            name: actor,
            avatarUrl: event.actorAvatarThumbUrl ?? event.actorAvatarUrl,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(actor, style: theme.textTheme.titleMedium),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${_activityActionText(context, event)}${note != null && note.isNotEmpty ? ' ' : ''}',
                      ),
                      if (note != null && note.isNotEmpty)
                        TextSpan(
                          text: note,
                          style: TextStyle(
                            decoration: _isDestructiveActivity(event.eventType)
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                    ],
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    ...meta,
                    _activityRelativeTime(context, event.createdAt),
                  ].join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ExcludeSemantics(
            child: Icon(
              _activityIcon(event.eventType),
              size: 20,
              color: _isDestructiveActivity(event.eventType)
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
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
          return 'izveidoja ceļojumu';
        }
        if (language == 'es') {
          return 'creó el viaje';
        }
        return en('created the trip');
      case 'trip.updated':
        if (language == 'lv') {
          return 'atjaunoja ceļojuma detaļas';
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
      case 'trip.members_invited':
        final invitedCount = _payloadInt(event, 'members_invited_count');
        if (language == 'lv') return 'nosūtīja $invitedCount uzaicinājumu(s)';
        if (language == 'es') return 'envió $invitedCount invitación(es)';
        return en('sent $invitedCount invitation(s)');
      case 'trip.member_joined':
        if (language == 'lv') return 'pievienojās ceļojumam';
        if (language == 'es') return 'se unió al viaje';
        return en('joined the trip');
      case 'trip.invitation_declined':
        if (language == 'lv') return 'noraidīja ceļojuma uzaicinājumu';
        if (language == 'es') return 'rechazó la invitación al viaje';
        return en('declined the trip invitation');
      case 'trip.invitation_revoked':
        if (language == 'lv') return 'atsauca ceļojuma uzaicinājumu';
        if (language == 'es') return 'canceló una invitación al viaje';
        return en('cancelled a trip invitation');
      case 'trip.member_removed':
        final name = _payloadString(event, 'removed_user_name') ?? '';
        if (language == 'lv') {
          return 'noņēma ${name.isEmpty ? 'dalībnieku' : name} no ceļojuma';
        }
        if (language == 'es') {
          return 'quitó a ${name.isEmpty ? 'un miembro' : name} del viaje';
        }
        return en('removed ${name.isEmpty ? 'a member' : name}');
      case 'trip.member_left':
        if (language == 'lv') {
          return 'pameta ceļojumu';
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
          return 'pabeidza ceļojumu';
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
      case 'payment.marked_sent':
        if (language == 'lv') {
          return 'atzīmēja maksājumu kā nosūtītu';
        }
        if (language == 'es') {
          return 'marcó un pago como enviado';
        }
        return en('recorded a payment');
      case 'payment.requested':
        if (language == 'lv') {
          return 'pieprasīja maksājumu';
        }
        if (language == 'es') {
          return 'solicitó un pago';
        }
        return en('requested a payment');
      case 'payment.request_marked_sent':
        if (language == 'lv') {
          return 'atzīmēja pieprasīto maksājumu kā nosūtītu';
        }
        if (language == 'es') {
          return 'marcó el pago solicitado como enviado';
        }
        return en('marked a requested payment as sent');
      case 'payment.request_cancelled':
        if (language == 'lv') {
          return 'atcēla maksājuma pieprasījumu';
        }
        if (language == 'es') {
          return 'canceló una solicitud de pago';
        }
        return en('cancelled a payment request');
      case 'payment.request_declined':
        if (language == 'lv') {
          return 'noraidīja maksājuma pieprasījumu';
        }
        if (language == 'es') {
          return 'rechazó una solicitud de pago';
        }
        return en('declined a payment request');
      case 'payment.confirmed':
        if (language == 'lv') {
          return 'apstiprināja maksājumu';
        }
        if (language == 'es') {
          return 'confirmó un pago';
        }
        return en('confirmed a payment');
      case 'payment.cancelled':
        if (language == 'lv') {
          return 'atcēla maksājuma ierakstu';
        }
        if (language == 'es') {
          return 'canceló un pago';
        }
        return en('cancelled a payment record');
      case 'payment.not_received':
        if (language == 'lv') {
          return 'atzīmēja maksājumu kā nesaņemtu';
        }
        if (language == 'es') {
          return 'marcó un pago como no recibido';
        }
        return en('marked a payment as not received');
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
    return AppFormatters.displayCurrencyFromCents(
      context,
      amountCents,
      currencyCode: currencyCode,
    );
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
    if (normalized.contains('payment')) {
      return Icons.account_balance_wallet_rounded;
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
}
