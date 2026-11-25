import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';
import 'receipt_thumbnail.dart';

/// Fetches a fresh authorized URL on every attempt. The caller retains account
/// checks and URL policy; the widget never stores a signed link for retry.
class ReceiptOpenAction extends StatefulWidget {
  const ReceiptOpenAction({
    super.key,
    required this.load,
    required this.open,
    this.compactLabel,
    this.loadPreview,
    this.isCurrentAccount,
  }) : assert(loadPreview == null || isCurrentAccount != null);
  final Future<Uri?> Function() load;
  final Future<bool> Function(Uri) open;
  final Future<Uri?> Function()? loadPreview;
  final bool Function()? isCurrentAccount;

  /// Shows a small chip with this label instead of the full-width row.
  final String? compactLabel;
  @override
  State<ReceiptOpenAction> createState() => _ReceiptOpenActionState();
}

class _ReceiptOpenActionState extends State<ReceiptOpenAction> {
  bool _busy = false;
  String? _error;
  Future<void> _open() async {
    if (_busy || widget.isCurrentAccount?.call() == false) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final uri = await widget.load();
      if (!mounted || widget.isCurrentAccount?.call() == false) return;
      if (uri == null) {
        setState(() => _error = context.l10n.receiptLinkInvalid);
      } else {
        final opened = await widget.open(uri);
        if (!opened && mounted) {
          setState(() => _error = context.l10n.couldNotOpenReceiptLink);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.couldNotOpenReceiptLink);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _chip(BuildContext context, String label) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: colors.primary.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            key: const ValueKey('receipt-open'),
            borderRadius: BorderRadius.circular(12),
            onTap: _busy ? null : _open,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 36),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.loadPreview case final preview?)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ReceiptThumbnail(
                            load: preview,
                            isCurrentAccount: widget.isCurrentAccount!,
                          ),
                          if (_busy)
                            const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      )
                    else if (_busy)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                        color: colors.primary,
                      ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_error != null)
          Text(_error!, style: TextStyle(color: colors.error)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => widget.compactLabel != null
      ? _chip(context, widget.compactLabel!)
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1),
            TextButton(
              key: const ValueKey('receipt-open'),
              onPressed: _busy ? null : _open,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
              ),
              child: Row(
                children: [
                  if (_busy)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.receipt_long_outlined, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      context.l10n.openReceiptAction,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  if (!_busy) const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              TextButton.icon(
                onPressed: _busy ? null : _open,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retryAction),
              ),
            ],
            const Divider(height: 1),
          ],
        );
}
