import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../l10n/l10n.dart';
import 'receipt_crop_editor_page.dart';
import 'receipt_crop_flow.dart';

/// Capture and crop occupy one route; nothing is attached before Save.
class ReceiptCameraPage extends StatefulWidget {
  const ReceiptCameraPage({super.key, required this.isCurrentAccount});

  final bool Function() isCurrentAccount;

  @override
  State<ReceiptCameraPage> createState() => _ReceiptCameraPageState();
}

class _ReceiptCameraPageState extends State<ReceiptCameraPage>
    with WidgetsBindingObserver {
  CameraController? _camera;
  PreparedReceiptCrop? _crop;
  Future<void> _work = Future.value();
  int _generation = 0;
  bool _foreground = true;
  bool _busy = true;
  bool _denied = false;
  bool _failed = false;

  bool _current(int generation) =>
      mounted &&
      _foreground &&
      generation == _generation &&
      widget.isCurrentAccount();

  // Camera initialization, capture and disposal must not race on the native side.
  void _enqueue(Future<void> Function() action) {
    _work = _work.then((_) => action());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  Future<void> _release() async {
    final camera = _camera;
    _camera = null;
    try {
      await camera?.dispose();
    } catch (_) {
      // A disconnected camera may already have released its native resources.
    }
  }

  void _start() {
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _failed = false;
      _denied = false;
    });
    _enqueue(() async {
      await _release();
      if (!_current(generation)) return;
      CameraController? camera;
      try {
        final cameras = await availableCameras();
        if (!_current(generation)) return;
        if (cameras.isEmpty) throw CameraException('NoCamera', '');
        final rear = cameras.where(
          (c) => c.lensDirection == CameraLensDirection.back,
        );
        camera = CameraController(
          rear.isEmpty ? cameras.first : rear.first,
          ResolutionPreset.veryHigh,
          enableAudio: false,
        );
        _camera = camera;
        await camera.initialize();
        if (!_current(generation)) {
          await _release();
          return;
        }
        // Some devices have no flash; that must not prevent receipt capture.
        try {
          await camera.setFlashMode(FlashMode.off);
        } on CameraException catch (_) {}
        if (!_current(generation)) {
          await _release();
          return;
        }
        setState(() => _busy = false);
      } catch (error) {
        await _release();
        if (!_current(generation)) return;
        setState(() {
          _busy = false;
          _failed = true;
          _denied =
              error is CameraException &&
              (error.code.contains('AccessDenied') ||
                  error.code.contains('AccessRestricted'));
        });
      }
    });
  }

  void _capture() {
    final camera = _camera;
    if (_busy || camera == null || !_current(_generation)) return;
    final generation = _generation;
    setState(() => _busy = true);
    _enqueue(() async {
      if (!_current(generation)) return;
      try {
        final photo = await camera.takePicture();
        final bytes = await _readAndRemove(photo);
        if (!_current(generation)) return;
        await _release();
        final crop = await PreparedReceiptCrop.prepare(bytes, photo.name);
        if (!_current(generation)) return;
        setState(() {
          _crop = crop;
          _busy = false;
        });
      } catch (_) {
        await _release();
        if (!_current(generation)) return;
        setState(() {
          _busy = false;
          _failed = true;
        });
      }
    });
  }

  // Only the file just created by our own camera is removed, never library files.
  Future<Uint8List> _readAndRemove(XFile photo) async {
    try {
      return await photo.readAsBytes();
    } finally {
      try {
        await File(photo.path).delete();
      } on FileSystemException catch (_) {}
    }
  }

  void _retake() {
    if (!widget.isCurrentAccount()) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _crop = null);
    _start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_crop != null) {
      // The crop editor owns its account/lifecycle check.
      return;
    }
    if (!_foreground) {
      ++_generation;
      setState(() => _busy = true);
      _enqueue(_release);
    } else if (!widget.isCurrentAccount()) {
      Navigator.of(context).pop();
    } else {
      _start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ++_generation;
    _enqueue(_release);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crop = _crop;
    if (crop != null) {
      return ReceiptCropEditorPage<ReceiptPhoto>(
        source: crop.source,
        isCurrentAccount: widget.isCurrentAccount,
        complete: crop.complete,
        onRetake: _retake,
      );
    }
    final t = context.l10n;
    final camera = _camera;
    return Theme(
      data: AppTheme.dark(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(t.receiptPhotoLabel),
          leading: IconButton(
            key: const ValueKey('receipt-camera-cancel'),
            tooltip: t.cancelAction,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: _busy
                      ? const CircularProgressIndicator()
                      : _failed
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _denied
                                    ? t.receiptPhotoAccessDenied
                                    : t.receiptPickFailed,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                key: const ValueKey('receipt-camera-retry'),
                                onPressed: _start,
                                child: Text(t.retryAction),
                              ),
                            ],
                          ),
                        )
                      : camera != null && widget.isCurrentAccount()
                      ? CameraPreview(camera)
                      : const SizedBox.shrink(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('receipt-camera-capture'),
                    onPressed: _busy || _failed ? null : _capture,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(t.takePhotoAction),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
