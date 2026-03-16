import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tripsplit/core/ui/test_keys.dart';
import 'package:tripsplit/main.dart' as app;

const _testEmail = String.fromEnvironment('TRIPSPLIT_TEST_EMAIL');
const _testPassword = String.fromEnvironment('TRIPSPLIT_TEST_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('boots app and opens notifications safely', (tester) async {
    app.main();
    await tester.pump(const Duration(milliseconds: 500));

    final emailField = find.byKey(const ValueKey(AppTestKeys.loginEmailField));
    final passwordField = find.byKey(
      const ValueKey(AppTestKeys.loginPasswordField),
    );
    final submitButton = find.byKey(
      const ValueKey(AppTestKeys.authSubmitButton),
    );
    final notificationsButton = find.byKey(
      const ValueKey(AppTestKeys.shellNotificationsButton),
    );

    await _pumpUntilAny(tester, <Finder>[
      emailField,
      notificationsButton,
    ], timeout: const Duration(seconds: 45));

    if (_exists(emailField)) {
      expect(passwordField, findsOneWidget);
      expect(submitButton, findsOneWidget);

      if (_testEmail.isEmpty || _testPassword.isEmpty) {
        // No test credentials provided; smoke-check login screen only.
        return;
      }

      await tester.enterText(emailField, _testEmail);
      await tester.enterText(passwordField, _testPassword);
      await tester.tap(submitButton);
      await tester.pump(const Duration(milliseconds: 300));

      await _pumpUntilAny(tester, <Finder>[
        notificationsButton,
        emailField,
      ], timeout: const Duration(seconds: 60));
      if (!_exists(notificationsButton)) {
        fail(
          'Login did not reach shell. '
          'Verify TRIPSPLIT_TEST_EMAIL/TRIPSPLIT_TEST_PASSWORD.',
        );
      }
    }

    await _pumpUntil(
      tester,
      notificationsButton,
      timeout: const Duration(seconds: 30),
    );
    await tester.tap(notificationsButton);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));

    final error = tester.takeException();
    expect(error, isNull);
  });
}

bool _exists(Finder finder) => finder.evaluate().isNotEmpty;

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  Duration step = const Duration(milliseconds: 250),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(step);
    if (_exists(finder)) {
      return;
    }
  }
  fail('Timeout waiting for finder: $finder.');
}

Future<void> _pumpUntilAny(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 30),
  Duration step = const Duration(milliseconds: 250),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(step);
    if (finders.any(_exists)) {
      return;
    }
  }
  final description = finders.map((finder) => '$finder').join(', ');
  fail('Timeout waiting for any of: $description.');
}
