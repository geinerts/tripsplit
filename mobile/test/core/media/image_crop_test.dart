import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/media/image_crop.dart';
import 'package:tripsplit/core/media/image_crop_editor_page.dart';
import 'package:tripsplit/core/media/image_crop_flow.dart';
import 'package:tripsplit/core/media/image_crop_service.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

final _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

ImageCropSourceData _source({ImageCropRect? crop, bool hasOriginal = true}) =>
    ImageCropSourceData(
      bytes: _pixel,
      width: 1600,
      height: 1200,
      crop: crop,
      hasOriginal: hasOriginal,
      revision: 'r1',
    );

Widget _editor<T>({
  required Future<ImageCropSourceData> Function() load,
  required Future<T> Function(ImageCropRect, ImageCropSourceData) complete,
  void Function(T?)? onClosed,
  double scale = 1,
}) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Builder(
    builder: (context) => TextButton(
      onPressed: () async {
        final result = await Navigator.of(context).push<T>(
          MaterialPageRoute(
            builder: (_) => ImageCropEditorPage<T>(
              title: 'Crop',
              aspectRatio: 16 / 9,
              load: load,
              complete: complete,
            ),
          ),
        );
        onClosed?.call(result);
      },
      child: const Text('Open'),
    ),
  ),
);

class _Api implements ApiClient {
  final calls =
      <
        ({
          String path,
          Map<String, dynamic>? query,
          Map<String, dynamic>? body,
          Map<String, String>? headers,
        })
      >[];
  Map<String, dynamic> response = {};

  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    calls.add((path: path, query: query, body: body, headers: headers));
    return response;
  }

  @override
  Future<void> revokeCurrentSession() async {}
}

void main() {
  group('crop window', () {
    const size = Size(1600, 1200);

    test('starts with the largest centred frame', () {
      final rect = ImageCropWindow(imageSize: size, aspectRatio: 16 / 9).rect;
      expect(rect.width, 1);
      expect(rect.height, closeTo(.75, .0001));
      expect(rect.x, 0);
      expect(rect.y, closeTo(.125, .0001));
    });

    test('reopens at the saved crop', () {
      const saved = ImageCropRect(x: .25, y: .1, width: .5, height: .375);
      final rect = ImageCropWindow(
        imageSize: size,
        aspectRatio: 16 / 9,
        initial: saved,
      ).rect;
      expect(rect.x, closeTo(.25, .0001));
      expect(rect.y, closeTo(.1, .0001));
      expect(rect.width, closeTo(.5, .0001));
    });

    test('stays inside the image however far it is dragged', () {
      final window = ImageCropWindow(imageSize: size, aspectRatio: 16 / 9)
        ..zoom(2)
        ..pan(const Offset(99999, 99999));
      final rect = window.rect;
      expect(rect.x + rect.width, closeTo(1, .0001));
      expect(rect.y + rect.height, closeTo(1, .0001));
      window.pan(const Offset(-99999, -99999));
      expect(window.rect.x, closeTo(0, .0001));
      expect(window.rect.y, closeTo(0, .0001));
    });

    test('zoom stops at the server minimum and at the whole image', () {
      final window = ImageCropWindow(imageSize: size, aspectRatio: 16 / 9)
        ..zoom(100);
      expect(window.cropWidth, ImageCropWindow.minimumWidth);
      expect(window.canZoomIn, isFalse);
      window.zoom(.001);
      expect(window.cropWidth, 1600);
      expect(window.canZoomOut, isFalse);
    });

    test('a small image can still be used whole', () {
      final window = ImageCropWindow(
        imageSize: const Size(200, 200),
        aspectRatio: 1,
      );
      expect(window.minCropWidth, 200);
      expect(window.canZoomIn, isFalse);
      expect(window.rect.width, 1);
    });
  });

  group('editor', () {
    Future<void> open(WidgetTester tester) async {
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('dragging and zooming change the saved crop', (tester) async {
      ImageCropRect? closed;
      await tester.pumpWidget(
        _editor<ImageCropRect>(
          load: () async => _source(),
          complete: (rect, _) async => rect,
          onClosed: (rect) => closed = rect,
        ),
      );
      await open(tester);
      await tester.tap(find.byKey(const ValueKey('image-crop-zoom-in')));
      await tester.pump();
      await tester.drag(
        find.byKey(const ValueKey('image-crop-canvas')),
        const Offset(-120, 0),
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('image-crop-done')));
      await tester.pumpAndSettle();
      expect(closed!.width, closeTo(.8, .0001));
      // Dragging the photo left moves the frame right, from its centred start.
      expect(closed!.x, greaterThan(.1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('explains an image that can only be zoomed', (tester) async {
      await tester.pumpWidget(
        _editor<ImageCropRect>(
          load: () async => _source(hasOriginal: false),
          complete: (rect, _) async => rect,
        ),
      );
      await open(tester);
      expect(
        find.byKey(const ValueKey('image-crop-zoom-only')),
        findsOneWidget,
      );
    });

    testWidgets('offers a retry when the photo cannot be opened', (
      tester,
    ) async {
      var attempts = 0;
      await tester.pumpWidget(
        _editor<ImageCropRect>(
          load: () async {
            if (++attempts == 1) throw StateError('offline');
            return _source();
          },
          complete: (rect, _) async => rect,
        ),
      );
      await open(tester);
      expect(find.text('Couldn\'t open this photo.'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('image-crop-canvas')), findsOneWidget);
      expect(attempts, 2);
    });

    testWidgets('stays open and says why when saving fails', (tester) async {
      var closedCount = 0;
      await tester.pumpWidget(
        _editor<ImageCropRect>(
          load: () async => _source(),
          complete: (rect, _) async => throw const ApiException(
            'changed',
            statusCode: 409,
            code: 'image_changed',
          ),
          onClosed: (_) => closedCount++,
        ),
      );
      await open(tester);
      await tester.tap(find.byKey(const ValueKey('image-crop-done')));
      await tester.pumpAndSettle();
      expect(find.textContaining('changed in the meantime'), findsOneWidget);
      expect(find.byKey(const ValueKey('image-crop-canvas')), findsOneWidget);
      expect(closedCount, 0);
    });

    testWidgets('closing without saving returns nothing', (tester) async {
      var saves = 0;
      ImageCropRect? closed = const ImageCropRect(
        x: 0,
        y: 0,
        width: 1,
        height: 1,
      );
      await tester.pumpWidget(
        _editor<ImageCropRect>(
          load: () async => _source(),
          complete: (rect, _) async {
            saves++;
            return rect;
          },
          onClosed: (rect) => closed = rect,
        ),
      );
      await open(tester);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(closed, isNull);
      expect(saves, 0);
    });

    for (final size in [const Size(320, 568), const Size(844, 390)]) {
      testWidgets('fits $size at 200% text', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          _editor<ImageCropRect>(
            load: () async => _source(),
            complete: (rect, _) async => rect,
            scale: 2,
          ),
        );
        await open(tester);
        expect(tester.takeException(), isNull);
        expect(
          find.byKey(const ValueKey('image-crop-zoom-in')),
          findsOneWidget,
        );
      });
    }
  });

  group('service', () {
    test('asks for a trip source with the trip header', () async {
      final api = _Api()
        ..response = {
          'image_base64': base64Encode(_pixel),
          'width': 1600,
          'height': 1200,
          'crop': {'x': 0, 'y': .1, 'width': 1, 'height': .75},
          'has_original': false,
          'revision': 'uploads/trips/a.webp',
        };
      final source = await ImageCropService(
        api,
      ).load(ImageCropKind.trip, tripId: 9);
      expect(api.calls.single.path, contains('image_crop_source'));
      expect(api.calls.single.query, {'kind': 'trip'});
      expect(api.calls.single.headers, {'X-Trip-Id': '9'});
      expect(source.hasOriginal, isFalse);
      expect(source.revision, 'uploads/trips/a.webp');
      expect(source.crop!.height, .75);
    });

    test('saves a visit crop with its id and revision', () async {
      final api = _Api()..response = {'ok': true};
      await ImageCropService(api).save(
        ImageCropKind.travel,
        const ImageCropRect(x: .1, y: .2, width: .5, height: .5),
        'v3',
        placeId: 4,
      );
      final body = api.calls.single.body!;
      expect(api.calls.single.path, contains('update_image_crop'));
      expect(body['kind'], 'travel');
      expect(body['id'], 4);
      expect(body['revision'], 'v3');
      expect(body['crop'], {'x': .1, 'y': .2, 'width': .5, 'height': .5});
      expect(api.calls.single.headers, isNull);
    });
  });

  testWidgets('reads the size of a photo', (tester) async {
    final described = await tester.runAsync(
      () => describeImage(Uint8List.fromList(_pixel)),
    );
    expect(described!.width, 1);
    expect(described.height, 1);
  });
}
