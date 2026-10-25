import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../domain/entities/trip_user.dart';
import '../../domain/entities/trip_invite_link.dart';
import '../../domain/entities/pending_trip_invitation.dart';
import 'pending_trip_invitations.dart';

class TripInviteMembersPage extends StatefulWidget {
  const TripInviteMembersPage({
    super.key,
    required this.tripName,
    required this.loadFriends,
    required this.loadLink,
    required this.loadPending,
    required this.revoke,
  });
  final String tripName;
  final Future<List<TripUser>> Function() loadFriends;
  final Future<TripInviteLink> Function() loadLink;
  final Future<List<PendingTripInvitation>> Function() loadPending;
  final Future<void> Function(int) revoke;
  @override
  State<TripInviteMembersPage> createState() => _TripInviteMembersPageState();
}

class _TripInviteMembersPageState extends State<TripInviteMembersPage> {
  List<TripUser> _friends = [];
  final _selected = <int>{};
  TripInviteLink? _link;
  bool _friendsLoading = false, _linkLoading = false, _friendsFailed = false;
  bool _copying = false, _submitted = false;
  String? _linkError;
  @override
  void initState() {
    super.initState();
    _loadFriends();
    _loadLink();
  }

  Future<void> _loadFriends() async {
    if (_friendsLoading) return;
    setState(() {
      _friendsLoading = true;
      _friendsFailed = false;
    });
    try {
      final friends = await widget.loadFriends();
      if (mounted) setState(() => _friends = friends);
    } catch (_) {
      if (mounted) setState(() => _friendsFailed = true);
    } finally {
      if (mounted) setState(() => _friendsLoading = false);
    }
  }

  Future<void> _loadLink() async {
    if (_linkLoading) return;
    setState(() {
      _linkLoading = true;
      _linkError = null;
      _link = null;
    });
    try {
      final link = await widget.loadLink();
      if (link.inviteUrl.trim().isEmpty) {
        throw StateError('Empty invitation link');
      }
      if (mounted) setState(() => _link = link);
    } catch (error) {
      if (mounted) {
        setState(
          () => _linkError =
              error is ApiException && error.message.trim().isNotEmpty
              ? error.message
              : context.l10n.workspaceFailedToGenerateInviteLink,
        );
      }
    } finally {
      if (mounted) setState(() => _linkLoading = false);
    }
  }

  Future<void> _copy() async {
    if (_copying || _link == null) return;
    setState(() => _copying = true);
    try {
      await Clipboard.setData(ClipboardData(text: _link!.inviteUrl.trim()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.workspaceInviteLinkCopied)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.inviteClipboardFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _copying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppFormScaffold(
      key: const ValueKey('invite-members-page'),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: _submitted ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.inviteTripMembersAction,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          widget.tripName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              key: const ValueKey('invite-members-list'),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Text(
                  t.workspaceInviteLink,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (_linkLoading)
                  const LinearProgressIndicator()
                else if (_linkError != null) ...[
                  Text(
                    _linkError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const ValueKey('invite-link-retry'),
                      onPressed: _loadLink,
                      icon: const Icon(Icons.refresh),
                      label: Text(t.retryAction),
                    ),
                  ),
                ] else if (_link != null) ...[
                  SelectableText(
                    _link!.inviteUrl.trim(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const ValueKey('invite-link-copy'),
                      onPressed: _copying ? null : _copy,
                      icon: const Icon(Icons.copy_outlined),
                      label: Text(t.workspaceCopyInviteLink),
                    ),
                  ),
                  if (_link!.expiresAt != null)
                    Text(
                      t.workspaceExpiresUtc(_link!.expiresAt!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                PendingTripInvitations(
                  load: widget.loadPending,
                  revoke: widget.revoke,
                ),
                const SizedBox(height: 16),
                Text(
                  t.navFriends,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_friendsLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(),
                  ),
                if (_friendsFailed) ...[
                  Text(
                    t.workspaceFailedToLoadFriends,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const ValueKey('invite-friends-retry'),
                      onPressed: _loadFriends,
                      icon: const Icon(Icons.refresh),
                      label: Text(t.retryAction),
                    ),
                  ),
                ] else if (!_friendsLoading && _friends.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(t.workspaceNoFriendsAvailableAddFriendsFirst),
                  ),
                for (final friend in _friends) ...[
                  CheckboxListTile(
                    key: ValueKey('invite-friend-${friend.id}'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          child: ClipOval(
                            child:
                                (friend.avatarThumbUrl ??
                                        friend.avatarUrl ??
                                        '')
                                    .isEmpty
                                ? Text(
                                    friend.nickname.trim().isEmpty
                                        ? '?'
                                        : friend.nickname
                                              .trim()
                                              .characters
                                              .first
                                              .toUpperCase(),
                                  )
                                : Image.network(
                                    friend.avatarThumbUrl ?? friend.avatarUrl!,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Text(
                                      friend.nickname.trim().isEmpty
                                          ? '?'
                                          : friend.nickname
                                                .trim()
                                                .characters
                                                .first
                                                .toUpperCase(),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(friend.nickname)),
                      ],
                    ),
                    value: _selected.contains(friend.id),
                    onChanged: _submitted
                        ? null
                        : (selected) => setState(() {
                            if (selected == true) {
                              _selected.add(friend.id);
                            } else {
                              _selected.remove(friend.id);
                            }
                          }),
                  ),
                  const Divider(height: 1),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const ValueKey('invite-members-submit'),
                onPressed: _selected.isEmpty || _submitted
                    ? null
                    : () {
                        if (_submitted) return;
                        setState(() => _submitted = true);
                        Navigator.pop(context, Set<int>.of(_selected));
                      },
                child: Text(t.tripInviteAction),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
