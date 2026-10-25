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
    'trip crop returns the saved file; cancellation never uses original',
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
        final crop = await AppImageCropper.cropTripImage(
          context: host,
          source: XFile(original.path),
        );
        expect(crop!.path, saved.path);
        expect(await crop.readAsBytes(), [3, 4]);
        expect(arguments!['source_path'], original.path);
        expect(
          arguments!['ratio_x'] / arguments!['ratio_y'],
          AppImageCropper.tripAspectRatio,
        );
        expect(arguments!['android.lock_aspect_ratio'], isTrue);
        expect(arguments!['ios.aspect_ratio_lock_enabled'], isTrue);
        resultPath = null;
        expect(
          await AppImageCropper.cropTripImage(
            context: host,
            source: XFile(original.path),
          ),
          isNull,
        );
        // Avatar cropping keeps its independent square frame.
        await AppImageCropper.cropAvatar(
          context: host,
          source: XFile(original.path),
        );
        expect(arguments!['ratio_x'], arguments!['ratio_y']);
      });
    },
  );
}
