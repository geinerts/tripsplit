part of 'workspace_page.dart';

extension _WorkspacePageTripActions on _WorkspacePageState {
  Future<void> _onGeneratePressed() async {
    if (_snapshot == null || _isMutating) {
      return;
    }
    if (!_snapshot!.isActive) {
      _showSnack(context.l10n.tripClosedRandomDisabled, isError: true);
      return;
    }

    final members = _randomSelection.toList(growable: false)..sort();
    if (members.length < 2) {
      _showSnack(context.l10n.selectAtLeastTwoMembers, isError: true);
      return;
    }

    await _runMutation(
      action: () async {
        final result = await widget.workspaceController.generateOrder(
          tripId: widget.trip.id,
          members: members,
        );
        if (!mounted) {
          return;
        }
        _updateState(() {
          _lastDraw = result;
          final next = result.remainingIds.isNotEmpty
              ? result.remainingIds.toSet()
              : result.membersIds.toSet();
          _randomSelection = next;
        });

        await _loadData(showLoader: false);
        if (mounted) {
          final label = result.pickedUserNickname.isNotEmpty
              ? result.pickedUserNickname
              : context.l10n.userWithId(result.pickedUserId);
          if (result.cycleCompleted) {
            _showSnack(context.l10n.pickedCycleCompleted(label));
          } else {
            _showSnack(context.l10n.pickedUser(label));
          }
        }
      },
    );
  }

  Future<void> _onEndTripPressed() async {
    final snapshot = _snapshot;
    if (snapshot == null || _isMutating) {
      return;
    }
    if (!snapshot.isActive) {
      _showSnack(context.l10n.tripAlreadyClosed);
      return;
    }
    if (!_canEditMembers) {
      _showSnack(context.l10n.onlyCreatorCanFinishTrip, isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final t = context.l10n;
        return AlertDialog(
          title: Text(t.finishTripTitle),
          content: Text(t.finishTripConfirmationText),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.finishTripStartSettlementsAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await _runMutation(
      action: () async {
        await widget.workspaceController.endTrip(tripId: widget.trip.id);
        await _loadData(showLoader: false);
        if (!mounted) {
          return;
        }
        final next = _snapshot;
        if (next == null) {
          _showSnack(context.l10n.tripFinished);
          return;
        }
        if (next.isArchived) {
          _showSnack(context.l10n.tripFullySettledArchived);
        } else {
          _showSnack(context.l10n.tripFinishedSettlementStarted);
        }
      },
    );
  }

  Future<void> _onSettlementMarkSent(SettlementItem settlement) async {
    final settlementId = settlement.id;
    if (settlementId == null || settlementId <= 0) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.markSettlementSent(
          tripId: widget.trip.id,
          settlementId: settlementId,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.markedAsSent);
        }
      },
    );
  }

  Future<void> _onSettlementConfirmReceived(SettlementItem settlement) async {
    final settlementId = settlement.id;
    if (settlementId == null || settlementId <= 0) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.confirmSettlementReceived(
          tripId: widget.trip.id,
          settlementId: settlementId,
        );
        await _loadData(showLoader: false);
        if (!mounted) {
          return;
        }
        final next = _snapshot;
        if (next?.isArchived == true) {
          _showSnack(context.l10n.confirmedAllSettlementsArchived);
        } else {
          _showSnack(context.l10n.confirmedAsReceived);
        }
      },
    );
  }

  Future<void> _openReceiptUrl(String url) async {
    final parsed = Uri.tryParse(url.trim());
    if (parsed == null) {
      _showSnack(context.l10n.receiptLinkInvalid, isError: true);
      return;
    }

    final opened = await launchUrl(
      parsed,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _showSnack(context.l10n.couldNotOpenReceiptLink, isError: true);
    }
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

  Future<void> _onLogoutPressed() async {
    if (_isMutating || _isLoading) {
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
}
