import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tripsplit/app/app_dependencies.dart';
import 'package:tripsplit/app/app.dart';

void main() {
  testWidgets('shows login skeleton', (WidgetTester tester) async {
    await tester.pumpWidget(
      TripSplitApp(dependencies: AppDependencies.bootstrap()),
    );
    await tester.pump(const Duration(seconds: 5));

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/branding/logo_full.png',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Log in'), findsOneWidget);
  });
}
