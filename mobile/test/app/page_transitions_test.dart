import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/ui/app_scaffold.dart';

void main() {
  Future<void> open(WidgetTester tester, TargetPlatform platform) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light().copyWith(platform: platform),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  AppPageRoute<void>(
                    builder: (_) => const AppPageScaffold(
                      body: Center(child: Text('Inner')),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Inner'), findsOneWidget);
  }

  testWidgets('on iOS a page can be swiped back from the edge', (tester) async {
    await open(tester, TargetPlatform.iOS);
    final gesture = await tester.startGesture(const Offset(5, 300));
    await gesture.moveBy(const Offset(500, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Inner'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('a page slides in on iOS, so the one below never shows '
      'through it', (tester) async {
    await open(tester, TargetPlatform.iOS);
    Navigator.of(tester.element(find.text('Inner'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    // Halfway: the closing page is still fully opaque, not fading.
    final opacities = tester
        .widgetList<FadeTransition>(
          find.ancestor(
            of: find.text('Inner'),
            matching: find.byType(FadeTransition),
          ),
        )
        .map((fade) => fade.opacity.value);
    expect(opacities.every((value) => value == 1), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Inner'), findsNothing);
  });

  testWidgets('Android uses its own transition and goes back', (tester) async {
    await open(tester, TargetPlatform.android);
    Navigator.of(tester.element(find.text('Inner'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });
}
