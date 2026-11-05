import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';

/// Displays authorized receipt images without handing bearer links to a browser.
/// Every retry refreshes authorization; image cache entries are evicted on close.
class ReceiptViewerPage extends StatefulWidget {
  const ReceiptViewerPage({
    super.key,
    required this.initialUri,
    required this.reload,
    required this.isCurrentAccount,
  });

  final Uri initialUri;
  final Future<Uri?> Function() reload;
  final bool Function() isCurrentAccount;

  @override
  State<ReceiptViewerPage> createState() => _ReceiptViewerPageState();
}

class _ReceiptViewerPageState extends State<ReceiptViewerPage>
    with WidgetsBindingObserver {
  NetworkImage? _image;
  bool _refreshing = false;
  final _transform = TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isCurrentAccount()) {
      _image = NetworkImage(widget.initialUri.toString());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !widget.isCurrentAccount()) {
      _discardImage();
      setState(() {});
    }
  }

  void _discardImage() {
    final image = _image;
    _image = null;
    if (image != null) unawaited(image.evict());
  }

  Future<void> _retry() async {
    if (_refreshing) return;
    _discardImage();
    setState(() => _refreshing = true);
    try {
      final uri = widget.isCurrentAccount() ? await widget.reload() : null;
      if (!mounted || !widget.isCurrentAccount()) return;
      if (uri != null) _image = NetworkImage(uri.toString());
      _transform.value = Matrix4.identity();
    } catch (_) {
      // Keep the signed URL and server details out of visible error messages.
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _discardImage();
    _transform.dispose();
    super.dispose();
  }

  Widget _error() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 40),
          const SizedBox(height: 16),
          Text(
            context.l10n.couldNotOpenReceiptLink,
            textAlign: TextAlign.center,
          ),
          TextButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retryAction),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return Scaffold(
      key: const ValueKey('receipt-viewer'),
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(context.l10n.receiptPhotoLabel),
      ),
      body: SafeArea(
        child: _refreshing
            ? const Center(child: CircularProgressIndicator())
            : image == null || !widget.isCurrentAccount()
            ? _error()
            : LayoutBuilder(
                builder: (context, constraints) => InteractiveViewer(
                  transformationController: _transform,
                  maxScale: 8,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Image(
                      image: image,
                      fit: BoxFit.contain,
                      semanticLabel: context.l10n.receiptPhotoLabel,
                      frameBuilder: (context, child, frame, synchronous) =>
                          frame != null || synchronous
                          ? child
                          : const Center(child: CircularProgressIndicator()),
                      errorBuilder: (context, error, stack) => _error(),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
