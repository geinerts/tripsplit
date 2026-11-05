import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/workspace/presentation/utils/workspace_member_short_names.dart';

void main() {
  test('a first name is used only while it identifies one person', () {
    final names = WorkspaceMemberShortNames([
      (id: 1, name: 'Anna Ozola'),
      (id: 2, name: 'Janis Berzins'),
      (id: 3, name: 'Janis Liepa'),
      (id: 4, name: 'Cher'),
    ]);
    expect(names.labelFor(1, 'Anna Ozola'), 'Anna');
    expect(names.labelFor(2, 'Janis Berzins'), 'Janis Berzins');
    expect(names.labelFor(3, 'Janis Liepa'), 'Janis Liepa');
    expect(names.labelFor(4, 'Cher'), 'Cher');
  });

  test('diacritics and letter case do not separate first names', () {
    final names = WorkspaceMemberShortNames([
      (id: 1, name: 'Matiss Geinerts'),
      (id: 2, name: 'mat\u012bss Geinerts'),
    ]);
    expect(names.labelFor(1, 'Matiss Geinerts'), 'Matiss Geinerts');
  });

  test('one person under two spellings still counts once', () {
    final names = WorkspaceMemberShortNames([
      (id: 1, name: 'Anna'),
      (id: 1, name: 'Anna Ozola'),
    ]);
    expect(names.labelFor(1, 'Anna Ozola'), 'Anna');
  });

  test('members without an id are told apart by name', () {
    final names = WorkspaceMemberShortNames([
      (id: null, name: 'Anna Ozola'),
      (id: null, name: 'Anna Liepa'),
    ]);
    expect(names.labelFor(null, 'Anna Ozola'), 'Anna Ozola');
  });
}
