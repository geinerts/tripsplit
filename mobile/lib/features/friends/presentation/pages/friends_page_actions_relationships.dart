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

  Future<bool> _confirmCancelInvite(FriendRequest request) async {
    final t = context.l10n;
    return showAppConfirmationDialog(
      context: context,
      title: t.friendsCancelInvite,
      message: t.friendsCancelInviteTo(request.user.preferredName),
      confirmLabel: t.friendsCancelInvite,
      cancelLabel: t.friendsKeep,
      icon: Icons.person_remove_alt_1_outlined,
      destructive: true,
    );
  }

  Future<void> _cancelInvite(FriendRequest request) async {
    if (_cancelLoading.contains(request.requestId)) {
      return;
    }
    final confirmed = await _confirmCancelInvite(request);
    if (!confirmed || !mounted) {
      return;
    }

    _updateState(() {
      _cancelLoading.add(request.requestId);
    });

    try {
      await widget.controller.cancelInvite(requestId: request.requestId);
      if (!mounted) {
        return;
      }
      _showSnack(
        context.l10n.friendsInviteToCancelled(request.user.preferredName),
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
          _cancelLoading.remove(request.requestId);
        });
      }
    }
  }
}
