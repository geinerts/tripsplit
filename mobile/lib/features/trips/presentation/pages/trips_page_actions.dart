part of 'trips_page.dart';

extension _TripsPageActions on _TripsPageState {
  Future<void> _loadTrips({bool forceRefresh = true}) async {
    final trace = PerfMonitor.start('screen.trips.load');
    var success = false;
    final cached = widget.controller.peekTripsCache(allowStale: true);
    if (_trips.isEmpty && cached != null) {
      _updateState(() {
        _trips = cached;
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
      final trips = await widget.controller.loadTrips(forceRefresh: forceRefresh);
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
    if (_isMutating) {
      return;
    }

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
        memberIds: result.memberIds,
      );
      final imageBytes = result.imageBytes;
      final imageFileName = result.imageFileName?.trim() ?? '';
      if (imageBytes != null && imageBytes.isNotEmpty && imageFileName.isNotEmpty) {
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
            'Trip created, but image upload failed: ${error.message}',
            isError: true,
          );
        } catch (_) {
          _showSnack('Trip created, but image upload failed.', isError: true);
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
  }

  bool _isTripOwner(Trip trip) {
    final userId = widget.authController.currentUser?.id ?? 0;
    if (userId <= 0) {
      return false;
    }
    return (trip.createdBy ?? 0) == userId;
  }

  Future<void> _openTripActions(Trip trip) async {
    final t = context.l10n;
    final canEdit = _isTripOwner(trip);
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: Text(t.openLabel),
                onTap: () => Navigator.of(sheetContext).pop('open'),
              ),
              if (canEdit)
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text('${t.editAction} ${t.tripTitleShort}'),
                  onTap: () => Navigator.of(sheetContext).pop('edit'),
                ),
            ],
          ),
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
    await _openWorkspace(trip);
  }

  Future<void> _onEditTripPressed(Trip trip) async {
    if (_isMutating) {
      return;
    }
    if (!_isTripOwner(trip)) {
      _showSnack('Only trip creator can edit this trip.', isError: true);
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
    final hasNewImage = imageBytes != null && imageBytes.isNotEmpty && imageFileName.isNotEmpty;
    if (!hasNameChange && !hasNewImage) {
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
      );
      if (!mounted) {
        return;
      }
      _showSnack('Trip updated.');
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
      _showSnack('Failed to update trip.', isError: true);
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

  Future<void> _openProfile() async {
    await Navigator.of(context).pushNamed(AppRouter.profile);
    if (!mounted) {
      return;
    }
    await _loadTrips();
  }

  Future<void> _openSettingsSheet() async {
    if (_isMutating) {
      return;
    }

    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final t = sheetContext.l10n;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: Text(t.appearance),
                onTap: () => Navigator.of(sheetContext).pop('appearance'),
              ),
              ListTile(
                leading: const Icon(Icons.translate_outlined),
                title: Text(t.languageAction),
                onTap: () => Navigator.of(sheetContext).pop('language'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(t.logOutButton),
                onTap: () => Navigator.of(sheetContext).pop('logout'),
              ),
            ],
          ),
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

  Future<void> _onBottomNavTapped(int index) async {
    switch (index) {
      case 0:
        return;
      case 1:
        await _openCreateTripDialog();
        return;
      case 2:
        _showSnack(context.l10n.friendsSectionComingSoon);
        return;
      case 3:
        await _openProfile();
        return;
      default:
        return;
    }
  }

  Future<void> _onLogoutPressed() async {
    if (_isMutating) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final t = context.l10n;
        return AlertDialog(
          title: Text(t.logOutButton),
          content: Text(t.logoutFromDeviceQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.cancelAction),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.logOutButton),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
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
      ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
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
