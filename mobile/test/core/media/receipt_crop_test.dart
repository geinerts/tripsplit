import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/media/image_crop.dart';
import 'package:tripsplit/core/media/receipt_crop.dart';
import 'package:tripsplit/core/media/receipt_crop_editor_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

Future<Uint8List> _photo() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 120, 240),
    Paint()..color = Colors.white,
  );
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 60, 120),
    Paint()..color = Colors.red,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(120, 240);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return data!.buffer.asUint8List();
}

Widget _app(
  Uint8List bytes, {
  required Future<ImageCropRect> Function(ImageCropRect, int) complete,
  required void Function(ImageCropRect?) closed,
  bool Function()? current,
  double scale = 1,
  Locale locale = const Locale('en'),
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        child: const Text('Open'),
        onPressed: () async => closed(
          await Navigator.of(context).push<ImageCropRect>(
            MaterialPageRoute(
              builder: (_) => ReceiptCropEditorPage<ImageCropRect>(
                source: ImageCropSourceData(
                  bytes: bytes,
                  width: 120,
                  height: 240,
                ),
                isCurrentAccount: current ?? () => true,
                complete: complete,
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  test(
    'starts whole and supports narrow tall receipts without locking ratio',
    () {
      final window = ReceiptCropWindow(const Size(4000, 3000));
      expect(window.rect, const Rect.fromLTWH(0, 0, 1, 1));
      window.resize(const Offset(-1, 0), const Offset(.4, 0));
      window.resize(const Offset(1, 0), const Offset(-.4, 0));
      expect(window.rect.width, closeTo(.2, .00001));
      expect(window.rect.height, 1);
      window.move(const Offset(999, -999));
      expect(window.rect.right, closeTo(1, .00001));
      expect(window.rect.top, 0);
      window.resize(const Offset(-1, -1), const Offset(999, 999));
      expect(window.rect.width * window.size.width, closeTo(32, .00001));
      expect(window.rect.height * window.size.height, closeTo(32, .00001));
    },
  );

  test('rotation preserves the selected region; reset restores original', () {
    final window = ReceiptCropWindow(const Size(120, 240));
    window.resize(const Offset(1, 1), const Offset(-.5, -.5));
    window.rotate();
    expect(window.size, const Size(240, 120));
    expect(window.rect, const Rect.fromLTWH(.5, 0, .5, .5));
    for (var i = 0; i < 3; i++) {
      window.rotate();
    }
    expect(window.rect, const Rect.fromLTWH(0, 0, .5, .5));
    window.reset();
    expect(window.rect, const Rect.fromLTWH(0, 0, 1, 1));
    expect(window.quarterTurns, 0);
  });

  testWidgets('rendered pixels and dimensions match every rotated selection', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final bytes = await _photo();
      final window = ReceiptCropWindow(const Size(120, 240));
      window.resize(const Offset(1, 1), const Offset(-.5, -.5));
      for (var i = 0; i < 4; i++) {
        final cropped = await renderReceiptCrop(
          bytes,
          window.crop,
          window.quarterTurns,
        );
        final codec = await ui.instantiateImageCodec(cropped);
        final image = (await codec.getNextFrame()).image;
        expect(image.width, i.isEven ? 60 : 120);
        expect(image.height, i.isEven ? 120 : 60);
        final pixels = (await image.toByteData())!;
        final center =
            ((image.height ~/ 2) * image.width + image.width ~/ 2) * 4;
        expect(pixels.getUint8(center), 244);
        expect(pixels.getUint8(center + 1), 67);
        expect(pixels.getUint8(center + 2), 54);
        image.dispose();
        codec.dispose();
        window.rotate();
      }
    });
  });

  testWidgets('drag edge, rotate and save the selection', (tester) async {
    final bytes = (await tester.runAsync(_photo))!;
    ImageCropRect? result;
    int? turns;
    await tester.pumpWidget(
      _app(
        bytes,
        complete: (crop, rotation) async {
          turns = rotation;
          return crop;
        },
        closed: (value) => result = value,
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('receipt-crop-handle-7')),
      const Offset(40, 0),
    );
    await tester.tap(find.byKey(const ValueKey('receipt-crop-rotate')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('receipt-crop-save')));
    await tester.pumpAndSettle();
    expect(turns, 1);
    expect(result!.y, greaterThan(0));
    expect(result!.height, lessThan(1));
    expect(result!.width, 1);
  });

  testWidgets('cancel returns null and never saves', (tester) async {
    final bytes = (await tester.runAsync(_photo))!;
    var saves = 0, closes = 0;
    await tester.pumpWidget(
      _app(
        bytes,
        complete: (crop, _) async {
          saves++;
          return crop;
        },
        closed: (value) {
          expect(value, isNull);
          closes++;
        },
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('receipt-crop-cancel')));
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(closes, 1);
  });

  testWidgets(
    'save failure allows retry; late result after account change is discarded',
    (tester) async {
      final bytes = (await tester.runAsync(_photo))!;
      var current = true, fail = true, saves = 0, closes = 0;
      final pending = Completer<ImageCropRect>();
      await tester.pumpWidget(
        _app(
          bytes,
          current: () => current,
          complete: (crop, _) {
            saves++;
            if (fail) throw StateError('Failed');
            return pending.future;
          },
          closed: (value) {
            expect(value, isNull);
            closes++;
          },
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('receipt-crop-save')));
      await tester.pumpAndSettle();
      expect(
        find.text("Couldn't save the new crop. Try again."),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      fail = false;
      await tester.tap(find.byKey(const ValueKey('receipt-crop-save')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('receipt-crop-save')));
      expect(saves, 2);
      current = false;
      pending.complete(const ImageCropRect(x: 0, y: 0, width: 1, height: 1));
      await tester.pumpAndSettle();
      expect(closes, 1);
    },
  );

  testWidgets(
    '320px and large Latvian text keeps controls usable and resets crop',
    (tester) async {
      tester.view.reset();
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final bytes = (await tester.runAsync(_photo))!;
      ImageCropRect? result;
      await tester.pumpWidget(
        _app(
          bytes,
          scale: 2,
          locale: const Locale('lv'),
          complete: (crop, _) async => crop,
          closed: (value) => result = value,
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('receipt-crop-rotate')));
      await tester.tap(find.byKey(const ValueKey('receipt-crop-reset')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('receipt-crop-save')));
      await tester.pumpAndSettle();
      expect(result!.width, 1);
      expect(result!.height, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
