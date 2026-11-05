import 'package:flutter/material.dart';

import 'splyto_illustration.dart';

/// Shared "check your inbox" confirmation used after the app asks the server to
/// send an email (password reset, account deletion confirmation).
class EmailSentView extends StatelessWidget {
  const EmailSentView({
    super.key,
    required this.title,
    required this.message,
    this.hint,
  });

  final String title;
  final String message;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SplytoEmailSentIllustration(width: 160, height: 124),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 12),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Primary action under an [EmailSentView]; identical on every confirmation.
ButtonStyle emailSentButtonStyle(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  return FilledButton.styleFrom(
    backgroundColor: colors.primary,
    foregroundColor: colors.onPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  );
}
