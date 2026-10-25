import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tripsplit/core/media/receipt_image_preparer.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native encoder reduces a 12MP receipt without cropping it', (
    tester,
  ) async {
    await tester.runAsync(() async {
      const width = 3024;
      const height = 4032;
      final random = Random(42);
      final pixels = Uint8List(width * height * 4);
      for (var offset = 0; offset < pixels.length; offset += 4) {
        pixels[offset] = random.nextInt(256);
        pixels[offset + 1] = random.nextInt(256);
        pixels[offset + 2] = random.nextInt(256);
        pixels[offset + 3] = 255;
      }
      final decoded = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        pixels,
        width,
        height,
        ui.PixelFormat.rgba8888,
        decoded.complete,
      );
      final noise = await decoded.future;
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder)
        ..drawImage(noise, ui.Offset.zero, ui.Paint());
      canvas.drawRect(
        const ui.Rect.fromLTWH(400, 500, 2200, 1800),
        ui.Paint()..color = const ui.Color(0xffffffff),
      );
      canvas.drawRect(
        const ui.Rect.fromLTWH(0, 0, 200, 200),
        ui.Paint()..color = const ui.Color(0xffff0000),
      );
      canvas.drawRect(
        const ui.Rect.fromLTWH(width - 200, height - 200, 200, 200),
        ui.Paint()..color = const ui.Color(0xff0000ff),
      );
      final paragraph =
          (ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: 80))
                ..pushStyle(ui.TextStyle(color: const ui.Color(0xff000000)))
                ..addText(
                  'SPLYTO TEST RECEIPT\n\nCoffee     EUR 5.00\nLunch     EUR 37.50\n\nTOTAL     EUR 42.50',
                ))
              .build()
            ..layout(const ui.ParagraphConstraints(width: 1900));
      canvas.drawParagraph(paragraph, const ui.Offset(550, 700));
      final picture = recorder.endRecording();
      final sourceImage = await picture.toImage(width, height);
      final source = (await sourceImage.toByteData(
        format: ui.ImageByteFormat.png,
      ))!.buffer.asUint8List();
      sourceImage.dispose();
      picture.dispose();
      noise.dispose();
      paragraph.dispose();
      expect(source.length, greaterThan(8 * 1024 * 1024));
      final timer = Stopwatch()..start();
      final result = await ReceiptImagePreparer.prepare(
        bytes: source,
        fileName: 'large-receipt.png',
      );
      expect(
        result.bytes.length,
        lessThanOrEqualTo(ReceiptImagePreparer.maxUploadBytes),
      );
      expect(result.fileName, 'large-receipt.jpg');
      final codec = await ui.instantiateImageCodec(result.bytes);
      final image = (await codec.getNextFrame()).image;
      expect(image.width / image.height, closeTo(width / height, .002));
      expect(image.height, inInclusiveRange(1600, 4096));
      final rgba = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      final top = (10 * image.width + 10) * 4;
      final bottom = ((image.height - 11) * image.width + image.width - 11) * 4;
      expect(rgba[top], greaterThan(200));
      expect(rgba[top + 2], lessThan(40));
      expect(rgba[bottom + 2], greaterThan(200));
      expect(rgba[bottom], lessThan(40));
      // ignore: avoid_print
      print(
        'Receipt: ${source.length} -> ${result.bytes.length} bytes; ${image.width}x${image.height}; ${timer.elapsedMilliseconds} ms',
      );
      image.dispose();
      codec.dispose();
    });
  });
}
