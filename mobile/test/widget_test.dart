import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tripsplit/app/app_dependencies.dart';
import 'package:tripsplit/app/app.dart';

void main() {
  testWidgets('shows login skeleton', (WidgetTester tester) async {
    await tester.pumpWidget(
      TripSplitApp(dependencies: AppDependencies.bootstrap()),
    );

    expect(find.text('Splyto'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Log in'), findsOneWidget);
  });
}
