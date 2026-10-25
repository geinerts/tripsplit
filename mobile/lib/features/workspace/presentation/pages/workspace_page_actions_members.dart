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
                            ?.copyWith(fontWeight: FontWeight.w600),
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
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  itemCount: members.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = members[index];
                    final isCurrent = user.id == _currentUserId;
                    final canRemoveMember =
                        _canEditMembers && !isCurrent && !user.isOwner;
                    final name = user.preferredName.trim().isEmpty
                        ? context.l10n.userWithId(user.id)
                        : user.preferredName.trim();

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: ValueKey('member-row-${user.id}'),
                        borderRadius: AppDesign.cardRadius,
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
                                  maxLines: 2,
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
                              if (canRemoveMember)
                                IconButton(
                                  tooltip: context.l10n.memberRemoveAction,
                                  onPressed: _isMutating
                                      ? null
                                      : () async {
                                          Navigator.of(sheetContext).pop();
                                          await Future<void>.delayed(
                                            const Duration(milliseconds: 120),
                                          );
                                          if (!mounted) {
                                            return;
                                          }
                                          await _onRemoveTripMemberPressed(
                                            user,
                                          );
                                        },
                                  icon: const Icon(
                                    Icons.person_remove_alt_1_outlined,
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

  Future<void> _onRemoveTripMemberPressed(WorkspaceUser user) async {
    if (!_canEditMembers || _isMutating || user.isOwner) {
      return;
    }
    final name = user.preferredName.trim().isEmpty
        ? context.l10n.userWithId(user.id)
        : user.preferredName.trim();
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.memberRemoveTitle,
      message: context.l10n.memberRemoveBody(name),
      confirmLabel: context.l10n.memberRemoveAction,
      cancelLabel: context.l10n.cancelAction,
      icon: Icons.person_remove_alt_1_outlined,
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }

    await _runMutation(
      action: () async {
        await widget.tripsController.removeMember(
          tripId: widget.trip.id,
          userId: user.id,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.memberRemoved(name));
        }
      },
    );
  }

  Future<void> _openAddMembersDialog() async {
    if (widget.trip.isSolo ||
        !_canEditMembers ||
        _snapshot == null ||
        _isMutating) {
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
  }) => Navigator.of(context).push<Set<int>>(
    AppFormPageRoute(
      builder: (_) => TripInviteMembersPage(
        tripName: widget.trip.name,
        loadFriends: () async {
          final snapshot =
              widget.friendsController.peekSnapshotCache(allowStale: false) ??
              await widget.friendsController.loadSnapshot(forceRefresh: false);
          return snapshot.friends
              .where((friend) => !existingMemberIds.contains(friend.id))
              .map(
                (friend) => TripUser(
                  id: friend.id,
                  nickname: friend.nickname,
                  avatarUrl: friend.avatarUrl,
                  avatarThumbUrl: friend.avatarThumbUrl,
                ),
              )
              .toList();
        },
        loadLink: () =>
            widget.tripsController.createTripInviteLink(tripId: widget.trip.id),
        loadPending: () => widget.tripsController.listPendingInvitations(
          tripId: widget.trip.id,
        ),
        revoke: (id) => widget.tripsController.revokeInvitation(
          tripId: widget.trip.id,
          invitationId: id,
        ),
      ),
    ),
  );
}
