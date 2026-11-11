import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_person_toggle.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../domain/entities/trip_user.dart';
import '../../domain/entities/pending_trip_invitation.dart';
import 'pending_trip_invitations.dart';

class TripInviteMembersPage extends StatefulWidget {
  const TripInviteMembersPage({
    super.key,
    required this.tripName,
    required this.loadFriends,
    required this.loadPending,
    required this.revoke,
  });
  final String tripName;
  final Future<List<TripUser>> Function() loadFriends;
  final Future<List<PendingTripInvitation>> Function() loadPending;
  final Future<void> Function(int) revoke;
  @override
  State<TripInviteMembersPage> createState() => _TripInviteMembersPageState();
}

class _TripInviteMembersPageState extends State<TripInviteMembersPage> {
  List<TripUser> _friends = [];
  final _selected = <int>{};
  bool _friendsLoading = false, _friendsFailed = false;
  bool _submitted = false;
  final _friendQuery = TextEditingController();

  /// Above this many friends a search field appears, as in the trip form.
  static const _friendSearchThreshold = 12;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    _friendQuery.dispose();
    super.dispose();
  }

  List<TripUser> get _visibleFriends {
    final query = _friendQuery.text.trim().toLowerCase();
    if (query.isEmpty) return _friends;
    return [
      for (final friend in _friends)
        if (_selected.contains(friend.id) ||
            friend.nickname.toLowerCase().contains(query))
          friend,
    ];
  }

  Widget _friendAvatar(TripUser friend) {
    final colors = Theme.of(context).colorScheme;
    final name = friend.nickname.trim();
    final initial = Text(
      name.isEmpty ? '?' : name.characters.first.toUpperCase(),
    );
    final url = (friend.avatarThumbUrl ?? friend.avatarUrl ?? '').trim();
    return CircleAvatar(
      radius: 18,
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
      child: ClipOval(
        child: url.isEmpty
            ? initial
            : Image.network(
                url,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => initial,
              ),
      ),
    );
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
                if (_friends.length > _friendSearchThreshold) ...[
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('invite-friend-search'),
                    controller: _friendQuery,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: t.tripsSearchFriends,
                    ),
                  ),
                ],
                if (_friends.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  // Same picker as the trip form: tap a face to include them.
                  Wrap(
                    key: const ValueKey('invite-friends-grid'),
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      for (final friend in _visibleFriends)
                        AppPersonToggle(
                          key: ValueKey('invite-friend-${friend.id}'),
                          name: friend.nickname,
                          avatar: _friendAvatar(friend),
                          selected: _selected.contains(friend.id),
                          onChanged: (on) {
                            if (_submitted) return;
                            setState(() {
                              on
                                  ? _selected.add(friend.id)
                                  : _selected.remove(friend.id);
                            });
                          },
                        ),
                    ],
                  ),
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
