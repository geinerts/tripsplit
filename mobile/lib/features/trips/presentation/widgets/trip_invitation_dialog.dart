import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_components.dart';

/// Explicit responses remain distinct from closing the invitation (null).
class TripInvitationDialog extends StatelessWidget {
  const TripInvitationDialog({
    super.key,
    required this.message,
    this.acceptLabel,
    this.declineLabel,
  });
  final String message;
  final String? acceptLabel, declineLabel;
  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: AppActionSheet(
      title: context.l10n.shellTripInviteTitle,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 24),
          child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(acceptLabel ?? context.l10n.friendsAccept),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(declineLabel ?? context.l10n.friendsDecline),
          ),
        ),
      ],
    ),
  );
}
