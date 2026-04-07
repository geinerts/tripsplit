part of 'workspace_page.dart';

extension _WorkspacePageMembersActions on _WorkspacePageState {
  Future<void> _openTripMembersListSheet(List<WorkspaceUser> users) async {
    if (users.isEmpty) {
      return;
    }
    final members = users.toList(growable: false);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.72;
        final title = _plainLocalizedText(
          en: 'Trip members',
          lv: 'Trip dalībnieki',
        );
        final youLabel = _plainLocalizedText(en: 'You', lv: 'Tu');

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
    final searchController = TextEditingController();
    final selected = <int>{};
    final selectedUsers = <int, TripUser>{};
    BuildContext? dialogBuildContext;
    var searchResults = const <TripUser>[];
    var isSearching = false;
    var isInviteLinkLoading = false;
    var inviteLinkRequested = false;
    var inviteLink = '';
    String? inviteLinkErrorText;
    String? inviteLinkExpiresAt;
    var searchSeq = 0;
    Timer? searchDebounce;

    try {
      return await showDialog<Set<int>>(
        context: context,
        builder: (dialogContext) {
          final t = dialogContext.l10n;
          String? searchErrorText;

          Future<void> runSearch(
            StateSetter setDialogState,
            String rawQuery,
          ) async {
            final query = rawQuery.trim();
            if (query.length < 2) {
              setDialogState(() {
                isSearching = false;
                searchErrorText = null;
                searchResults = const <TripUser>[];
              });
              return;
            }
            final requestId = ++searchSeq;

            bool canUpdateDialog() {
              final c = dialogBuildContext;
              return mounted &&
                  c != null &&
                  c.mounted &&
                  requestId == searchSeq;
            }

            setDialogState(() {
              isSearching = true;
              searchErrorText = null;
            });

            try {
              final users = await widget.tripsController.loadDirectoryUsers(
                query: query,
                limit: 25,
                excludeIds: existingMemberIds.toList(growable: false),
              );
              if (!canUpdateDialog()) {
                return;
              }
              setDialogState(() {
                searchResults = users
                    .where((user) => !existingMemberIds.contains(user.id))
                    .toList(growable: false);
                for (final user in searchResults) {
                  if (selected.contains(user.id)) {
                    selectedUsers[user.id] = user;
                  }
                }
              });
            } on ApiException catch (error) {
              if (!canUpdateDialog()) {
                return;
              }
              setDialogState(() {
                searchResults = const <TripUser>[];
                searchErrorText = error.message;
              });
            } catch (_) {
              if (!canUpdateDialog()) {
                return;
              }
              setDialogState(() {
                searchResults = const <TripUser>[];
                searchErrorText = t.failedToLoadUsersDirectory;
              });
            } finally {
              if (canUpdateDialog()) {
                setDialogState(() {
                  isSearching = false;
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
                    : _plainLocalizedText(
                        en: 'Failed to generate invite link.',
                        lv: 'Neizdevās izveidot ielūguma saiti.',
                      );
              });
            } catch (_) {
              if (!canUpdateDialog()) {
                return;
              }
              setDialogState(() {
                inviteLinkErrorText = _plainLocalizedText(
                  en: 'Failed to generate invite link.',
                  lv: 'Neizdevās izveidot ielūguma saiti.',
                );
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

              final hasQuery = searchController.text.trim().isNotEmpty;

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
                          _plainLocalizedText(
                            en: 'Invite link',
                            lv: 'Ielūguma saite',
                          ),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.55),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: isInviteLinkLoading
                                    ? Text(
                                        _plainLocalizedText(
                                          en: 'Generating invite link...',
                                          lv: 'Veido ielūguma saiti...',
                                        ),
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
                                            ? _plainLocalizedText(
                                                en: 'Invite link unavailable.',
                                                lv: 'Ielūguma saite nav pieejama.',
                                              )
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
                                tooltip: _plainLocalizedText(
                                  en: 'Copy invite link',
                                  lv: 'Kopēt ielūguma saiti',
                                ),
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
                                          _plainLocalizedText(
                                            en: 'Invite link copied.',
                                            lv: 'Ielūguma saite nokopēta.',
                                          ),
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
                            _plainLocalizedText(
                              en: 'Expires: $inviteLinkExpiresAt UTC',
                              lv: 'Derīga līdz: $inviteLinkExpiresAt UTC',
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
                            'No members selected yet.',
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
                          t.searchUsersHint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: t.searchUsersHint,
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            searchDebounce?.cancel();
                            final query = value.trim();
                            if (query.length < 2) {
                              setDialogState(() {
                                isSearching = false;
                                searchErrorText = null;
                                searchResults = const <TripUser>[];
                              });
                              return;
                            }
                            searchDebounce = Timer(
                              const Duration(milliseconds: 320),
                              () => runSearch(setDialogState, query),
                            );
                          },
                        ),
                        if (isSearching) ...[
                          const SizedBox(height: 10),
                          const LinearProgressIndicator(minHeight: 2),
                        ],
                        const SizedBox(height: 10),
                        if (searchErrorText != null)
                          Text(
                            searchErrorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (!hasQuery)
                          Text(
                            'Type at least 2 letters to search members.',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        else if (searchResults.isEmpty)
                          Text(t.noSearchMatches)
                        else
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 260),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: searchResults.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final user = searchResults[index];
                                final isPicked = selected.contains(user.id);
                                return CheckboxListTile(
                                  dense: true,
                                  value: isPicked,
                                  title: Text(user.nickname),
                                  onChanged: (checked) {
                                    setDialogState(() {
                                      if (checked == true) {
                                        selected.add(user.id);
                                        selectedUsers[user.id] = user;
                                      } else {
                                        selected.remove(user.id);
                                        selectedUsers.remove(user.id);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
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
    } finally {
      searchDebounce?.cancel();
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        searchController.dispose();
      });
    }
  }
}
