import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/core/network/legacy_receipt_uploader.dart';
import 'package:tripsplit/features/workspace/data/datasources/workspace_remote_mutation_api.dart';

class _Client implements ApiClient {
  final bodies = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    bodies.add(Map.of(body!));
    return {
      'scan': {'is_receipt': false, 'items': <dynamic>[]},
    };
  }

  @override
  Future<void> revokeCurrentSession() async {}
}

class _UnusedUploader implements LegacyReceiptUploader {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  test(
    'ordinary scan keeps caching; deliberate rescan sends the flag and stable retry ID',
    () async {
      final client = _Client();
      final api = WorkspaceRemoteMutationApi(client, _UnusedUploader());
      await api.scanReceipt(
        receiptPath: 'receipts/test.webp',
        requestId: 'first-0001',
      );
      for (var attempt = 0; attempt < 2; attempt++) {
        await api.scanReceipt(
          receiptPath: 'receipts/test.webp',
          requestId: 'rescan-0002',
          rescan: true,
        );
      }
      expect(client.bodies.first, {
        'receipt_path': 'receipts/test.webp',
        'request_id': 'first-0001',
      });
      expect(client.bodies[1], {
        'receipt_path': 'receipts/test.webp',
        'request_id': 'rescan-0002',
        'rescan': true,
      });
      expect(client.bodies[2], client.bodies[1]);
    },
  );
}
