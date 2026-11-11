import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/media/trip_image_cache.dart';

void main() {
  late Directory directory;
  late AccountDataSession session;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('splyto-cover-test-');
    session = AccountDataSession(namespace: 'test')..activate(7);
  });
  tearDown(() async => directory.delete(recursive: true));

  test('cover is available after restart without a network request', () async {
    var calls = 0;
    TripImageCache cache() => TripImageCache(
      session,
      directory: () async => directory,
      client: () => MockClient((_) async {
        calls++;
        return http.Response.bytes(
          [1, 2, 3],
          200,
          headers: {'content-type': 'image/webp'},
        );
      }),
    );
    await cache().load(1, 'https://example.test/photo.webp');
    expect(await cache().load(1, 'https://example.test/photo.webp'), [1, 2, 3]);
    expect(calls, 1);
    expect(await cache().read(1), [1, 2, 3]);
    session.activate(8);
    expect(await cache().read(1), isNull);
    session.activate(7);
    await cache().clear();
    expect(await cache().read(1), isNull);
  });

  test(
    'failed replacement retains the downloaded photo; invalid responses are not cached',
    () async {
      var fail = false;
      final cache = TripImageCache(
        session,
        directory: () async => directory,
        client: () => MockClient((_) async {
          if (fail) throw const SocketException('Offline');
          return http.Response.bytes(
            [1, 2],
            200,
            headers: {'content-type': 'image/jpeg'},
          );
        }),
      );
      await cache.load(1, 'https://example.test/a.jpg');
      fail = true;
      expect(await cache.load(1, 'https://example.test/b.jpg'), [1, 2]);
      final invalid = TripImageCache(
        session,
        directory: () async => directory,
        client: () => MockClient((_) async => http.Response('error', 200)),
      );
      expect(await invalid.load(2, 'https://example.test/c.jpg'), isNull);
      expect(await invalid.read(2), isNull);
    },
  );

  test(
    'download completing after logout cannot restore cleared account photos',
    () async {
      final entered = Completer<void>();
      final response = Completer<http.Response>();
      final cache = TripImageCache(
        session,
        directory: () async => directory,
        client: () => MockClient((_) {
          entered.complete();
          return response.future;
        }),
      );
      final pending = cache.load(1, 'https://example.test/a.jpg');
      final rejected = expectLater(
        pending,
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'account_changed'),
        ),
      );
      await entered.future;
      session.invalidate();
      await cache.clear();
      session.activate(8);
      response.complete(
        http.Response.bytes(
          [1, 2],
          200,
          headers: {'content-type': 'image/jpeg'},
        ),
      );
      await rejected;
      expect(await cache.read(1), isNull);
      session.activate(7);
      expect(await cache.read(1), isNull);
    },
  );

  test('oversized downloads are not stored', () async {
    final cache = TripImageCache(
      session,
      directory: () async => directory,
      client: () => MockClient(
        (_) async => http.Response.bytes(
          List.filled(TripImageCache.maxImageBytes + 1, 0),
          200,
          headers: {'content-type': 'image/jpeg'},
        ),
      ),
    );
    expect(await cache.load(1, 'https://example.test/a.jpg'), isNull);
    expect(await cache.read(1), isNull);
  });
}
