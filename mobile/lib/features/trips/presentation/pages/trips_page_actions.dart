part of 'trips_page.dart';

extension _TripsPageActions on _TripsPageState {
  Future<void> _loadTrips({bool forceRefresh = true}) async {
    final trace = PerfMonitor.start('screen.trips.load');
    var success = false;
    var cached = widget.controller.peekTripsCache(allowStale: true);
    if (_trips.isEmpty && cached == null) {
      cached = await widget.controller.primeTripsCacheFromDisk();
    }
    if (_trips.isEmpty && cached != null) {
      final cachedTrips = cached;
      _updateState(() {
        _trips = cachedTrips;
        _isLoading = false;
        _errorText = null;
      });
    }

    final shouldShowLoader = _trips.isEmpty;
    if (shouldShowLoader) {
      _updateState(() {
        _isLoading = true;
        _errorText = null;
      });
    } else {
      _updateState(() {
        _errorText = null;
      });
    }

    try {
      final trips = await widget.controller.loadTrips(
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }
      _updateState(() {
        _trips = trips;
        _errorText = null;
      });
      success = true;
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      if (_trips.isEmpty) {
        _updateState(() {
          _errorText = error.message;
        });
      } else {
        _showSnack(error.message, isError: true);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (_trips.isEmpty) {
        _updateState(() {
          _errorText = context.l10n.unexpectedErrorLoadingTrips;
        });
      } else {
        _showSnack(context.l10n.unexpectedErrorLoadingTrips, isError: true);
      }
    } finally {
      trace.stop(success: success);
      if (mounted) {
        _updateState(() {
          _isLoading = false;
        });
        if (_openCreateAfterLoad && _errorText == null) {
          _openCreateAfterLoad = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _openCreateTripDialog();
          });
        }
      }
    }
  }

  Future<void> _openCreateTripDialog() async {
    if (_isMutating || _isCreateTripDialogOpen) {
      return;
    }

    _isCreateTripDialogOpen = true;
    try {
      final result = await _showCreateTripDialog();
      if (result == null || !mounted) {
        return;
      }

      _updateState(() {
        _isMutating = true;
      });

      try {
        var createdTrip = await widget.controller.createTrip(
          name: result.name,
          currencyCode: result.currencyCode,
          memberIds: result.memberIds,
          dateFrom: result.dateFrom,
          dateTo: result.dateTo,
        );
        final imageBytes = result.imageBytes;
        final imageFileName = result.imageFileName?.trim() ?? '';
        if (imageBytes != null &&
            imageBytes.isNotEmpty &&
            imageFileName.isNotEmpty) {
          try {
            final uploaded = await widget.controller.uploadTripImage(
              tripId: createdTrip.id,
              fileName: imageFileName,
              bytes: imageBytes,
            );
            createdTrip = await widget.controller.updateTrip(
              tripId: createdTrip.id,
              name: createdTrip.name,
              imagePath: uploaded.path,
            );
          } on ApiException catch (error) {
            _showSnack(
              context.l10n.tripsTripCreatedButImageUploadFailedWithReason(
                error.message,
              ),
              isError: true,
            );
          } catch (_) {
            _showSnack(
              context.l10n.tripsTripCreatedButImageUploadFailed,
              isError: true,
            );
          }
        }
        if (!mounted) {
          return;
        }
        _showSnack(context.l10n.tripCreated(createdTrip.name));
        await _loadTrips();
      } on ApiException catch (error) {
        if (!mounted) {
          return;
        }
        _showSnack(error.message, isError: true);
      } catch (_) {
        if (!mounted) {
          return;
        }
        _showSnack(context.l10n.failedToCreateTrip, isError: true);
      } finally {
        if (mounted) {
          _updateState(() {
            _isMutating = false;
          });
        }
      }
    } finally {
      _isCreateTripDialogOpen = false;
    }
  }

  bool _isTripOwner(Trip trip) {
    final userId = widget.authController.currentUser?.id ?? 0;
    if (userId <= 0) {
      return false;
    }
    if (trip.canCurrentUserDeleteTrip) {
      return true;
    }
    return (trip.createdBy ?? 0) == userId;
  }

  bool _canManageTrip(Trip trip) {
    if (trip.canCurrentUserManageTrip) {
      return true;
    }
    return _isTripOwner(trip);
  }

  Future<void> _openTripActions(Trip trip) async {
    final t = context.l10n;
    final canEdit = trip.isActive && _canManageTrip(trip);
    final canDelete = trip.isActive && _isTripOwner(trip);
    final choice = await showAppBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppActionSheetTile(
              icon: Icons.open_in_new,
              title: t.openLabel,
              onTap: () => Navigator.of(sheetContext).pop('open'),
            ),
            if (canEdit)
              AppActionSheetTile(
                icon: Icons.edit_outlined,
                title: '${t.editAction} ${t.tripTitleShort}',
                onTap: () => Navigator.of(sheetContext).pop('edit'),
              ),
            if (canDelete)
              AppActionSheetTile(
                icon: Icons.delete_outline,
                title: '${t.deleteAction} ${t.tripTitleShort}',
                destructive: true,
                onTap: () => Navigator.of(sheetContext).pop('delete'),
              ),
          ],
        );
      },
    );

    if (!mounted || choice == null) {
      return;
    }
    if (choice == 'edit') {
      await _onEditTripPressed(trip);
      return;
    }
    if (choice == 'delete') {
      await _onDeleteTripPressed(trip);
      return;
    }
    await _openWorkspace(trip);
  }

  Future<void> _onEditTripPressed(Trip trip) async {
    if (_isMutating) {
      return;
    }
    if (!_canManageTrip(trip)) {
      _showSnack(
        context.l10n.workspaceOnlyTripCreatorCanEditThisTrip,
        isError: true,
      );
      return;
    }

    final result = await _showEditTripDialog(trip);
    if (result == null || !mounted) {
      return;
    }

    final nextName = result.name.trim();
    final hasNameChange = nextName != trip.name.trim();
    final imageBytes = result.imageBytes;
    final imageFileName = result.imageFileName?.trim() ?? '';
    final hasNewImage =
        imageBytes != null && imageBytes.isNotEmpty && imageFileName.isNotEmpty;
    final removeImage = result.removeImage && !hasNewImage;
    if (!hasNameChange && !hasNewImage && !removeImage) {
      _showSnack(context.l10n.noChangesToSave);
      return;
    }

    _updateState(() {
      _isMutating = true;
    });
    try {
      String? imagePath;
      if (hasNewImage) {
        final uploaded = await widget.controller.uploadTripImage(
          tripId: trip.id,
          fileName: imageFileName,
          bytes: imageBytes,
        );
        imagePath = uploaded.path;
      }
      await widget.controller.updateTrip(
        tripId: trip.id,
        name: nextName,
        imagePath: imagePath,
        removeImage: removeImage,
      );
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.workspaceTripUpdated);
      await _loadTrips();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.workspaceFailedToUpdateTrip, isError: true);
    } finally {
      if (mounted) {
        _updateState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _onDeleteTripPressed(Trip trip) async {
    if (_isMutating) {
      return;
    }
    if (!_isTripOwner(trip)) {
      _showSnack(context.l10n.shellOnlyTripCreatorCanDelete, isError: true);
      return;
    }
    if (!trip.isActive) {
      _showSnack(context.l10n.shellOnlyActiveTripsCanDelete, isError: true);
      return;
    }

    final t = context.l10n;
    final tripLabel = trip.name.trim().isEmpty
        ? t.tripWithId(trip.id)
        : trip.name;
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: '${t.deleteAction} ${t.tripTitleShort}',
      message: context.l10n
          .tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(tripLabel),
      confirmLabel: t.deleteAction,
      cancelLabel: t.cancelAction,
      icon: Icons.delete_outline,
      destructive: true,
    );

    if (!confirmed || !mounted) {
      return;
    }

    _updateState(() {
      _isMutating = true;
    });
    try {
      await widget.controller.deleteTrip(tripId: trip.id);
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.shellTripDeleted);
      await _loadTrips();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.shellFailedToDeleteTrip, isError: true);
    } finally {
      if (mounted) {
        _updateState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _openWorkspace(Trip trip, {bool openAddExpense = false}) async {
    final onTripOpened = widget.onTripOpened;
    if (onTripOpened != null) {
      onTripOpened(trip, openAddExpense: openAddExpense);
      return;
    }
    await Navigator.of(context).pushNamed(
      AppRouter.workspace,
      arguments: <String, Object>{
        'trip': trip,
        'open_add_expense': openAddExpense,
      },
    );
    if (!mounted) {
      return;
    }
    await _loadTrips();
  }

  Future<void> _openSettingsSheet() async {
    if (_isMutating) {
      return;
    }

    final choice = await showAppBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        final t = sheetContext.l10n;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppActionSheetTile(
              icon: Icons.brightness_6_outlined,
              title: t.appearance,
              onTap: () => Navigator.of(sheetContext).pop('appearance'),
            ),
            AppActionSheetTile(
              icon: Icons.translate_outlined,
              title: t.languageAction,
              onTap: () => Navigator.of(sheetContext).pop('language'),
            ),
            AppActionSheetTile(
              icon: Icons.logout,
              title: t.logOutButton,
              onTap: () => Navigator.of(sheetContext).pop('logout'),
            ),
          ],
        );
      },
    );

    if (!mounted || choice == null) {
      return;
    }

    switch (choice) {
      case 'appearance':
        showThemeModePicker(context);
        return;
      case 'language':
        showAppLocalePicker(context);
        return;
      case 'logout':
        await _onLogoutPressed();
        return;
      default:
        return;
    }
  }

  void _onBottomNavTapped(AppBottomNavItem item) {
    switch (item) {
      case AppBottomNavItem.home:
        return;
      case AppBottomNavItem.analytics:
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.shell,
            (route) => false,
            arguments: const <String, Object>{'initial_tab': 1},
          ),
        );
        return;
      case AppBottomNavItem.expenses:
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.shell,
            (route) => false,
            arguments: const <String, Object>{'open_add_expense': true},
          ),
        );
        return;
      case AppBottomNavItem.friends:
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.shell,
            (route) => false,
            arguments: const <String, Object>{'initial_tab': 3},
          ),
        );
        return;
      case AppBottomNavItem.profile:
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.shell,
            (route) => false,
            arguments: const <String, Object>{'initial_tab': 4},
          ),
        );
        return;
    }
  }

  Future<void> _onLogoutPressed() async {
    if (_isMutating) {
      return;
    }

    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.logOutButton,
      message: context.l10n.logoutFromDeviceQuestion,
      confirmLabel: context.l10n.logOutButton,
      cancelLabel: context.l10n.cancelAction,
      icon: Icons.logout_rounded,
      destructive: true,
    );

    if (!confirmed || !mounted) {
      return;
    }

    _updateState(() {
      _isMutating = true;
    });
    try {
      await widget.authController.logout();
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.authIntro, (route) => false);
    } finally {
      if (mounted) {
        _updateState(() {
          _isMutating = false;
        });
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }
}
