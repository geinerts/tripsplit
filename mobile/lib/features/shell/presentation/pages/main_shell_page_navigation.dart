part of 'main_shell_page.dart';

extension _MainShellPageNavigation on _MainShellPageState {
  void _requestCreateTrip() {
    if (_selectedTabIndex != _MainShellPageState._tabHome || _isWorkspaceOpen) {
      _updateState(() {
        _selectedTabIndex = _MainShellPageState._tabHome;
        _openedTrip = null;
        _openAddExpenseOnWorkspaceStart = false;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _tripsCommandController.requestOpenCreateTrip();
    });
  }

  Future<void> _requestAddExpenseFromNav() async {
    if (_isLoggingOut) {
      return;
    }

    final openedTrip = _openedTrip;
    if (openedTrip != null && openedTrip.isActive) {
      _workspaceCommandController.requestOpenAddExpense();
      return;
    }

    List<Trip> trips;
    try {
      trips = await widget.tripsController.loadTrips(forceRefresh: true);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.message.trim().isNotEmpty
          ? error.message.trim()
          : context.l10n.unexpectedErrorLoadingTrips;
      _showSnack(message, isError: true);
      return;
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.unexpectedErrorLoadingTrips, isError: true);
      return;
    }

    if (!mounted) {
      return;
    }
    if (trips.isEmpty) {
      _requestCreateTrip();
      return;
    }

    final targetTrip = await _pickActiveTripForExpense(trips);
    if (targetTrip == null || !mounted) {
      return;
    }
    _openWorkspaceInShell(targetTrip, openAddExpense: true);
  }

  Future<Trip?> _pickActiveTripForExpense(List<Trip> allTrips) async {
    final activeTrips = allTrips
        .where((trip) => trip.isActive)
        .toList(growable: false);
    if (activeTrips.isEmpty) {
      return null;
    }
    if (activeTrips.length == 1) {
      return activeTrips.first;
    }

    return showDialog<Trip>(
      context: context,
      builder: (context) {
        final t = context.l10n;
        return AlertDialog(
          title: Text(t.addExpensesAction),
          content: SizedBox(
            width: 420,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: activeTrips.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final trip = activeTrips[index];
                  return ListTile(
                    title: Text(
                      _tripDisplayName(context, trip),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pop(trip),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.cancelAction),
            ),
          ],
        );
      },
    );
  }

  String _tripDisplayName(BuildContext context, Trip trip) {
    final name = trip.name.trim();
    if (name.isNotEmpty) {
      return name;
    }
    return context.l10n.tripWithId(trip.id);
  }

  void _showSnack(String message, {required bool isError}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? Theme.of(context).colorScheme.errorContainer
            : null,
      ),
    );
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case _MainShellPageState._tabAddExpense:
        _requestAddExpenseFromNav();
        return;
      case _MainShellPageState._tabActivities:
        if (_selectedTabIndex != _MainShellPageState._tabActivities ||
            _isWorkspaceOpen) {
          _updateState(() {
            _selectedTabIndex = _MainShellPageState._tabActivities;
            _openedTrip = null;
            _openAddExpenseOnWorkspaceStart = false;
          });
        }
        return;
      case _MainShellPageState._tabFriends:
        if (_selectedTabIndex != _MainShellPageState._tabFriends ||
            _isWorkspaceOpen) {
          _updateState(() {
            _selectedTabIndex = _MainShellPageState._tabFriends;
            _openedTrip = null;
            _openAddExpenseOnWorkspaceStart = false;
          });
        }
        return;
      case _MainShellPageState._tabProfile:
        if (_selectedTabIndex != _MainShellPageState._tabProfile ||
            _isWorkspaceOpen) {
          _updateState(() {
            _selectedTabIndex = _MainShellPageState._tabProfile;
            _openedTrip = null;
            _openAddExpenseOnWorkspaceStart = false;
          });
        }
        return;
      default:
        if (_selectedTabIndex != _MainShellPageState._tabHome ||
            _isWorkspaceOpen) {
          _updateState(() {
            _selectedTabIndex = _MainShellPageState._tabHome;
            _openedTrip = null;
            _openAddExpenseOnWorkspaceStart = false;
          });
        }
        return;
    }
  }

  void _openWorkspaceInShell(Trip trip, {bool openAddExpense = false}) {
    _updateState(() {
      _selectedTabIndex = _MainShellPageState._tabHome;
      _openedTrip = trip;
      _openAddExpenseOnWorkspaceStart = openAddExpense;
    });
    unawaited(_refreshGlobalNotifications());
  }

  void _closeWorkspaceInShell() {
    if (_openedTrip == null) {
      return;
    }
    _updateState(() {
      _openedTrip = null;
      _openAddExpenseOnWorkspaceStart = false;
    });
    _tripsCommandController.requestRefresh();
    unawaited(_refreshGlobalNotifications());
  }

  void _onTopBackPressed() {
    if (_isWorkspaceOpen) {
      _closeWorkspaceInShell();
      return;
    }
    if (_selectedTabIndex == _MainShellPageState._tabProfile &&
        _isProfileInEditMode) {
      _profileCommandController.requestCloseEditMode();
      return;
    }
    if (_selectedTabIndex != _MainShellPageState._tabHome) {
      _updateState(() {
        _selectedTabIndex = _MainShellPageState._tabHome;
      });
    }
  }

  void _onProfileChanged() {
    if (!mounted) {
      return;
    }
    // Profile changes (for example preferred currency) must refresh
    // trips-derived overview and dependent screens.
    widget.tripsController.clearTripsCache();
    _tripsCommandController.requestRefresh();
    _analyticsCommandController?.requestRefresh();
    if (_isWorkspaceOpen) {
      _workspaceCommandController.requestRefresh();
    }
    _updateState(() {});
  }

  void _onProfileEditModeChanged(bool isEditMode) {
    if (!mounted || _isProfileInEditMode == isEditMode) {
      return;
    }
    _updateState(() {
      _isProfileInEditMode = isEditMode;
    });
  }

  String _topTitle(BuildContext context) {
    final openedTrip = _openedTrip;
    if (openedTrip != null) {
      final name = openedTrip.name.trim();
      if (name.isNotEmpty) {
        return name;
      }
      return context.l10n.tripWithId(openedTrip.id);
    }
    final t = context.l10n;
    switch (_selectedTabIndex) {
      case _MainShellPageState._tabActivities:
        return t.navActivities;
      case _MainShellPageState._tabFriends:
        return t.navFriends;
      case _MainShellPageState._tabProfile:
        return t.profileTitle;
      default:
        return t.yourTrips;
    }
  }

  void _onRefreshPressed() {
    if (_isLoggingOut) {
      return;
    }
    unawaited(_refreshGlobalNotifications(showErrorSnack: false));
    if (_isWorkspaceOpen) {
      _workspaceCommandController.requestRefresh();
      return;
    }
    if (_selectedTabIndex == _MainShellPageState._tabProfile) {
      _profileCommandController.requestRefresh();
      return;
    }
    if (_selectedTabIndex == _MainShellPageState._tabActivities) {
      _analyticsCommandController?.requestRefresh();
      return;
    }
    if (_selectedTabIndex == _MainShellPageState._tabFriends) {
      _friendsCommandController.requestRefresh();
      return;
    }
    if (_selectedTabIndex == _MainShellPageState._tabHome) {
      _tripsCommandController.requestRefresh();
    }
  }
}
