import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ReceiptCameraFake extends CameraPlatform {
  ReceiptCameraFake(this.bytes, this.directory);

  final Uint8List bytes;
  final Directory directory;
  String? errorCode;
  bool noCameras = false;
  Completer<void>? initialization;
  Completer<void>? capture;
  int created = 0;
  int captures = 0;
  final disposed = <int>[];
  final files = <File>[];
  final descriptions = <CameraDescription>[];
  final audio = <bool>[];

  void install() {
    final original = CameraPlatform.instance;
    CameraPlatform.instance = this;
    addTearDown(() => CameraPlatform.instance = original);
  }

  @override
  Future<List<CameraDescription>> availableCameras() async => noCameras
      ? []
      : [
          const CameraDescription(
            name: 'front',
            lensDirection: CameraLensDirection.front,
            sensorOrientation: 90,
          ),
          const CameraDescription(
            name: 'rear',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90,
          ),
        ];

  @override
  Future<int> createCamera(
    CameraDescription description,
    ResolutionPreset? preset, {
    bool enableAudio = false,
  }) async {
    if (errorCode != null) throw CameraException(errorCode!, '');
    descriptions.add(description);
    audio.add(enableAudio);
    return ++created;
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    await initialization?.future;
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) =>
      Stream.value(
        CameraInitializedEvent(
          cameraId,
          640,
          480,
          ExposureMode.auto,
          true,
          FocusMode.auto,
          true,
        ),
      );

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) =>
      Stream.fromFuture(Completer<CameraErrorEvent>().future);

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() =>
      const Stream.empty();

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {}

  @override
  Widget buildPreview(int cameraId) => const ColoredBox(
    color: Colors.blue,
    key: ValueKey('fake-camera-preview'),
  );

  @override
  Future<XFile> takePicture(int cameraId) async {
    captures++;
    await capture?.future;
    final file = File('${directory.path}/capture-$captures.png')
      ..writeAsBytesSync(bytes);
    files.add(file);
    return XFile(file.path);
  }

  @override
  Future<void> dispose(int cameraId) async {
    disposed.add(cameraId);
  }
}

Future<void> waitForReceiptCrop(WidgetTester tester) async {
  for (var i = 0; i < 500; i++) {
    await tester.pump();
    if (find.byKey(const ValueKey('receipt-crop-save')).evaluate().isNotEmpty) {
      await tester.pumpAndSettle();
      return;
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
  fail('Receipt crop did not open');
}
