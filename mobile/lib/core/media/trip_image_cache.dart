import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../auth/account_data_session.dart';

/// Account-scoped, bounded disk copies of previously viewed trip covers.
class TripImageCache {
  TripImageCache(
    this.session, {
    Future<Directory> Function()? directory,
    http.Client Function()? client,
  }) : _directory = directory ?? getApplicationSupportDirectory,
       _client = client ?? http.Client.new;

  final AccountDataSession session;
  final Future<Directory> Function() _directory;
  final http.Client Function() _client;
  static const maxImageBytes = 8 * 1024 * 1024;
  static const maxCacheBytes = 64 * 1024 * 1024;
  Future<void> _tail = Future.value();
  final Map<String, Future<Uint8List?>> _downloads = {};

  Future<T> _locked<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<Directory> _root() async =>
      Directory.fromUri((await _directory()).uri.resolve('trip_covers_v1/'));

  Future<Directory> _accountDirectory(AccountDataLease lease) async {
    final namespace = base64Url.encode(utf8.encode(session.namespace));
    return Directory.fromUri(
      (await _root()).uri.resolve('$namespace/${lease.userId}/'),
    );
  }

  Future<Uint8List?> read(int tripId) async {
    final lease = session.capture();
    return _locked(() async {
      lease.check();
      try {
        final file = File.fromUri(
          (await _accountDirectory(lease)).uri.resolve('$tripId.image'),
        );
        if (!await file.exists()) return null;
        if (await file.length() > maxImageBytes) return null;
        final bytes = await file.readAsBytes();
        lease.check();
        return bytes;
      } on FileSystemException {
        lease.check();
        return null;
      }
    });
  }

  Future<Uint8List?> load(int tripId, String url) {
    final lease = session.capture();
    final key = '${lease.generation}:$tripId:$url';
    return _downloads.putIfAbsent(key, () {
      final result = session.run(() => _load(lease, tripId, url));
      return result.whenComplete(() {
        _downloads.remove(key);
      });
    });
  }

  Future<Uint8List?> _load(
    AccountDataLease lease,
    int tripId,
    String url,
  ) async {
    final cached = await read(tripId);
    final dir = await _accountDirectory(lease);
    final metadata = File.fromUri(dir.uri.resolve('$tripId.url'));
    try {
      if (cached != null &&
          await metadata.exists() &&
          await metadata.readAsString() == url) {
        lease.check();
        return cached;
      }
    } on FileSystemException {
      lease.check();
      // A missing/corrupt metadata file can be replaced by a fresh download.
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !{'http', 'https'}.contains(uri.scheme)) return cached;
    final client = _client();
    try {
      final bytes = await (() async {
        final response = await client.send(http.Request('GET', uri));
        if (response.statusCode != 200 ||
            (response.contentLength ?? 0) > maxImageBytes ||
            !(response.headers['content-type'] ?? '').toLowerCase().startsWith(
              'image/',
            )) {
          return null;
        }
        final buffer = BytesBuilder(copy: false);
        await for (final chunk in response.stream) {
          if (buffer.length + chunk.length > maxImageBytes) return null;
          buffer.add(chunk);
        }
        return buffer.takeBytes();
      })().timeout(const Duration(seconds: 10));
      lease.check();
      if (bytes == null || bytes.isEmpty) return cached;
      try {
        await _locked(() async {
          lease.check();
          await dir.create(recursive: true);
          final file = File.fromUri(dir.uri.resolve('$tripId.image'));
          await file.writeAsBytes(bytes, flush: true);
          await metadata.writeAsString(url, flush: true);
          // A sign-out during a write is followed by clear() on the same lock.
          lease.check();
          await _prune(dir);
        });
      } on FileSystemException {
        lease.check();
        // Disk storage is best-effort; still show a successfully downloaded image.
      }
      return bytes;
    } on IOException {
      lease.check();
      return cached;
    } on http.ClientException {
      lease.check();
      return cached;
    } on TimeoutException {
      lease.check();
      return cached;
    } finally {
      client.close();
    }
  }

  Future<void> _prune(Directory dir) async {
    final images = <({File file, FileStat stat})>[];
    await for (final entry in dir.list()) {
      if (entry is File && entry.uri.path.endsWith('.image')) {
        images.add((file: entry, stat: await entry.stat()));
      }
    }
    images.sort((a, b) => a.stat.modified.compareTo(b.stat.modified));
    var total = images.fold<int>(0, (sum, image) => sum + image.stat.size);
    for (final image in images) {
      if (total <= maxCacheBytes) break;
      await image.file.delete();
      final name = image.file.uri.pathSegments.last.replaceFirst(
        '.image',
        '.url',
      );
      final metadata = File.fromUri(dir.uri.resolve(name));
      if (await metadata.exists()) await metadata.delete();
      total -= image.stat.size;
    }
  }

  Future<void> clear() => _locked(() async {
    final root = await _root();
    if (await root.exists()) await root.delete(recursive: true);
  });
}
