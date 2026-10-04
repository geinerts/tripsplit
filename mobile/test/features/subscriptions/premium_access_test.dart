import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/core/auth/current_user_store.dart';
import 'package:tripsplit/features/auth/data/models/auth_user_model.dart';
import 'package:tripsplit/features/subscriptions/domain/entities/premium_access.dart';
import 'package:tripsplit/features/subscriptions/presentation/widgets/premium_status_tile.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

Map<String, dynamic> premiumFixture() => {
  'schema_version': 1,
  'account_id': 7,
  'plan': 'premium',
  'source': 'admin_grant',
  'expires_at': '2026-10-23T12:00:00Z',
  'checked_at': '2026-09-23T12:00:00Z',
  'refresh_after_seconds': 300,
  'billing_enabled': false,
  'limits_enforced': false,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('server grant loads for its owner and survives profile edits only', () {
    final user = AuthUserModel.fromLegacyMap({
      'id': 7,
      'nickname': 'Test',
      'premium_access': premiumFixture(),
    });
    expect(user.premiumAccess!.isPremium, isTrue);
    expect(
      user.copyWith(nickname: 'New').premiumAccess,
      same(user.premiumAccess),
    );
    expect(user.copyWith(id: 8).premiumAccess, isNull);
    expect(PremiumAccess.fromMap(premiumFixture(), accountId: 8), isNull);
  });

  test('malformed, expired, paid and wrong-account payloads fail closed', () {
    for (final change in <String, Object?>{
      'schema_version': 2,
      'account_id': '7',
      'plan': 'pro',
      'source': 'sandbox',
      'expires_at': '2026-09-23T12:00:00Z',
      'checked_at': '2026-02-30T12:00:00Z',
      'refresh_after_seconds': 301,
      'billing_enabled': true,
      'limits_enforced': true,
    }.entries) {
      expect(
        PremiumAccess.fromMap(
          premiumFixture()..[change.key] = change.value,
          accountId: 7,
        ),
        isNull,
        reason: change.key,
      );
    }
    final free = premiumFixture()
      ..addAll({'plan': 'free', 'source': null, 'expires_at': null});
    expect(PremiumAccess.fromMap(free, accountId: 7)!.isPremium, isFalse);
  });

  test('a cached grant is never restored or persisted as access', () async {
    SharedPreferences.setMockInitialValues({
      'trip_current_user_v1': jsonEncode({
        'id': 7,
        'nickname': 'Test',
        'premium_access': premiumFixture(),
      }),
    });
    final store = CurrentUserStore();
    expect((await store.read())!.premiumAccess, isNull);
    await store.write(
      AuthUserModel.fromLegacyMap({
        'id': 7,
        'nickname': 'Test',
        'premium_access': premiumFixture(),
      }),
    );
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('trip_current_user_v1'),
      isNot(contains('premium_access')),
    );
  });

  test(
    'expiry/freshness are bounded by server time, not device wall clock',
    () async {
      final short = premiumFixture()..['expires_at'] = '2026-09-23T12:00:01Z';
      final access = PremiumAccess.fromMap(short, accountId: 7)!;
      expect(access.isPremium, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      expect(access.isFresh, isFalse);
      expect(access.isPremium, isFalse);
    },
  );

  for (final locale in ['en', 'lv', 'es']) {
    for (final brightness in Brightness.values) {
      testWidgets('status fits narrow profile in $locale $brightness', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var refreshed = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: PremiumStatusTile(
                  access: PremiumAccess.fromMap(premiumFixture(), accountId: 7),
                  onRefresh: () => refreshed = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Premium'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byIcon(Icons.refresh));
        expect(refreshed, isTrue);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
