import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../errors/api_exception.dart';
import '../l10n/l10n.dart';
import 'image_crop.dart';

/// Move and zoom a photo under a fixed frame. Used for trip, profile and visit photos.
///
/// [load] supplies the photo, and [complete] runs when the person confirms. The page
/// closes with its result, or with null when cancelled.
class ImageCropEditorPage<T> extends StatefulWidget {
  const ImageCropEditorPage({
    super.key,
    required this.title,
    required this.aspectRatio,
    required this.load,
    required this.complete,
    this.circular = false,
  });

  final String title;
  final double aspectRatio;
  final bool circular;
  final Future<ImageCropSourceData> Function() load;
  final Future<T> Function(ImageCropRect crop, ImageCropSourceData source)
  complete;

  @override
  State<ImageCropEditorPage<T>> createState() => _ImageCropEditorPageState<T>();
}

class _ImageCropEditorPageState<T> extends State<ImageCropEditorPage<T>> {
  ImageCropSourceData? _source;
  ImageCropWindow? _window;
  bool _failed = false, _saving = false;
  double _lastScale = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final source = await widget.load();
      if (!mounted) return;
      setState(() {
        _source = source;
        _window = ImageCropWindow(
          imageSize: Size(source.width.toDouble(), source.height.toDouble()),
          aspectRatio: widget.aspectRatio,
          initial: source.crop,
        );
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _done() async {
    final source = _source, window = _window;
    if (source == null || window == null || _saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final t = context.l10n;
    setState(() => _saving = true);
    try {
      final result = await widget.complete(window.rect, source);
      if (mounted) Navigator.of(context).pop(result);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.code == 'image_changed'
                ? t.imageCropChanged
                : t.imageCropSaveFailed,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(t.imageCropSaveFailed)));
    }
  }

  void _zoom(double factor) => setState(() => _window?.zoom(factor));

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final window = _window, source = _source;
    return Theme(
      data: AppTheme.dark(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(widget.title),
          leading: CloseButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                key: const ValueKey('image-crop-done'),
                onPressed: window == null || _saving ? null : _done,
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
          child: _failed
              ? _LoadFailed(onRetry: _load)
              : window == null || source == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: _CropCanvas(
                        window: window,
                        bytes: source.bytes,
                        circular: widget.circular,
                        onChanged: (change) => setState(change),
                        onScaleStart: () => _lastScale = 1,
                        scaleDelta: (scale) {
                          final delta = scale / _lastScale;
                          _lastScale = scale;
                          return delta;
                        },
                      ),
                    ),
                    if (!source.hasOriginal)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Text(
                          t.imageCropZoomOnly,
                          key: const ValueKey('image-crop-zoom-only'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            key: const ValueKey('image-crop-zoom-out'),
                            tooltip: t.imageCropZoomOut,
                            onPressed: window.canZoomOut
                                ? () => _zoom(1 / 1.25)
                                : null,
                            icon: const Icon(Icons.zoom_out),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            key: const ValueKey('image-crop-zoom-in'),
                            tooltip: t.imageCropZoomIn,
                            onPressed: window.canZoomIn
                                ? () => _zoom(1.25)
                                : null,
                            icon: const Icon(Icons.zoom_in),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.imageCropLoadFailed, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: Text(context.l10n.retryAction),
          ),
        ],
      ),
    ),
  );
}

class _CropCanvas extends StatelessWidget {
  const _CropCanvas({
    required this.window,
    required this.bytes,
    required this.circular,
    required this.onChanged,
    required this.onScaleStart,
    required this.scaleDelta,
  });

  final ImageCropWindow window;
  final Uint8List bytes;
  final bool circular;
  final void Function(VoidCallback change) onChanged;
  final VoidCallback onScaleStart;
  final double Function(double scale) scaleDelta;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const margin = 16.0;
      final available = Size(
        constraints.maxWidth - margin * 2,
        constraints.maxHeight - margin * 2,
      );
      var frameWidth = available.width;
      var frameHeight = frameWidth / window.aspectRatio;
      if (frameHeight > available.height) {
        frameHeight = available.height;
        frameWidth = frameHeight * window.aspectRatio;
      }
      final frame = Rect.fromCenter(
        center: constraints.biggest.center(Offset.zero),
        width: frameWidth,
        height: frameHeight,
      );
      final scale = frameWidth / window.cropWidth;
      final imageLeft =
          frame.left - (window.center.dx - window.cropWidth / 2) * scale;
      final imageTop =
          frame.top - (window.center.dy - window.cropHeight / 2) * scale;
      return GestureDetector(
        key: const ValueKey('image-crop-canvas'),
        behavior: HitTestBehavior.opaque,
        onScaleStart: (_) => onScaleStart(),
        onScaleUpdate: (details) => onChanged(() {
          final zoomDelta = scaleDelta(details.scale);
          if (zoomDelta != 1) window.zoom(zoomDelta);
          // Dragging the photo moves the window the opposite way.
          window.pan(-details.focalPointDelta / scale);
        }),
        child: ClipRect(
          child: Stack(
            children: [
              Positioned(
                left: imageLeft,
                top: imageTop,
                width: window.imageSize.width * scale,
                height: window.imageSize.height * scale,
                child: Image.memory(
                  bytes,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _FramePainter(frame: frame, circular: circular),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _FramePainter extends CustomPainter {
  const _FramePainter({required this.frame, required this.circular});

  final Rect frame;
  final bool circular;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = Path();
    if (circular) {
      hole.addOval(frame);
    } else {
      hole.addRect(frame);
    }
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        hole,
      ),
      Paint()..color = const Color(0xB3000000),
    );
    final line = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(hole, line);
    if (circular) return;
    final grid = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final dx = frame.left + frame.width * i / 3;
      final dy = frame.top + frame.height * i / 3;
      canvas.drawLine(Offset(dx, frame.top), Offset(dx, frame.bottom), grid);
      canvas.drawLine(Offset(frame.left, dy), Offset(frame.right, dy), grid);
    }
  }

  @override
  bool shouldRepaint(_FramePainter old) =>
      old.frame != frame || old.circular != circular;
}
