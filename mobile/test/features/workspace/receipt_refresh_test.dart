import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/features/workspace/domain/entities/trip_expense.dart';
import 'package:tripsplit/features/workspace/data/datasources/workspace_remote_snapshot_loader.dart';
import 'package:tripsplit/features/workspace/domain/entities/trip_expenses_page.dart';
import 'package:tripsplit/features/workspace/domain/repositories/workspace_repository.dart';
import 'package:tripsplit/features/workspace/presentation/controllers/workspace_controller.dart';

class _Repository implements WorkspaceRepository {
  String? url =
      'https://splyto.eu/api/receipt-media.php?expires=123&signature=fresh';
  bool fail = false;
  final offsets = <int?>[];
  @override
  Future<TripExpensesPage> loadExpensesPage({
    required int tripId,
    int limit = 50,
    String? cursor,
    int? offset,
  }) async {
    expect(tripId, 12);
    offsets.add(offset);
    if (fail) throw const ApiException('Forbidden', statusCode: 403);
    return TripExpensesPage(
      items: [
        TripExpense(
          id: offset == null ? 1 : 7,
          amount: 1,
          originalAmount: 1,
          tripCurrencyCode: 'EUR',
          expenseCurrencyCode: 'EUR',
          fxRateToTrip: 1,
          category: '',
          note: '',
          expenseDate: '',
          splitMode: 'equal',
          paidById: 1,
          paidByNickname: '',
          receiptUrl: url,
          participants: const [],
        ),
      ],
      hasMore: offset == null,
      nextOffset: offset == null ? 1 : null,
      nextCursor: null,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Api implements ApiClient {
  final paths = <String>[];
  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    paths.add(path);
    return {
      'ok': true,
      'sync': {'changed': true, 'cursor': 123},
      'expenses': [
        {
          'id': 7,
          'receipt_url':
              'https://splyto.eu/api/receipt-media.php?signature=${paths.length}',
        },
      ],
    };
  }

  @override
  Future<void> revokeCurrentSession() async {}
}

void main() {
  test('receipt clicks fetch fresh pages, including older expenses', () async {
    final repo = _Repository();
    final controller = WorkspaceController(repo);
    expect(
      (await controller.loadReceiptUri(
        tripId: 12,
        expenseId: 7,
      ))?.queryParameters['signature'],
      'fresh',
    );
    repo.url = 'https://splyto.eu/api/receipt-media.php?signature=renewed';
    expect(
      (await controller.loadReceiptUri(
        tripId: 12,
        expenseId: 7,
      ))?.queryParameters['signature'],
      'renewed',
    );
    expect(repo.offsets, [null, 1, null, 1]);
  });
  test(
    'receipt authorization failures never fall back to cached links',
    () async {
      final repo = _Repository()..fail = true;
      await expectLater(
        WorkspaceController(repo).loadReceiptUri(tripId: 12, expenseId: 7),
        throwsA(isA<ApiException>()),
      );
    },
  );
  test('receipt links reject foreign hosts and non-web schemes', () async {
    final repo = _Repository();
    for (final url in [
      'javascript:alert(1)',
      'https://evil.test/receipt',
      'http://splyto.eu/receipt',
      'https://user@splyto.eu/receipt',
    ]) {
      repo.url = url;
      expect(
        await WorkspaceController(
          repo,
        ).loadReceiptUri(tripId: 12, expenseId: 7),
        isNull,
      );
    }
  });
  test('snapshots refresh signed media even without content changes', () async {
    final api = _Api();
    final loader = WorkspaceRemoteSnapshotLoader(api);
    final first = await loader.loadSnapshot(tripId: 12);
    final second = await loader.loadSnapshot(tripId: 12);
    expect(
      first.expenses.single.receiptUrl,
      isNot(second.expenses.single.receiptUrl),
    );
    expect(api.paths.every((path) => !path.contains('since=')), isTrue);
  });
}
