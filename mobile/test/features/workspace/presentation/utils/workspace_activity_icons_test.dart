import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/workspace/presentation/utils/workspace_activity_icons.dart';

void main() {
  test('every activity event type has its own icon', () {
    final icons = workspaceActivityIcons.values.toList();
    expect(icons.toSet(), hasLength(icons.length));
    expect(icons, isNot(contains(workspaceActivityFallbackIcon)));
  });

  test('event pairs from the same area are told apart', () {
    expect(
      workspaceActivityIcon('trip.member_ready'),
      isNot(workspaceActivityIcon('trip.member_not_ready')),
    );
    expect(
      workspaceActivityIcon('trip.member_joined'),
      isNot(workspaceActivityIcon('trip.members_invited')),
    );
    expect(
      workspaceActivityIcon('trip.updated'),
      isNot(workspaceActivityFallbackIcon),
    );
  });

  test('lookup normalizes the event type and falls back when unknown', () {
    expect(workspaceActivityIcon(' TRIP.Finished '), Icons.flag_rounded);
    expect(
      workspaceActivityIcon('something.new'),
      workspaceActivityFallbackIcon,
    );
  });
}
