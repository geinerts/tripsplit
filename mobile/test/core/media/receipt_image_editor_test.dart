import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/media/receipt_image_editor.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

void main() {
  testWidgets('uses cropped bytes, cleans temporary copies and respects cancel', (
    tester,
  ) async {
    const channel = MethodChannel('plugins.hunghd.vn/image_cropper');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final directory = Directory.systemTemp.createTempSync(
      'receipt-editor-test-',
    );
    addTearDown(() => directory.deleteSync(recursive: true));
    final output = File.fromUri(directory.uri.resolve('cropped.jpg'));
    final cropped = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAC0lEQVR4nGNgQAYAAA4AAamRc7EAAAAASUVORK5CYII=',
    );
    final original = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGNgYGAAAAAEAAH2FzhVAAAAAElFTkSuQmCC',
    );
    String? input;
    var cancel = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      input = (call.arguments as Map)['source_path'] as String;
      expect(await File(input!).readAsBytes(), original);
      if (cancel) return null;
      await output.writeAsBytes(cropped);
      return output.path;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.runAsync(() async {
      final result = await ReceiptImageEditor.cropAndPrepare(
        context: context,
        bytes: original,
        fileName: 'original.jpg',
      );
      expect(result!.bytes, cropped);
      expect(result.fileName, 'receipt.jpg');
      expect(await File(input!).exists(), isFalse);
      expect(await output.exists(), isFalse);
      cancel = true;
      expect(
        await ReceiptImageEditor.cropAndPrepare(
          context: context,
          bytes: original,
          fileName: 'original.jpg',
        ),
        isNull,
      );
      expect(await File(input!).exists(), isFalse);
    });
  });
}
