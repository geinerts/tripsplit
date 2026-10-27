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
    final isSolo = widget.trip.isSolo;
    if (isSolo && _pendingQueueCount > 0) {
      _showSnack(context.l10n.finishTripSyncPending, isError: true);
      return;
    }
    if (!isSolo && !snapshot.allMembersReadyToSettle) {
      _showSnack(
        context.l10n.workspaceAllMembersMustMarkReadyBeforeStartingSettlements,
        isError: true,
      );
      return;
    }

    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.finishTripTitle,
      message: isSolo
          ? context.l10n.finishSoloTripConfirmationText
          : context.l10n.finishTripConfirmationText,
      confirmLabel: isSolo
          ? context.l10n.finishTripAction
          : context.l10n.finishTripStartSettlementsAction,
      cancelLabel: context.l10n.cancelAction,
      icon: Icons.flag_circle_outlined,
    );

    if (!confirmed || !mounted) {
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
        if (isSolo && next.isArchived) {
          _showSnack(context.l10n.soloTripArchived);
        } else if (next.isArchived) {
          _showSnack(context.l10n.tripFullySettledArchived);
        } else {
          _showSnack(context.l10n.tripFinishedSettlementStarted);
        }
      },
    );
    if (mounted &&
        _snapshot != null &&
        !_snapshot!.isActive &&
        widget.onTravelMapRequested != null) {
      final add = await showAppConfirmationDialog(
        context: context,
        title: context.l10n.travelAddToMap,
        message: context.l10n.travelTripConfirm,
        confirmLabel: context.l10n.travelAddToMap,
        cancelLabel: context.l10n.cancelAction,
        icon: Icons.add_location_alt_outlined,
      );
      if (add && mounted) await widget.onTravelMapRequested?.call();
    }
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
              ? context.l10n.workspaceYouMarkedYourselfReadyToSettle
              : context.l10n.workspaceReadyToSettleMarkRemoved,
        );
      },
    );
  }

  Future<void> _onSettlementMarkSent(SettlementItem settlement) async {
    final settlementId = settlement.id;
    if (settlementId == null || settlementId <= 0) {
      return;
    }
    final confirmed = await _confirmSettlementCriticalAction(
      title: context.l10n.markSettlementSentConfirmTitle,
      message: context.l10n.markSettlementSentConfirmText,
      confirmLabel: context.l10n.iSentAction,
    );
    if (confirmed != true || !mounted) {
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

  Future<void> _onSettlementCancelSent(SettlementItem settlement) async {
    final settlementId = settlement.id;
    if (settlementId == null || settlementId <= 0) {
      return;
    }
    final confirmed = await _confirmSettlementCriticalAction(
      title: context.l10n.settlementCancelSentConfirmTitle,
      message: context.l10n.settlementCancelSentConfirmText,
      confirmLabel: context.l10n.settlementCancelSentAction,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.cancelSettlementSent(
          tripId: widget.trip.id,
          settlementId: settlementId,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.settlementSentCancelled);
        }
      },
    );
  }

  Future<void> _onSettlementReportNotReceived(SettlementItem settlement) async {
    final settlementId = settlement.id;
    if (settlementId == null || settlementId <= 0) {
      return;
    }
    final confirmed = await _confirmSettlementCriticalAction(
      title: context.l10n.settlementNotReceivedConfirmTitle,
      message: context.l10n.settlementNotReceivedConfirmText,
      confirmLabel: context.l10n.settlementNotReceivedAction,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.reportSettlementNotReceived(
          tripId: widget.trip.id,
          settlementId: settlementId,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.settlementMarkedNotReceived);
        }
      },
    );
  }

  Future<void> _onSettlementConfirmReceived(SettlementItem settlement) async {
    final settlementId = settlement.id;
    if (settlementId == null || settlementId <= 0) {
      return;
    }
    final confirmed = await _confirmSettlementCriticalAction(
      title: context.l10n.confirmSettlementReceivedConfirmTitle,
      message: context.l10n.confirmSettlementReceivedConfirmText,
      confirmLabel: context.l10n.confirmReceivedAction,
    );
    if (confirmed != true || !mounted) {
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

  Future<bool?> _confirmSettlementCriticalAction({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) {
    return showAppConfirmationDialog(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: context.l10n.cancelAction,
      icon: isDestructive
          ? Icons.report_problem_outlined
          : Icons.payments_outlined,
      destructive: isDestructive,
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
          _showSnack(context.l10n.workspaceReminderSent);
        }
      },
    );
  }

  Future<void> _onTripPaymentCreate({
    required SettlementItem settlement,
    required double amount,
    required String note,
  }) async {
    if (_snapshot == null || _isMutating || !_snapshot!.isActive) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.createTripPayment(
          tripId: widget.trip.id,
          toUserId: settlement.toUserId,
          amount: amount,
          note: note,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.paymentRecordedWaiting);
        }
      },
    );
  }

  Future<void> _onTripPaymentRequestCreate({
    required bool sharePaymentDetails,
    required SettlementItem settlement,
    required double amount,
    required String note,
  }) async {
    if (_snapshot == null || _isMutating || !_snapshot!.isActive) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.createTripPaymentRequest(
          sharePaymentDetails: sharePaymentDetails,
          tripId: widget.trip.id,
          fromUserId: settlement.fromUserId,
          amount: amount,
          note: note,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.paymentRequestCreated);
        }
      },
    );
  }

  Future<void> _onTripPaymentRequestMarkSent(PaymentItem payment) async {
    if (_snapshot == null || _isMutating || !payment.canMarkRequestSent) {
      return;
    }
    final amount = _formatMoney(
      context,
      payment.amount,
      currencyCode: widget.trip.currencyCode,
    );
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.paymentRequestMarkPaidConfirmTitle,
      message: context.l10n.paymentRequestMarkPaidConfirmText(
        amount,
        payment.to,
      ),
      confirmLabel: context.l10n.paymentMarkPaidAction,
      cancelLabel: context.l10n.cancelAction,
      icon: Icons.payments_rounded,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.markTripPaymentRequestSent(
          tripId: widget.trip.id,
          paymentId: payment.id,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.paymentRequestMarkedPaid);
        }
      },
    );
  }

  Future<void> _onTripPaymentRequestCancel(PaymentItem payment) async {
    if (_snapshot == null || _isMutating || !payment.canCancelRequest) {
      return;
    }
    final amount = _formatMoney(
      context,
      payment.amount,
      currencyCode: widget.trip.currencyCode,
    );
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.paymentRequestCancelTitle,
      message: context.l10n.paymentRequestCancelText(amount, payment.from),
      confirmLabel: context.l10n.cancelAction,
      cancelLabel: context.l10n.friendsKeep,
      icon: Icons.close_rounded,
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.cancelTripPaymentRequest(
          tripId: widget.trip.id,
          paymentId: payment.id,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.paymentRequestCancelled);
        }
      },
    );
  }

  Future<void> _onTripPaymentRequestDecline(PaymentItem payment) async {
    if (_snapshot == null || _isMutating || !payment.canDeclineRequest) {
      return;
    }
    final amount = _formatMoney(
      context,
      payment.amount,
      currencyCode: widget.trip.currencyCode,
    );
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.paymentRequestDeclineTitle,
      message: context.l10n.paymentRequestDeclineText(amount, payment.to),
      confirmLabel: context.l10n.paymentDeclineAction,
      cancelLabel: context.l10n.cancelAction,
      icon: Icons.block_rounded,
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.declineTripPaymentRequest(
          tripId: widget.trip.id,
          paymentId: payment.id,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.paymentRequestDeclined);
        }
      },
    );
  }

  Future<void> _onTripPaymentConfirmReceived(PaymentItem payment) async {
    if (_snapshot == null || _isMutating) {
      return;
    }
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.paymentConfirmTitle,
      message: context.l10n.paymentConfirmText(
        _formatMoney(
          context,
          payment.amount,
          currencyCode: widget.trip.currencyCode,
        ),
        payment.from,
      ),
      confirmLabel: context.l10n.confirmReceivedAction,
      cancelLabel: context.l10n.cancelAction,
      icon: Icons.verified_rounded,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.confirmTripPaymentReceived(
          tripId: widget.trip.id,
          paymentId: payment.id,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.paymentConfirmedMessage);
        }
      },
    );
  }

  Future<void> _onTripPaymentCancelSent(PaymentItem payment) async {
    if (_snapshot == null || _isMutating) {
      return;
    }
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.paymentCancelRecordTitle,
      message: context.l10n.paymentCancelRecordText(
        _formatMoney(
          context,
          payment.amount,
          currencyCode: widget.trip.currencyCode,
        ),
        payment.to,
      ),
      confirmLabel: context.l10n.settlementCancelSentAction,
      cancelLabel: context.l10n.cancelAction,
      icon: Icons.undo_rounded,
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.cancelTripPaymentSent(
          tripId: widget.trip.id,
          paymentId: payment.id,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.paymentRecordCancelled);
        }
      },
    );
  }

  Future<void> _onTripPaymentReportNotReceived(PaymentItem payment) async {
    if (_snapshot == null || _isMutating) {
      return;
    }
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.paymentNotReceivedTitle,
      message: context.l10n.paymentNotReceivedText(
        _formatMoney(
          context,
          payment.amount,
          currencyCode: widget.trip.currencyCode,
        ),
        payment.from,
      ),
      confirmLabel: context.l10n.settlementNotReceivedAction,
      cancelLabel: context.l10n.cancelAction,
      icon: Icons.report_problem_outlined,
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.reportTripPaymentNotReceived(
          tripId: widget.trip.id,
          paymentId: payment.id,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.paymentMarkedNotReceived);
        }
      },
    );
  }

  bool _isCurrentTripOwner() {
    final userId = widget.authController.currentUser?.id ?? _currentUserId;
    if (userId <= 0) {
      return false;
    }
    if (widget.trip.canCurrentUserDeleteTrip) {
      return true;
    }
    return (widget.trip.createdBy ?? 0) == userId;
  }

  Future<void> _openTripActionsSheet() async {
    if (_isMutating) return;
    final t = context.l10n;
    final canEdit = _isTripActive && widget.trip.canCurrentUserManageTrip;
    final canManageMembers = _canEditMembers && !widget.trip.isSolo;
    final canFinishSolo = widget.trip.isSolo && _canEditMembers;
    final canDelete = _isTripActive && _isCurrentTripOwner();
    if (!canEdit &&
        !canDelete &&
        !canManageMembers &&
        !canFinishSolo &&
        widget.onTravelMapRequested == null) {
      return;
    }

    Rect? shareOrigin;
    final choice = await showAppBottomSheet<String>(
      context: context,
      builder: (sheetContext) => AppActionSheet(
        key: const ValueKey('trip-actions-sheet'),
        title: t.tripOptionsTitle,
        children: [
          if (widget.onTravelMapRequested != null)
            AppPlainActionTile(
              key: const ValueKey('trip-add-to-map'),
              icon: Icons.add_location_alt_outlined,
              title: t.travelAddToMap,
              onTap: () => Navigator.of(sheetContext).pop('map'),
            ),
          if (canEdit)
            AppPlainActionTile(
              icon: Icons.edit_outlined,
              title: t.editTripAction,
              onTap: () => Navigator.of(sheetContext).pop('edit'),
            ),
          if (canManageMembers)
            AppPlainActionTile(
              icon: Icons.person_add_alt_outlined,
              title: t.inviteTripMembersAction,
              onTap: () => Navigator.of(sheetContext).pop('members'),
            ),
          if (canManageMembers)
            Builder(
              builder: (shareContext) => AppPlainActionTile(
                key: const ValueKey('workspace-trip-share'),
                icon: CupertinoIcons.arrowshape_turn_up_right,
                title: t.shareAction,
                onTap: () {
                  final box = shareContext.findRenderObject() as RenderBox?;
                  if (box != null && box.hasSize) {
                    shareOrigin = box.localToGlobal(Offset.zero) & box.size;
                  }
                  Navigator.of(sheetContext).pop('share');
                },
              ),
            ),
          if (canFinishSolo)
            AppPlainActionTile(
              icon: Icons.flag_outlined,
              title: t.finishTripAction,
              onTap: () => Navigator.of(sheetContext).pop('finish'),
            ),
          if (canDelete) ...[
            const Divider(height: 16),
            AppPlainActionTile(
              icon: Icons.delete_outline,
              title: t.deleteTripAction,
              destructive: true,
              onTap: () => Navigator.of(sheetContext).pop('delete'),
            ),
          ],
        ],
      ),
    );

    if (!mounted || choice == null) {
      return;
    }

    if (choice == 'map') {
      await widget.onTravelMapRequested?.call();
      return;
    }
    if (choice == 'edit') {
      await _onEditCurrentTripPressed();
      return;
    }
    if (choice == 'members') {
      await _openAddMembersDialog();
      return;
    }
    if (choice == 'share') {
      await _shareCurrentTrip(shareOrigin);
      return;
    }
    if (choice == 'delete') {
      await _onDeleteCurrentTripPressed();
      return;
    }
    if (choice == 'finish') {
      await _onEndTripPressed();
      return;
    }
  }

  Future<void> _shareCurrentTrip(Rect? origin) async {
    if (_isMutating || !_canEditMembers || widget.trip.isSolo) return;
    final trip = _displayTrip;
    final accountId = widget.authController.currentUser?.id;
    bool current() =>
        mounted &&
        widget.trip.id == trip.id &&
        widget.authController.currentUser?.id == accountId;
    _updateState(() => _isMutating = true);
    try {
      final invite = await widget.tripsController.createTripInviteLink(
        tripId: trip.id,
      );
      if (!current()) return;
      await SharePlus.instance.share(
        ShareParams(
          text: '${trip.name}\n${invite.inviteUrl}',
          subject: trip.name,
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      if (mounted && current()) {
        _showSnack(context.l10n.homeTripShareFailed, isError: true);
      }
    } finally {
      if (mounted) _updateState(() => _isMutating = false);
    }
  }

  Future<void> _onEditCurrentTripPressed() async {
    if (_isMutating) {
      return;
    }
    if (!_canEditMembers) {
      _showSnack(
        context.l10n.workspaceOnlyTripCreatorCanEditThisTrip,
        isError: true,
      );
      return;
    }

    final tripId = widget.trip.id;
    final userId = widget.authController.currentUser?.id;
    bool current() =>
        mounted &&
        widget.trip.id == tripId &&
        widget.authController.currentUser?.id == userId;
    final result = await _showEditTripDialog(_displayTrip);
    if (result == null || !current()) {
      return;
    }

    final nextName = result.name.trim();
    final hasNameChange = nextName != _displayTrip.name.trim();
    final hasBudgetChange = result.budgetCents != _tripBudgetCents;
    final hasDestinationsChange = !tripDestinationsEqual(
      result.destinations,
      _displayTrip.destinations,
    );
    final imageBytes = result.imageBytes;
    final imageFileName = result.imageFileName?.trim() ?? '';
    final hasNewImage =
        imageBytes != null && imageBytes.isNotEmpty && imageFileName.isNotEmpty;
    final removeImage = result.removeImage && !hasNewImage;

    if (!hasNameChange &&
        !hasNewImage &&
        !removeImage &&
        !hasBudgetChange &&
        !hasDestinationsChange) {
      _showSnack(context.l10n.noChangesToSave);
      return;
    }

    _updateState(() {
      _isMutating = true;
    });
    try {
      String? imagePath;
      if (hasNewImage) {
        final uploaded = await widget.tripsController.uploadTripImage(
          tripId: widget.trip.id,
          fileName: imageFileName,
          bytes: imageBytes,
        );
        if (!current()) return;
        imagePath = uploaded.path;
      }

      final updatedTrip = await widget.tripsController.updateTrip(
        tripId: widget.trip.id,
        name: nextName,
        imagePath: imagePath,
        removeImage: removeImage,
        budgetCents: hasBudgetChange ? result.budgetCents : null,
        destinations: hasDestinationsChange ? result.destinations : null,
        clearBudget: hasBudgetChange && result.budgetCents == null,
      );

      if (!current()) return;
      _updateState(() {
        _editedTrip = updatedTrip;
        _snapshot = _snapshot?.copyWith(
          budgetCents: updatedTrip.budgetCents,
          clearBudget: updatedTrip.budgetCents == null,
          budgetLoaded: true,
        );
      });
      widget.onTripUpdated?.call(updatedTrip);

      await _loadData(showLoader: false);
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.workspaceTripUpdated);
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

  Future<_EditTripResult?> _showEditTripDialog(Trip trip) async {
    final result = await Navigator.of(context).push<TripFormDraft>(
      AppFormPageRoute(
        builder: (_) => TripFormPage(
          trip: trip,
          budgetLoaded: true,
          budgetCents: _tripBudgetCents,
          pickImage: _pickTripImageForUploadFromSource,
        ),
      ),
    );
    if (result == null) return null;
    return _EditTripResult(
      name: result.name,
      budgetCents: result.budgetCents,
      destinations: result.destinations,
      imageFileName: result.image?.fileName,
      imageBytes: result.image?.bytes,
      removeImage: result.removeImage,
    );
  }

  Future<void> _openSettingsSheet() async {
    if (_isMutating) {
      return;
    }

    final canDeleteTrip = _isTripActive && _isCurrentTripOwner();
    final canLeaveTrip = _isTripActive && !_isCurrentTripOwner();
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
              icon: Icons.casino_outlined,
              title: context.l10n.workspaceRandomPicker,
              onTap: () => Navigator.of(sheetContext).pop('random_picker'),
            ),
            AppActionSheetTile(
              icon: Icons.logout,
              title: t.logOutButton,
              onTap: () => Navigator.of(sheetContext).pop('logout'),
            ),
            if (canLeaveTrip)
              AppActionSheetTile(
                icon: Icons.exit_to_app_rounded,
                title: 'Leave trip',
                destructive: true,
                onTap: () => Navigator.of(sheetContext).pop('leave_trip'),
              ),
            if (canDeleteTrip)
              AppActionSheetTile(
                icon: Icons.delete_outline,
                title: '${t.deleteAction} ${t.tripTitleShort}',
                destructive: true,
                onTap: () => Navigator.of(sheetContext).pop('delete_trip'),
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
      case 'random_picker':
        await _openRandomPickerSheet();
        return;
      case 'logout':
        await _onLogoutPressed();
        return;
      case 'leave_trip':
        await _onLeaveCurrentTripPressed();
        return;
      case 'delete_trip':
        await _onDeleteCurrentTripPressed();
        return;
      default:
        return;
    }
  }

  Future<void> _onLeaveCurrentTripPressed() async {
    if (_isMutating || _isLoading || _isCurrentTripOwner()) {
      return;
    }

    final tripName = widget.trip.name.trim();
    final tripLabel = tripName.isNotEmpty
        ? tripName
        : context.l10n.tripWithId(widget.trip.id);
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Leave trip?',
      message:
          'Leave "$tripLabel"? This is only possible if you have no expenses, settlements, or balances in this trip.',
      confirmLabel: 'Leave',
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
      await widget.tripsController.leaveTrip(tripId: widget.trip.id);
      if (!mounted) {
        return;
      }
      _showSnack('You left the trip.');

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
      _showSnack(context.l10n.unexpectedErrorSavingChanges, isError: true);
    } finally {
      if (mounted) {
        _updateState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _openRandomPickerSheet() async {
    final snapshot = _snapshot;
    if (snapshot == null || !mounted) {
      return;
    }
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.88;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.l10n.workspaceRandomPicker,
                    style: Theme.of(sheetContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Expanded(child: _buildRandomTab(snapshot)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onDeleteCurrentTripPressed() async {
    if (_isMutating || _isLoading) {
      return;
    }
    if (!_isCurrentTripOwner()) {
      _showSnack(context.l10n.shellOnlyTripCreatorCanDelete, isError: true);
      return;
    }
    if (!_isTripActive) {
      _showSnack(context.l10n.shellOnlyActiveTripsCanDelete, isError: true);
      return;
    }

    final t = context.l10n;
    final tripName = widget.trip.name.trim();
    final tripLabel = tripName.isNotEmpty
        ? tripName
        : t.tripWithId(widget.trip.id);
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
      await widget.tripsController.deleteTrip(tripId: widget.trip.id);
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.shellTripDeleted);

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
      _showSnack(context.l10n.shellFailedToDeleteTrip, isError: true);
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
}
