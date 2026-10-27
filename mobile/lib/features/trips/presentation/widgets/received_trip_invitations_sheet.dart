import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_components.dart';
import '../../domain/entities/received_trip_invitation.dart';

class ReceivedTripInvitationsSheet extends StatefulWidget {
  const ReceivedTripInvitationsSheet({
    super.key,
    required this.load,
    required this.respond,
  });
  final Future<List<ReceivedTripInvitation>> Function() load;
  final Future<void> Function(ReceivedTripInvitation) respond;
  @override
  State<ReceivedTripInvitationsSheet> createState() =>
      _ReceivedTripInvitationsSheetState();
}

class _ReceivedTripInvitationsSheetState
    extends State<ReceivedTripInvitationsSheet> {
  late Future<List<ReceivedTripInvitation>> _invitations;
  int? _busyId;
  @override
  void initState() {
    super.initState();
    _invitations = Future.sync(widget.load);
  }

  void _reload() {
    final pending = Future.sync(widget.load);
    setState(() {
      _invitations = pending;
    });
  }

  Future<void> _respond(ReceivedTripInvitation invitation) async {
    if (_busyId != null) return;
    setState(() => _busyId = invitation.id);
    try {
      await widget.respond(invitation);
    } finally {
      if (mounted) {
        setState(() => _busyId = null);
        _reload();
      }
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height * .65,
    child: AppActionSheet(
      title: context.l10n.homeTripInvitations,
      children: [
        FutureBuilder<List<ReceivedTripInvitation>>(
          future: _invitations,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Column(
                children: [
                  Text(context.l10n.homeInvitationsLoadFailed),
                  TextButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.l10n.retryAction),
                  ),
                ],
              );
            }
            final invitations = snapshot.data ?? [];
            if (invitations.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.mark_email_read_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.homeNoTripInvitations,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                for (final invitation in invitations) ...[
                  ListTile(
                    key: ValueKey('received-trip-invitation-${invitation.id}'),
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Icon(
                        Icons.luggage_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(invitation.tripName),
                    subtitle: Text(invitation.inviterName),
                    trailing: _busyId == invitation.id
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _busyId == null ? () => _respond(invitation) : null,
                  ),
                  const Divider(height: 1),
                ],
              ],
            );
          },
        ),
      ],
    ),
  );
}
