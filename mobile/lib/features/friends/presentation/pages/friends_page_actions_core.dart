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
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 220) {
      return;
    }
    unawaited(_loadMoreFriends());
  }

  Future<void> _loadMoreFriends() async {
    if (_isLoadingMoreFriends || !_friendsHasMore) {
      return;
    }
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }

    _updateState(() {
      _isLoadingMoreFriends = true;
    });
    try {
      final page = await widget.controller.loadSectionPage(
        section: _FriendsPageState._sectionFriends,
        limit: _FriendsPageState._pageLimit,
        cursor: _friendsNextCursor,
        offset: _friendsNextCursor == null ? _friendsNextOffset : null,
      );
      if (!mounted) {
        return;
      }

      final existing = snapshot.friends.map((item) => item.id).toSet();
      final mergedFriends = <FriendUser>[...snapshot.friends];
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
          pendingSent: snapshot.pendingSent,
          pendingReceived: snapshot.pendingReceived,
        );
      });
    } catch (_) {
      // Keep infinite scroll silent; user can still pull-to-refresh.
    } finally {
      if (mounted) {
        _updateState(() {
          _isLoadingMoreFriends = false;
        });
      }
    }
  }

  Future<void> _loadMorePendingReceived() async {
    if (_isLoadingMorePendingReceived || !_pendingReceivedHasMore) {
      return;
    }
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }

    _updateState(() {
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
      if (!mounted) {
        return;
      }

      final existing = snapshot.pendingReceived
          .map((item) => item.requestId)
          .toSet();
      final merged = <FriendRequest>[...snapshot.pendingReceived];
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
          friends: snapshot.friends,
          pendingSent: snapshot.pendingSent,
          pendingReceived: merged,
        );
      });
    } finally {
      if (mounted) {
        _updateState(() {
          _isLoadingMorePendingReceived = false;
        });
      }
    }
  }

  Future<void> _loadMorePendingSent() async {
    if (_isLoadingMorePendingSent || !_pendingSentHasMore) {
      return;
    }
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }

    _updateState(() {
      _isLoadingMorePendingSent = true;
    });
    try {
      final page = await widget.controller.loadSectionPage(
        section: _FriendsPageState._sectionPendingSent,
        limit: _FriendsPageState._pageLimit,
        cursor: _pendingSentNextCursor,
        offset: _pendingSentNextCursor == null ? _pendingSentNextOffset : null,
      );
      if (!mounted) {
        return;
      }

      final existing = snapshot.pendingSent
          .map((item) => item.requestId)
          .toSet();
      final merged = <FriendRequest>[...snapshot.pendingSent];
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
          friends: snapshot.friends,
          pendingSent: merged,
          pendingReceived: snapshot.pendingReceived,
        );
      });
    } finally {
      if (mounted) {
        _updateState(() {
          _isLoadingMorePendingSent = false;
        });
      }
    }
  }

  Future<void> _loadSnapshot({required bool showLoader}) async {
    final trace = PerfMonitor.start('screen.friends.load');
    var success = false;
    final shouldShowLoader = showLoader && _snapshot == null;
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
      if (!mounted) {
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
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.message.trim().isNotEmpty
          ? error.message.trim()
          : context.l10n.workspaceFailedToLoadFriends;
      if (_snapshot == null) {
        _updateState(() {
          _errorText = message;
        });
      } else {
        _showSnack(message, isError: true);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      final message = context.l10n.friendsUnexpectedErrorLoadingFriends;
      if (_snapshot == null) {
        _updateState(() {
          _errorText = message;
        });
      } else {
        _showSnack(message, isError: true);
      }
    } finally {
      trace.stop(success: success);
      if (mounted) {
        _updateState(() {
          _isLoading = false;
          _isLoadingMoreFriends = false;
          _isLoadingMorePendingReceived = false;
          _isLoadingMorePendingSent = false;
        });
      }
    }
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
