part of 'friends_page.dart';

extension _FriendsPageProfile on _FriendsPageState {
  Future<void> _openFriendProfile(FriendUser user) async {
    var profileUser = user;
    var isRemovingFriend = false;
    var isOpeningTrip = false;
    String? tripError;
    final accountId = widget.authController.currentUser?.id;
    final tripActions = FriendTripActions(
      trips: widget.tripsController,
      workspace: widget.workspaceController,
      accountIsCurrent: () =>
          mounted &&
          accountId != null &&
          widget.authController.currentUser?.id == accountId,
    );
    Future<List<WorkspaceSharedTrip>> sharedTripsFuture = widget
        .workspaceController
        .loadSharedTripsWithUser(userId: user.id, limit: 20);
    // The route may build after this request completes; FutureBuilder still reads its error.
    sharedTripsFuture.ignore();

    await Navigator.of(context).push<void>(
      AppPageRoute<void>(
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
                tripsRequest.ignore();
                setProfileState(() {
                  sharedTripsFuture = tripsRequest;
                });

                await _loadSnapshot(showLoader: false);
                if (!mounted || !profileContext.mounted) {
                  return;
                }
                if (_snapshot == null && _errorText != null) {
                  Navigator.of(profileContext).pop();
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
                return showAppBottomSheet<_FriendProfileAction>(
                  context: profileContext,
                  builder: (sheetContext) {
                    return AppActionSheet(
                      title: name,
                      children: [
                        AppPlainActionTile(
                          icon: Icons.person_remove_alt_1_rounded,
                          title: context.l10n.friendsRemoveFriend,
                          destructive: true,
                          onTap: () => Navigator.of(
                            sheetContext,
                          ).pop(_FriendProfileAction.removeFriend),
                        ),
                      ],
                    );
                  },
                );
              }

              Future<bool> confirmRemoveFriend() async {
                final title = context.l10n.friendsRemoveThisFriend;
                final body = context.l10n
                    .friendsWillBeRemovedFromYourFriendsListYouCanAdd(name);
                return showAppConfirmationDialog(
                  context: profileContext,
                  title: title,
                  message: body,
                  confirmLabel: context.l10n.friendsContinue,
                  cancelLabel: context.l10n.authCancel,
                  icon: Icons.person_remove_alt_1_rounded,
                  destructive: true,
                );
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
                subtitle: context.l10n.friendRelationshipLabel,
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
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const ValueKey('friend-invite-to-trip'),
                      icon: const Icon(Icons.person_add_outlined),
                      label: Text(context.l10n.friendInviteToTrip),
                      onPressed: isRemovingFriend || isOpeningTrip
                          ? null
                          : () async {
                              final sent = await Navigator.of(profileContext)
                                  .push<bool>(
                                    AppFormPageRoute(
                                      builder: (_) => FriendTripInvitePage(
                                        friendId: profileUser.id,
                                        friendName: name,
                                        actions: tripActions,
                                      ),
                                    ),
                                  );
                              if (!mounted || !profileContext.mounted) return;
                              if (sent == true) {
                                ScaffoldMessenger.of(
                                  profileContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n.friendTripInviteSent,
                                    ),
                                  ),
                                );
                              }
                            },
                    ),
                  ),
                  if (isOpeningTrip) const LinearProgressIndicator(),
                  if (tripError != null)
                    Text(
                      tripError!,
                      style: TextStyle(
                        color: Theme.of(profileContext).colorScheme.error,
                      ),
                    ),
                  UserSharedTripsSection(
                    onOpenTrip: (shared) async {
                      if (isOpeningTrip || isRemovingFriend) return;
                      setProfileState(() {
                        isOpeningTrip = true;
                        tripError = null;
                      });
                      try {
                        final trip = await tripActions.accessibleTrip(
                          shared.id,
                        );
                        if (!mounted || !profileContext.mounted) return;
                        if (trip == null) {
                          setProfileState(
                            () =>
                                tripError = context.l10n.friendTripUnavailable,
                          );
                          return;
                        }
                        Navigator.pop(profileContext);
                        widget.onOpenTrip(trip);
                      } catch (_) {
                        if (mounted && profileContext.mounted) {
                          setProfileState(
                            () =>
                                tripError = context.l10n.friendTripActionFailed,
                          );
                        }
                      } finally {
                        if (mounted && profileContext.mounted) {
                          setProfileState(() => isOpeningTrip = false);
                        }
                      }
                    },
                    future: sharedTripsFuture,
                    reload: () =>
                        widget.workspaceController.loadSharedTripsWithUser(
                          userId: profileUser.id,
                          limit: 20,
                        ),
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
                    wiseTitle: 'Wise',
                    wisePayLink: profileUser.wisePayLink,
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
}

enum _FriendProfileAction { removeFriend }
