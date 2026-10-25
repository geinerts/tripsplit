import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const illustrations = <String>[
    'splyto_trip_cover_large',
    'splyto_trip_cover_small',
    'splyto_empty_trips',
    'splyto_empty_friends',
    'splyto_empty_analytics',
    'splyto_empty_notifications',
    'splyto_settlements_complete',
    'splyto_empty_expenses',
    'splyto_no_results',
    'splyto_trip_load_error',
    'splyto_tutorial_01_create_trip',
    'splyto_tutorial_02_invite_friends',
    'splyto_tutorial_03_add_expense',
  ];

  for (final name in illustrations) {
    testWidgets('$name loads as a bundled Flutter SVG', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SvgPicture.asset(
                'assets/branding/$name.svg',
                width: 320,
                height: 184,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
