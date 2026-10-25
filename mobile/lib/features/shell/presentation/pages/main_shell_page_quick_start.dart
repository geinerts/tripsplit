part of 'main_shell_page.dart';

extension _MainShellQuickStart on _MainShellPageState {
  void _onHomeServerTripsState(bool? empty) {
    _homeConfirmedEmpty = empty == true;
    _scheduleQuickStart();
  }

  bool get _canPresentQuickStart =>
      mounted &&
      _homeConfirmedEmpty &&
      !_homeInteractionBusy &&
      _isAppInForeground &&
      !_isLoggingOut &&
      !_isWorkspaceOpen &&
      _selectedTabIndex == _MainShellPageState._tabHome &&
      !_isProcessingInviteDeepLink &&
      _queuedInviteDeepLinkCode == null &&
      !_isProcessingFriendDeepLink &&
      _friendLinkResolutions == 0 &&
      !_isOpeningExpense &&
      !_quickStartOpen &&
      ModalRoute.of(context)?.isCurrent == true;

  void _scheduleQuickStart() {
    _quickStartTimer?.cancel();
    final service = widget.quickStartService;
    if (!mounted || service == null) return;
    final generation = service.accountSession.generation;
    if (_quickStartGeneration != generation) {
      _quickStartGeneration = generation;
      _quickStartClaimed = false;
      _quickStartFinished = false;
    }
    if (!_homeConfirmedEmpty ||
        _quickStartFinished ||
        _quickStartOpen ||
        !_isAppInForeground ||
        _isWorkspaceOpen ||
        _selectedTabIndex != _MainShellPageState._tabHome) {
      return;
    }
    // Defer beyond initial route/deep-link handling. While another modal is
    // present, retry quietly; never put the guide on top of that modal.
    _quickStartTimer = Timer(const Duration(milliseconds: 750), _tryQuickStart);
  }

  Future<void> _tryQuickStart() async {
    final service = widget.quickStartService;
    if (service == null || _quickStartFinished || _quickStartChecking) return;
    if (!_canPresentQuickStart) {
      _scheduleQuickStart();
      return;
    }
    _quickStartChecking = true;
    try {
      final lease = service.accountSession.capture();
      if (!_quickStartClaimed) {
        final claimed = await service.claimAutomaticPresentation();
        if (!mounted || !lease.isCurrent) return;
        if (!claimed) {
          _quickStartFinished = true;
          return;
        }
        _quickStartClaimed = true;
      }
      if (!_canPresentQuickStart) {
        _scheduleQuickStart();
        return;
      }
      _quickStartOpen = true;
      _quickStartFinished = true;
      final create = await _quickStartPresenter.show(context);
      if (mounted && lease.isCurrent && create == true) _requestCreateTrip();
    } catch (_) {
      // Fail closed on an unavailable endpoint, migration or connection. A
      // successful future Home refresh may retry; no offline eligibility guess.
    } finally {
      _quickStartChecking = false;
      _quickStartOpen = false;
    }
  }

  Future<void> _replayQuickStart() async {
    if (_quickStartOpen || _isLoggingOut) return;
    final userId = widget.authController.currentUser?.id;
    _quickStartOpen = true;
    _quickStartTimer?.cancel();
    try {
      final create = await _quickStartPresenter.show(context);
      if (mounted &&
          userId == widget.authController.currentUser?.id &&
          create == true) {
        _requestCreateTrip();
      }
    } finally {
      _quickStartOpen = false;
    }
  }
}
