part of 'trips_page.dart';

extension _TripsPageDialogs on _TripsPageState {
  Future<_CreateTripResult?> _showCreateTripDialog() async {
    final nameController = TextEditingController();
    final searchController = TextEditingController();
    Uint8List? selectedImageBytes;
    String? selectedImageName;
    final selected = <int>{};
    final selectedUsers = <int, TripUser>{};
    BuildContext? dialogBuildContext;
    var searchResults = const <TripUser>[];
    var isSearching = false;
    var searchSeq = 0;
    Timer? searchDebounce;

    try {
      return await showDialog<_CreateTripResult>(
        context: context,
        builder: (context) {
          final t = context.l10n;
          String? errorText;
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
              final users = await widget.controller.loadDirectoryUsers(
                query: query,
                limit: 25,
              );
              if (!canUpdateDialog()) {
                return;
              }
              setDialogState(() {
                searchResults = users;
                for (final user in users) {
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

              return AlertDialog(
                title: Text(t.createNewTripTitle),
                content: SizedBox(
                  width: 450,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: t.tripNameLabel,
                            hintText: t.tripNameHint,
                          ),
                          onChanged: (_) {
                            setDialogState(() {
                              errorText = null;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await _pickTripImageForUpload();
                            if (!mounted || !context.mounted) {
                              return;
                            }
                            if (picked == null) {
                              return;
                            }
                            setDialogState(() {
                              selectedImageBytes = picked.bytes;
                              selectedImageName = picked.fileName;
                            });
                          },
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Choose trip image (optional)'),
                        ),
                        if (selectedImageName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Selected image: $selectedImageName',
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
                                  onChanged: (value) {
                                    setDialogState(() {
                                      if (value == true) {
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
                        if (errorText != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.length < 2 || name.length > 120) {
                        setDialogState(() {
                          errorText = t.tripNameLengthValidation;
                        });
                        return;
                      }

                      final memberIds = selected.toList(growable: false)
                        ..sort();
                      Navigator.of(context).pop(
                        _CreateTripResult(
                          name: name,
                          memberIds: memberIds,
                          imageFileName: selectedImageName,
                          imageBytes: selectedImageBytes,
                        ),
                      );
                    },
                    child: Text(t.createAction),
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
        nameController.dispose();
      });
    }
  }

}
