import 'package:flutter/foundation.dart';

import '../../../core/config/app_env.dart';
import '../../../core/errors/api_exception.dart';
import '../data/quick_splits_repository.dart';
import '../domain/quick_split.dart';

/// The Quick splits tab: newest first, kept in memory for the signed-in account.
class QuickSplitsController extends ChangeNotifier {
  QuickSplitsController(this.repository);

  final QuickSplitsRepository repository;

  List<QuickSplit> _items = const [];
  String? _nextCursor;
  bool _loading = false;
  bool _loaded = false;
  bool _failed = false;
  bool _offline = false;
  int _generation = 0;

  List<QuickSplit> get items => _items;
  bool get isLoading => _loading;
  bool get hasLoaded => _loaded;
  bool get hasFailed => _failed;
  bool get isOffline => _offline;
  bool get hasMore => _nextCursor != null;

  Future<void> load({bool more = false}) async {
    if (_loading || (more && _nextCursor == null)) return;
    final generation = ++_generation;
    _loading = true;
    notifyListeners();
    try {
      final page = await repository.list(cursor: more ? _nextCursor : null);
      if (generation != _generation) return;
      _items = more ? [..._items, ...page.items] : page.items;
      _nextCursor = page.nextCursor;
      _loaded = true;
      _failed = false;
      _offline = false;
    } on ApiException catch (error) {
      if (generation != _generation) return;
      _failed = true;
      _offline = error.isNetworkError;
    } catch (_) {
      if (generation != _generation) return;
      _failed = true;
      _offline = false;
    } finally {
      if (generation == _generation) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<QuickSplit> add(QuickSplitInput input) async {
    final saved = await repository.add(input);
    _upsert(saved);
    return saved;
  }

  Future<QuickSplit> update(int id, QuickSplitInput input) async {
    final saved = await repository.update(id, input);
    _upsert(saved);
    return saved;
  }

  Future<QuickSplit> get(int id) => repository.get(id);

  /// A fresh, authorized link to the receipt photo, loaded on every open;
  /// only an https link on the API host is accepted, as for trip receipts.
  Future<Uri?> loadReceiptUri(int id) async {
    final split = await repository.get(id);
    final uri = Uri.tryParse(split.receiptUrl ?? '');
    final base = Uri.parse(AppEnv.current.apiBaseUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != base.host ||
        uri.port != base.port ||
        uri.userInfo.isNotEmpty) {
      return null;
    }
    return uri;
  }

  Future<void> delete(int id) async {
    await repository.delete(id);
    _remove(id);
  }

  Future<void> moveToTrip({
    required int id,
    required int tripId,
    required int expenseId,
  }) async {
    await repository.moveToTrip(id: id, tripId: tripId, expenseId: expenseId);
    _remove(id);
  }

  /// Forgets everything, e.g. when the account signs out.
  void clear() {
    _generation++;
    _items = const [];
    _nextCursor = null;
    _loading = false;
    _loaded = false;
    _failed = false;
    _offline = false;
    notifyListeners();
  }

  void _upsert(QuickSplit split) {
    final next = [
      for (final item in _items)
        if (item.id != split.id) item,
      split,
    ];
    next.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
    _items = next;
    notifyListeners();
  }

  void _remove(int id) {
    _items = [
      for (final item in _items)
        if (item.id != id) item,
    ];
    notifyListeners();
  }
}
