part of 'trips_page.dart';

extension _TripsPageDialogs on _TripsPageState {
  Future<_CreateTripResult?> _showCreateTripDialog() async {
    final nameController = TextEditingController();
    Uint8List? selectedImageBytes;
    String? selectedImageName;
    final selected = <int>{};
    final selectedUsers = <int, TripUser>{};
    BuildContext? dialogBuildContext;
    var friendQuickPicks = const <TripUser>[];
    var isLoadingFriendQuickPicks = false;
    var friendQuickPicksRequested = false;
    var selectedCurrencyCode = AppCurrencyCatalog.defaultCode;
    DateTime? tripDateFrom;
    DateTime? tripDateTo;

    try {
      return await Navigator.of(context).push<_CreateTripResult>(
        AppFormPageRoute<_CreateTripResult>(
          builder: (sheetContext) {
            final t = sheetContext.l10n;
            String? errorText;
            String formatTripDate(DateTime value) {
              final dd = value.day.toString().padLeft(2, '0');
              final mm = value.month.toString().padLeft(2, '0');
              final yyyy = value.year.toString().padLeft(4, '0');
              return '$dd.$mm.$yyyy';
            }

            String? toIsoDate(DateTime? value) {
              if (value == null) {
                return null;
              }
              final normalized = DateTime(value.year, value.month, value.day);
              final mm = normalized.month.toString().padLeft(2, '0');
              final dd = normalized.day.toString().padLeft(2, '0');
              return '${normalized.year}-$mm-$dd';
            }

            Future<DateTime?> pickTripDate({
              required DateTime initialDate,
              required DateTime firstDate,
              required DateTime lastDate,
            }) async {
              final picked = await showDatePicker(
                context: sheetContext,
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
              );
              if (picked == null) {
                return null;
              }
              return DateTime(picked.year, picked.month, picked.day);
            }

            Future<void> loadFriendQuickPicks(
              StateSetter setDialogState,
            ) async {
              if (isLoadingFriendQuickPicks) {
                return;
              }
              bool canUpdateDialog() {
                final c = dialogBuildContext;
                return mounted && c != null && c.mounted;
              }

              setDialogState(() {
                isLoadingFriendQuickPicks = true;
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
                });
              } finally {
                if (canUpdateDialog()) {
                  setDialogState(() {
                    isLoadingFriendQuickPicks = false;
                  });
                }
              }
            }

            Future<void> onPickTripImage(StateSetter setDialogState) async {
              final hasImage = selectedImageBytes != null;
              final selectedSource =
                  await showAppBottomSheet<_TripImageSourceOption>(
                    context: context,
                    builder: (bottomSheetContext) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppActionSheetTile(
                            icon: Icons.photo_camera_outlined,
                            title: t.takePhotoAction,
                            onTap: () => Navigator.of(
                              bottomSheetContext,
                            ).pop(_TripImageSourceOption.camera),
                          ),
                          AppActionSheetTile(
                            icon: Icons.photo_library_outlined,
                            title: t.chooseFromLibraryAction,
                            onTap: () => Navigator.of(
                              bottomSheetContext,
                            ).pop(_TripImageSourceOption.library),
                          ),
                          if (hasImage)
                            AppActionSheetTile(
                              icon: Icons.delete_outline,
                              title: context.l10n.profileRemoveImage,
                              destructive: true,
                              onTap: () => Navigator.of(
                                bottomSheetContext,
                              ).pop(_TripImageSourceOption.remove),
                            ),
                        ],
                      );
                    },
                  );
              if (!mounted || !context.mounted || selectedSource == null) {
                return;
              }
              if (selectedSource == _TripImageSourceOption.remove) {
                setDialogState(() {
                  selectedImageBytes = null;
                  selectedImageName = null;
                });
                return;
              }
              final source = selectedSource == _TripImageSourceOption.camera
                  ? ImageSource.camera
                  : ImageSource.gallery;
              final picked = await _pickTripImageForUploadFromSource(source);
              if (!mounted || !context.mounted || picked == null) {
                return;
              }
              setDialogState(() {
                selectedImageBytes = picked.bytes;
                selectedImageName = picked.fileName;
              });
            }

            Future<String?> pickCurrencyCode(
              BuildContext dialogContext,
              String currentCode,
            ) async {
              var query = '';
              return showAppBottomSheet<String>(
                context: dialogContext,
                builder: (pickerContext) {
                  final maxHeight =
                      MediaQuery.sizeOf(pickerContext).height * 0.62;
                  return SizedBox(
                    height: maxHeight,
                    child: StatefulBuilder(
                      builder: (context, setPickerState) {
                        final normalizedQuery = query.trim().toUpperCase();
                        final filtered = AppCurrencyCatalog.supported
                            .where((item) {
                              if (normalizedQuery.isEmpty) {
                                return true;
                              }
                              final label = AppCurrencyCatalog.labelForCode(
                                item.code,
                                context.l10n,
                              );
                              final haystack =
                                  '${item.code} $label ${item.symbol}'
                                      .toUpperCase();
                              return haystack.contains(normalizedQuery);
                            })
                            .toList(growable: false);

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                              child: TextField(
                                textInputAction: TextInputAction.search,
                                onChanged: (value) {
                                  setPickerState(() {
                                    query = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      context.l10n.profileEditSearchCurrency,
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: filtered.isEmpty
                                  ? Center(
                                      child: Text(
                                        context
                                            .l10n
                                            .profileEditNoCurrenciesFound,
                                        style: Theme.of(
                                          pickerContext,
                                        ).textTheme.bodyMedium,
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        0,
                                        12,
                                        12,
                                      ),
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(height: 6),
                                      itemBuilder: (context, index) {
                                        final item = filtered[index];
                                        final selected =
                                            item.code == currentCode;
                                        return Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            onTap: () => Navigator.of(
                                              pickerContext,
                                            ).pop(item.code),
                                            child: Ink(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    12,
                                                    10,
                                                    12,
                                                    10,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                color: selected
                                                    ? Theme.of(pickerContext)
                                                          .colorScheme
                                                          .primary
                                                          .withValues(
                                                            alpha: 0.10,
                                                          )
                                                    : Theme.of(pickerContext)
                                                          .colorScheme
                                                          .surfaceContainerHighest
                                                          .withValues(
                                                            alpha: 0.45,
                                                          ),
                                                border: Border.all(
                                                  color: selected
                                                      ? Theme.of(
                                                          pickerContext,
                                                        ).colorScheme.primary
                                                      : AppDesign.cardStroke(
                                                          pickerContext,
                                                        ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 34,
                                                    height: 34,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Theme.of(
                                                        pickerContext,
                                                      ).colorScheme.surface,
                                                      border: Border.all(
                                                        color:
                                                            AppDesign.cardStroke(
                                                              pickerContext,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      item.symbol,
                                                      style:
                                                          Theme.of(
                                                                pickerContext,
                                                              )
                                                              .textTheme
                                                              .titleMedium
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      '${item.code} - ${AppCurrencyCatalog.labelForCode(item.code, context.l10n)}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          Theme.of(
                                                                pickerContext,
                                                              )
                                                              .textTheme
                                                              .titleSmall
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                    ),
                                                  ),
                                                  if (selected)
                                                    Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: Theme.of(
                                                        pickerContext,
                                                      ).colorScheme.primary,
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
                        );
                      },
                    ),
                  );
                },
              );
            }

            return StatefulBuilder(
              builder: (context, setDialogState) {
                dialogBuildContext = context;
                AppCurrencyOption selectedCurrency =
                    AppCurrencyCatalog.supported.first;
                for (final item in AppCurrencyCatalog.supported) {
                  if (item.code == selectedCurrencyCode) {
                    selectedCurrency = item;
                    break;
                  }
                }
                final viewInsetsBottom = MediaQuery.of(
                  context,
                ).viewInsets.bottom;
                if (!friendQuickPicksRequested) {
                  friendQuickPicksRequested = true;
                  unawaited(loadFriendQuickPicks(setDialogState));
                }

                return AppFormScaffold(
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.only(bottom: viewInsetsBottom),
                    child: SizedBox.expand(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                t.createNewTripTitle,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () => unawaited(
                                          onPickTripImage(setDialogState),
                                        ),
                                        behavior: HitTestBehavior.opaque,
                                        child: SizedBox(
                                          width: 62,
                                          height: 62,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                width: 56,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppDesign.cardStroke(
                                                      context,
                                                    ),
                                                  ),
                                                  gradient:
                                                      selectedImageBytes == null
                                                      ? AppDesign.brandGradient
                                                      : null,
                                                ),
                                                alignment: Alignment.center,
                                                child:
                                                    selectedImageBytes == null
                                                    ? const Icon(
                                                        Icons.image_outlined,
                                                        color: Colors.white,
                                                        size: 22,
                                                      )
                                                    : ClipOval(
                                                        child: Image.memory(
                                                          selectedImageBytes!,
                                                          width: 56,
                                                          height: 56,
                                                          fit: BoxFit.cover,
                                                          gaplessPlayback: true,
                                                        ),
                                                      ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.surface,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color:
                                                          AppDesign.cardStroke(
                                                            context,
                                                          ),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.photo_camera_rounded,
                                                    size: 14,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
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
                                      ),
                                    ],
                                  ),
                                  if (selectedImageName != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      context.l10n.tripsSelectedImage(
                                        selectedImageName!,
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Text(
                                    context.l10n.tripsTripDates,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          onTap: () async {
                                            final now = DateTime.now();
                                            final picked = await pickTripDate(
                                              initialDate:
                                                  tripDateFrom ??
                                                  tripDateTo ??
                                                  DateTime(
                                                    now.year,
                                                    now.month,
                                                    now.day,
                                                  ),
                                              firstDate: DateTime(2020, 1, 1),
                                              lastDate: DateTime(2100, 12, 31),
                                            );
                                            if (!mounted || picked == null) {
                                              return;
                                            }
                                            setDialogState(() {
                                              tripDateFrom = picked;
                                              if (tripDateTo != null &&
                                                  tripDateTo!.isBefore(
                                                    picked,
                                                  )) {
                                                tripDateTo = picked;
                                              }
                                              errorText = null;
                                            });
                                          },
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              labelText: context.l10n.tripsFrom,
                                              suffixIcon: const Icon(
                                                Icons.calendar_today_outlined,
                                                size: 18,
                                              ),
                                            ),
                                            child: Text(
                                              tripDateFrom == null
                                                  ? context.l10n.tripsSelectDate
                                                  : formatTripDate(
                                                      tripDateFrom!,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          onTap: () async {
                                            final now = DateTime.now();
                                            final firstDate =
                                                tripDateFrom ??
                                                DateTime(2020, 1, 1);
                                            final initial =
                                                tripDateTo ??
                                                tripDateFrom ??
                                                DateTime(
                                                  now.year,
                                                  now.month,
                                                  now.day,
                                                );
                                            final picked = await pickTripDate(
                                              initialDate:
                                                  initial.isBefore(firstDate)
                                                  ? firstDate
                                                  : initial,
                                              firstDate: firstDate,
                                              lastDate: DateTime(2100, 12, 31),
                                            );
                                            if (!mounted || picked == null) {
                                              return;
                                            }
                                            setDialogState(() {
                                              tripDateTo = picked;
                                              errorText = null;
                                            });
                                          },
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              labelText: context.l10n.tripsTo,
                                              suffixIcon: const Icon(
                                                Icons.calendar_today_outlined,
                                                size: 18,
                                              ),
                                            ),
                                            child: Text(
                                              tripDateTo == null
                                                  ? context.l10n.tripsSelectDate
                                                  : formatTripDate(tripDateTo!),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    context.l10n.tripsMainCurrency,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(18),
                                      onTap: () async {
                                        final picked = await pickCurrencyCode(
                                          sheetContext,
                                          selectedCurrencyCode,
                                        );
                                        if (!mounted ||
                                            !context.mounted ||
                                            picked == null) {
                                          return;
                                        }
                                        setDialogState(() {
                                          selectedCurrencyCode =
                                              AppCurrencyCatalog.normalize(
                                                picked,
                                              );
                                        });
                                      },
                                      child: Ink(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          12,
                                          12,
                                          12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: AppDesign.cardStroke(
                                              context,
                                            ),
                                          ),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.35),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 34,
                                              height: 34,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                border: Border.all(
                                                  color: AppDesign.cardStroke(
                                                    context,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                selectedCurrency.symbol,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                '${selectedCurrency.code} - ${AppCurrencyCatalog.labelForCode(selectedCurrency.code, context.l10n)}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    t.selectedPeopleLabel,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 6),
                                  if (selectedUsers.isEmpty)
                                    Text(
                                      t.workspaceNoMembersSelectedYet,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
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
                                  if (isLoadingFriendQuickPicks) ...[
                                    const SizedBox(height: 10),
                                    const LinearProgressIndicator(minHeight: 2),
                                  ],
                                  if (friendQuickPicks.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final friend in friendQuickPicks)
                                          FilterChip(
                                            label: Text(friend.nickname),
                                            selected: selected.contains(
                                              friend.id,
                                            ),
                                            onSelected: (isSelected) {
                                              setDialogState(() {
                                                if (isSelected) {
                                                  selected.add(friend.id);
                                                  selectedUsers[friend.id] =
                                                      friend;
                                                } else {
                                                  selected.remove(friend.id);
                                                  selectedUsers.remove(
                                                    friend.id,
                                                  );
                                                }
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                  if (errorText != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      errorText!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () =>
                                        Navigator.of(sheetContext).pop(),
                                    child: Text(t.cancelAction),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final name = nameController.text.trim();
                                      if (name.length < 2 ||
                                          name.length > 120) {
                                        setDialogState(() {
                                          errorText =
                                              t.tripNameLengthValidation;
                                        });
                                        return;
                                      }
                                      if (tripDateFrom == null ||
                                          tripDateTo == null) {
                                        setDialogState(() {
                                          errorText = context
                                              .l10n
                                              .tripsPleaseSelectTripPeriodFromAndToDates;
                                        });
                                        return;
                                      }
                                      if (tripDateTo!.isBefore(tripDateFrom!)) {
                                        setDialogState(() {
                                          errorText = context
                                              .l10n
                                              .tripsTripEndDateMustBeOnOrAfterStartDate;
                                        });
                                        return;
                                      }
                                      final dateFromIso = toIsoDate(
                                        tripDateFrom,
                                      );
                                      final dateToIso = toIsoDate(tripDateTo);
                                      if (dateFromIso == null ||
                                          dateToIso == null) {
                                        setDialogState(() {
                                          errorText = context
                                              .l10n
                                              .tripsTripPeriodFormatIsInvalidPleasePickDatesAgain;
                                        });
                                        return;
                                      }

                                      final memberIds = selected.toList(
                                        growable: false,
                                      )..sort();
                                      Navigator.of(sheetContext).pop(
                                        _CreateTripResult(
                                          name: name,
                                          currencyCode: selectedCurrencyCode,
                                          memberIds: memberIds,
                                          dateFrom: dateFromIso,
                                          dateTo: dateToIso,
                                          imageFileName: selectedImageName,
                                          imageBytes: selectedImageBytes,
                                        ),
                                      );
                                    },
                                    child: Text(t.createAction),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    } finally {
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        nameController.dispose();
      });
    }
  }
}

enum _TripImageSourceOption { camera, library, remove }
