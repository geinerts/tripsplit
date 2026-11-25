import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../l10n/l10n.dart';
import 'image_crop.dart';
import 'receipt_crop.dart';

/// Local receipt framing, without presenting another native camera controller.
class ReceiptCropEditorPage<T> extends StatefulWidget {
  const ReceiptCropEditorPage({
    super.key,
    required this.source,
    required this.isCurrentAccount,
    required this.complete,
    this.onRetake,
  });

  final ImageCropSourceData source;
  final bool Function() isCurrentAccount;
  final Future<T> Function(ImageCropRect crop, int quarterTurns) complete;
  final VoidCallback? onRetake;

  @override
  State<ReceiptCropEditorPage<T>> createState() =>
      _ReceiptCropEditorPageState<T>();
}

class _ReceiptCropEditorPageState<T> extends State<ReceiptCropEditorPage<T>>
    with WidgetsBindingObserver {
  late final _window = ReceiptCropWindow(
    Size(widget.source.width.toDouble(), widget.source.height.toDouble()),
  );
  late final _image = MemoryImage(widget.source.bytes);
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !widget.isCurrentAccount()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_image.evict());
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!widget.isCurrentAccount()) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await widget.complete(_window.crop, _window.quarterTurns);
      if (!mounted) return;
      Navigator.of(context).pop(widget.isCurrentAccount() ? result : null);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.imageCropSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Theme(
      data: AppTheme.dark(),
      child: PopScope(
        canPop: !_saving,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(t.receiptPhotoLabel),
            centerTitle: true,
            leading: IconButton(
              key: const ValueKey('receipt-crop-cancel'),
              tooltip: t.cancelAction,
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  key: const ValueKey('receipt-crop-save'),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(t.saveAction),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: AbsorbPointer(
                    absorbing: _saving,
                    child: widget.isCurrentAccount()
                        ? _ReceiptCanvas(
                            window: _window,
                            image: _image,
                            onChanged: (change) => setState(change),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    children: [
                      IconButton(
                        key: const ValueKey('receipt-crop-rotate'),
                        tooltip: t.imageCropRotate,
                        onPressed: _saving
                            ? null
                            : () => setState(_window.rotate),
                        icon: const Icon(Icons.rotate_right),
                      ),
                      if (widget.onRetake != null)
                        TextButton.icon(
                          key: const ValueKey('receipt-camera-retake'),
                          onPressed: _saving ? null : widget.onRetake,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: Text(t.receiptRetakePhoto),
                        ),
                      IconButton(
                        key: const ValueKey('receipt-crop-reset'),
                        tooltip: t.imageCropReset,
                        onPressed: _saving
                            ? null
                            : () => setState(_window.reset),
                        icon: const Icon(Icons.restart_alt),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptCanvas extends StatelessWidget {
  const _ReceiptCanvas({
    required this.window,
    required this.image,
    required this.onChanged,
  });

  final ReceiptCropWindow window;
  final ImageProvider image;
  final void Function(VoidCallback) onChanged;

  static const edges = [
    Offset(-1, -1),
    Offset(0, -1),
    Offset(1, -1),
    Offset(1, 0),
    Offset(1, 1),
    Offset(0, 1),
    Offset(-1, 1),
    Offset(-1, 0),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 64 || constraints.maxHeight < 64) {
        return const SizedBox.shrink();
      }
      final fitted = applyBoxFit(
        BoxFit.contain,
        window.size,
        Size(constraints.maxWidth - 48, constraints.maxHeight - 48),
      ).destination;
      final bounds = Alignment.center.inscribe(
        fitted,
        Offset.zero & constraints.biggest,
      );
      final rect = window.rect;
      final frame = Rect.fromLTWH(
        bounds.left + rect.left * bounds.width,
        bounds.top + rect.top * bounds.height,
        rect.width * bounds.width,
        rect.height * bounds.height,
      );
      Offset normalized(Offset delta) =>
          Offset(delta.dx / bounds.width, delta.dy / bounds.height);
      return Stack(
        children: [
          Positioned.fromRect(
            rect: bounds,
            child: RotatedBox(
              quarterTurns: window.quarterTurns,
              child: Image(
                image: image,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ReceiptFramePainter(frame)),
            ),
          ),
          Positioned.fromRect(
            rect: frame,
            child: GestureDetector(
              key: const ValueKey('receipt-crop-frame'),
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) =>
                  onChanged(() => window.move(normalized(details.delta))),
            ),
          ),
          for (var i = 0; i < edges.length; i++)
            Positioned(
              left: frame.center.dx + edges[i].dx * frame.width / 2 - 24,
              top: frame.center.dy + edges[i].dy * frame.height / 2 - 24,
              width: 48,
              height: 48,
              child: Semantics(
                label: '${context.l10n.imageCropEditAction} ${i + 1}/8',
                onIncrease: () =>
                    onChanged(() => window.resize(edges[i], edges[i] * .01)),
                onDecrease: () =>
                    onChanged(() => window.resize(edges[i], edges[i] * -.01)),
                child: GestureDetector(
                  key: ValueKey('receipt-crop-handle-$i'),
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) => onChanged(
                    () => window.resize(edges[i], normalized(details.delta)),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _ReceiptFramePainter extends CustomPainter {
  const _ReceiptFramePainter(this.frame);
  final Rect frame;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRect(frame),
      ),
      Paint()..color = const Color(0xB3000000),
    );
    canvas.drawRect(
      frame,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Subtle corner brackets show the draggable area without covering the photo.
    final handle = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;
    final length = (frame.shortestSide / 4).clamp(2.0, 14.0);
    for (final corner in [
      frame.topLeft,
      frame.topRight,
      frame.bottomRight,
      frame.bottomLeft,
    ]) {
      final dx = corner.dx == frame.left ? length : -length;
      final dy = corner.dy == frame.top ? length : -length;
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx + dx, corner.dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx, corner.dy + dy),
        handle,
      );
    }
    final grid = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final x = frame.left + frame.width * i / 3;
      final y = frame.top + frame.height * i / 3;
      canvas.drawLine(Offset(x, frame.top), Offset(x, frame.bottom), grid);
      canvas.drawLine(Offset(frame.left, y), Offset(frame.right, y), grid);
    }
  }

  @override
  bool shouldRepaint(_ReceiptFramePainter oldDelegate) =>
      oldDelegate.frame != frame;
}
