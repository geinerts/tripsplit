import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';

void main() {
  Map<String, Object?> trip(Object? preview) => {
    'id': 1,
    'name': 'Rome',
    'members_count': 5,
    'members_preview': preview,
  };

  test('members preview keeps the real avatar or null, at most three', () {
    final parsed = TripModel.fromLegacyMap(
      trip([
        {
          'id': 1,
          'display_name': ' Matiss Geinerts ',
          'avatar_url': 'https://example.invalid/1.jpg',
          'avatar_thumb_url': 'https://example.invalid/1-thumb.jpg',
        },
        {'id': 2, 'display_name': 'Anna', 'avatar_url': ''},
        'broken',
        {'id': 0, 'display_name': 'No id'},
        {'id': 3, 'display_name': 'Valerija', 'avatar_url': null},
        {'id': 4, 'display_name': 'Fourth'},
      ]),
    );
    expect(parsed.membersCount, 5);
    expect(parsed.membersPreview.map((m) => m.id), [1, 2, 3]);
    expect(parsed.membersPreview.first.displayName, 'Matiss Geinerts');
    expect(parsed.membersPreview.first.avatarThumbUrl, endsWith('1-thumb.jpg'));
    expect(parsed.membersPreview[1].avatarUrl, isNull);
    expect(parsed.membersPreview[2].avatarUrl, isNull);
  });

  test('missing or malformed preview falls back to an empty list', () {
    expect(TripModel.fromLegacyMap(trip(null)).membersPreview, isEmpty);
    expect(TripModel.fromLegacyMap(trip('x')).membersPreview, isEmpty);
    expect(TripModel.fromLegacyMap({'id': 2}).membersPreview, isEmpty);
  });
}
