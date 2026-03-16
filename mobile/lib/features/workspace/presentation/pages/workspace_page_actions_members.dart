part of 'workspace_page.dart';

extension _WorkspacePageMembersActions on _WorkspacePageState {
  Future<void> _openAddMembersDialog() async {
    if (!_canEditMembers || _snapshot == null || _isMutating) {
      return;
    }

    final memberIds = _snapshot!.users.map((user) => user.id).toSet();
    final selected = await _showAddMembersSearchDialog(existingMemberIds: memberIds);

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
    var searchSeq = 0;
    Timer? searchDebounce;

    try {
      return await showDialog<Set<int>>(
        context: context,
        builder: (dialogContext) {
          final t = dialogContext.l10n;
          String? searchErrorText;

          Future<void> runSearch(StateSetter setDialogState, String rawQuery) async {
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
              return mounted && c != null && c.mounted && requestId == searchSeq;
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

          return StatefulBuilder(
            builder: (context, setDialogState) {
              dialogBuildContext = context;

              final hasQuery = searchController.text.trim().isNotEmpty;
              final inviteLink = _buildDemoMembersInviteLink();

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
                          'Invite link (demo)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.45,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant.withValues(alpha: 0.55),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  inviteLink,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Copy invite link',
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: inviteLink),
                                  );
                                  if (!mounted) {
                                    return;
                                  }
                                  _showSnack('Demo invite link copied.');
                                },
                                icon: const Icon(Icons.copy_all_outlined),
                              ),
                            ],
                          ),
                        ),
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

  String _buildDemoMembersInviteLink() {
    final slug = _slugifyTripInviteName(widget.trip.name);
    final compactSlug = slug.replaceAll('-', '').toUpperCase();
    final seed = '${compactSlug}T${widget.trip.id}';
    final prefix = seed.length >= 8 ? seed.substring(0, 8) : seed.padRight(8, 'X');
    final code = '$prefix-DEMO';
    return 'https://egm.lv/projekti/trip/join/$code';
  }

  String _slugifyTripInviteName(String rawName) {
    final normalized = rawName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    if (normalized.isEmpty) {
      return 'trip';
    }
    return normalized;
  }
}
