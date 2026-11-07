import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/app/locale/app_locale_controller.dart';
import 'package:tripsplit/app/locale/app_locale_picker.dart';
import 'package:tripsplit/app/locale/app_locale_scope.dart';
import 'package:tripsplit/app/theme/theme_mode_controller.dart';
import 'package:tripsplit/app/theme/theme_mode_picker.dart';
import 'package:tripsplit/app/theme/theme_mode_scope.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

Future<void> mount(
  WidgetTester tester,
  AppLocaleController locale,
  ThemeModeController theme,
) => tester.pumpWidget(
  AppLocaleScope(
    controller: locale,
    child: ThemeModeScope(
      controller: theme,
      child: AnimatedBuilder(
        animation: Listenable.merge([locale, theme]),
        builder: (_, _) => MaterialApp(
          locale: locale.locale,
          localeListResolutionCallback: (locales, _) =>
              AppLocaleController.resolveDeviceLocale(locales),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: theme.themeMode,
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  Text(
                    '${Localizations.localeOf(context).languageCode}/${Theme.of(context).brightness.name}',
                    key: const ValueKey('resolved'),
                  ),
                  TextButton(
                    onPressed: () => showAppLocalePicker(context),
                    child: const Text('Language picker'),
                  ),
                  TextButton(
                    onPressed: () => showThemeModePicker(context),
                    child: const Text('Theme picker'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'new and legacy system preferences follow device; explicit choices survive reload',
    () async {
      for (final raw in [null, 'system', 'invalid']) {
        SharedPreferences.setMockInitialValues({
          if (raw != null) 'app.locale': raw,
          if (raw != null) 'app.theme_mode': raw,
        });
        final locale = AppLocaleController();
        final theme = ThemeModeController();
        expect(locale.mode, AppLocaleMode.system);
        expect(theme.themeMode, ThemeMode.system);
        await locale.load();
        await theme.load();
        expect(locale.mode, AppLocaleMode.system);
        expect(locale.locale, isNull);
        expect(theme.themeMode, ThemeMode.system);
        locale.dispose();
        theme.dispose();
      }
      final locale = AppLocaleController();
      final theme = ThemeModeController();
      await locale.setMode(AppLocaleMode.latvian);
      await theme.setThemeMode(ThemeMode.light);
      final restoredLocale = AppLocaleController();
      final restoredTheme = ThemeModeController();
      await restoredLocale.load();
      await restoredTheme.load();
      expect(restoredLocale.locale, const Locale('lv'));
      expect(restoredTheme.themeMode, ThemeMode.light);
      await restoredLocale.setMode(AppLocaleMode.system);
      await restoredTheme.setThemeMode(ThemeMode.system);
      await locale.load();
      await theme.load();
      expect(locale.mode, AppLocaleMode.system);
      expect(theme.themeMode, ThemeMode.system);
      locale.dispose();
      theme.dispose();
      restoredLocale.dispose();
      restoredTheme.dispose();
    },
  );

  test(
    'phone language matches regional variants and otherwise falls back to English',
    () {
      for (final code in [
        'en',
        'lv',
        'es',
        'de',
        'fr',
        'it',
        'pt',
        'pl',
        'nl',
        'sv',
        'da',
        'nb',
        'fi',
        'cs',
        'uk',
        'ru',
      ]) {
        expect(
          AppLocaleController.resolveDeviceLocale([Locale(code, 'XX')]),
          Locale(code),
        );
      }
      expect(
        AppLocaleController.resolveDeviceLocale([
          const Locale('ja'),
          const Locale('es'),
        ]),
        const Locale('en'),
      );
      expect(
        AppLocaleController.resolveDeviceLocale([const Locale('no', 'NO')]),
        const Locale('nb'),
      );
      expect(AppLocaleController.resolveDeviceLocale([]), const Locale('en'));
      expect(AppLocaleController.resolveDeviceLocale(null), const Locale('en'));
    },
  );

  test('every offered language persists and has a generated catalog', () async {
    for (final mode in AppLocaleMode.values.where(
      (m) => m.languageCode != null,
    )) {
      final controller = AppLocaleController();
      await controller.setMode(mode);
      final restored = AppLocaleController();
      await restored.load();
      expect(restored.mode, mode);
      expect(AppLocalizations.supportedLocales, contains(restored.locale));
      final t = await AppLocalizations.delegate.load(restored.locale!);
      expect(t.navHome, isNotEmpty);
      expect(t.homePeople(1), isNot(t.homePeople(2)));
      expect(t.workspaceBalanceReceive('€12.50'), contains('€12.50'));
      controller.dispose();
      restored.dispose();
    }
  });

  testWidgets(
    'phone changes apply live; manual overrides win until system is reselected',
    (tester) async {
      final device = tester.binding.platformDispatcher;
      addTearDown(device.clearLocalesTestValue);
      addTearDown(device.clearPlatformBrightnessTestValue);
      device.localesTestValue = [const Locale('lv', 'LV')];
      device.platformBrightnessTestValue = Brightness.dark;
      final locale = AppLocaleController();
      final theme = ThemeModeController();
      addTearDown(locale.dispose);
      addTearDown(theme.dispose);
      await mount(tester, locale, theme);
      await tester.pumpAndSettle();
      expect(find.text('lv/dark'), findsOneWidget);
      expect(locale.effectiveLocale, const Locale('lv'));
      device.localesTestValue = [const Locale('es', 'MX')];
      device.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      expect(find.text('es/light'), findsOneWidget);
      expect(locale.effectiveLocale, const Locale('es'));
      await locale.setMode(AppLocaleMode.english);
      await theme.setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('en/dark'), findsOneWidget);
      device.localesTestValue = [const Locale('lv')];
      await tester.pumpAndSettle();
      expect(find.text('en/dark'), findsOneWidget);
      expect(locale.effectiveLocale, const Locale('en'));
      await locale.setMode(AppLocaleMode.system);
      await theme.setThemeMode(ThemeMode.system);
      await tester.pumpAndSettle();
      expect(find.text('lv/light'), findsOneWidget);
      device.localesTestValue = [const Locale('ja')];
      await tester.pumpAndSettle();
      expect(find.text('en/light'), findsOneWidget);
    },
  );

  testWidgets('pickers offer manual selection and return to system', (
    tester,
  ) async {
    final device = tester.binding.platformDispatcher;
    device.localesTestValue = [const Locale('en')];
    addTearDown(device.clearLocalesTestValue);
    final locale = AppLocaleController();
    final theme = ThemeModeController();
    addTearDown(locale.dispose);
    addTearDown(theme.dispose);
    await mount(tester, locale, theme);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Language picker'));
    await tester.pumpAndSettle();
    expect(find.text('Use device language'), findsOneWidget);
    await tester.ensureVisible(find.text('Latviešu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Latviešu'));
    await tester.pumpAndSettle();
    expect(locale.mode, AppLocaleMode.latvian);
    await tester.tap(find.text('Language picker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sistēma'));
    await tester.pumpAndSettle();
    expect(locale.mode, AppLocaleMode.system);
    await tester.tap(find.text('Theme picker'));
    await tester.pumpAndSettle();
    expect(find.text('Use device appearance'), findsOneWidget);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(theme.themeMode, ThemeMode.dark);
    await tester.tap(find.text('Theme picker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(theme.themeMode, ThemeMode.system);
  });
}
