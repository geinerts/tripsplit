part of 'friends_page.dart';

extension _FriendsPageActionsRelationships on _FriendsPageState {
  Future<void> _respondInvite(FriendRequest request, bool accept) async {
    if (_respondLoading.contains(request.requestId)) {
      return;
    }
    _updateState(() {
      _respondLoading.add(request.requestId);
    });

    try {
      await widget.controller.respondInvite(
        requestId: request.requestId,
        accept: accept,
      );
      if (!mounted) {
        return;
      }
      _showSnack(
        accept
            ? context.l10n.friendsFriendAdded
            : context.l10n.friendsRequestDeclined,
      );
      await _loadSnapshot(showLoader: false);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.friendsFailedToUpdateRequest, isError: true);
    } finally {
      if (mounted) {
        _updateState(() {
          _respondLoading.remove(request.requestId);
        });
      }
    }
  }

  Future<void> _cancelInvite(FriendRequest request) async {
    if (_respondLoading.contains(request.requestId)) {
      return;
    }
    _updateState(() {
      _respondLoading.add(request.requestId);
    });

    try {
      await widget.controller.cancelInvite(requestId: request.requestId);
      if (!mounted) {
        return;
      }
      _showSnack(
        context.l10n.friendsInviteToCancelled(_friendPrimaryName(request.user)),
      );
      await _loadSnapshot(showLoader: false);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.friendsFailedToCancelInvite, isError: true);
    } finally {
      if (mounted) {
        _updateState(() {
          _respondLoading.remove(request.requestId);
        });
      }
    }
  }
}
