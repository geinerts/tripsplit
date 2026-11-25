import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/workspace/presentation/widgets/receipt_open_action.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets(
    'receipt chip shows the photo and opens a fresh full-image link',
    (tester) async {
      final thumb = Uri.parse(
        'https://splyto.eu/api/receipt-media.php?signature=thumb',
      );
      final full = Uri.parse(
        'https://splyto.eu/api/receipt-media.php?signature=full',
      );
      final provider = ResizeImage.resizeIfNeeded(
        96,
        null,
        NetworkImage(thumb.toString()),
      );
      final key = await provider.obtainKey(ImageConfiguration.empty);
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 32, 42),
        Paint()..color = Colors.white,
      );
      final picture = recorder.endRecording();
      final pixels = await tester.runAsync(() => picture.toImage(32, 42));
      picture.dispose();
      PaintingBinding.instance.imageCache.putIfAbsent(
        key,
        () => OneFrameImageStreamCompleter(
          Future.value(ImageInfo(image: pixels!)),
        ),
      );
      var previews = 0;
      var loads = 0;
      Uri? opened;
      await tester.pumpWidget(
        _app(
          ReceiptOpenAction(
            compactLabel: 'Receipt',
            isCurrentAccount: () => true,
            loadPreview: () async {
              previews++;
              return thumb;
            },
            load: () async {
              loads++;
              return full;
            },
            open: (uri) async {
              opened = uri;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('receipt-thumbnail')), findsOneWidget);
      expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
      expect(loads, 0);
      expect(previews, 1);
      await tester.tap(find.byKey(const ValueKey('receipt-open')));
      await tester.pumpAndSettle();
      expect(opened, full);
      expect(loads, 1);
      expect(previews, 1);
      expect(find.textContaining('signature='), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(PaintingBinding.instance.imageCache.containsKey(key), isFalse);
    },
  );

  testWidgets(
    'failed preview leaves receipt opening available without exposing its URL',
    (tester) async {
      var opened = false;
      await tester.pumpWidget(
        _app(
          ReceiptOpenAction(
            compactLabel: 'Receipt',
            isCurrentAccount: () => true,
            loadPreview: () async => throw StateError('private signed URL'),
            load: () async => Uri.parse('https://splyto.eu/receipt'),
            open: (_) async {
              opened = true;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.textContaining('private signed URL'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('receipt-open')));
      await tester.pumpAndSettle();
      expect(opened, isTrue);
    },
  );

  for (final disposed in [false, true]) {
    testWidgets(
      'late preview is discarded after ${disposed ? 'closing' : 'account change'}',
      (tester) async {
        final pending = Completer<Uri?>();
        var current = true;
        var opens = 0;
        await tester.pumpWidget(
          _app(
            ReceiptOpenAction(
              compactLabel: 'Receipt',
              isCurrentAccount: () => current,
              loadPreview: () => pending.future,
              load: () async => Uri.parse('https://splyto.eu/receipt'),
              open: (_) async {
                opens++;
                return true;
              },
            ),
          ),
        );
        if (disposed) await tester.pumpWidget(const SizedBox.shrink());
        current = false;
        pending.complete(
          Uri.parse('https://splyto.eu/receipt?signature=old-account'),
        );
        await tester.pumpAndSettle();
        expect(find.byType(Image), findsNothing);
        if (!disposed) {
          await tester.tap(find.byKey(const ValueKey('receipt-open')));
        }
        await tester.pumpAndSettle();
        expect(opens, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
