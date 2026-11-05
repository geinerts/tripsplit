import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/workspace/presentation/widgets/receipt_viewer_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

void main() {
  testWidgets('receipt stays in app, supports zoom and refreshes failed links', (
    tester,
  ) async {
    var reloads = 0;
    var current = true;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ReceiptViewerPage(
          initialUri: Uri.parse(
            'https://splyto.eu/api/receipt-media.php?signature=old',
          ),
          isCurrentAccount: () => current,
          reload: () async {
            reloads++;
            return Uri.parse(
              'https://splyto.eu/api/receipt-media.php?signature=fresh',
            );
          },
        ),
      ),
    );
    expect(find.byKey(const ValueKey('receipt-viewer')), findsOneWidget);
    expect(
      tester.widget<InteractiveViewer>(find.byType(InteractiveViewer)).maxScale,
      8,
    );
    final first =
        tester.widget<Image>(find.byType(Image)).image as NetworkImage;
    expect(first.url, contains('signature=old'));
    // Flutter's test HTTP client returns 400: exercise failure without real data.
    await tester.pumpAndSettle();
    expect(find.textContaining('signature='), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(reloads, 1);
    final next = tester.widget<Image>(find.byType(Image)).image as NetworkImage;
    expect(next.url, contains('signature=fresh'));
    current = false;
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(reloads, 1);
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
