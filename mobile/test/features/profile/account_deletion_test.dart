import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/features/auth/presentation/widgets/account_deletion_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

Future<void> mount(
  WidgetTester tester, {
  required Future<void> Function(String, List<String>) request,
  String locale = 'en',
  bool dark = false,
  double width = 390,
  double scale = 1,
  GlobalKey? boundary,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: AccountDeletionPage(
          email: 'traveller@example.invalid',
          onRequest: request,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> submit(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('account-delete-submit'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets('feedback is optional; a successful request is not deletion', (
    tester,
  ) async {
    var calls = 0;
    await mount(
      tester,
      request: (password, reasons) async {
        calls++;
        expect(password, isEmpty);
        expect(reasons, isEmpty);
      },
    );
    await submit(tester);
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('One last step in your inbox'), findsOneWidget);
    expect(find.textContaining('traveller@example.invalid'), findsOneWidget);
    expect(
      find.text('Your account stays active until you confirm deletion.'),
      findsOneWidget,
    );
    expect(find.byType(CheckboxListTile), findsNothing);
  });

  testWidgets(
    'selected reasons survive failure and duplicate sends are blocked',
    (tester) async {
      var calls = 0;
      final first = Completer<void>();
      await mount(
        tester,
        request: (_, reasons) {
          calls++;
          expect(reasons, ['technical_issue']);
          return calls == 1 ? first.future : Future.value();
        },
      );
      final reason = find.byKey(
        const ValueKey('delete-reason-technical_issue'),
      );
      await tester.ensureVisible(reason);
      await tester.tap(reason);
      await submit(tester);
      final button = find.byKey(const ValueKey('account-delete-submit'));
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(calls, 1);
      first.completeError(
        const ApiException('Synthetic mail failure', statusCode: 503),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Could not send deletion link. Please try again.'),
        findsOneWidget,
      );
      expect(tester.widget<CheckboxListTile>(reason).value, isTrue);
      await submit(tester);
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.text('One last step in your inbox'), findsOneWidget);
    },
  );

  testWidgets(
    'local password reauthentication is requested without trimming it',
    (tester) async {
      var calls = 0;
      await mount(
        tester,
        request: (password, reasons) async {
          calls++;
          if (calls == 1) {
            expect(password, isEmpty);
            throw const ApiException(
              'Reauthenticate',
              statusCode: 403,
              code: 'REAUTHENTICATION_REQUIRED',
            );
          }
          expect(password, ' Actual-password-123 ');
        },
      );
      await submit(tester);
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('account-delete-password'));
      expect(field, findsOneWidget);
      await submit(tester);
      expect(calls, 1, reason: 'Do not send an empty known-required password');
      await tester.ensureVisible(field);
      await tester.enterText(field, ' Actual-password-123 ');
      tester.testTextInput.hide();
      await submit(tester);
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.text('One last step in your inbox'), findsOneWidget);
    },
  );

  for (final dark in [false, true]) {
    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets(
        'deletion form 320px 200% ${locale.languageCode} dark=$dark',
        (tester) async {
          await mount(
            tester,
            request: (_, reasons) async {},
            locale: locale.languageCode,
            dark: dark,
            width: 320,
            scale: 2,
          );
          await submit(tester);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final dark in [false, true]) {
    testWidgets('capture deletion form and sent state dark=$dark', (
      tester,
    ) async {
      final key = GlobalKey();
      await mount(
        tester,
        request: (_, reasons) async {},
        locale: 'lv',
        dark: dark,
        boundary: key,
      );
      Future<void> capture(String state) async {
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/account-deletion/${dark ? 'dark' : 'light'}-$state.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('form');
      await submit(tester);
      await tester.pumpAndSettle();
      await capture('sent');
    });
  }
}
