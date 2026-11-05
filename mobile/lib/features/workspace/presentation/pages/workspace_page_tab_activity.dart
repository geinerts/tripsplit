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
              workspaceActivityIcon(event.eventType),
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
    final t = context.l10n;
    switch (event.eventType.trim().toLowerCase()) {
      case 'expense.created':
        return t.activityEventExpenseCreated;
      case 'expense.updated':
        return t.activityEventExpenseUpdated;
      case 'expense.deleted':
        return t.activityEventExpenseDeleted;
      case 'expense.comment_added':
        return t.activityEventExpenseCommentAdded;
      case 'trip.created':
        return t.activityEventTripCreated;
      case 'trip.updated':
        return _tripUpdatedText(context, event);
      case 'trip.members_added':
        final count = _payloadInt(event, 'members_added_count');
        return count > 0
            ? '${t.activityEventTripMembersAdded}: $count'
            : t.activityEventTripMembersAdded;
      case 'trip.members_invited':
        return t.activityEventTripMembersInvited(
          _payloadInt(event, 'members_invited_count'),
        );
      case 'trip.member_joined':
        return t.activityEventTripMemberJoined;
      case 'trip.invitation_declined':
        return t.activityEventTripInvitationDeclined;
      case 'trip.invitation_revoked':
        return t.activityEventTripInvitationRevoked;
      case 'trip.member_removed':
        return t.activityEventTripMemberRemoved(
          (_payloadString(event, 'removed_user_name') ?? '').isEmpty
              ? t.activityMember
              : _payloadString(event, 'removed_user_name')!,
        );
      case 'trip.member_left':
        return t.activityEventTripMemberLeft;
      case 'trip.member_role_updated':
        return t.activityEventTripMemberRoleUpdated(
          (_payloadString(event, 'target_user_name') ?? '').isEmpty
              ? t.activityMember
              : _payloadString(event, 'target_user_name')!,
          switch (_payloadString(event, 'role')) {
            'owner' => t.workspaceTripOwner,
            'admin' => t.activityRoleAdmin,
            _ => t.workspaceMember,
          },
        );
      case 'trip.member_ready':
        return t.activityEventTripMemberReady;
      case 'trip.member_not_ready':
        return t.activityEventTripMemberNotReady;
      case 'trip.all_members_ready':
        return t.activityEventTripAllMembersReady;
      case 'trip.finished':
        return t.activityEventTripFinished;
      case 'trip.settled':
        return t.activityEventTripSettled;
      case 'settlement.marked_sent':
        return t.activityEventSettlementMarkedSent;
      case 'settlement.confirmed':
        return t.activityEventSettlementConfirmed;
      case 'settlement.sent_cancelled':
        return t.activityEventSettlementSentCancelled;
      case 'settlement.not_received':
        return t.activityEventSettlementNotReceived;
      case 'settlement.reminder_sent':
        return t.activityEventSettlementReminderSent;
      case 'payment.marked_sent':
        return t.activityEventPaymentMarkedSent;
      case 'payment.requested':
        return t.activityEventPaymentRequested;
      case 'payment.request_marked_sent':
        return t.activityEventPaymentRequestMarkedSent;
      case 'payment.request_cancelled':
        return t.activityEventPaymentRequestCancelled;
      case 'payment.request_declined':
        return t.activityEventPaymentRequestDeclined;
      case 'payment.confirmed':
        return t.activityEventPaymentConfirmed;
      case 'payment.cancelled':
        return t.activityEventPaymentCancelled;
      case 'payment.not_received':
        return t.activityEventPaymentNotReceived;
      default:
        return t.activityEventUnknown;
    }
  }

  /// Names the change when exactly one trip detail changed.
  String _tripUpdatedText(BuildContext context, WorkspaceActivityEvent event) {
    final t = context.l10n;
    final specific = <String>[
      if (event.payload['name_changed'] == true) t.activityEventTripRenamed,
      if (event.payload['currency_changed'] == true)
        t.activityEventTripCurrencyChanged,
      if (event.payload['image_changed'] == true)
        t.activityEventTripPhotoChanged,
      if (event.payload['budget_changed'] == true)
        t.activityEventTripBudgetChanged,
      if (event.payload['destinations_changed'] == true)
        t.activityEventTripDestinationsChanged,
    ];
    return specific.length == 1 ? specific.single : t.activityEventTripUpdated;
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

  bool _isDestructiveActivity(String type) {
    final normalized = type.trim().toLowerCase();
    return normalized.contains('deleted');
  }
}
