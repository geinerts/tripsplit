import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';

/// Explicit responses are distinct from dismissing the dialog (null).
class TripInvitationDialog extends StatelessWidget {
  const TripInvitationDialog({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.shellTripInviteTitle),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(context.l10n.friendsDecline),
      ),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(context.l10n.friendsAccept),
      ),
    ],
  );
}
