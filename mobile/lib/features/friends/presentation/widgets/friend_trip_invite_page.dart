import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../workspace/presentation/widgets/workspace_input_pages.dart';
import '../controllers/friend_trip_actions.dart';

class FriendTripInvitePage extends StatefulWidget {
  const FriendTripInvitePage({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.actions,
  });
  final int friendId;
  final String friendName;
  final FriendTripActions actions;
  @override
  State<FriendTripInvitePage> createState() => _FriendTripInvitePageState();
}

class _FriendTripInvitePageState extends State<FriendTripInvitePage> {
  List<Trip> _trips = [];
  int? _selected;
  bool _loading = true, _sending = false;
  String? _error;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
      _error = null;
    });
    try {
      final trips = await widget.actions.invitableTrips(widget.friendId);
      if (!mounted) return;
      setState(() {
        _trips = trips;
        if (!trips.any((t) => t.id == _selected)) _selected = null;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    if (_sending || _selected == null) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final sent = await widget.actions.invite(_selected!, widget.friendId);
      if (!mounted) return;
      if (sent) {
        Navigator.pop(context, true);
        return;
      }
      await _load();
      if (mounted) setState(() => _error = context.l10n.friendTripUnavailable);
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.friendTripActionFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return PopScope(
      canPop: !_sending,
      child: WorkspaceInputPage(
        title: t.friendInviteToTrip,
        canClose: !_sending,
        action: t.tripInviteAction,
        onSubmit: _sending || _loading || _failed || _selected == null
            ? null
            : _send,
        children: [
          Text(
            widget.friendName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          Text(
            t.friendChooseTrip,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          if (_loading || _sending) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_failed) ...[
            Text(t.friendTripActionFailed),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: Text(t.retryAction),
            ),
          ] else if (!_loading && _trips.isEmpty)
            Text(t.friendNoInvitableTrips)
          else if (!_loading)
            for (final trip in _trips) ...[
              ListTile(
                key: ValueKey('friend-invite-trip-${trip.id}'),
                contentPadding: EdgeInsets.zero,
                title: Text(trip.name),
                subtitle: Text(
                  '${trip.currencyCode} · ${t.friendsMembers(trip.membersCount)}',
                ),
                leading: Icon(
                  _selected == trip.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _selected == trip.id
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                selected: _selected == trip.id,
                onTap: _sending
                    ? null
                    : () => setState(() => _selected = trip.id),
              ),
              const Divider(height: 1),
            ],
        ],
      ),
    );
  }
}
