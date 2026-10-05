import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/account_local_storage.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/features/friends/data/models/friend_user_model.dart';
import 'package:tripsplit/features/workspace/data/datasources/workspace_remote_data_source.dart';
import 'package:tripsplit/features/workspace/data/datasources/workspace_remote_parsers.dart';
import 'package:tripsplit/features/workspace/data/datasources/workspace_remote_snapshot_loader.dart';
import 'package:tripsplit/features/workspace/data/local/workspace_local_store.dart';
import 'package:tripsplit/features/workspace/data/local/workspace_snapshot_codec.dart';
import 'package:tripsplit/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:tripsplit/features/workspace/domain/entities/payment_details.dart';
import 'package:tripsplit/features/workspace/presentation/widgets/payment_request_details_sheet.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

const privateUser = <String, dynamic>{
  'id': 2,
  'nickname': 'Payee',
  'bank_account_holder': 'Private holder',
  'bank_iban': 'PRIVATE-IBAN',
  'bank_bic': 'PRIVATE-BIC',
  'revolut_handle': 'PRIVATE-REVOLUT',
  'revolut_me_link': 'PRIVATE-LINK',
  'paypal_me_link': 'PRIVATE-PAYPAL',
  'wise_pay_link': 'PRIVATE-WISE',
};

class _Api implements ApiClient {
  int calls = 0;
  bool fail = false;
  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    calls++;
    expect(path, contains('trip_payment_request_details'));
    expect(method, HttpMethod.post);
    expect(body, {'payment_id': 5});
    expect(headers?['X-Trip-Id'], '10');
    if (fail) throw const ApiException('Offline', isNetworkError: true);
    return {'ok': true, 'payment_details': privateUser};
  }

  @override
  Future<void> revokeCurrentSession() async {}
}

class _Remote implements WorkspaceRemoteDataSource {
  final pending = Completer<PaymentDetails>();
  @override
  Future<PaymentDetails> loadPaymentRequestDetails({
    required int tripId,
    required int paymentId,
  }) => pending.future;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('trip and friend parsers ignore legacy financial fields', () {
    expect(
      WorkspaceRemoteParsers.parseUser(privateUser).hasPaymentDetails,
      isFalse,
    );
    expect(
      FriendUserModel.fromLegacyMap(privateUser).hasPaymentDetails,
      isFalse,
    );
    final cached = WorkspaceSnapshotCodec.fromMap({
      'users': [privateUser],
    });
    expect(cached.users.single.hasPaymentDetails, isFalse);
    final serialized = WorkspaceSnapshotCodec.toMap(cached).toString();
    expect(serialized, isNot(contains('PRIVATE-')));
    expect(serialized, isNot(contains('bank_iban')));
  });

  test(
    'payment details use fresh authorized requests with no offline fallback',
    () async {
      final api = _Api();
      final loader = WorkspaceRemoteSnapshotLoader(api);
      expect(
        (await loader.loadPaymentRequestDetails(
          tripId: 10,
          paymentId: 5,
        )).bankIban,
        'PRIVATE-IBAN',
      );
      await loader.loadPaymentRequestDetails(tripId: 10, paymentId: 5);
      expect(api.calls, 2);
      api.fail = true;
      await expectLater(
        loader.loadPaymentRequestDetails(tripId: 10, paymentId: 5),
        throwsA(isA<ApiException>()),
      );
    },
  );

  test(
    'late details response is rejected after account change and never persisted',
    () async {
      SharedPreferences.setMockInitialValues({});
      final session = AccountDataSession()..activate(1);
      final remote = _Remote();
      final repository = WorkspaceRepositoryImpl(
        remote,
        WorkspaceLocalStore(AccountLocalStorage(session)),
      );
      final result = repository.loadPaymentRequestDetails(
        tripId: 10,
        paymentId: 5,
      );
      session.activate(3);
      remote.pending.complete(const PaymentDetails(bankIban: 'PRIVATE-IBAN'));
      await expectLater(
        result,
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'account_changed'),
        ),
      );
      expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
    },
  );

  testWidgets('details sheet shows loading, a safe error and fresh retry', (
    tester,
  ) async {
    var calls = 0;
    final pending = Completer<PaymentDetails>();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PaymentRequestDetailsSheet(
            load: () {
              calls++;
              return calls == 1
                  ? pending.future
                  : Future.value(
                      const PaymentDetails(bankIban: 'LV80BANK0000435195001'),
                    );
            },
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.completeError(
      const ApiException('Server internals must not be shown'),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Server internals'), findsNothing);
    expect(
      find.textContaining('Payment details are unavailable'),
      findsOneWidget,
    );
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.textContaining('LV80BANK0000435195001'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final locale in ['en', 'lv', 'es']) {
    testWidgets('details sheet fits a narrow screen in $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PaymentRequestDetailsSheet(
              load: () async => const PaymentDetails(
                bankAccountHolder:
                    'Long recipient name for a narrow mobile screen',
                bankIban: 'LV80BANK0000435195001',
                bankBic: 'HABALV22',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
