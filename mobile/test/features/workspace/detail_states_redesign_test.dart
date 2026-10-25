import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/ui/app_components.dart';
import 'package:tripsplit/core/ui/app_sheet.dart';
import 'package:tripsplit/features/workspace/domain/entities/payment_details.dart';
import 'package:tripsplit/features/workspace/presentation/widgets/payment_request_details_sheet.dart';
import 'package:tripsplit/l10n/app_localizations.dart';
import 'package:tripsplit/features/workspace/presentation/widgets/receipt_open_action.dart';

const details = PaymentDetails(
  bankAccountHolder: 'Anna Parker',
  bankIban: 'LV80BANK0000435195001',
  bankBic: 'HABALV22',
  revolutHandle: '@anna',
);
Future<void> mount(
  WidgetTester tester, {
  required WidgetBuilder builder,
  bool dark = false,
  String locale = 'en',
  double scale = 1,
  double width = 390,
  GlobalKey? boundary,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Builder(builder: builder),
  );
  await tester.pumpWidget(
    boundary == null ? app : RepaintBoundary(key: boundary, child: app),
  );
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
  testWidgets('detail states review images', (tester) async {
    if (!const bool.fromEnvironment('DETAIL_PREVIEWS')) return;
    for (final dark in [false, true]) {
      for (final screen in [
        'confirm',
        'destructive',
        'details',
        'details-loading',
        'details-error',
        'details-empty',
        'receipt',
        'receipt-loading',
        'receipt-error',
      ]) {
        final key = GlobalKey();
        final pending = Completer<PaymentDetails>();
        final receiptPending = Completer<Uri?>();
        await mount(
          tester,
          dark: dark,
          boundary: key,
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {
                  final t = AppLocalizations.of(context)!;
                  if (screen.startsWith('receipt')) {
                    showAppBottomSheet<void>(
                      context: context,
                      builder: (_) => AppActionSheet(
                        title: t.expenseDetailsTitle,
                        children: [
                          ReceiptOpenAction(
                            load: () => screen == 'receipt-loading'
                                ? receiptPending.future
                                : Future.error(StateError('Private failure')),
                            open: (_) async => false,
                          ),
                        ],
                      ),
                    );
                  } else if (screen == 'confirm' || screen == 'destructive') {
                    showAppConfirmationDialog(
                      context: context,
                      title: screen == 'confirm'
                          ? t.markSettlementSentConfirmTitle
                          : t.expenseDeleteCommentTitle,
                      message: screen == 'confirm'
                          ? t.markSettlementSentConfirmText
                          : 'Thanks! I included the airport transfer.',
                      confirmLabel: screen == 'confirm'
                          ? t.iSentAction
                          : t.deleteAction,
                      cancelLabel: t.cancelAction,
                      destructive: screen == 'destructive',
                    );
                  } else {
                    showAppBottomSheet<void>(
                      context: context,
                      builder: (_) => PaymentRequestDetailsSheet(
                        load: () {
                          if (screen == 'details-loading') {
                            return pending.future;
                          }
                          if (screen == 'details-error') {
                            return Future.error(
                              StateError('Private server error'),
                            );
                          }
                          return Future.value(
                            screen == 'details-empty'
                                ? const PaymentDetails()
                                : details,
                          );
                        },
                      ),
                    );
                  }
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        if (screen.startsWith('receipt')) {
          await tester.pumpAndSettle();
          if (screen != 'receipt') {
            await tester.tap(find.byKey(const ValueKey('receipt-open')));
          }
        }
        if (screen == 'details-loading' || screen == 'receipt-loading') {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        } else {
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/detail-states/${dark ? 'dark' : 'light'}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    }
  });
  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      testWidgets(
        'confirmation 320px 200% $locale dark=$dark accepts cancels and dismisses',
        (tester) async {
          bool? result;
          await mount(
            tester,
            locale: locale,
            dark: dark,
            scale: 2,
            width: 320,
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  final t = AppLocalizations.of(context)!;
                  result = await showAppConfirmationDialog(
                    context: context,
                    title: t.markSettlementSentConfirmTitle,
                    message: t.markSettlementSentConfirmText,
                    confirmLabel: t.iSentAction,
                    cancelLabel: t.cancelAction,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          );
          for (final action in [
            'close',
            'cancel',
            'accept',
            'barrier',
            'back',
          ]) {
            result = null;
            await tester.tap(find.text('Open'));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            if (action == 'close') {
              await tester.tap(find.byIcon(Icons.close));
            } else if (action == 'barrier') {
              await tester.tapAt(const Offset(5, 5));
            } else if (action == 'back') {
              await tester.binding.handlePopRoute();
            } else {
              final button = action == 'accept'
                  ? find.byType(FilledButton)
                  : find.descendant(
                      of: find.byKey(const ValueKey('app-confirmation-dialog')),
                      matching: find.byType(TextButton),
                    );
              await tester.ensureVisible(button);
              await tester.pumpAndSettle();
              await tester.tap(button);
            }
            await tester.pumpAndSettle();
            expect(result, action == 'accept');
          }
        },
      );
      testWidgets(
        'details 320px 200% $locale dark=$dark loading error retry content close',
        (tester) async {
          final pending = Completer<PaymentDetails>();
          var calls = 0;
          await mount(
            tester,
            locale: locale,
            dark: dark,
            scale: 2,
            width: 320,
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showAppBottomSheet<void>(
                  context: context,
                  builder: (_) => PaymentRequestDetailsSheet(
                    load: () {
                      calls++;
                      return calls == 1
                          ? pending.future
                          : Future.value(details);
                    },
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.byIcon(Icons.close), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          pending.completeError(StateError('Private server error'));
          await tester.pumpAndSettle();
          expect(find.textContaining('Private server'), findsNothing);
          await tester.ensureVisible(find.byIcon(Icons.refresh_rounded));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.refresh_rounded));
          await tester.pumpAndSettle();
          expect(calls, 2);
          expect(find.textContaining('LV80BANK0000435195001'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.byIcon(Icons.close));
          await tester.pumpAndSettle();
          expect(find.byType(PaymentRequestDetailsSheet), findsNothing);
        },
      );
    }
  }
  testWidgets(
    'closed details ignore late response; reopening loads fresh details',
    (tester) async {
      final pending = Completer<PaymentDetails>();
      var calls = 0;
      await mount(
        tester,
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showAppBottomSheet<void>(
              context: context,
              builder: (_) => PaymentRequestDetailsSheet(
                load: () {
                  calls++;
                  return calls == 1
                      ? pending.future
                      : Future.value(const PaymentDetails());
                },
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      pending.complete(details);
      await tester.pumpAndSettle();
      expect(find.textContaining('LV80BANK'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.textContaining('LV80BANK'), findsNothing);
      expect(find.byIcon(Icons.close), findsOneWidget);
    },
  );
  testWidgets('details copy preserves exact IBAN', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await mount(
      tester,
      builder: (_) =>
          Scaffold(body: PaymentRequestDetailsSheet(load: () async => details)),
    );
    await tester.pumpAndSettle();
    final row = find
        .ancestor(of: find.textContaining('IBAN:'), matching: find.byType(Row))
        .first;
    await tester.tap(
      find.descendant(of: row, matching: find.byType(IconButton)),
    );
    await tester.pumpAndSettle();
    expect(copied, details.bankIban);
  });
  testWidgets(
    'receipt loading rejects duplicate taps and retry obtains a fresh URL',
    (tester) async {
      final pending = Completer<Uri?>();
      var calls = 0;
      final opened = <Uri>[];
      await mount(
        tester,
        builder: (_) => Scaffold(
          body: ReceiptOpenAction(
            load: () {
              calls++;
              return calls == 1
                  ? pending.future
                  : Future.value(
                      Uri.parse(
                        'https://splyto.eu/api/receipt-media.php?signature=fresh',
                      ),
                    );
            },
            open: (uri) async {
              opened.add(uri);
              return true;
            },
          ),
        ),
      );
      final action = tester
          .widget<TextButton>(find.byKey(const ValueKey('receipt-open')))
          .onPressed!;
      action();
      action();
      await tester.pump();
      expect(calls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.completeError(StateError('Private URL must not be shown'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Private URL'), findsNothing);
      expect(opened, isEmpty);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(opened.single.queryParameters['signature'], 'fresh');
    },
  );
  testWidgets(
    'receipt invalid URL and failed launch offer retry; disposed load never launches',
    (tester) async {
      var calls = 0;
      var opens = 0;
      final pending = Completer<Uri?>();
      await mount(
        tester,
        builder: (_) => Scaffold(
          body: ReceiptOpenAction(
            load: () {
              calls++;
              return calls == 1
                  ? Future.value(null)
                  : calls == 2
                  ? Future.value(Uri.parse('https://splyto.eu/receipt'))
                  : pending.future;
            },
            open: (_) async {
              opens++;
              return false;
            },
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('receipt-open')));
      await tester.pumpAndSettle();
      expect(opens, 0);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(opens, 1);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      pending.complete(Uri.parse('https://splyto.eu/receipt'));
      await tester.pumpAndSettle();
      expect(opens, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
