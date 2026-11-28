import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/router/app_router.dart';
import 'package:tripsplit/app/theme/app_design.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/app/theme/auth_flow_theme.dart';
import 'package:tripsplit/core/ui/app_background.dart';
import 'package:tripsplit/core/ui/app_components.dart';
import 'package:tripsplit/core/ui/app_scaffold.dart';

/// The pre-auth screens are always dark, even when the app runs in light mode.
/// Regression: dialogs kept a white surface with white text, and pages with a
/// transparent scaffold showed the light app background behind white titles.
Widget _app(Widget home) => MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: ThemeMode.light,
  builder: (context, child) => AppBackground(child: child!),
  home: AuthFlowTheme(child: home),
);

bool _isDark(Color color) => color.computeLuminance() < 0.1;

void main() {
  testWidgets('auth page paints a dark canvas behind a transparent scaffold', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        AppPageScaffold(
          appBar: AppBar(title: const Text('Reset password')),
          body: const Card(child: Text('Email address')),
        ),
      ),
    );
    final canvas = tester.widget<ColoredBox>(
      find
          .ancestor(
            of: find.text('Reset password'),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(canvas.color, AppDesign.authCanvas);
    final title = tester.widget<RichText>(
      find
          .descendant(
            of: find.text('Reset password'),
            matching: find.byType(RichText),
          )
          .first,
    );
    expect(_isDark(title.text.style!.color!), isFalse);
  });

  testWidgets('confirmation dialog in the auth flow has a dark surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAppConfirmationDialog(
                context: context,
                title: 'Verify your email',
                message: 'Verification email sent.',
                confirmLabel: 'Resend link',
                cancelLabel: 'Close',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final dialogContext = tester.element(find.text('Verification email sent.'));
    final theme = Theme.of(dialogContext);
    final surface =
        theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface;
    expect(_isDark(surface), isTrue, reason: 'dialog surface $surface');
    final message = tester.widget<Text>(find.text('Verification email sent.'));
    final color =
        message.style?.color ?? DefaultTextStyle.of(dialogContext).style.color!;
    expect(_isDark(color), isFalse, reason: 'message text $color');
  });

  testWidgets('opening an auth route never flashes the light background', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        themeMode: ThemeMode.light,
        builder: (context, child) => AppBackground(child: child!),
        routes: {
          AppRouter.forgotPassword: (_) => const AuthFlowTheme(
            child: AppPageScaffold(body: Text('Reset password')),
          ),
        },
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRouter.forgotPassword),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    // First frames of the transition: the page's own opaque backdrop (the
    // nearest coloured box around it) must already be the dark auth canvas.
    Color? nearest;
    tester.element(find.text('Reset password')).visitAncestorElements((
      element,
    ) {
      final widget = element.widget;
      if (widget is ColoredBox) {
        nearest = widget.color;
        return false;
      }
      return true;
    });
    expect(nearest, AppDesign.authCanvas);
    await tester.pumpAndSettle();
  });
}
