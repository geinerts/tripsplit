import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tripsplit/features/travel_map/data/travel_location_service.dart';

void main() {
  test('a small place without a locality uses its district', () {
    const mark = Placemark(
      locality: '',
      subAdministrativeArea: 'Ādažu novads',
      administrativeArea: 'Vidzeme',
      country: 'Latvia',
      isoCountryCode: 'lv',
    );
    expect(placemarkCity(mark), 'Ādažu novads');
  });

  test('without the city centre the position is rounded, never exact', () {
    const mark = Placemark(
      locality: 'Riga',
      administrativeArea: 'Riga',
      country: 'Latvia',
      isoCountryCode: 'LV',
    );
    final place = currentCityCandidate(
      mark,
      latitude: 56.94961,
      longitude: 24.10519,
    );
    expect(place.city, 'Riga');
    expect(place.countryCode, 'LV');
    expect(place.latitude, 56.9);
    expect(place.longitude, 24.1);
  });

  test('the city centre is used when it was found', () {
    const mark = Placemark(
      locality: 'Tirana',
      country: 'Albania',
      isoCountryCode: 'AL',
    );
    final place = currentCityCandidate(
      mark,
      centre: Location(
        latitude: 41.3275,
        longitude: 19.8187,
        timestamp: DateTime.utc(2026),
      ),
      latitude: 41.31,
      longitude: 19.84,
    );
    expect(place.latitude, 41.3275);
    expect(place.longitude, 19.8187);
  });
}
