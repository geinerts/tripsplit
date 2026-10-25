part of 'workspace_page.dart';

extension _WorkspacePageMemberProfileActions on _WorkspacePageState {
  Future<void> _openTripMemberProfilePage(WorkspaceUser user) async {
    var profileUser = user;
    final snapshot = _snapshot;
    var paidExpensesCount = 0;
    var involvedExpensesCount = 0;
    var paidTotal = 0.0;
    Future<List<WorkspaceSharedTrip>> sharedTripsFuture = widget
        .workspaceController
        .loadSharedTripsWithUser(userId: user.id, limit: 20);
    // The route may build after this request completes; FutureBuilder still reads its error.
    sharedTripsFuture.ignore();

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
                tripsRequest.ignore();
                setProfileState(() {
                  sharedTripsFuture = tripsRequest;
                });

                await _loadData(showLoader: false);
                if (widget.authController.currentUser?.id == profileUser.id) {
                  await widget.authController.loadCurrentUser();
                }
                if (!mounted || !profileContext.mounted) {
                  return;
                }
                if (_snapshot == null) {
                  Navigator.of(profileContext).pop();
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
              final roleText = profileUser.isOwner
                  ? context.l10n.workspaceTripOwner
                  : profileUser.isAdmin
                  ? 'Admin'
                  : context.l10n.workspaceMember;
              final readyText = profileUser.isReadyToSettle
                  ? context.l10n.workspaceReadyForSettlement
                  : context.l10n.workspaceNotReadyForSettlement;
              // Workspace members deliberately omit private payout details.
              // Only the signed-in owner's profile can use their own details.
              final currentUser = widget.authController.currentUser;
              final ownProfile = currentUser?.id == profileUser.id
                  ? currentUser
                  : null;
              final holderName =
                  (ownProfile?.bankAccountHolder ?? '').trim().isNotEmpty
                  ? ownProfile!.bankAccountHolder!.trim()
                  : name;
              return UserProfilePage(
                title: title,
                name: name,
                nickname: hasDifferentNickname ? nickname : null,
                avatarUrl: profileUser.avatarThumbUrl ?? profileUser.avatarUrl,
                badges: [
                  [
                    roleText,
                    if (profileUser.id == _currentUserId) context.l10n.youLabel,
                  ].join(' · '),
                ],
                statusBadge: widget.trip.isSolo
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (profileUser.isReadyToSettle) ...[
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              readyText,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: profileUser.isReadyToSettle
                                        ? Theme.of(context).colorScheme.primary
                                        : AppDesign.mutedColor(context),
                                  ),
                            ),
                          ),
                        ],
                      ),
                enableNameCopy: false,
                bankTitle: context.l10n.workspaceBankDetails,
                bankDescription: context
                    .l10n
                    .workspaceIbanAndPayoutDetailsWillBeAddedHereInA,
                showBankDetails: false,
                onRefresh: refreshProfile,
                sections: [
                  _buildTripActivitySection(
                    context: profileContext,
                    paidExpensesCount: paidExpensesCount,
                    paidTotal: paidTotal,
                    involvedExpensesCount: involvedExpensesCount,
                    currencyCode: widget.trip.currencyCode,
                  ),
                  UserProfilePaymentDetailsSection(
                    compactEmpty: true,
                    sectionTitle: context.l10n.workspacePaymentDetails,
                    emptyText: context
                        .l10n
                        .workspaceThisMemberHasNotAddedPayoutDetailsYet,
                    bankTransferTitle: context.l10n.workspaceBankTransfer,
                    bankHolderLabel: context.l10n.workspaceHolder,
                    bankHolderName: holderName,
                    bankIban: ownProfile?.bankIban,
                    bankBic: ownProfile?.bankBic,
                    revolutTitle: 'Revolut',
                    revolutHandle: ownProfile?.revolutHandle,
                    revolutMeLink: ownProfile?.revolutMeLink,
                    paypalTitle: 'PayPal.me',
                    paypalMeLink: ownProfile?.paypalMeLink,
                    wiseTitle: 'Wise',
                    wisePayLink: ownProfile?.wisePayLink,
                    openLinkFailedText:
                        context.l10n.workspaceCouldNotOpenPaymentLink,
                    onErrorMessage: (message) =>
                        _showSnack(message, isError: true),
                  ),
                  UserSharedTripsSection(
                    future: sharedTripsFuture,
                    reload: () =>
                        widget.workspaceController.loadSharedTripsWithUser(
                          userId: profileUser.id,
                          limit: 20,
                        ),
                    fallbackTrip: _fallbackSharedTripForCurrentTrip(),
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
    final metrics = [
      UserProfileMetricTile(
        label: context.l10n.workspacePaidExpenses,
        value: '$paidExpensesCount',
      ),
      UserProfileMetricTile(
        label: context.l10n.workspacePaidTotal,
        value: AppFormatters.displayCurrencyFromCents(
          context,
          (paidTotal * 100).round(),
          currencyCode: currencyCode,
        ),
      ),
      UserProfileMetricTile(
        label: context.l10n.workspaceInvolvedIn,
        value: '$involvedExpensesCount',
      ),
    ];
    return UserProfileSectionCard(
      showDivider: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.workspaceTripActivity,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 300 ||
                  MediaQuery.textScalerOf(context).scale(16) > 20;
              var labelHeight = 0.0;
              if (!stacked) {
                final width = (constraints.maxWidth - 50) / 3;
                for (final metric in metrics) {
                  final painter = TextPainter(
                    text: TextSpan(
                      text: metric.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    textDirection: Directionality.of(context),
                    textScaler: MediaQuery.textScalerOf(context),
                  )..layout(maxWidth: width);
                  labelHeight = math.max(labelHeight, painter.height);
                  painter.dispose();
                }
              }
              return stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final metric in metrics)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: metric,
                          ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < metrics.length; i++) ...[
                          if (i > 0)
                            Container(
                              width: 1,
                              height: 52,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              color: AppDesign.cardStroke(context),
                            ),
                          Expanded(
                            child: UserProfileMetricTile(
                              label: metrics[i].label,
                              value: metrics[i].value,
                              labelHeight: labelHeight,
                            ),
                          ),
                        ],
                      ],
                    );
            },
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.memberActivityScope,
            style: Theme.of(context).textTheme.bodySmall,
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
}
