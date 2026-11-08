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

  test('malformed, expired and wrong-account payloads fail closed', () {
    for (final change in <String, Object?>{
      'schema_version': 0,
      'account_id': '7',
      'plan': 'pro',
      'source': 'Not A Source',
      'expires_at': '2026-09-23T12:00:00Z',
      'checked_at': '2026-02-30T12:00:00Z',
      'refresh_after_seconds': 301,
      'billing_enabled': 'yes',
      'limits_enforced': null,
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

  test('payloads from later servers are accepted', () {
    for (final change in <String, Object?>{
      'schema_version': 2,
      'source': 'purchase',
      'billing_enabled': true,
      'limits_enforced': true,
      'expires_at': null,
      'extra_field': 'ignored',
    }.entries) {
      final access = PremiumAccess.fromMap(
        premiumFixture()..[change.key] = change.value,
        accountId: 7,
      );
      expect(access?.isPremium, isTrue, reason: change.key);
    }
  });

  test('Premium for everyone offers features and hides the plan row', () {
    final launch = PremiumAccess.fromMap(
      premiumFixture()..addAll({
        'source': 'launch',
        'expires_at': null,
        'features': {'trip_export': true, 'year_summary': true},
      }),
      accountId: 7,
    )!;
    expect(launch.source, 'launch');
    expect(launch.expiresAt, isNull);
    expect(launch.allows(PremiumFeatures.tripExport), isTrue);
    expect(launch.allows(PremiumFeatures.yearSummary), isTrue);
    expect(launch.showsPlanStatus, isFalse);
    expect(
      PremiumAccess.fromMap(premiumFixture(), accountId: 7)!.showsPlanStatus,
      isTrue,
    );
    final free = premiumFixture()
      ..addAll({'plan': 'free', 'source': null, 'expires_at': null});
    expect(PremiumAccess.fromMap(free, accountId: 7)!.showsPlanStatus, isFalse);
    expect(
      PremiumAccess.fromMap(
        free..['billing_enabled'] = true,
        accountId: 7,
      )!.showsPlanStatus,
      isTrue,
    );
  });

  test('the server feature list decides each feature', () {
    final free = premiumFixture()
      ..addAll({
        'plan': 'free',
        'source': null,
        'expires_at': null,
        'features': {'trip_export': true, 'year_summary': false, 'x': 'yes'},
      });
    final access = PremiumAccess.fromMap(free, accountId: 7)!;
    expect(access.allows(PremiumFeatures.tripExport), isTrue);
    expect(access.allows(PremiumFeatures.yearSummary), isFalse);
    expect(access.allows('x'), isFalse);
    expect(access.allows('unlisted'), isFalse);
    // Without a feature list the app falls back to the plan and expiry.
    final older = PremiumAccess.fromMap(
      premiumFixture()..['expires_at'] = '2099-01-01T00:00:00Z',
      accountId: 7,
    )!;
    expect(older.allows(PremiumFeatures.tripExport), isTrue);
    final olderFree = premiumFixture()
      ..addAll({'plan': 'free', 'source': null, 'expires_at': null});
    expect(
      PremiumAccess.fromMap(
        olderFree,
        accountId: 7,
      )!.allows(PremiumFeatures.tripExport),
      isFalse,
    );
  });

  test('an expired grant offers no listed feature', () {
    final now = DateTime.now().toUtc();
    String stamp(DateTime value) =>
        '${value.toIso8601String().split('.').first}Z';
    final access = PremiumAccess.fromMap(
      premiumFixture()..addAll({
        'checked_at': stamp(now.subtract(const Duration(days: 2))),
        'expires_at': stamp(now.subtract(const Duration(days: 1))),
        'features': {'trip_export': true},
      }),
      accountId: 7,
    )!;
    expect(access.allows(PremiumFeatures.tripExport), isFalse);
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
