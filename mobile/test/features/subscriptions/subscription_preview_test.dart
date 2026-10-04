import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/core/auth/current_user_store.dart';
import 'package:tripsplit/features/auth/data/models/auth_user_model.dart';
import 'package:tripsplit/features/subscriptions/domain/entities/subscription_preview.dart';

Map<String, dynamic> fixture() =>
    jsonDecode(
          File(
            '../api/tests/Fixtures/subscription_preview_v1.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

Map<String, dynamic> userPayload() => {
  'id': 7,
  'nickname': 'Test',
  'subscription_preview': fixture(),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'server contract loads draft limits without granting a subscription',
    () {
      final preview = AuthUserModel.fromLegacyMap(
        userPayload(),
      ).subscriptionPreview!;
      expect(preview.accountId, 7);
      expect(preview.catalogVersion, '2026-09-draft-1');
      expect(preview.freeLimits.activeOwnedTrips, 1);
      expect(preview.freeLimits.currenciesPerTrip, 2);
      expect(preview.proLimits.activeOwnedTrips, isNull);
      expect(preview.proLimits.currenciesPerTrip, isNull);
    },
  );

  test('old servers without billing fields remain compatible', () {
    final user = AuthUserModel.fromLegacyMap({'id': 7, 'nickname': 'Test'});
    expect(user.id, 7);
    expect(user.subscriptionPreview, isNull);
  });

  test('wrong account cannot carry another account preview', () {
    final map = userPayload()..['id'] = 8;
    expect(AuthUserModel.fromLegacyMap(map).subscriptionPreview, isNull);
    expect(SubscriptionPreview.fromMap(fixture(), accountId: 0), isNull);
  });

  test('profile edits retain preview, account identity changes discard it', () {
    final user = AuthUserModel.fromLegacyMap(userPayload());
    expect(
      user.copyWith(nickname: 'Updated').subscriptionPreview,
      same(user.subscriptionPreview),
    );
    expect(
      user.copyWith(id: 7).subscriptionPreview,
      same(user.subscriptionPreview),
    );
    expect(user.copyWith(id: 8).subscriptionPreview, isNull);
  });

  test(
    'unsupported or enabled billing payloads are not treated as previews',
    () {
      for (final change in <String, Object?>{
        'schema_version': 2,
        'mode': 'live',
        'plan': 'pro',
        'billing_enabled': true,
        'limits_enforced': true,
        'account_id': '7',
        'catalog_version': '',
      }.entries) {
        final map = fixture()..[change.key] = change.value;
        expect(
          SubscriptionPreview.fromMap(map, accountId: 7),
          isNull,
          reason: change.key,
        );
      }
    },
  );

  test('every contract field is required rather than inferred', () {
    for (final key in fixture().keys) {
      final map = fixture()..remove(key);
      expect(
        SubscriptionPreview.fromMap(map, accountId: 7),
        isNull,
        reason: key,
      );
    }
  });

  test('invalid preview data does not prevent loading the profile', () {
    for (final invalid in [
      null,
      true,
      2,
      'pro',
      <Object>[],
      <String, dynamic>{},
    ]) {
      final map = userPayload()..['subscription_preview'] = invalid;
      final user = AuthUserModel.fromLegacyMap(map);
      expect(user.nickname, 'Test');
      expect(user.subscriptionPreview, isNull);
    }
  });

  test('missing or malformed limits never mean unlimited', () {
    for (final invalid in [-1, 0, 1.5, '2', true, <String, dynamic>{}]) {
      expect(
        SubscriptionPlanLimits.fromMap({
          'active_owned_trips': invalid,
          'currencies_per_trip': 2,
        }),
        isNull,
      );
      expect(
        SubscriptionPlanLimits.fromMap({
          'active_owned_trips': 1,
          'currencies_per_trip': invalid,
        }),
        isNull,
      );
    }
    expect(
      SubscriptionPlanLimits.fromMap({'active_owned_trips': null}),
      isNull,
    );
    expect(
      SubscriptionPlanLimits.fromMap({'currencies_per_trip': null}),
      isNull,
    );
  });

  test('preview must preserve unlimited current access', () {
    final map = fixture();
    (map['effective_limits'] as Map<String, dynamic>)['active_owned_trips'] = 1;
    expect(SubscriptionPreview.fromMap(map, accountId: 7), isNull);
  });

  test('billing preview is not persisted with the offline profile', () async {
    final store = CurrentUserStore();
    await store.write(AuthUserModel.fromLegacyMap(userPayload()));
    final prefs = await SharedPreferences.getInstance();
    final saved = jsonDecode(prefs.getString('trip_current_user_v1')!);
    expect(saved.containsKey('subscription_preview'), isFalse);
    final restored = await store.read();
    expect(restored!.id, 7);
    expect(restored.subscriptionPreview, isNull);
  });

  test('even a manually injected cached preview is ignored', () async {
    SharedPreferences.setMockInitialValues({
      'trip_current_user_v1': jsonEncode(userPayload()),
    });
    final restored = await CurrentUserStore().read();
    expect(restored!.nickname, 'Test');
    expect(restored.subscriptionPreview, isNull);
  });
}
