import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_design.dart';
import '../../../../core/l10n/l10n.dart';

/// Local preview only: saved receipts are opened through the authenticated loader.
class ReceiptAttachmentCard extends StatelessWidget {
  const ReceiptAttachmentCard({
    super.key,
    required this.fileName,
    required this.onRemove,
    this.bytes,
    this.busy = false,
    this.enabled = true,
    this.saved = false,
    this.openAction,
    this.status,
  });

  final String fileName;
  final Uint8List? bytes;
  final VoidCallback onRemove;
  final bool busy;
  final bool enabled;
  final bool saved;
  final Widget? openAction;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final title = saved ? t.currentReceiptAttached : t.receiptPhotoLabel;
    final fallback = Icon(
      Icons.receipt_long_outlined,
      color: colors.primary,
      size: 28,
    );
    return Container(
      key: const ValueKey('receipt-attachment-card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppDesign.cardRadius,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 56,
                    height: 72,
                    child: bytes != null
                        ? Image.memory(
                            bytes!,
                            fit: BoxFit.contain,
                            cacheWidth: 168,
                            frameBuilder: (_, child, frame, synchronous) =>
                                synchronous || frame != null ? child : fallback,
                            errorBuilder: (_, error, stack) => fallback,
                          )
                        : fallback,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Tooltip(
                  message: fileName,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('receipt-remove'),
                onPressed: busy || !enabled ? null : onRemove,
                tooltip: t.removeReceiptAction,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          ?openAction,
          if (busy || status != null) ...[
            const SizedBox(height: 8),
            if (busy) ...[
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 8),
            ],
            Semantics(
              liveRegion: true,
              child: Text(
                busy ? t.expenseReadingReceipt : status!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
