import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';

/// Fetches a fresh authorized URL on every attempt. The caller retains account
/// checks and URL policy; the widget never stores a signed link for retry.
class ReceiptOpenAction extends StatefulWidget {
  const ReceiptOpenAction({super.key, required this.load, required this.open});
  final Future<Uri?> Function() load;
  final Future<bool> Function(Uri) open;
  @override
  State<ReceiptOpenAction> createState() => _ReceiptOpenActionState();
}

class _ReceiptOpenActionState extends State<ReceiptOpenAction> {
  bool _busy = false;
  String? _error;
  Future<void> _open() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final uri = await widget.load();
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(height: 1),
      TextButton(
        key: const ValueKey('receipt-open'),
        onPressed: _busy ? null : _open,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
            if (!_busy) const Icon(Icons.open_in_new, size: 20),
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
