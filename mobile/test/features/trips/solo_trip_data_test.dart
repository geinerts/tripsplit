import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/account_local_storage.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/core/network/legacy_trip_image_uploader.dart';
import 'package:tripsplit/features/trips/data/datasources/trips_remote_data_source.dart';
import 'package:tripsplit/features/trips/data/local/trips_local_store.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';

class _Uploader implements LegacyTripImageUploader {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Api implements ApiClient {
  String? path;
  Map<String, dynamic>? body;
  bool oldServer = false;
  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    this.path = path;
    this.body = body;
    if (oldServer) throw const ApiException('Unknown action.', statusCode: 404);
    return {
      'trip': {'id': 7, ...?body},
    };
  }

  @override
  Future<void> revokeCurrentSession() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('one-member legacy and explicit group trips are not solo', () {
    expect(TripModel.fromLegacyMap({'members_count': 1}).isSolo, isFalse);
    expect(
      TripModel.fromLegacyMap({
        'trip_mode': 'group',
        'members_count': 1,
      }).isSolo,
      isFalse,
    );
    expect(TripModel.fromLegacyMap({'trip_mode': 'solo'}).isSolo, isTrue);
  });

  test(
    'solo mode persists across restart and stays account isolated',
    () async {
      SharedPreferences.setMockInitialValues({});
      final session = AccountDataSession(namespace: 'https://solo.test')
        ..activate(7);
      final store = TripsLocalStore(AccountLocalStorage(session));
      await store.writeTrips([
        TripModel.fromLegacyMap({'id': 1, 'trip_mode': 'solo'}),
      ]);
      final restarted = AccountDataSession(namespace: session.namespace)
        ..activate(7);
      expect(
        (await TripsLocalStore(
          AccountLocalStorage(restarted),
        ).readTrips()).single.isSolo,
        isTrue,
      );
      session.activate(8);
      expect(await store.readTrips(), isEmpty);
    },
  );

  for (final mode in ['solo', 'group']) {
    test(
      'creation sends explicit $mode intent to the correct endpoint',
      () async {
        final api = _Api();
        final remote = TripsRemoteDataSourceImpl(api, _Uploader());
        final trip = await remote.createTrip(
          name: 'Test',
          currencyCode: 'EUR',
          memberIds: [],
          tripMode: mode,
        );
        expect(
          api.path,
          contains(
            mode == 'solo' ? 'action=create_solo_trip' : 'action=create_trip',
          ),
        );
        expect(api.body?['trip_mode'], mode);
        expect(trip.tripMode, mode);
      },
    );
  }

  test(
    'old server cannot silently create a group in place of a solo trip',
    () async {
      final api = _Api()..oldServer = true;
      final remote = TripsRemoteDataSourceImpl(api, _Uploader());
      await expectLater(
        remote.createTrip(
          name: 'Private',
          currencyCode: 'EUR',
          memberIds: [],
          tripMode: 'solo',
        ),
        throwsA(isA<ApiException>()),
      );
      expect(api.path, contains('action=create_solo_trip'));
    },
  );
}
