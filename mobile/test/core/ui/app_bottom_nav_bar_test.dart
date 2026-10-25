import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/ui/app_bottom_nav_bar.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final brightness in Brightness.values) {
    for (final locale in ['en', 'lv', 'es']) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('raised expense action $brightness $locale scale=$scale', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(320, 720);
          tester.view.devicePixelRatio = 1;
          tester.view.padding = const FakeViewPadding(bottom: 34);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPadding);
          final boundary = GlobalKey();
          final taps = <AppBottomNavItem>[];
          await tester.pumpWidget(
            MaterialApp(
              theme: brightness == Brightness.dark
                  ? AppTheme.dark()
                  : AppTheme.light(),
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                bottomNavigationBar: RepaintBoundary(
                  key: boundary,
                  child: AppBottomNavBar(
                    selectedItem: AppBottomNavItem.home,
                    onSelected: taps.add,
                    avatarLetter: 'M',
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final raised = tester.getRect(
            find.byKey(const ValueKey('nav-expenses-raised-icon')),
          );
          // This point lies above the bar's top divider and must still respond.
          await tester.tapAt(Offset(raised.center.dx, raised.top + 8));
          await tester.pumpAndSettle();
          expect(taps, [AppBottomNavItem.expenses]);
          for (final item in [
            AppBottomNavItem.home,
            AppBottomNavItem.analytics,
            AppBottomNavItem.friends,
            AppBottomNavItem.profile,
          ]) {
            await tester.tap(find.byKey(ValueKey('nav-${item.name}')));
            await tester.pumpAndSettle();
            expect(taps.last, item);
          }
          expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
          expect(find.byIcon(Icons.add), findsOneWidget);
          expect(tester.takeException(), isNull);
          if (const bool.fromEnvironment('NAV_PREVIEWS') &&
              locale == 'en' &&
              scale == 1) {
            await tester.runAsync(() async {
              final image =
                  await (boundary.currentContext!.findRenderObject()!
                          as RenderRepaintBoundary)
                      .toImage(pixelRatio: 3);
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final file = File(
                '../output/design/navigation/raised-${brightness.name}.png',
              );
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        });
      }
    }
  }
}
