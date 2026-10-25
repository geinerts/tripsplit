import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/account_local_storage.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/features/workspace/data/datasources/workspace_remote_data_source.dart';
import 'package:tripsplit/features/workspace/data/local/workspace_local_store.dart';
import 'package:tripsplit/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_notification.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_notifications_inbox.dart';

const inbox = WorkspaceNotificationsInbox(
  unreadCount: 1,
  notifications: [
    WorkspaceNotification(
      id: 1,
      tripId: 0,
      type: 'friend_invite_received',
      title: 'Invite',
      body: 'Invitation',
      isRead: false,
      createdAt: '2026-10-23 12:00:00',
    ),
  ],
);

class Remote implements WorkspaceRemoteDataSource {
  bool offline = false;
  Completer<int>? mark;
  Completer<WorkspaceNotificationsInbox>? load;
  @override
  Future<WorkspaceNotificationsInbox> loadGlobalNotifications({
    int limit = 80,
    String? cursor,
    int? offset,
  }) async {
    if (offline) throw const ApiException('Offline', isNetworkError: true);
    return load == null ? inbox : load!.future;
  }

  @override
  Future<int> markGlobalNotificationsRead({
    List<int> notificationIds = const [],
  }) async => mark == null ? 0 : mark!.future;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'read state survives reopening offline and an older load response',
    () async {
      final session = AccountDataSession()..activate(7);
      final store = WorkspaceLocalStore(AccountLocalStorage(session));
      final remote = Remote();
      final repo = WorkspaceRepositoryImpl(remote, store);
      await repo.loadGlobalNotifications();
      remote.load = Completer<WorkspaceNotificationsInbox>();
      final oldLoad = repo.loadGlobalNotifications();
      await repo.markGlobalNotificationsRead();
      remote.load!.complete(inbox);
      await oldLoad;
      remote.offline = true;
      final cached = await repo.loadGlobalNotifications();
      expect(cached.isCached, isTrue);
      expect(cached.unreadCount, 0);
      expect(cached.notifications.single.isRead, isTrue);
    },
  );
  test(
    'late read response cannot write into a different account cache',
    () async {
      final session = AccountDataSession()..activate(7);
      final store = WorkspaceLocalStore(AccountLocalStorage(session));
      final remote = Remote()..mark = Completer<int>();
      final repo = WorkspaceRepositoryImpl(remote, store);
      await repo.loadGlobalNotifications();
      final marking = repo.markGlobalNotificationsRead();
      session.activate(8);
      remote.mark!.complete(0);
      await expectLater(
        marking,
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'account_changed'),
        ),
      );
      expect(await store.readGlobalNotificationsInbox(), isNull);
      session.activate(7);
      expect((await store.readGlobalNotificationsInbox())!.unreadCount, 1);
    },
  );
}
