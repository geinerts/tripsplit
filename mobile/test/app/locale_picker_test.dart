import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/app/locale/app_locale_controller.dart';
import 'package:tripsplit/app/locale/app_locale_picker.dart';
import 'package:tripsplit/app/locale/app_locale_scope.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

void main() {
  testWidgets('language list has names only and includes Russian', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = AppLocaleController();
    await tester.pumpWidget(
      AppLocaleScope(
        controller: controller,
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAppLocalePicker(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('Latviešu'), findsOneWidget);
    expect(find.textContaining('🇱🇻'), findsNothing);
    expect(find.byIcon(Icons.phone_iphone), findsNothing);

    await tester.tap(find.byKey(const ValueKey('language-ru')));
    await tester.pumpAndSettle();
    expect(controller.mode, AppLocaleMode.russian);
  });
}
