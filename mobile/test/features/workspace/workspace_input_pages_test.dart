import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/l10n/app_localizations.dart';
import 'package:tripsplit/features/workspace/presentation/widgets/workspace_input_pages.dart';

class Harness {
  Object? result;
  bool closed = false;
  Future<void> mount(
    WidgetTester tester,
    Widget page, {
    String locale = 'en',
    bool dark = false,
    double scale = 1,
  }) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
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
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.of(
                  context,
                ).push(MaterialPageRoute<Object>(builder: (_) => page));
                closed = true;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }
}

Widget payment({bool request = false}) => TripPaymentComposerPage(
  memberName: 'Anna Parker',
  maxAmount: 24,
  maxAmountLabel: '€24.00',
  isRequest: request,
);
Future<void> close(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.close));
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      for (final mode in ['comment', 'payment', 'request']) {
        testWidgets(
          '$mode 320px 200% $locale dark=$dark keyboard and dismissal',
          (tester) async {
            final h = Harness();
            await h.mount(
              tester,
              mode == 'comment'
                  ? const EditExpenseCommentPage(initial: 'Airport transfer')
                  : payment(request: mode == 'request'),
              locale: locale,
              dark: dark,
              scale: 2,
            );
            if (mode == 'request') {
              await tester.scrollUntilVisible(
                find.byKey(const ValueKey('payment-share-consent')),
                180,
                scrollable: find
                    .descendant(
                      of: find.byType(ListView),
                      matching: find.byType(Scrollable),
                    )
                    .first,
              );
              await tester.pumpAndSettle();
              expect(
                tester
                    .widget<CheckboxListTile>(
                      find.byKey(const ValueKey('payment-share-consent')),
                    )
                    .value,
                isFalse,
              );
            }
            tester.view.viewInsets = const FakeViewPadding(bottom: 300);
            addTearDown(tester.view.resetViewInsets);
            await tester.pumpAndSettle();
            expect(
              tester.getBottomRight(find.byType(FilledButton)).dy,
              lessThanOrEqualTo(544),
            );
            expect(tester.takeException(), isNull);
            await close(tester);
            expect(h.closed, isTrue);
            expect(h.result, isNull);
          },
        );
      }
    }
  }
  testWidgets(
    'payment rejects invalid amounts and returns comma decimal and note exactly once',
    (tester) async {
      final h = Harness();
      await h.mount(tester, payment());
      final amount = find.byKey(const ValueKey('payment-amount'));
      for (final input in ['', '-1', '0', 'NaN', 'Infinity', '25']) {
        await tester.enterText(amount, input);
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(h.closed, isFalse);
        expect(
          tester.widget<TextField>(amount).decoration!.errorText,
          isNotNull,
        );
      }
      await tester.enterText(amount, '12,50');
      await tester.enterText(
        find.byKey(const ValueKey('payment-note')),
        'Cash at the station',
      );
      final save = tester
          .widget<FilledButton>(find.byType(FilledButton))
          .onPressed!;
      save();
      save();
      await tester.pumpAndSettle();
      final draft = h.result! as TripPaymentDraft;
      expect(draft.amount, 12.5);
      expect(draft.note, 'Cash at the station');
      expect(draft.sharePaymentDetails, isFalse);
      expect(find.text('Open'), findsOneWidget);
    },
  );
  for (final consent in [false, true]) {
    testWidgets(
      'request shares payment details only with explicit consent $consent',
      (tester) async {
        final h = Harness();
        await h.mount(tester, payment(request: true));
        if (consent) {
          await tester.tap(find.byKey(const ValueKey('payment-share-consent')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        final draft = h.result! as TripPaymentDraft;
        expect(draft.amount, 24);
        expect(draft.sharePaymentDetails, consent);
      },
    );
  }
  testWidgets(
    'comment disables blank and unchanged values; trims changed text and submits once',
    (tester) async {
      final h = Harness();
      await h.mount(tester, const EditExpenseCommentPage(initial: 'Original'));
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      final input = find.byKey(const ValueKey('comment-edit-input'));
      await tester.enterText(input, '   ');
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.enterText(input, '  Updated comment  ');
      await tester.pump();
      final save = tester
          .widget<FilledButton>(find.byType(FilledButton))
          .onPressed!;
      save();
      save();
      await tester.pumpAndSettle();
      expect(h.result, 'Updated comment');
      expect(find.text('Open'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
