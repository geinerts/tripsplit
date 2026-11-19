import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/media/receipt_image_preparer.dart';

class _Encoder extends FlutterImageCompressPlatform {
  final calls = <({Uint8List source, int quality, int width, int height})>[];
  final outputs = <Uint8List>[];

  @override
  Future<Uint8List> compressWithList(
    Uint8List image, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    int inSampleSize = 1,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) async {
    expect(format, CompressFormat.jpeg);
    expect(autoCorrectionAngle, isTrue);
    expect(keepExif, isFalse);
    calls.add((
      source: image,
      quality: quality,
      width: minWidth,
      height: minHeight,
    ));
    return outputs.length > 1 ? outputs.removeAt(0) : outputs.single;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Uint8List png(int width, int height) {
  List<int> chunk(String type, List<int> data) {
    final body = [...type.codeUnits, ...data];
    var crc = 0xffffffff;
    for (final byte in body) {
      crc ^= byte;
      for (var bit = 0; bit < 8; bit++) {
        crc = (crc >>> 1) ^ ((crc & 1) == 1 ? 0xedb88320 : 0);
      }
    }
    final length = ByteData(4)..setUint32(0, data.length);
    final checksum = ByteData(4)..setUint32(0, crc ^ 0xffffffff);
    return [
      ...length.buffer.asUint8List(),
      ...body,
      ...checksum.buffer.asUint8List(),
    ];
  }

  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8)
    ..setUint8(9, 3);
  return Uint8List.fromList([
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    ...chunk('IHDR', header.buffer.asUint8List()),
    ...chunk('PLTE', [0, 0, 0]),
    ...chunk('IDAT', ZLibEncoder().convert(Uint8List((width + 1) * height))),
    ...chunk('IEND', []),
  ]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FlutterImageCompressPlatform original;
  late _Encoder encoder;
  setUp(() {
    original = FlutterImageCompressPlatform.instance;
    encoder = _Encoder();
    FlutterImageCompressPlatform.instance = encoder;
  });
  tearDown(() => FlutterImageCompressPlatform.instance = original);

  test('small supported receipts retain their bytes and filename', () async {
    for (final extension in ['jpg', 'JPEG', 'png', 'webp']) {
      final bytes = png(120, 80);
      final result = await ReceiptImagePreparer.prepare(
        bytes: bytes,
        fileName: 'receipt.$extension',
      );
      expect(identical(result.bytes, bytes), isTrue);
      expect(result.fileName, 'receipt.$extension');
    }
    expect(encoder.calls, isEmpty);
  });

  test(
    'oversized receipts retry from the original and never exceed the budget',
    () async {
      final source = Uint8List(ReceiptImagePreparer.maxUploadBytes + 1);
      encoder.outputs.addAll([source, source, png(120, 80)]);
      final result = await ReceiptImagePreparer.prepare(
        bytes: source,
        fileName: 'receipt.PNG',
      );
      expect(result.fileName, 'receipt.jpg');
      expect(
        result.bytes.length,
        lessThanOrEqualTo(ReceiptImagePreparer.maxUploadBytes),
      );
      expect(encoder.calls.map((call) => call.quality), [90, 82, 90]);
      expect(
        encoder.calls.every((call) => identical(call.source, source)),
        isTrue,
      );
      expect(encoder.calls.last.width, lessThan(encoder.calls.first.width));
    },
  );

  test(
    'small compressed high-resolution receipts are resized before upload',
    () async {
      final source = png(4096, 3072);
      expect(source.length, lessThan(ReceiptImagePreparer.maxUploadBytes));
      encoder.outputs.add(png(3200, 2400));
      final result = await ReceiptImagePreparer.prepare(
        bytes: source,
        fileName: 'camera.png',
      );
      expect(identical(result.bytes, source), isFalse);
      expect(encoder.calls, hasLength(1));
      expect(
        encoder.calls.single.width * encoder.calls.single.height,
        lessThanOrEqualTo(ReceiptImagePreparer.maxUploadPixels),
      );
    },
  );

  test(
    'an encoder that ignores requested dimensions cannot bypass the cap',
    () async {
      encoder.outputs.add(png(4096, 3072));
      await expectLater(
        ReceiptImagePreparer.prepare(
          bytes: png(4096, 3072),
          fileName: 'large.png',
        ),
        throwsFormatException,
      );
      expect(encoder.calls, hasLength(12));
    },
  );

  test('HEIC is converted even when its file is small', () async {
    encoder.outputs.add(png(120, 80));
    final result = await ReceiptImagePreparer.prepare(
      bytes: Uint8List.fromList([1]),
      fileName: 'IMG_1234.HEIC',
    );
    expect(result.fileName, 'IMG_1234.jpg');
    expect(encoder.calls, hasLength(1));
  });

  test(
    'empty images and failed compression are not sent as oversized files',
    () async {
      await expectLater(
        ReceiptImagePreparer.prepare(
          bytes: Uint8List(0),
          fileName: 'empty.jpg',
        ),
        throwsFormatException,
      );
      final source = Uint8List(ReceiptImagePreparer.maxUploadBytes + 1);
      encoder.outputs.add(source);
      await expectLater(
        ReceiptImagePreparer.prepare(bytes: source, fileName: 'large.jpg'),
        throwsFormatException,
      );
      expect(encoder.calls, hasLength(12));
    },
  );
}
