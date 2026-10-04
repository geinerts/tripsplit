import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/auth/auth_session_store.dart';

Map<String, dynamic> payload(int userId) => {
  'user_id': userId,
  'access_token': 'access-$userId',
  'refresh_token': 'refresh-$userId',
  'access_expires_in_sec': 3600,
  'refresh_expires_in_sec': 7200,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'restart restores account owner and both tokens from one secure record',
    () async {
      final store = AuthSessionStore();
      await store.saveFromAuthPayload(payload(1));
      await store.saveFromAuthPayload(payload(2));
      final restarted = AuthSessionStore();
      expect(await restarted.readAccountOwner(), 2);
      expect(await restarted.readValidAccessToken(), 'access-2');
      expect(await restarted.readValidRefreshToken(), 'refresh-2');
      final records = await const FlutterSecureStorage().readAll();
      expect(records.keys, ['trip_auth_session_v2']);
    },
  );

  test(
    'legacy credentials never infer an offline owner from a cached profile',
    () async {
      final expiry = DateTime.now()
          .add(const Duration(hours: 2))
          .millisecondsSinceEpoch;
      FlutterSecureStorage.setMockInitialValues({
        'trip_access_token_v1': 'legacy-access',
        'trip_access_expiry_epoch_ms_v1': '$expiry',
        'trip_refresh_token_v1': 'legacy-refresh',
        'trip_refresh_expiry_epoch_ms_v1': '$expiry',
      });
      final store = AuthSessionStore();
      expect(await store.readValidAccessToken(), 'legacy-access');
      expect(await store.readAccountOwner(), isNull);
    },
  );

  test(
    'damaged new record cannot revive old-account legacy credentials',
    () async {
      final expiry = DateTime.now()
          .add(const Duration(hours: 2))
          .millisecondsSinceEpoch;
      FlutterSecureStorage.setMockInitialValues({
        'trip_auth_session_v2': 'invalid-json',
        'trip_access_token_v1': 'legacy-access',
        'trip_access_expiry_epoch_ms_v1': '$expiry',
      });
      final store = AuthSessionStore();
      expect(await store.readValidAccessToken(), isNull);
      expect(await store.readValidRefreshToken(), isNull);
      expect(await store.readAccountOwner(), isNull);
    },
  );

  test('logout removes atomic record and legacy credentials', () async {
    FlutterSecureStorage.setMockInitialValues({
      'trip_access_token_v1': 'legacy',
    });
    final store = AuthSessionStore();
    await store.saveFromAuthPayload(payload(1));
    await store.clear();
    final restarted = AuthSessionStore();
    expect(await restarted.readAccountOwner(), isNull);
    expect(await restarted.readValidRefreshToken(), isNull);
    expect(await const FlutterSecureStorage().readAll(), isEmpty);
  });
}
