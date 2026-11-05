import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/ui/email_sent_view.dart';
import 'package:tripsplit/core/ui/splyto_illustration.dart';

Widget _host(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: ThemeData(brightness: brightness, useMaterial3: true),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('shows illustration, title, message and hint '
        'in ${brightness.name} mode', (tester) async {
      await tester.pumpWidget(
        _host(
          const EmailSentView(
            title: 'Check your inbox',
            message: 'Link sent.',
            hint: 'Valid for 1 hour.',
          ),
          brightness: brightness,
        ),
      );
      await tester.pump();

      expect(find.byType(SplytoEmailSentIllustration), findsOneWidget);
      expect(find.text('Check your inbox'), findsOneWidget);
      expect(find.text('Link sent.'), findsOneWidget);
      expect(find.text('Valid for 1 hour.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('omits the hint when none is given', (tester) async {
    await tester.pumpWidget(
      _host(const EmailSentView(title: 'Title', message: 'Message')),
    );
    await tester.pump();
    expect(find.text('Message'), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('stays readable at 200% text scale on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _host(
          const EmailSentView(
            title: 'Check your inbox',
            message:
                'If an account with this email exists, we have sent a link.',
            hint: 'The link is valid for 1 hour.',
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
