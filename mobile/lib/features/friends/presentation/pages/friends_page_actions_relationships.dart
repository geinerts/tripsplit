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
            ? _txt(en: 'Friend added.', lv: 'Draugs pievienots.')
            : _txt(en: 'Request declined.', lv: 'Pieprasījums noraidīts.'),
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
      _showSnack(
        _txt(
          en: 'Failed to update request.',
          lv: 'Neizdevās atjaunināt pieprasījumu.',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        _updateState(() {
          _respondLoading.remove(request.requestId);
        });
      }
    }
  }

  Future<bool> _confirmCancelInvite(FriendRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_txt(en: 'Cancel invite', lv: 'Atcelt uzaicinājumu')),
        content: Text(
          _txt(
            en: 'Cancel invite to ${request.user.preferredName}?',
            lv: 'Atcelt uzaicinājumu lietotājam ${request.user.preferredName}?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_txt(en: 'Keep', lv: 'Atstāt')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_txt(en: 'Cancel invite', lv: 'Atcelt uzaicinājumu')),
          ),
        ],
      ),
    );
    return confirmed == true;
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
        _txt(
          en: 'Invite to ${request.user.preferredName} cancelled.',
          lv: 'Uzaicinājums lietotājam ${request.user.preferredName} atcelts.',
        ),
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
      _showSnack(
        _txt(
          en: 'Failed to cancel invite.',
          lv: 'Neizdevās atcelt uzaicinājumu.',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        _updateState(() {
          _cancelLoading.remove(request.requestId);
        });
      }
    }
  }
}
