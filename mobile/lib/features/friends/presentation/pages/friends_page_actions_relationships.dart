part of 'friends_page.dart';

extension _FriendsPageActionsRelationships on _FriendsPageState {
  Future<void> _openFriendListActions(FriendUser friend) async {
    final accountId = widget.authController.currentUser?.id;
    if (accountId == null || _friendActionLoading.contains(friend.id)) {
      return;
    }
    bool accountIsCurrent() =>
        mounted && widget.authController.currentUser?.id == accountId;
    _updateState(() => _friendActionLoading.add(friend.id));
    try {
      final selected = await showAppBottomSheet<_FriendProfileAction>(
        context: context,
        builder: (sheetContext) => AppActionSheet(
          title: _friendPrimaryName(friend),
          children: [
            AppPlainActionTile(
              icon: Icons.person_remove_alt_1_rounded,
              title: context.l10n.friendsRemoveFriend,
              destructive: true,
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(_FriendProfileAction.removeFriend),
            ),
          ],
        ),
      );
      if (!mounted ||
          !accountIsCurrent() ||
          selected != _FriendProfileAction.removeFriend) {
        return;
      }
      final confirmed = await showAppConfirmationDialog(
        context: context,
        title: context.l10n.friendsRemoveThisFriend,
        message: context.l10n.friendsWillBeRemovedFromYourFriendsListYouCanAdd(
          _friendPrimaryName(friend),
        ),
        confirmLabel: context.l10n.friendsContinue,
        cancelLabel: context.l10n.authCancel,
        icon: Icons.person_remove_alt_1_rounded,
        destructive: true,
      );
      if (!confirmed || !accountIsCurrent()) return;
      await widget.controller.removeFriend(userId: friend.id);
      if (!mounted || !accountIsCurrent()) return;
      _showSnack(context.l10n.friendsFriendRemoved);
      await _loadSnapshot(showLoader: false);
    } on ApiException catch (error) {
      if (accountIsCurrent()) _showSnack(error.message, isError: true);
    } catch (_) {
      if (mounted && accountIsCurrent()) {
        _showSnack(context.l10n.friendsCouldNotRemoveFriend, isError: true);
      }
    } finally {
      if (mounted) {
        _updateState(() => _friendActionLoading.remove(friend.id));
      }
    }
  }

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
