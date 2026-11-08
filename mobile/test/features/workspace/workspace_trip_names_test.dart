import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_user.dart';

WorkspaceUser _user(int id, String first, [String? last]) => WorkspaceUser(
  id: id,
  nickname: 'user$id',
  firstName: first,
  lastName: last,
  displayName: last == null ? first : '$first $last',
);

List<String> _names(List<WorkspaceUser> users) => WorkspaceUser.withTripNames(
  users,
).map((user) => user.preferredName).toList();

void main() {
  test('unique first names show only the first name', () {
    expect(
      _names([_user(1, 'Anna', 'Kalniņa'), _user(2, 'Pēteris', 'Ozols')]),
      ['Anna', 'Pēteris'],
    );
  });

  test('the same first name adds the last initial', () {
    expect(
      _names([
        _user(1, 'Anna', 'Kalniņa'),
        _user(2, 'Anna', 'Ozola'),
        _user(3, 'Pēteris', 'Ozols'),
      ]),
      ['Anna K.', 'Anna O.', 'Pēteris'],
    );
  });

  test('the same first name and initial show the full name', () {
    expect(
      _names([
        _user(1, 'Anna', 'Kalniņa'),
        _user(2, 'Anna', 'Kļava'),
        _user(3, 'Anna', 'Ozola'),
      ]),
      ['Anna Kalniņa', 'Anna Kļava', 'Anna O.'],
    );
  });

  test('diacritics are ignored, so Matiss and Matīss count as the same', () {
    expect(
      _names([_user(1, 'Matīss', 'Geinerts'), _user(2, 'Matiss', 'Geinerts')]),
      ['Matīss Geinerts', 'Matiss Geinerts'],
    );
  });

  test('without a last name the full name is used', () {
    expect(
      _names([
        const WorkspaceUser(id: 1, nickname: 'Anna'),
        _user(2, 'Anna', 'Ozola'),
      ]),
      ['Anna', 'Anna O.'],
    );
  });

  test('the full name stays available, for the member profile', () {
    final user = WorkspaceUser.withTripNames([
      _user(1, 'Anna', 'Kalniņa'),
    ]).single;
    expect(user.preferredName, 'Anna');
    expect(user.fullName, 'Anna Kalniņa');
  });
}
