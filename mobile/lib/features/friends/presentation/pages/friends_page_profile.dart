part of 'friends_page.dart';

extension _FriendsPageProfile on _FriendsPageState {
  Future<void> _openFriendProfile(FriendUser user) async {
    var profileUser = user;
    var isRemovingFriend = false;
    Future<List<WorkspaceSharedTrip>> sharedTripsFuture = widget
        .workspaceController
        .loadSharedTripsWithUser(userId: user.id, limit: 20);

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (pageContext) {
          return StatefulBuilder(
            builder: (profileContext, setProfileState) {
              final name = _friendPrimaryName(profileUser);
              final holderName =
                  (profileUser.bankAccountHolder ?? '').trim().isNotEmpty
                  ? (profileUser.bankAccountHolder ?? '').trim()
                  : name;

              Future<void> refreshProfile() async {
                final tripsRequest = widget.workspaceController
                    .loadSharedTripsWithUser(userId: profileUser.id, limit: 20);
                setProfileState(() {
                  sharedTripsFuture = tripsRequest;
                });

                await _loadSnapshot(showLoader: false);
                if (!mounted) {
                  return;
                }

                final snapshot = _snapshot;
                if (snapshot != null) {
                  for (final candidate in snapshot.friends) {
                    if (candidate.id == profileUser.id) {
                      setProfileState(() {
                        profileUser = candidate;
                      });
                      break;
                    }
                  }
                }

                try {
                  await tripsRequest;
                } catch (_) {}
              }

              Future<_FriendProfileAction?> showProfileActionsSheet() async {
                final isIOS =
                    Theme.of(profileContext).platform == TargetPlatform.iOS;
                if (isIOS) {
                  return showCupertinoModalPopup<_FriendProfileAction>(
                    context: profileContext,
                    builder: (sheetContext) => CupertinoActionSheet(
                      actions: [
                        CupertinoActionSheetAction(
                          isDestructiveAction: true,
                          onPressed: () => Navigator.of(
                            sheetContext,
                          ).pop(_FriendProfileAction.removeFriend),
                          child: Text(context.l10n.friendsRemoveFriend),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(context.l10n.authCancel),
                      ),
                    ),
                  );
                }

                return showModalBottomSheet<_FriendProfileAction>(
                  context: profileContext,
                  showDragHandle: true,
                  builder: (sheetContext) {
                    final isDark =
                        Theme.of(sheetContext).brightness == Brightness.dark;
                    final removeColor = isDark
                        ? Colors.red.shade200
                        : Colors.red.shade700;
                    return SafeArea(
                      child: ListTile(
                        leading: Icon(
                          Icons.person_remove_alt_1_rounded,
                          color: removeColor,
                        ),
                        title: Text(
                          context.l10n.friendsRemoveFriend,
                          style: TextStyle(
                            color: removeColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () => Navigator.of(
                          sheetContext,
                        ).pop(_FriendProfileAction.removeFriend),
                      ),
                    );
                  },
                );
              }

              Future<bool> confirmRemoveFriend() async {
                final title = context.l10n.friendsRemoveThisFriend;
                final body = context.l10n
                    .friendsWillBeRemovedFromYourFriendsListYouCanAdd(name);
                final isIOS =
                    Theme.of(profileContext).platform == TargetPlatform.iOS;
                if (isIOS) {
                  final result = await showCupertinoDialog<bool>(
                    context: profileContext,
                    builder: (dialogContext) => CupertinoAlertDialog(
                      title: Text(title),
                      content: Text(body),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: Text(context.l10n.authCancel),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: Text(context.l10n.friendsContinue),
                        ),
                      ],
                    ),
                  );
                  return result == true;
                }

                final result = await showDialog<bool>(
                  context: profileContext,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(title),
                    content: Text(body),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(context.l10n.authCancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(context.l10n.friendsContinue),
                      ),
                    ],
                  ),
                );
                return result == true;
              }

              Future<void> onOpenProfileActions() async {
                if (isRemovingFriend) {
                  return;
                }
                final selectedAction = await showProfileActionsSheet();
                if (selectedAction != _FriendProfileAction.removeFriend ||
                    !mounted ||
                    !profileContext.mounted) {
                  return;
                }

                final confirmed = await confirmRemoveFriend();
                if (!confirmed || !mounted || !profileContext.mounted) {
                  return;
                }

                setProfileState(() {
                  isRemovingFriend = true;
                });
                try {
                  await widget.controller.removeFriend(userId: profileUser.id);
                  if (!mounted) {
                    return;
                  }
                  _showSnack(context.l10n.friendsFriendRemoved);
                  await _loadSnapshot(showLoader: false);
                  if (!profileContext.mounted) {
                    return;
                  }
                  Navigator.of(profileContext).pop();
                } on ApiException catch (error) {
                  if (!mounted) {
                    return;
                  }
                  _showSnack(error.message, isError: true);
                } catch (_) {
                  if (!mounted) {
                    return;
                  }
                  _showSnack(
                    context.l10n.friendsCouldNotRemoveFriend,
                    isError: true,
                  );
                } finally {
                  if (mounted && profileContext.mounted) {
                    setProfileState(() {
                      isRemovingFriend = false;
                    });
                  }
                }
              }

              return UserProfilePage(
                title: context.l10n.friendsFriendProfile,
                name: name,
                nickname: profileUser.nickname,
                avatarUrl: profileUser.avatarThumbUrl ?? profileUser.avatarUrl,
                appBarActions: [
                  IconButton(
                    onPressed: isRemovingFriend
                        ? null
                        : () => unawaited(onOpenProfileActions()),
                    tooltip: context.l10n.friendsMoreActions,
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
                ],
                sections: [
                  _buildCommonTripsSection(
                    context: profileContext,
                    future: sharedTripsFuture,
                  ),
                  UserProfilePaymentDetailsSection(
                    sectionTitle: context.l10n.workspacePaymentDetails,
                    emptyText: context
                        .l10n
                        .friendsThisFriendHasNotAddedPayoutDetailsYet,
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
                    openLinkFailedText:
                        context.l10n.workspaceCouldNotOpenPaymentLink,
                    onErrorMessage: (message) =>
                        _showSnack(message, isError: true),
                  ),
                ],
                bankTitle: context.l10n.workspaceBankDetails,
                bankDescription: context
                    .l10n
                    .workspaceIbanAndPayoutDetailsWillBeAddedHereInA,
                showBankDetails: false,
                onRefresh: refreshProfile,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCommonTripsSection({
    required BuildContext context,
    required Future<List<WorkspaceSharedTrip>> future,
  }) {
    return UserProfileSectionCard(
      child: FutureBuilder<List<WorkspaceSharedTrip>>(
        future: future,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;
          final items = snapshot.data ?? const <WorkspaceSharedTrip>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.l10n.workspaceCommonTrips} (${items.length})',
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
                        context.l10n.workspaceLoadingCommonTrips,
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
                      context.l10n.friendsCouldNotLoadCommonTripsRightNow,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppDesign.mutedColor(context),
                      ),
                    ),
                  ),
                if (items.isEmpty)
                  Text(
                    context.l10n.workspaceNoCommonTripsFoundYet,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppDesign.mutedColor(context),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        _buildCommonTripTile(context, items[i]),
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

  Widget _buildCommonTripTile(BuildContext context, WorkspaceSharedTrip trip) {
    final imageUrl = (trip.imageThumbUrl ?? trip.imageUrl ?? '').trim();
    final hasImage = imageUrl.isNotEmpty;
    final statusText = trip.isArchived
        ? context.l10n.friendsFinished
        : (trip.isSettling
              ? context.l10n.settlingStatus
              : context.l10n.activeStatus);
    final statusColor = trip.isArchived
        ? AppDesign.mutedColor(context)
        : (trip.isSettling
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.primary);

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
                        _commonTripImageFallback(context),
                  )
                : _commonTripImageFallback(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.name.trim().isEmpty
                      ? context.l10n.friendsTrip(trip.id)
                      : trip.name.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  _commonTripSubtitle(context, trip),
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
              borderRadius: BorderRadius.circular(999),
              color: statusColor.withValues(alpha: 0.12),
              border: Border.all(color: statusColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              statusText,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commonTripImageFallback(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.landscape_rounded,
        size: 22,
        color: AppDesign.mutedColor(context),
      ),
    );
  }

  String _commonTripSubtitle(BuildContext context, WorkspaceSharedTrip trip) {
    final dateLabel = _commonTripDateLabel(context, trip);
    final membersText = context.l10n.friendsMembers(trip.membersCount);
    return '$dateLabel • $membersText';
  }

  String _commonTripDateLabel(BuildContext context, WorkspaceSharedTrip trip) {
    final raw = trip.archivedAt ?? trip.endedAt ?? trip.createdAt;
    if (raw == null || raw.trim().isEmpty) {
      return context.l10n.friendsNoDate;
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    return MaterialLocalizations.of(context).formatMediumDate(parsed.toLocal());
  }
}

enum _FriendProfileAction { removeFriend }
