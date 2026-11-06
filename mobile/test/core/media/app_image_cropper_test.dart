import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripsplit/core/media/app_image_cropper.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

void main() {
  const channel = MethodChannel('plugins.hunghd.vn/image_cropper');
  testWidgets(
    'receipt crop returns the saved file; cancellation never uses original',
    (tester) async {
      final dir = Directory.systemTemp.createTempSync('splyto-crop-test-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final original = File('${dir.path}/original.jpg')
        ..writeAsBytesSync([1, 2]);
      final saved = File('${dir.path}/cropped.jpg')..writeAsBytesSync([3, 4]);
      Map<dynamic, dynamic>? arguments;
      String? resultPath = saved.path;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'cropImage');
        arguments = call.arguments as Map<dynamic, dynamic>;
        return resultPath;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      late BuildContext host;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              host = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.runAsync(() async {
        resultPath = saved.path;
        final receipt = await AppImageCropper.cropReceipt(
          context: host,
          source: XFile(original.path),
        );
        expect(await receipt!.readAsBytes(), [3, 4]);
        expect(arguments!['ratio_x'], isNull);
        expect(arguments!['ratio_y'], isNull);
        expect(arguments!['android.lock_aspect_ratio'], isFalse);
        expect(arguments!['ios.aspect_ratio_lock_enabled'], isFalse);
        expect(arguments!['ios.rotate_button_hidden'], isFalse);
        resultPath = null;
        expect(
          await AppImageCropper.cropReceipt(
            context: host,
            source: XFile(original.path),
          ),
          isNull,
        );
      });
    },
  );
}
