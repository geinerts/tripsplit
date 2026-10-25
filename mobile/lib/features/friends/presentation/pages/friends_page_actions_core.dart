part of 'friends_page.dart';

extension _FriendsPageActionsCore on _FriendsPageState {
  void _bindCommandController(FriendsPageCommandController? controller) {
    if (controller == null) {
      return;
    }
    _handledRefreshRequestCount = controller.refreshRequestCount;
    controller.addListener(_onCommandControllerChanged);
  }

  void _unbindCommandController(FriendsPageCommandController? controller) {
    controller?.removeListener(_onCommandControllerChanged);
  }

  void _onCommandControllerChanged() {
    final controller = widget.commandController;
    if (controller == null) {
      return;
    }
    if (controller.refreshRequestCount == _handledRefreshRequestCount) {
      return;
    }
    _handledRefreshRequestCount = controller.refreshRequestCount;
    unawaited(_loadSnapshot(showLoader: false));
  }

  FriendsSnapshot _buildSnapshot({
    required List<FriendUser> friends,
    required List<FriendRequest> pendingSent,
    required List<FriendRequest> pendingReceived,
  }) {
    return FriendsSnapshot(
      friends: friends,
      pendingSent: pendingSent,
      pendingReceived: pendingReceived,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _errorText != null || _isLoading) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 220) {
      return;
    }
    unawaited(_loadMoreFriends());
  }

  Future<void> _loadMoreFriends() async {
    if (_isLoading || _isLoadingMoreFriends || !_friendsHasMore) {
      return;
    }
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }

    final generation = _loadGeneration;
    _updateState(() {
      _errorText = null;
      _isLoadingMoreFriends = true;
    });
    try {
      final page = await widget.controller.loadSectionPage(
        section: _FriendsPageState._sectionFriends,
        limit: _FriendsPageState._pageLimit,
        cursor: _friendsNextCursor,
        offset: _friendsNextCursor == null ? _friendsNextOffset : null,
      );
      if (!mounted || generation != _loadGeneration) {
        return;
      }

      final current = _snapshot!;
      final existing = current.friends.map((item) => item.id).toSet();
      final mergedFriends = <FriendUser>[...current.friends];
      for (final friend in page.friends) {
        if (existing.add(friend.id)) {
          mergedFriends.add(friend);
        }
      }

      _updateState(() {
        _friendsTotalCount = page.friendsCount;
        _pendingReceivedTotalCount = page.pendingReceivedCount;
        _friendsHasMore = page.hasMore;
        _friendsNextCursor = page.nextCursor;
        _friendsNextOffset = page.nextOffset;
        _snapshot = _buildSnapshot(
          friends: mergedFriends,
          pendingSent: current.pendingSent,
          pendingReceived: current.pendingReceived,
        );
      });
    } catch (error) {
      if (mounted && generation == _loadGeneration) {
        _handleFriendsLoadError(error);
      }
    } finally {
      if (mounted && generation == _loadGeneration) {
        _updateState(() {
          _isLoadingMoreFriends = false;
        });
      }
    }
  }

  Future<void> _loadMorePendingReceived() async {
    if (_isLoading ||
        _isLoadingMorePendingReceived ||
        !_pendingReceivedHasMore) {
      return;
    }
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }

    final generation = _loadGeneration;
    _updateState(() {
      _errorText = null;
      _isLoadingMorePendingReceived = true;
    });
    try {
      final page = await widget.controller.loadSectionPage(
        section: _FriendsPageState._sectionPendingReceived,
        limit: _FriendsPageState._pageLimit,
        cursor: _pendingReceivedNextCursor,
        offset: _pendingReceivedNextCursor == null
            ? _pendingReceivedNextOffset
            : null,
      );
      if (!mounted || generation != _loadGeneration) {
        return;
      }

      final current = _snapshot!;
      final existing = current.pendingReceived
          .map((item) => item.requestId)
          .toSet();
      final merged = <FriendRequest>[...current.pendingReceived];
      for (final req in page.requests) {
        if (existing.add(req.requestId)) {
          merged.add(req);
        }
      }

      _updateState(() {
        _friendsTotalCount = page.friendsCount;
        _pendingReceivedTotalCount = page.pendingReceivedCount;
        _pendingReceivedHasMore = page.hasMore;
        _pendingReceivedNextCursor = page.nextCursor;
        _pendingReceivedNextOffset = page.nextOffset;
        _snapshot = _buildSnapshot(
          friends: current.friends,
          pendingSent: current.pendingSent,
          pendingReceived: merged,
        );
      });
    } catch (error) {
      if (mounted && generation == _loadGeneration) {
        _handleFriendsLoadError(error);
      }
    } finally {
      if (mounted && generation == _loadGeneration) {
        _updateState(() {
          _isLoadingMorePendingReceived = false;
        });
      }
    }
  }

  Future<void> _loadMorePendingSent() async {
    if (_isLoading || _isLoadingMorePendingSent || !_pendingSentHasMore) {
      return;
    }
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }

    final generation = _loadGeneration;
    _updateState(() {
      _errorText = null;
      _isLoadingMorePendingSent = true;
    });
    try {
      final page = await widget.controller.loadSectionPage(
        section: _FriendsPageState._sectionPendingSent,
        limit: _FriendsPageState._pageLimit,
        cursor: _pendingSentNextCursor,
        offset: _pendingSentNextCursor == null ? _pendingSentNextOffset : null,
      );
      if (!mounted || generation != _loadGeneration) {
        return;
      }

      final current = _snapshot!;
      final existing = current.pendingSent
          .map((item) => item.requestId)
          .toSet();
      final merged = <FriendRequest>[...current.pendingSent];
      for (final req in page.requests) {
        if (existing.add(req.requestId)) {
          merged.add(req);
        }
      }

      _updateState(() {
        _friendsTotalCount = page.friendsCount;
        _pendingReceivedTotalCount = page.pendingReceivedCount;
        _pendingSentTotalCount = page.pendingSentCount;
        _pendingSentHasMore = page.hasMore;
        _pendingSentNextCursor = page.nextCursor;
        _pendingSentNextOffset = page.nextOffset;
        _snapshot = _buildSnapshot(
          friends: current.friends,
          pendingSent: merged,
          pendingReceived: current.pendingReceived,
        );
      });
    } catch (error) {
      if (mounted && generation == _loadGeneration) {
        _handleFriendsLoadError(error);
      }
    } finally {
      if (mounted && generation == _loadGeneration) {
        _updateState(() {
          _isLoadingMorePendingSent = false;
        });
      }
    }
  }

  Future<void> _loadSnapshot({required bool showLoader}) async {
    final trace = PerfMonitor.start('screen.friends.load');
    var success = false;
    final generation = ++_loadGeneration;
    _updateState(() {
      _isLoading = true;
      _errorText = null;
      _isLoadingMoreFriends = false;
      _isLoadingMorePendingReceived = false;
      _isLoadingMorePendingSent = false;
    });

    try {
      final pages = await Future.wait<FriendsSectionPage>([
        widget.controller.loadSectionPage(
          section: _FriendsPageState._sectionFriends,
          limit: _FriendsPageState._pageLimit,
        ),
        widget.controller.loadSectionPage(
          section: _FriendsPageState._sectionPendingSent,
          limit: _FriendsPageState._pageLimit,
        ),
        widget.controller.loadSectionPage(
          section: _FriendsPageState._sectionPendingReceived,
          limit: _FriendsPageState._pageLimit,
        ),
      ]);
      if (!mounted || generation != _loadGeneration) {
        return;
      }

      final friendsPage = pages[0];
      final sentPage = pages[1];
      final receivedPage = pages[2];
      final snapshot = _buildSnapshot(
        friends: friendsPage.friends,
        pendingSent: sentPage.requests,
        pendingReceived: receivedPage.requests,
      );

      _updateState(() {
        _friendsTotalCount = friendsPage.friendsCount;
        _pendingReceivedTotalCount = friendsPage.pendingReceivedCount;
        _pendingSentTotalCount = sentPage.pendingSentCount;
        _friendsHasMore = friendsPage.hasMore;
        _friendsNextCursor = friendsPage.nextCursor;
        _friendsNextOffset = friendsPage.nextOffset;
        _pendingReceivedHasMore = receivedPage.hasMore;
        _pendingReceivedNextCursor = receivedPage.nextCursor;
        _pendingReceivedNextOffset = receivedPage.nextOffset;
        _pendingSentHasMore = sentPage.hasMore;
        _pendingSentNextCursor = sentPage.nextCursor;
        _pendingSentNextOffset = sentPage.nextOffset;
        _snapshot = snapshot;
      });
      success = true;
    } catch (error) {
      if (mounted && generation == _loadGeneration) {
        _handleFriendsLoadError(error);
      }
    } finally {
      trace.stop(success: success);
      if (mounted && generation == _loadGeneration) {
        _updateState(() {
          _isLoading = false;
          _isLoadingMoreFriends = false;
          _isLoadingMorePendingReceived = false;
          _isLoadingMorePendingSent = false;
        });
      }
    }
  }

  void _handleFriendsLoadError(Object error) {
    final denied =
        error is ApiException &&
        ([401, 403, 404].contains(error.statusCode) ||
            error.code == 'account_changed');
    _updateState(() {
      _errorText = error is ApiException && error.message.trim().isNotEmpty
          ? error.message
          : context.l10n.workspaceFailedToLoadFriends;
      if (denied) {
        _loadGeneration++;
        _searchGeneration++;
        _snapshot = null;
        _friendSearchDebounce?.cancel();
        _friendSearchResults = [];
        _isSearchingUsers = false;
        _friendsHasMore = _pendingReceivedHasMore = _pendingSentHasMore = false;
        _isLoading = _isLoadingMoreFriends = _isLoadingMorePendingReceived =
            _isLoadingMorePendingSent = false;
      }
    });
  }

  void _showSnack(String message, {bool isError = false}) {
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
}
