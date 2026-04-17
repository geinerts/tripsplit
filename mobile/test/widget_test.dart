import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tripsplit/app/app_dependencies.dart';
import 'package:tripsplit/app/app.dart';
import 'package:tripsplit/app/router/app_router.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('app boots', (WidgetTester tester) async {
    await tester.pumpWidget(
      TripSplitApp(
        dependencies: AppDependencies.bootstrap(),
        initialRoute: AppRouter.authIntro,
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
