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
}
