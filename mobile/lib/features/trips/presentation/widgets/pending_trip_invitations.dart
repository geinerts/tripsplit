import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/pending_trip_invitation.dart';

class PendingTripInvitations extends StatefulWidget {
  const PendingTripInvitations({
    super.key,
    required this.load,
    required this.revoke,
  });
  final Future<List<PendingTripInvitation>> Function() load;
  final Future<void> Function(int invitationId) revoke;

  @override
  State<PendingTripInvitations> createState() => _PendingTripInvitationsState();
}

class _PendingTripInvitationsState extends State<PendingTripInvitations> {
  late Future<List<PendingTripInvitation>> _pending;
  int? _revoking;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _pending = widget.load();
  }

  Future<void> _revoke(int id) async {
    setState(() {
      _revoking = id;
      _failed = false;
    });
    try {
      await widget.revoke(id);
      if (mounted) _reload();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _revoking = null);
    }
  }

  void _reload() {
    final pending = widget.load();
    setState(() {
      _pending = pending;
    });
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<PendingTripInvitation>>(
        future: _pending,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return TextButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.tripInvitationsRetry),
            );
          }
          final invitations = snapshot.data ?? [];
          if (invitations.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.tripInvitationsPending,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (_failed)
                Text(
                  context.l10n.tripInvitationRevokeFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: invitations.length,
                  itemBuilder: (context, index) {
                    final invite = invitations[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule),
                      title: Text(
                        invite.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: _revoking == invite.id
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              tooltip: context.l10n.tripInvitationRevoke,
                              icon: const Icon(Icons.close),
                              onPressed: _revoking != null
                                  ? null
                                  : () => _revoke(invite.id),
                            ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
}
