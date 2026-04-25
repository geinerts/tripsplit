part of 'workspace_page.dart';

extension _WorkspacePageMemberProfileActions on _WorkspacePageState {
  Future<void> _openTripMemberProfilePage(WorkspaceUser user) async {
    var profileUser = user;
    final snapshot = _snapshot;
    var paidExpensesCount = 0;
    var involvedExpensesCount = 0;
    var paidTotal = 0.0;
    final isOwner = (widget.trip.createdBy ?? 0) == profileUser.id;
    Future<List<WorkspaceSharedTrip>> sharedTripsFuture = widget
        .workspaceController
        .loadSharedTripsWithUser(userId: user.id, limit: 20);

    void recomputeActivity(WorkspaceSnapshot? source, int userId) {
      paidExpensesCount = 0;
      involvedExpensesCount = 0;
      paidTotal = 0.0;
      if (source == null) {
        return;
      }
      for (final expense in source.expenses) {
        if (expense.paidById == userId) {
          paidExpensesCount += 1;
          paidTotal += expense.amount;
        }
        final isParticipant = expense.participants.any((p) => p.id == userId);
        if (expense.paidById == userId || isParticipant) {
          involvedExpensesCount += 1;
        }
      }
    }

    recomputeActivity(snapshot, profileUser.id);

    await Navigator.of(context).push<void>(
      AppPageRoute<void>(
        builder: (pageContext) {
          return StatefulBuilder(
            builder: (profileContext, setProfileState) {
              Future<void> refreshProfile() async {
                final tripsRequest = widget.workspaceController
                    .loadSharedTripsWithUser(userId: profileUser.id, limit: 20);
                setProfileState(() {
                  sharedTripsFuture = tripsRequest;
                });

                await _loadData(showLoader: false);
                if (!mounted) {
                  return;
                }

                final fresh = _snapshot;
                WorkspaceUser? refreshedUser;
                if (fresh != null) {
                  recomputeActivity(fresh, profileUser.id);
                  for (final candidate in fresh.users) {
                    if (candidate.id == profileUser.id) {
                      refreshedUser = candidate;
                      break;
                    }
                  }
                }
                setProfileState(() {
                  if (refreshedUser != null) {
                    profileUser = refreshedUser;
                  }
                });

                try {
                  await tripsRequest;
                } catch (_) {}
              }

              final title = context.l10n.workspaceMemberProfile;
              final name = profileUser.preferredName.trim().isEmpty
                  ? profileContext.l10n.userWithId(profileUser.id)
                  : profileUser.preferredName.trim();
              final nickname = profileUser.nickname.trim();
              final hasDifferentNickname =
                  nickname.isNotEmpty &&
                  nickname.toLowerCase() != name.toLowerCase();
              final roleText = isOwner
                  ? context.l10n.workspaceTripOwner
                  : context.l10n.workspaceMember;
              final readyText = profileUser.isReadyToSettle
                  ? context.l10n.workspaceReadyForSettlement
                  : context.l10n.workspaceNotReadyForSettlement;
              final holderName =
                  (profileUser.bankAccountHolder ?? '').trim().isNotEmpty
                  ? (profileUser.bankAccountHolder ?? '').trim()
                  : name;
              return UserProfilePage(
                title: title,
                name: name,
                nickname: hasDifferentNickname ? nickname : null,
                avatarUrl: profileUser.avatarThumbUrl ?? profileUser.avatarUrl,
                badges: [roleText, readyText],
                enableNameCopy: false,
                bankTitle: context.l10n.workspaceBankDetails,
                bankDescription: context
                    .l10n
                    .workspaceIbanAndPayoutDetailsWillBeAddedHereInA,
                showBankDetails: false,
                onRefresh: refreshProfile,
                sections: [
                  UserProfilePaymentDetailsSection(
                    sectionTitle: context.l10n.workspacePaymentDetails,
                    emptyText: context
                        .l10n
                        .workspaceThisMemberHasNotAddedPayoutDetailsYet,
                    bankTransferTitle: context.l10n.workspaceBankTransfer,
                    bankHolderLabel: context.l10n.workspaceHolder,
                    bankHolderName: holderName,
                    bankIban: profileUser.bankIban,
                    bankBic: profileUser.bankBic,
                    revolutTitle: 'Revolut',
                    revolutHandle: profileUser.revolutHandle,
                    revolutMeLink: profileUser.revolutMeLink,
                    paypalTitle: 'PayPal.me',
                    paypalMeLink: profileUser.paypalMeLink,
                    wiseTitle: 'Wise',
                    wisePayLink: profileUser.wisePayLink,
                    openLinkFailedText:
                        context.l10n.workspaceCouldNotOpenPaymentLink,
                    onErrorMessage: (message) =>
                        _showSnack(message, isError: true),
                  ),
                  _buildSharedTripsSection(
                    context: profileContext,
                    future: sharedTripsFuture,
                    fallbackTrip: _fallbackSharedTripForCurrentTrip(),
                  ),
                  _buildTripActivitySection(
                    context: profileContext,
                    paidExpensesCount: paidExpensesCount,
                    paidTotal: paidTotal,
                    involvedExpensesCount: involvedExpensesCount,
                    currencyCode: widget.trip.currencyCode,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTripActivitySection({
    required BuildContext context,
    required int paidExpensesCount,
    required double paidTotal,
    required int involvedExpensesCount,
    required String currencyCode,
  }) {
    return UserProfileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.workspaceTripActivity,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: UserProfileMetricTile(
                  label: context.l10n.workspacePaidExpenses,
                  value: '$paidExpensesCount',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: UserProfileMetricTile(
                  label: context.l10n.workspacePaidTotal,
                  value: _formatMoney(
                    context,
                    paidTotal,
                    currencyCode: currencyCode,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: UserProfileMetricTile(
                  label: context.l10n.workspaceInvolvedIn,
                  value: '$involvedExpensesCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  WorkspaceSharedTrip _fallbackSharedTripForCurrentTrip() {
    return WorkspaceSharedTrip(
      id: widget.trip.id,
      name: widget.trip.name.trim().isEmpty
          ? context.l10n.workspaceCurrentTrip
          : widget.trip.name.trim(),
      status: widget.trip.status.trim().toLowerCase(),
      imageUrl: widget.trip.imageUrl,
      imageThumbUrl: widget.trip.imageThumbUrl,
      membersCount: widget.trip.membersCount,
      createdAt: widget.trip.createdAt,
      endedAt: widget.trip.endedAt,
      archivedAt: widget.trip.archivedAt,
    );
  }

  Widget _buildSharedTripsSection({
    required BuildContext context,
    required Future<List<WorkspaceSharedTrip>> future,
    required WorkspaceSharedTrip fallbackTrip,
  }) {
    final title = context.l10n.workspaceCommonTrips;
    final loadingText = context.l10n.workspaceLoadingCommonTrips;
    final emptyText = context.l10n.workspaceNoCommonTripsFoundYet;
    final errorText =
        context.l10n.workspaceCouldNotLoadAllCommonTripsShowingCurrentOne;

    return UserProfileSectionCard(
      child: FutureBuilder<List<WorkspaceSharedTrip>>(
        future: future,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;
          final loaded = snapshot.data ?? const <WorkspaceSharedTrip>[];
          final items = loaded.isNotEmpty
              ? loaded
              : <WorkspaceSharedTrip>[fallbackTrip];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title (${items.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (isLoading)
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loadingText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppDesign.mutedColor(context),
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      errorText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppDesign.mutedColor(context),
                      ),
                    ),
                  ),
                if (items.isEmpty)
                  Text(
                    emptyText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppDesign.mutedColor(context),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        _buildSharedTripTile(context, items[i]),
                        if (i < items.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSharedTripTile(BuildContext context, WorkspaceSharedTrip trip) {
    final imageUrl = (trip.imageThumbUrl ?? trip.imageUrl ?? '').trim();
    final hasImage = imageUrl.isNotEmpty;
    final statusLabel = trip.isArchived
        ? context.l10n.archivedStatus
        : (trip.isSettling
              ? context.l10n.settlingStatus
              : context.l10n.activeStatus);
    final statusColor = trip.isArchived
        ? AppDesign.mutedColor(context)
        : (trip.isSettling ? AppDesign.lightAccent : AppDesign.lightPrimary);
    final subtitle = _sharedTripSubtitle(context, trip);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasImage
                ? Image.network(
                    imageUrl,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) =>
                        _sharedTripImageFallback(context),
                  )
                : _sharedTripImageFallback(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.name.trim().isEmpty
                      ? context.l10n.tripWithId(trip.id)
                      : trip.name.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppDesign.mutedColor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sharedTripImageFallback(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D7A5E), Color(0xFF215A45)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.landscape_rounded, color: Colors.white, size: 20),
    );
  }

  String _sharedTripSubtitle(BuildContext context, WorkspaceSharedTrip trip) {
    final membersLabel = context.l10n.workspaceMembers;
    final dateLabel = _sharedTripDateLabel(trip);
    if (dateLabel.isEmpty) {
      return '${trip.membersCount} $membersLabel';
    }
    return '$dateLabel • ${trip.membersCount} $membersLabel';
  }

  String _sharedTripDateLabel(WorkspaceSharedTrip trip) {
    final raw = (trip.endedAt ?? trip.createdAt ?? '').trim();
    if (raw.isEmpty) {
      return '';
    }
    final parsed = DateTime.tryParse(raw)?.toLocal();
    if (parsed == null) {
      return '';
    }
    final dd = parsed.day.toString().padLeft(2, '0');
    final mm = parsed.month.toString().padLeft(2, '0');
    return '$dd.$mm';
  }
}
