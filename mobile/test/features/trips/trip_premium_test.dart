import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/account_local_storage.dart';
import 'package:tripsplit/features/subscriptions/domain/entities/premium_access.dart';
import 'package:tripsplit/features/trips/data/local/trips_local_store.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';

Map<String, dynamic> tripMap([Object? premiumFeatures]) => {
  'id': 20,
  'name': 'Rome',
  'currency_code': 'EUR',
  'status': 'active',
  'members_count': 3,
  'premium_features': ?premiumFeatures,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('trip Premium features come from the trips list', () {
    final trip = TripModel.fromLegacyMap(
      tripMap({'trip_export': true, 'other': 'yes'}),
    );
    expect(trip.premiumFeatures, {'trip_export': true});
    expect(trip.premiumFeatures![PremiumFeatures.tripExport], isTrue);
    expect(
      trip.withImage(imageUrl: null, imageThumbUrl: null).premiumFeatures,
      {'trip_export': true},
    );
  });

  test('older servers send no trip Premium features', () {
    expect(TripModel.fromLegacyMap(tripMap()).premiumFeatures, isNull);
    expect(TripModel.fromLegacyMap(tripMap('yes')).premiumFeatures, isNull);
  });

  test('the offline trips cache never keeps trip Premium', () async {
    SharedPreferences.setMockInitialValues({});
    final session = AccountDataSession(namespace: 'https://splyto.test')
      ..activate(1);
    final store = TripsLocalStore(AccountLocalStorage(session));
    await store.writeTrips([
      TripModel.fromLegacyMap(tripMap({'trip_export': true})),
    ]);
    final cached = await store.readTrips();
    expect(cached.single.name, 'Rome');
    expect(cached.single.premiumFeatures, isNull);
  });
}
