import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tripsplit/core/location/location_access.dart';

void main() {
  test('maps position errors to the problem the user can fix', () {
    expect(
      locationAccessProblemFor(const LocationServiceDisabledException()),
      LocationAccessProblem.servicesDisabled,
    );
    expect(
      locationAccessProblemFor(const PermissionDeniedException('no')),
      LocationAccessProblem.denied,
    );
    expect(
      locationAccessProblemFor(
        const LocationAccessException(LocationAccessProblem.deniedForever),
      ),
      LocationAccessProblem.deniedForever,
    );
    expect(locationAccessProblemFor(StateError('other')), isNull);
  });
}
