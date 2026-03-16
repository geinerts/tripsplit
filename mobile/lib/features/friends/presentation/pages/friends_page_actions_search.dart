part of 'friends_page.dart';

extension _FriendsPageActionsSearch on _FriendsPageState {
  void _onSearchChanged() {
    _searchDebounce?.cancel();
    final query = _searchController.text.trim();
    if (query.length < 2) {
      _updateState(() {
        _searchResults = const <FriendUser>[];
        _isSearching = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      unawaited(_performSearch(query));
    });
  }

  List<int> _searchExcludeIds(FriendsSnapshot snapshot) {
    final ids = <int>{};
    for (final friend in snapshot.friends) {
      ids.add(friend.id);
    }
    for (final req in snapshot.pendingSent) {
      ids.add(req.user.id);
    }
    for (final req in snapshot.pendingReceived) {
      ids.add(req.user.id);
    }
    return ids.toList(growable: false);
  }

  Future<void> _performSearch(String query) async {
    final snapshot = _snapshot;
    if (snapshot == null || query.trim().length < 2) {
      return;
    }
    _updateState(() {
      _isSearching = true;
    });

    try {
      final users = await widget.controller.searchUsers(
        query: query,
        limit: 20,
        excludeIds: _searchExcludeIds(snapshot),
      );
      if (!mounted) {
        return;
      }
      if (_searchController.text.trim() != query.trim()) {
        return;
      }
      _updateState(() {
        _searchResults = users;
      });
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
        _txt(
          en: 'Search failed. Try again.',
          lv: 'Meklēšana neizdevās. Mēģini vēlreiz.',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        _updateState(() {
          _isSearching = false;
        });
      }
    }
  }
}
