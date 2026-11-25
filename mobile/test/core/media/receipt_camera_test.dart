import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/media/receipt_camera_page.dart';
import 'package:tripsplit/core/media/receipt_crop_flow.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

import '../../support/receipt_camera_fake.dart';

Future<Uint8List> photo() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    const Rect.fromLTWH(0, 0, 120, 240),
    Paint()..color = Colors.white,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(120, 240);
  final bytes = (await image.toByteData(
    format: ui.ImageByteFormat.png,
  ))!.buffer.asUint8List();
  image.dispose();
  picture.dispose();
  return bytes;
}

void main() {
  late ReceiptCameraFake camera;
  late Uint8List bytes;
  late Directory directory;
  bool current = true;
  int returns = 0;
  ReceiptPhoto? result;

  Future<void> mount(
    WidgetTester tester, {
    double scale = 1,
    Locale locale = const Locale('en'),
  }) async {
    current = true;
    returns = 0;
    result = null;
    bytes = (await tester.runAsync(photo))!;
    directory = Directory.systemTemp.createTempSync('splyto-camera-test-');
    addTearDown(() => directory.deleteSync(recursive: true));
    camera = ReceiptCameraFake(bytes, directory)..install();
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<ReceiptPhoto>(
                  MaterialPageRoute(
                    builder: (_) =>
                        ReceiptCameraPage(isCurrentAccount: () => current),
                  ),
                );
                returns++;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('receipt-camera-capture')));
    await waitForReceiptCrop(tester);
  }

  testWidgets(
    'capture goes directly to crop; retake returns to camera; only Save returns bytes',
    (tester) async {
      await mount(tester);
      await open(tester);
      expect(
        camera.descriptions.single.lensDirection,
        CameraLensDirection.back,
      );
      expect(camera.audio, [false]);
      await capture(tester);
      expect(returns, 0);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Open'), findsNothing);
      expect(camera.disposed, [1]);
      expect(camera.files.single.existsSync(), isFalse);
      await tester.tap(find.byKey(const ValueKey('receipt-camera-retake')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('fake-camera-preview')), findsOneWidget);
      expect(returns, 0);
      await capture(tester);
      await tester.tap(find.byKey(const ValueKey('receipt-crop-save')));
      await tester.pumpAndSettle();
      expect(returns, 1);
      expect(result!.bytes, bytes);
      expect(camera.captures, 2);
      expect(camera.disposed, [1, 2]);
      expect(camera.files.every((f) => !f.existsSync()), isTrue);
    },
  );

  for (final crop in [false, true]) {
    testWidgets(
      'cancel from ${crop ? 'crop' : 'camera'} returns no attachment',
      (tester) async {
        await mount(tester);
        await open(tester);
        if (crop) await capture(tester);
        await tester.tap(
          find.byKey(
            ValueKey(crop ? 'receipt-crop-cancel' : 'receipt-camera-cancel'),
          ),
        );
        await tester.pumpAndSettle();
        expect(returns, 1);
        expect(result, isNull);
        expect(camera.disposed, [1]);
      },
    );
  }

  testWidgets('permission denied explains Settings and retry recovers', (
    tester,
  ) async {
    await mount(tester);
    camera.errorCode = 'CameraAccessDeniedWithoutPrompt';
    await open(tester);
    expect(find.textContaining('Settings'), findsOneWidget);
    expect(camera.captures, 0);
    camera.errorCode = null;
    await tester.tap(find.byKey(const ValueKey('receipt-camera-retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fake-camera-preview')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('receipt-camera-cancel')));
    await tester.pumpAndSettle();
  });

  testWidgets('missing camera shows recoverable failure', (tester) async {
    await mount(tester);
    camera.noCameras = true;
    await open(tester);
    expect(find.byKey(const ValueKey('receipt-camera-retry')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('receipt-camera-capture')),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('receipt-camera-cancel')));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });

  testWidgets(
    'background releases camera, resume recreates it, account change closes it',
    (tester) async {
      await mount(tester);
      await open(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(camera.disposed, [1]);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(camera.created, 2);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      current = false;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(returns, 1);
      expect(result, isNull);
      expect(camera.disposed, [1, 2]);
    },
  );

  testWidgets(
    'cancel during capture discards late photo and removes temporary file',
    (tester) async {
      await mount(tester);
      await open(tester);
      final pending = camera.capture = Completer<void>();
      await tester.tap(find.byKey(const ValueKey('receipt-camera-capture')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('receipt-camera-cancel')));
      await tester.pumpAndSettle();
      pending.complete();
      for (var i = 0; i < 100 && camera.disposed.isEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      expect(result, isNull);
      expect(returns, 1);
      expect(camera.files.single.existsSync(), isFalse);
      expect(camera.disposed, [1]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('camera and crop fit 320px at 200 percent Latvian text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester, scale: 2, locale: const Locale('lv'));
    await open(tester);
    expect(tester.takeException(), isNull);
    await capture(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('receipt-crop-cancel')));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'permission prompt lifecycle serializes initialization and disposal',
    (tester) async {
      await mount(tester);
      final pending = camera.initialization = Completer<void>();
      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(camera.created, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(camera.created, 1);
      pending.complete();
      await tester.pumpAndSettle();
      expect(camera.disposed, [1]);
      expect(camera.created, 2);
      expect(find.byKey(const ValueKey('fake-camera-preview')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('receipt-camera-cancel')));
      await tester.pumpAndSettle();
      expect(camera.disposed, [1, 2]);
    },
  );

  testWidgets(
    'repeated shutter taps capture once and crop survives background',
    (tester) async {
      await mount(tester);
      await open(tester);
      final pending = camera.capture = Completer<void>();
      await tester.tap(find.byKey(const ValueKey('receipt-camera-capture')));
      await tester.tap(find.byKey(const ValueKey('receipt-camera-capture')));
      await tester.pump();
      expect(camera.captures, 1);
      pending.complete();
      await waitForReceiptCrop(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(camera.created, 1);
      expect(find.byKey(const ValueKey('receipt-crop-save')), findsOneWidget);
      current = false;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(returns, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
