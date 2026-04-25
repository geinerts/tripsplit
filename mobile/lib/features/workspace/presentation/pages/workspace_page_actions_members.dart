part of 'workspace_page.dart';

extension _WorkspacePageMembersActions on _WorkspacePageState {
  Future<void> _openTripMembersListSheet(List<WorkspaceUser> users) async {
    if (users.isEmpty) {
      return;
    }
    final members = users.toList(growable: false);

    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.72;
        final title = context.l10n.workspaceTripMembers;
        final youLabel = context.l10n.youLabel;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$title (${members.length})',
                        style: Theme.of(sheetContext).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        sheetContext,
                      ).closeButtonTooltip,
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  itemCount: members.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final user = members[index];
                    final isCurrent = user.id == _currentUserId;
                    final name = user.preferredName.trim().isEmpty
                        ? context.l10n.userWithId(user.id)
                        : user.preferredName.trim();

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          Navigator.of(sheetContext).pop();
                          await Future<void>.delayed(
                            const Duration(milliseconds: 120),
                          );
                          if (!mounted) {
                            return;
                          }
                          await _openTripMemberProfilePage(user);
                        },
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(sheetContext)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(sheetContext)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              _largeMemberAvatar(
                                id: user.id,
                                name: name,
                                avatarUrl:
                                    user.avatarThumbUrl ?? user.avatarUrl,
                                size: 36,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(sheetContext)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(sheetContext)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    youLabel,
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(
                                            sheetContext,
                                          ).colorScheme.primary,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAddMembersDialog() async {
    if (!_canEditMembers || _snapshot == null || _isMutating) {
      return;
    }

    final memberIds = _snapshot!.users.map((user) => user.id).toSet();
    final selected = await _showAddMembersSearchDialog(
      existingMemberIds: memberIds,
    );

    if (selected == null || selected.isEmpty || !mounted) {
      return;
    }

    await _runMutation(
      action: () async {
        final added = await widget.tripsController.addMembers(
          tripId: widget.trip.id,
          memberIds: selected.toList(growable: false),
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(
            added > 0
                ? context.l10n.addedMembersCount(added)
                : context.l10n.noNewMembersAdded,
          );
        }
      },
    );
  }

  Future<Set<int>?> _showAddMembersSearchDialog({
    required Set<int> existingMemberIds,
  }) async {
    final selected = <int>{};
    final selectedUsers = <int, TripUser>{};
    BuildContext? dialogBuildContext;
    var isInviteLinkLoading = false;
    var inviteLinkRequested = false;
    var inviteLink = '';
    String? inviteLinkErrorText;
    String? inviteLinkExpiresAt;
    var friendQuickPicks = const <TripUser>[];
    var isLoadingFriendQuickPicks = false;
    var friendQuickPicksRequested = false;
    String? friendQuickPicksErrorText;

    return await showDialog<Set<int>>(
      context: context,
      builder: (dialogContext) {
        final t = dialogContext.l10n;

        Future<void> loadFriendQuickPicks(StateSetter setDialogState) async {
          if (isLoadingFriendQuickPicks) {
            return;
          }

          bool canUpdateDialog() {
            final c = dialogBuildContext;
            return mounted && c != null && c.mounted;
          }

          setDialogState(() {
            isLoadingFriendQuickPicks = true;
            friendQuickPicksErrorText = null;
          });

          try {
            final cached = widget.friendsController.peekSnapshotCache(
              allowStale: false,
            );
            final snapshot =
                cached ??
                await widget.friendsController.loadSnapshot(
                  forceRefresh: false,
                );
            if (!canUpdateDialog()) {
              return;
            }

            setDialogState(() {
              friendQuickPicks = snapshot.friends
                  .where((friend) => !existingMemberIds.contains(friend.id))
                  .map(
                    (friend) => TripUser(
                      id: friend.id,
                      nickname: friend.nickname,
                      avatarUrl: friend.avatarUrl,
                      avatarThumbUrl: friend.avatarThumbUrl,
                    ),
                  )
                  .toList(growable: false);
            });
          } catch (_) {
            if (!canUpdateDialog()) {
              return;
            }
            setDialogState(() {
              friendQuickPicks = const <TripUser>[];
              friendQuickPicksErrorText =
                  context.l10n.workspaceFailedToLoadFriends;
            });
          } finally {
            if (canUpdateDialog()) {
              setDialogState(() {
                isLoadingFriendQuickPicks = false;
              });
            }
          }
        }

        Future<void> loadInviteLink(StateSetter setDialogState) async {
          if (isInviteLinkLoading) {
            return;
          }
          bool canUpdateDialog() {
            final c = dialogBuildContext;
            return mounted && c != null && c.mounted;
          }

          setDialogState(() {
            isInviteLinkLoading = true;
            inviteLinkErrorText = null;
          });

          try {
            final payload = await widget.tripsController.createTripInviteLink(
              tripId: widget.trip.id,
            );
            if (!canUpdateDialog()) {
              return;
            }
            setDialogState(() {
              inviteLink = payload.inviteUrl.trim();
              inviteLinkExpiresAt = payload.expiresAt;
              inviteLinkErrorText = null;
            });
          } on ApiException catch (error) {
            if (!canUpdateDialog()) {
              return;
            }
            final normalized = error.message.trim();
            setDialogState(() {
              inviteLinkErrorText = normalized.isNotEmpty
                  ? normalized
                  : context.l10n.workspaceFailedToGenerateInviteLink;
            });
          } catch (_) {
            if (!canUpdateDialog()) {
              return;
            }
            setDialogState(() {
              inviteLinkErrorText =
                  context.l10n.workspaceFailedToGenerateInviteLink;
            });
          } finally {
            if (canUpdateDialog()) {
              setDialogState(() {
                isInviteLinkLoading = false;
              });
            }
          }
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            dialogBuildContext = context;
            if (!inviteLinkRequested) {
              inviteLinkRequested = true;
              unawaited(loadInviteLink(setDialogState));
            }
            if (!friendQuickPicksRequested) {
              friendQuickPicksRequested = true;
              unawaited(loadFriendQuickPicks(setDialogState));
            }

            return AlertDialog(
              title: Text(t.addTripMembersTitle),
              content: SizedBox(
                width: 430,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.workspaceInviteLink,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant
                                .withValues(alpha: 0.55),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: isInviteLinkLoading
                                  ? Text(
                                      context
                                          .l10n
                                          .workspaceGeneratingInviteLink,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    )
                                  : Text(
                                      inviteLink.isEmpty
                                          ? context
                                                .l10n
                                                .workspaceInviteLinkUnavailable
                                          : inviteLink,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                            ),
                            IconButton(
                              tooltip: context.l10n.workspaceCopyInviteLink,
                              onPressed:
                                  isInviteLinkLoading || inviteLink.isEmpty
                                  ? null
                                  : () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: inviteLink),
                                      );
                                      if (!mounted) {
                                        return;
                                      }
                                      _showSnack(
                                        context.l10n.workspaceInviteLinkCopied,
                                      );
                                    },
                              icon: const Icon(Icons.copy_all_outlined),
                            ),
                          ],
                        ),
                      ),
                      if (inviteLinkErrorText != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          inviteLinkErrorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (!isInviteLinkLoading &&
                          inviteLinkErrorText == null &&
                          inviteLinkExpiresAt != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.workspaceExpiresUtc(
                            inviteLinkExpiresAt!,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        t.selectedPeopleLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      if (selectedUsers.isEmpty)
                        Text(
                          t.workspaceNoMembersSelectedYet,
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final user in selectedUsers.values)
                              InputChip(
                                label: Text(user.nickname),
                                selected: true,
                                onDeleted: () {
                                  setDialogState(() {
                                    selected.remove(user.id);
                                    selectedUsers.remove(user.id);
                                  });
                                },
                              ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.navFriends,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (isLoadingFriendQuickPicks) ...[
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(minHeight: 2),
                      ] else ...[
                        const SizedBox(height: 8),
                      ],
                      if (friendQuickPicksErrorText != null)
                        Text(
                          friendQuickPicksErrorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else if (friendQuickPicks.isEmpty)
                        Text(
                          context
                              .l10n
                              .workspaceNoFriendsAvailableAddFriendsFirst,
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final friend in friendQuickPicks)
                              FilterChip(
                                label: Text(friend.nickname),
                                selected: selected.contains(friend.id),
                                onSelected: (isSelected) {
                                  setDialogState(() {
                                    if (isSelected) {
                                      selected.add(friend.id);
                                      selectedUsers[friend.id] = friend;
                                    } else {
                                      selected.remove(friend.id);
                                      selectedUsers.remove(friend.id);
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.cancelAction),
                ),
                ElevatedButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(selected),
                  child: Text(t.addAction),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
