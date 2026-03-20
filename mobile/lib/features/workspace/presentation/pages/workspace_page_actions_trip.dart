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
    if (!snapshot.allMembersReadyToSettle) {
      _showSnack(
        _plainLocalizedText(
          en: 'All members must mark ready before starting settlements.',
          lv: 'Pirms norēķinu sākšanas visiem dalībniekiem jāatzīmē gatavība.',
        ),
        isError: true,
      );
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
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: AppDesign.logoBackgroundGradient,
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                ),
                child: Text(t.finishTripStartSettlementsAction),
              ),
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

  Future<void> _onReadyToSettleChanged(bool isReady) async {
    final snapshot = _snapshot;
    if (snapshot == null || _isMutating || !snapshot.isActive) {
      return;
    }
    if (_currentUserId <= 0) {
      return;
    }

    await _runMutation(
      action: () async {
        await widget.workspaceController.setReadyToSettle(
          tripId: widget.trip.id,
          isReady: isReady,
        );
        await _loadData(showLoader: false);
        if (!mounted) {
          return;
        }
        _showSnack(
          isReady
              ? _plainLocalizedText(
                  en: 'You marked yourself ready to settle.',
                  lv: 'Tu atzīmēji sevi kā gatavu norēķiniem.',
                )
              : _plainLocalizedText(
                  en: 'Ready-to-settle mark removed.',
                  lv: 'Gatavības atzīme noņemta.',
                ),
        );
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

  Future<void> _onSettlementRemind(SettlementItem settlement) async {
    final settlementId = settlement.id;
    if (settlementId == null || settlementId <= 0) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.remindSettlement(
          tripId: widget.trip.id,
          settlementId: settlementId,
        );
        if (mounted) {
          _showSnack(
            _plainLocalizedText(
              en: 'Reminder sent.',
              lv: 'Atgādinājums nosūtīts.',
            ),
          );
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

    final canDeleteTrip = _canEditMembers && _isTripActive;
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
              if (canDeleteTrip)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(sheetContext).colorScheme.error,
                  ),
                  title: Text(
                    '${t.deleteAction} ${t.tripTitleShort}',
                    style: TextStyle(
                      color: Theme.of(sheetContext).colorScheme.error,
                    ),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('delete_trip'),
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
      case 'delete_trip':
        await _onDeleteCurrentTripPressed();
        return;
      default:
        return;
    }
  }

  Future<void> _onDeleteCurrentTripPressed() async {
    if (_isMutating || _isLoading) {
      return;
    }
    if (!_canEditMembers) {
      _showSnack(
        _plainLocalizedText(
          en: 'Only trip creator can delete this trip.',
          lv: 'Šo ceļojumu drīkst dzēst tikai izveidotājs.',
        ),
        isError: true,
      );
      return;
    }
    if (!_isTripActive) {
      _showSnack(
        _plainLocalizedText(
          en: 'Only active trips can be deleted.',
          lv: 'Dzēst var tikai aktīvus ceļojumus.',
        ),
        isError: true,
      );
      return;
    }

    final t = context.l10n;
    final tripName = widget.trip.name.trim();
    final tripLabel = tripName.isNotEmpty
        ? tripName
        : t.tripWithId(widget.trip.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${t.deleteAction} ${t.tripTitleShort}'),
          content: Text(
            _plainLocalizedText(
              en: 'Delete "$tripLabel"? This is allowed only before any expenses are added.',
              lv: 'Dzēst "$tripLabel"? Tas ir atļauts tikai pirms ceļojumam pievienoti izdevumi.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(t.cancelAction),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              child: Text(t.deleteAction),
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
      await widget.tripsController.deleteTrip(tripId: widget.trip.id);
      if (!mounted) {
        return;
      }
      _showSnack(
        _plainLocalizedText(en: 'Trip deleted.', lv: 'Ceļojums izdzēsts.'),
      );

      final onExitRequested = widget.onExitRequested;
      if (onExitRequested != null) {
        onExitRequested();
      } else {
        Navigator.of(context).maybePop();
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(
        _plainLocalizedText(
          en: 'Failed to delete trip.',
          lv: 'Neizdevās izdzēst ceļojumu.',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        _updateState(() {
          _isMutating = false;
        });
      }
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
