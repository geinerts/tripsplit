import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/app/theme/theme_mode_controller.dart';
import 'package:tripsplit/app/theme/theme_mode_scope.dart';
import 'package:tripsplit/app/locale/app_locale_controller.dart';
import 'package:tripsplit/app/locale/app_locale_scope.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/features/auth/data/models/auth_user_model.dart';
import 'package:tripsplit/features/auth/domain/entities/auth_user.dart';
import 'package:tripsplit/features/auth/domain/entities/notification_preferences.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/auth/presentation/pages/profile_page.dart';
import 'package:tripsplit/features/auth/presentation/widgets/privacy_policy_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

final _privacyAssets = <String, String>{};

class _PolicyAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) => rootBundle.load(key);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return _privacyAssets[key] ??
        await rootBundle.loadString(key, cache: cache);
  }
}

class _Auth implements AuthController {
  AuthUser user = AuthUserModel.fromLegacyMap({
    'id': 1,
    'nickname': 'Matiss',
    'first_name': 'Matiss',
    'last_name': 'Geinerts',
    'email': 'matiss@example.com',
    'preferred_currency_code': 'EUR',
    'premium_access': {
      'schema_version': 1,
      'account_id': 1,
      'plan': 'free',
      'source': null,
      'expires_at': null,
      'checked_at': '2026-10-22T12:00:00Z',
      'refresh_after_seconds': 300,
      'billing_enabled': false,
      'limits_enforced': false,
    },
  });
  NotificationPreferences prefs = const NotificationPreferences.defaults();
  Object? error;
  Completer<NotificationPreferences>? pending;
  final updates = <Map<Symbol, dynamic>>[];
  final profiles = <Map<Symbol, dynamic>>[];
  int logoutCalls = 0, feedbackCalls = 0;
  @override
  AuthUser? get currentUser => user;
  @override
  Future<AuthUser> loadCurrentUser() async => user;
  @override
  NotificationPreferences get notificationPreferences => prefs;
  @override
  Future<NotificationPreferences> loadNotificationPreferences() async => prefs;
  @override
  Uint8List? avatarBytesFor(AuthUser? user) => null;
  @override
  String? avatarUrlFor(AuthUser? user, {bool preferThumb = false}) => null;
  @override
  dynamic noSuchMethod(Invocation i) {
    if (i.memberName == #updateNotificationPreferences) {
      updates.add(i.namedArguments);
      if (error != null) return Future<NotificationPreferences>.error(error!);
      if (pending != null) return pending!.future;
      prefs = prefs.copyWith(
        pushExpenseAddedEnabled: i.namedArguments[#pushExpenseAddedEnabled],
        pushFriendInvitesEnabled: i.namedArguments[#pushFriendInvitesEnabled],
        pushTripUpdatesEnabled: i.namedArguments[#pushTripUpdatesEnabled],
        pushSettlementUpdatesEnabled:
            i.namedArguments[#pushSettlementUpdatesEnabled],
        inAppBannerEnabled: i.namedArguments[#inAppBannerEnabled],
        inAppExpenseAddedEnabled: i.namedArguments[#inAppExpenseAddedEnabled],
      );
      return Future.value(prefs);
    }
    if (i.memberName == #updateProfile) {
      profiles.add(i.namedArguments);
      if (error != null) return Future<AuthUser>.error(error!);
      return Future.value(user);
    }
    if (i.memberName == #logout) {
      logoutCalls++;
      return Future.value(true);
    }
    if (i.memberName == #submitFeedback) {
      feedbackCalls++;
      return Future<void>.value();
    }
    return super.noSuchMethod(i);
  }
}

Future<void> _mount(
  WidgetTester tester,
  _Auth auth, {
  bool dark = false,
  String locale = 'en',
  double scale = 1,
  double width = 390,
  GlobalKey? boundary,
  ProfilePageCommandController? commands,
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 44, bottom: 20);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  final theme = ThemeModeController();
  final language = AppLocaleController();
  await theme.setThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
  await language.setMode(
    locale == 'lv'
        ? AppLocaleMode.latvian
        : locale == 'es'
        ? AppLocaleMode.spanish
        : AppLocaleMode.english,
  );
  addTearDown(theme.dispose);
  addTearDown(language.dispose);
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundary,
      child: AnimatedBuilder(
        animation: Listenable.merge([theme, language]),
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: theme.themeMode,
          locale: language.locale ?? Locale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => ThemeModeScope(
            controller: theme,
            child: AppLocaleScope(
              controller: language,
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: DefaultAssetBundle(
                  bundle: _PolicyAssetBundle(),
                  child: child!,
                ),
              ),
            ),
          ),
          home: ProfilePage(
            controller: auth,
            commandController: commands,
            onQuickStartRequested: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations _t(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(ProfilePage)))!;
Future<void> _tap(WidgetTester tester, String text) async {
  final target = find.text(text);
  if (target.evaluate().isEmpty) {
    tester
        .state<ScrollableState>(find.byType(Scrollable).last)
        .position
        .jumpTo(0);
    await tester.pumpAndSettle();
  }
  for (var i = 0; i < 30 && target.evaluate().isEmpty; i++) {
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -180));
    await tester.pumpAndSettle();
  }
  expect(target, findsWidgets, reason: 'Missing settings action: $text');
  await tester.ensureVisible(target.first);
  await tester.pumpAndSettle();
  await tester.tap(target.first);
  await tester.pumpAndSettle();
}

Future<void> _back(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator).last).pop();
  await tester.pumpAndSettle();
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  expect(tester.takeException(), isNull);
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('../output/design/profile/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    WidgetController.hitTestWarningShouldBeFatal = true;
    // Load shared assets outside individual tests' fake-async zones.
    for (final language in ['en', 'lv', 'es']) {
      final key = 'assets/legal/privacy_$language.json';
      _privacyAssets[key] = await rootBundle.loadString(key);
    }
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final dark in [false, true]) {
    for (final locale in ['en', 'lv', 'es']) {
      testWidgets('profile settings 320px 200% $locale dark=$dark', (
        tester,
      ) async {
        final commands = ProfilePageCommandController();
        await _mount(
          tester,
          _Auth(),
          dark: dark,
          locale: locale,
          width: 320,
          scale: 2,
          commands: commands,
        );
        final t = _t(tester);
        for (final label in [
          t.profileAppearance,
          t.profileLanguage,
          t.profileAppBanners,
          t.profilePushNotificationsTitle,
        ]) {
          await _tap(tester, label);
          expect(tester.takeException(), isNull);
          await _back(tester);
        }
        await _tap(tester, 'Matiss Geinerts');
        await _tap(tester, t.profileEditPaymentMethod);
        expect(tester.takeException(), isNull);
        await _back(tester);
        commands.requestCloseEditMode();
        await tester.pumpAndSettle();
        for (final label in [
          t.profileChangePassword,
          t.profileAccountSettings,
        ]) {
          await _tap(tester, label);
          expect(tester.takeException(), isNull);
          commands.requestCloseEditMode();
          await tester.pumpAndSettle();
        }
        await _tap(tester, t.profileContactUs);
        expect(tester.takeException(), isNull);
        await _back(tester);
        await _tap(tester, t.profilePrivacyPolicy);
        expect(find.byType(PrivacyPolicyPage), findsOneWidget);
        expect(
          find.byKey(const ValueKey('privacy-draft-notice')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('privacy-security')),
          600,
          scrollable: find
              .descendant(
                of: find.byKey(const ValueKey('privacy-policy-content')),
                matching: find.byType(Scrollable),
              )
              .first,
          maxScrolls: 150,
        );
        expect(tester.takeException(), isNull);
        await _back(tester);
        expect(find.byType(ProfilePage), findsOneWidget);
      });
    }
  }
  testWidgets(
    'push row opens details without toggling; failed save rolls back',
    (tester) async {
      final auth = _Auth();
      await _mount(tester, auth);
      await _tap(tester, _t(tester).profilePushNotificationsTitle);
      expect(auth.updates, isEmpty);
      auth.error = const ApiException('Save failed');
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(auth.updates.single[#pushExpenseAddedEnabled], false);
      expect(tester.widget<Switch>(find.byType(Switch).first).value, true);
      expect(find.text('Save failed'), findsOneWidget);
    },
  );
  testWidgets('notification save blocks duplicate changes and keeps result', (
    tester,
  ) async {
    final auth = _Auth()..pending = Completer<NotificationPreferences>();
    await _mount(tester, auth);
    await _tap(tester, _t(tester).profileAppBanners);
    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    expect(tester.widget<Switch>(find.byType(Switch).first).onChanged, isNull);
    expect(auth.updates.length, 1);
    auth.pending!.complete(
      auth.prefs.copyWith(inAppExpenseAddedEnabled: false),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch).first).value, false);
  });
  testWidgets('password validation preserves fields on API failure', (
    tester,
  ) async {
    final auth = _Auth()
      ..error = const ApiException('Incorrect current password');
    await _mount(tester, auth);
    final t = _t(tester);
    await _tap(tester, t.profileChangePassword);
    await _tap(tester, t.saveAction);
    expect(auth.profiles, isEmpty);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'old-secret');
    await tester.enterText(fields.at(1), 'new-secret');
    await tester.enterText(fields.at(2), 'new-secret');
    await _tap(tester, t.saveAction);
    expect(auth.profiles.single[#currentPassword], 'old-secret');
    expect(auth.profiles.single[#password], 'new-secret');
    expect(find.text('Incorrect current password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });
  testWidgets('logout cancellation and contact sheet do not submit feedback', (
    tester,
  ) async {
    final auth = _Auth();
    await _mount(tester, auth);
    final t = _t(tester);
    await _tap(tester, t.logOutButton);
    await tester.tap(find.text(t.cancelAction));
    await tester.pumpAndSettle();
    expect(auth.logoutCalls, 0);
    await _tap(tester, t.profileContactUs);
    expect(find.text(t.profileContactDescription), findsOneWidget);
    expect(find.text(t.profileAttachScreenshot), findsNothing);
    expect(find.text(t.profileSendAction), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(auth.feedbackCalls, 0);
    await _back(tester);
    expect(auth.feedbackCalls, 0);
  });
  testWidgets('theme and language selections update the actual app', (
    tester,
  ) async {
    await _mount(tester, _Auth());
    await _tap(tester, _t(tester).profileAppearance);
    await _tap(tester, _t(tester).themeModeDark);
    expect(
      Theme.of(tester.element(find.byType(ProfilePage))).brightness,
      Brightness.dark,
    );
    await _tap(tester, _t(tester).profileLanguage);
    await _tap(tester, _t(tester).languageLatvian);
    expect(
      Localizations.localeOf(
        tester.element(find.byType(ProfilePage)),
      ).languageCode,
      'lv',
    );
  });
  testWidgets(
    'payment sharing defaults off and only saves after confirmation',
    (tester) async {
      final auth = _Auth();
      await _mount(tester, auth);
      final t = _t(tester);
      await _tap(tester, 'Matiss Geinerts');
      await _tap(tester, t.profileEditPaymentMethod);
      final toggle = find.byKey(const ValueKey('profile-payment-sharing'));
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(auth.profiles, isEmpty);
      await _back(tester);
      expect(auth.profiles, isEmpty);
      await _tap(tester, t.profileEditPaymentMethod);
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      await _tap(tester, t.profileEditSaveDetails);
      expect(auth.profiles.single[#sharePaymentDetailsWithTrips], isTrue);
    },
  );

  testWidgets('previous payment sharing consent can be switched off', (
    tester,
  ) async {
    final auth = _Auth();
    auth.user = auth.user.copyWith(sharePaymentDetailsWithTrips: true);
    await _mount(tester, auth);
    final t = _t(tester);
    await _tap(tester, 'Matiss Geinerts');
    await _tap(tester, t.profileEditPaymentMethod);
    final toggle = find.byKey(const ValueKey('profile-payment-sharing'));
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    await _tap(tester, t.profileEditSaveDetails);
    expect(auth.profiles.single[#sharePaymentDetailsWithTrips], isFalse);
  });

  testWidgets(
    'payment methods preserve edits while switching and cancel without saving',
    (tester) async {
      final auth = _Auth();
      await _mount(tester, auth);
      final t = _t(tester);
      await _tap(tester, 'Matiss Geinerts');
      await _tap(tester, t.profileEditPaymentMethod);
      await tester.enterText(
        find.byType(TextField).first,
        'LV80BANK0000435195001',
      );
      await _tap(tester, t.profileEditBankTransferIbanSwift);
      await _tap(tester, t.profileEditRevolut);
      await _tap(tester, t.profileEditRevolut);
      await _tap(tester, t.profileEditBankTransferIbanSwift);
      expect(find.text('LV80BANK0000435195001'), findsOneWidget);
      await _back(tester);
      expect(auth.profiles, isEmpty);
    },
  );
  testWidgets(
    'contact address can be copied on a narrow screen with large text',
    (tester) async {
      await _mount(tester, _Auth(), width: 320, scale: 2, locale: 'lv');
      await _tap(tester, _t(tester).profileContactUs);
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
      final address = tester
          .widget<SelectableText>(find.byType(SelectableText))
          .data;
      expect(address, 'support@splyto.eu');
      await _tap(tester, _t(tester).copyAction);
      expect(copied, address);
      expect(find.text(_t(tester).paymentCopied), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  for (final result in ['opened', 'unavailable', 'error']) {
    testWidgets('contact email launch $result', (tester) async {
      final auth = _Auth();
      await _mount(tester, auth);
      final calls = <MethodCall>[];
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call);
        if (result == 'error') throw PlatformException(code: 'unavailable');
        return result == 'opened';
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      final t = _t(tester);
      await _tap(tester, t.profileContactUs);
      await _tap(tester, t.profileContactEmailAction);
      expect(calls.single.method, 'launch');
      expect(calls.single.arguments['url'], 'mailto:support@splyto.eu');
      expect(calls.single.arguments['useSafariVC'], false);
      expect(
        find.text(t.profileContactEmailUnavailable),
        result == 'opened' ? findsNothing : findsOneWidget,
      );
      expect(find.text('support@splyto.eu'), findsOneWidget);
      expect(auth.feedbackCalls, 0);
      expect(tester.takeException(), isNull);
    });
  }
  if (const bool.fromEnvironment('PROFILE_PREVIEWS')) {
    for (final dark in [false, true]) {
      testWidgets('profile review dark=$dark', (tester) async {
        final key = GlobalKey();
        final commands = ProfilePageCommandController();
        await _mount(
          tester,
          _Auth(),
          dark: dark,
          boundary: key,
          commands: commands,
        );
        final t = _t(tester);
        final prefix = dark ? 'dark' : 'light';
        await _capture(tester, key, '$prefix-profile');
        for (final item in [
          (t.profileAppearance, 'appearance'),
          (t.profileLanguage, 'language'),
          (t.profileAppBanners, 'in-app'),
          (t.profilePushNotificationsTitle, 'push'),
          (t.profileContactUs, 'feedback'),
          (t.profilePrivacyPolicy, 'privacy'),
        ]) {
          await _tap(tester, item.$1);
          await _capture(tester, key, '$prefix-${item.$2}');
          await _back(tester);
        }
        await _tap(tester, 'Matiss Geinerts');
        await _capture(tester, key, '$prefix-edit');
        await _tap(tester, t.profileEditPaymentMethod);
        await _capture(tester, key, '$prefix-payment');
        await _tap(tester, t.profileEditBankTransferIbanSwift);
        await _capture(tester, key, '$prefix-payment-methods');
        await _back(tester);
        await _back(tester);
        commands.requestCloseEditMode();
        await tester.pumpAndSettle();
        for (final item in [
          (t.profileChangePassword, 'password'),
          (t.profileAccountSettings, 'account'),
        ]) {
          await _tap(tester, item.$1);
          await _capture(tester, key, '$prefix-${item.$2}');
          commands.requestCloseEditMode();
          await tester.pumpAndSettle();
        }
      });
    }
  }
}
