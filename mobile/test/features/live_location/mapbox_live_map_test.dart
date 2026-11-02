import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:tripsplit/features/live_location/domain/live_location.dart';
import 'package:tripsplit/features/live_location/presentation/mapbox_live_map.dart';

LiveMember member({double accuracy = 25}) => LiveMember.fromJson({
  'user_id': 2,
  'name': 'Ruslans',
  'latitude': 38.72,
  'longitude': -9.14,
  'accuracy_m': accuracy,
  'observed_at': 1793190000,
  'expires_at': 1793193600,
});

void main() {
  test('Retina annotation decoding preserves the logical marker size', () {
    for (final ratio in [2.0, 3.0]) {
      expect(112 / ratio * liveMapIconScale(TargetPlatform.iOS, ratio), 56);
    }
    expect(112 * liveMapIconScale(TargetPlatform.android, 3), 56);
  });
  test('native map receives longitude/latitude, not swapped coordinates', () {
    final point = liveMapPoint(member());
    expect(point.coordinates.lng, -9.14);
    expect(point.coordinates.lat, 38.72);
  });

  test('accuracy area is a closed geographic ring measured in metres', () {
    final value = member();
    final ring = liveAccuracyArea(value).coordinates.single;
    expect(ring.length, 37);
    expect(ring.last, ring.first);
    const distance = Distance(roundResult: false);
    for (final point in ring) {
      expect(
        distance(
          value.point,
          LatLng(point.lat.toDouble(), point.lng.toDouble()),
        ),
        closeTo(25, .1),
      );
    }
  });

  test('poor accuracy cannot cover the entire map', () {
    final value = member(accuracy: 50000);
    final point = liveAccuracyArea(value).coordinates.single.first;
    expect(
      const Distance()(
        value.point,
        LatLng(point.lat.toDouble(), point.lng.toDouble()),
      ),
      closeTo(2000, 1),
    );
  });
}
