part of 'trips_page.dart';

extension _TripsPageInviteActions on _TripsPageState {
  Future<void> _onJoinTripPressed() async {
    if (_isMutating || _isLoading || _isJoiningTrip) {
      return;
    }
    _isJoiningTrip = true;
    _notifyInteractionState();
    try {
      await _joinTripFromInput();
    } finally {
      _isJoiningTrip = false;
      _notifyInteractionState();
    }
  }

  Future<void> _joinTripFromInput() async {
    final inviteToken = await _showJoinTripInviteDialog();
    if (inviteToken == null || !mounted) {
      return;
    }

    _updateState(() {
      _isMutating = true;
    });
    try {
      final preview = await widget.controller.previewTripInvite(
        inviteToken: inviteToken,
      );
      final joined = await widget.controller.joinTripInvite(
        inviteToken: inviteToken,
        previewNonce: preview.previewNonce,
      );
      await _loadTrips();
      if (!mounted) {
        return;
      }
      final trip = _resolveJoinedTrip(joined.trip.id, fallback: joined.trip);
      _showSnack(
        joined.alreadyMember
            ? context.l10n.tripsYouAreAlreadyAMemberOfThisTrip
            : context.l10n.tripsJoinedTripSuccessfully,
      );
      await _openWorkspace(trip);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.tripsFailedToJoinTripFromInvite, isError: true);
    } finally {
      if (mounted) {
        _updateState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<String?> _showJoinTripInviteDialog() => Navigator.of(
    context,
    rootNavigator: true,
  ).push<String>(AppFormPageRoute(builder: (_) => const JoinTripInvitePage()));

  Trip _resolveJoinedTrip(int tripId, {required Trip fallback}) {
    for (final trip in _trips) {
      if (trip.id == tripId) {
        return trip;
      }
    }
    return fallback;
  }

  Future<List<ReceivedTripInvitation>> _fetchReceivedInvitations() async {
    final generation = ++_invitationsGeneration;
    final accountId = widget.authController.currentUser?.id;
    bool current() =>
        mounted &&
        generation == _invitationsGeneration &&
        accountId == widget.authController.currentUser?.id;
    try {
      final invitations = await widget.controller.listReceivedInvitations();
      if (current()) {
        _updateState(() {
          _receivedInvitations = invitations;
          _invitationsFailed = false;
        });
      }
      if (!mounted || accountId != widget.authController.currentUser?.id) {
        throw const ApiException('Account changed', code: 'account_changed');
      }
      return invitations;
    } catch (_) {
      if (current()) {
        _updateState(() {
          _receivedInvitations = const [];
          _invitationsFailed = true;
        });
      }
      rethrow;
    }
  }

  Future<void> _refreshReceivedInvitations() async {
    try {
      await _fetchReceivedInvitations();
    } catch (_) {
      /* Sheet offers a fresh retry. */
    }
  }

  Future<void> _openReceivedInvitations() async {
    if (_invitationSheetOpen || _isMutating) return;
    _invitationSheetOpen = true;
    _notifyInteractionState();
    try {
      await showAppBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        builder: (_) => ReceivedTripInvitationsSheet(
          load: _fetchReceivedInvitations,
          respond: _reviewReceivedInvitation,
        ),
      );
    } finally {
      _invitationSheetOpen = false;
      _notifyInteractionState();
    }
  }

  Future<void> _reviewReceivedInvitation(
    ReceivedTripInvitation invitation,
  ) async {
    if (_isMutating) return;
    _updateState(() => _isMutating = true);
    try {
      final preview = await widget.controller.previewTripInvite(
        inviteToken: invitation.inviteToken,
      );
      if (!mounted) return;
      final decision = await showDialog<bool>(
        context: context,
        builder: (_) => TripInvitationDialog(
          message: context.l10n.shellInviteJoinTripQuestion(
            preview.tripName,
            preview.inviterName,
          ),
        ),
      );
      if (!mounted || decision == null) return;
      if (decision) {
        await widget.controller.joinTripInvite(
          inviteToken: invitation.inviteToken,
          previewNonce: preview.previewNonce,
        );
      } else {
        await widget.controller.declineTripInvite(
          inviteToken: invitation.inviteToken,
        );
      }
      await _loadTrips();
    } on ApiException catch (error) {
      if (mounted) _showSnack(error.message, isError: true);
    } catch (_) {
      if (mounted) {
        _showSnack(context.l10n.homeInvitationResponseFailed, isError: true);
      }
    } finally {
      if (mounted) _updateState(() => _isMutating = false);
    }
  }

  Future<void> _shareTrip(Trip trip, BuildContext buttonContext) async {
    if (_sharingTripId != null ||
        _isMutating ||
        !trip.canCurrentUserManageTrip ||
        !trip.isActive ||
        trip.isSolo) {
      return;
    }
    _updateState(() => _sharingTripId = trip.id);
    try {
      final invite = await widget.controller.createTripInviteLink(
        tripId: trip.id,
      );
      if (!mounted || !buttonContext.mounted) return;
      final box = buttonContext.findRenderObject() as RenderBox?;
      final origin = box != null && box.hasSize
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      await SharePlus.instance.share(
        ShareParams(
          text: '${trip.name}\n${invite.inviteUrl}',
          subject: trip.name,
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      if (mounted) _showSnack(context.l10n.homeTripShareFailed, isError: true);
    } finally {
      if (mounted) _updateState(() => _sharingTripId = null);
    }
  }
}
