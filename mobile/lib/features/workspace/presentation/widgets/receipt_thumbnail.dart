import 'dart:async';

import 'package:flutter/material.dart';

/// A small authorized preview, kept only while its receipt action is mounted.
class ReceiptThumbnail extends StatefulWidget {
  const ReceiptThumbnail({
    super.key,
    required this.load,
    required this.isCurrentAccount,
  });

  final Future<Uri?> Function() load;
  final bool Function() isCurrentAccount;

  @override
  State<ReceiptThumbnail> createState() => _ReceiptThumbnailState();
}

class _ReceiptThumbnailState extends State<ReceiptThumbnail>
    with WidgetsBindingObserver {
  ImageProvider? _image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load());
  }

  Future<void> _load() async {
    if (!widget.isCurrentAccount()) return;
    try {
      final uri = await widget.load();
      if (!mounted || !widget.isCurrentAccount() || uri == null) return;
      setState(
        () => _image = ResizeImage.resizeIfNeeded(
          96,
          null,
          NetworkImage(uri.toString()),
        ),
      );
    } catch (_) {
      // Opening the receipt remains available and fetches a new authorized link.
    }
  }

  void _discard() {
    final image = _image;
    _image = null;
    if (image != null) unawaited(image.evict());
  }

  @override
  void didUpdateWidget(covariant ReceiptThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isCurrentAccount()) _discard();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !widget.isCurrentAccount()) {
      setState(_discard);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _discard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fallback = Center(
      child: Icon(Icons.receipt_long_outlined, size: 16, color: colors.primary),
    );
    final image = widget.isCurrentAccount() ? _image : null;
    return ExcludeSemantics(
      child: Container(
        key: const ValueKey('receipt-thumbnail'),
        width: 18,
        height: 18,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: image == null
            ? fallback
            : Image(
                image: image,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                frameBuilder: (_, child, frame, synchronous) =>
                    synchronous || frame != null ? child : fallback,
                errorBuilder: (_, error, stack) => fallback,
              ),
      ),
    );
  }
}
