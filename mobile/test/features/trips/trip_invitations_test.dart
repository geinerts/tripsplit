import 'dart:async';
import 'package:tripsplit/features/trips/domain/entities/received_trip_invitation.dart';
import 'package:tripsplit/features/trips/data/repositories/trips_repository_impl.dart';
import 'package:tripsplit/features/trips/data/local/trips_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/account_local_storage.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/core/network/legacy_trip_image_uploader.dart';
import 'package:tripsplit/features/trips/data/datasources/trips_remote_data_source.dart';
import 'package:tripsplit/features/trips/presentation/widgets/trip_invitation_dialog.dart';
import 'package:tripsplit/features/trips/presentation/widgets/pending_trip_invitations.dart';
import 'package:tripsplit/features/trips/domain/entities/pending_trip_invitation.dart';
import 'package:tripsplit/features/workspace/data/datasources/workspace_remote_parsers.dart';
import 'package:tripsplit/features/workspace/data/local/workspace_local_store.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_notifications_inbox.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class _Uploader implements LegacyTripImageUploader {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Api implements ApiClient {
  String? path;
  Map<String, dynamic>? body;
  bool fail = false;

  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    this.path = path;
    this.body = body;
    if (path.contains('list_received_trip_invitations')) {
      expect(method, HttpMethod.get);
      expect(body, isNull);
      expect(headers, isNull);
      if (fail) throw const ApiException('Unavailable', statusCode: 409);
      return {
        'ok': true,
        'invitations': [
          {
            'id': 9,
            'trip_id': 10,
            'trip_name': 'Summer',
            'inviter_name': 'Anna',
            'invite_token': 'abcdefghij',
          },
        ],
      };
    }
    expect(method, HttpMethod.post);
    if (fail) throw const ApiException('Unavailable', statusCode: 409);
    return {
      'ok': true,
      'invite': {
        'invite_token': 'abcdefghij',
        'preview_nonce': 'fresh-nonce',
        'trip_id': 1,
        'trip_name': 'Trip',
        'already_member': false,
        'is_directed': true,
      },
    };
  }

  @override
  Future<void> revokeCurrentSession() async {}
}

class _IncomingRemote implements TripsRemoteDataSource {
  final pending = Completer<List<ReceivedTripInvitation>>();
  @override
  Future<List<ReceivedTripInvitation>> listReceivedInvitations() =>
      pending.future;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'received invitations use authenticated inbox without a target user or trip header',
    () async {
      final api = _Api();
      final remote = TripsRemoteDataSourceImpl(api, _Uploader());
      final invitations = await remote.listReceivedInvitations();
      expect(invitations.single.inviteToken, 'abcdefghij');
      expect(invitations.single.tripName, 'Summer');
      api.fail = true;
      await expectLater(
        remote.listReceivedInvitations(),
        throwsA(isA<ApiException>()),
      );
    },
  );

  test(
    'received invitation tokens are not persisted or delivered across accounts',
    () async {
      SharedPreferences.setMockInitialValues({});
      final session = AccountDataSession()..activate(1);
      final remote = _IncomingRemote();
      final repo = TripsRepositoryImpl(
        remote,
        TripsLocalStore(AccountLocalStorage(session)),
      );
      final result = repo.listReceivedInvitations();
      session.activate(2);
      remote.pending.complete([
        const ReceivedTripInvitation(
          id: 9,
          tripId: 10,
          tripName: 'Private',
          inviterName: 'Anna',
          inviteToken: 'private-token',
        ),
      ]);
      await expectLater(
        result,
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            'account_changed',
          ),
        ),
      );
      expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
    },
  );

  testWidgets(
    'pending management retries loading and revocation without losing state',
    (tester) async {
      var loadFailed = true;
      var revokeFailed = true;
      var revoked = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: AlertDialog(
              content: SizedBox(
                width: 430,
                child: SingleChildScrollView(
                  child: PendingTripInvitations(
                    load: () async {
                      if (loadFailed) throw const ApiException('Offline');
                      return revoked
                          ? []
                          : [
                              const PendingTripInvitation(
                                id: 9,
                                userId: 2,
                                name: 'Invited person',
                              ),
                            ];
                    },
                    revoke: (id) async {
                      expect(id, 9);
                      if (revokeFailed) throw const ApiException('Offline');
                      revoked = true;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Invitations unavailable. Retry'), findsOneWidget);
      loadFailed = false;
      await tester.tap(find.text('Invitations unavailable. Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Invited person'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Cancel invitation'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not cancel invitation. Try again.'),
        findsOneWidget,
      );
      expect(find.text('Invited person'), findsOneWidget);
      revokeFailed = false;
      await tester.tap(find.byTooltip('Cancel invitation'));
      await tester.pumpAndSettle();
      expect(find.text('Invited person'), findsNothing);
      expect(revoked, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'preview retains directed intent and decline calls only decline endpoint',
    () async {
      final api = _Api();
      final remote = TripsRemoteDataSourceImpl(api, _Uploader());
      final preview = await remote.previewTripInvite(inviteToken: 'abcdefghij');
      expect(preview.isDirected, isTrue);
      expect(preview.alreadyMember, isFalse);
      expect(preview.previewNonce, 'fresh-nonce');
      await remote.declineTripInvite(inviteToken: preview.inviteToken);
      expect(api.path, contains('action=decline_trip_invite'));
      expect(api.body, {'invite_token': 'abcdefghij'});
      api.fail = true;
      await expectLater(
        remote.declineTripInvite(inviteToken: 'abcdefghij'),
        throwsA(isA<ApiException>()),
      );
    },
  );

  test(
    'invitation notification survives cache roundtrip without crossing accounts',
    () async {
      SharedPreferences.setMockInitialValues({});
      final session = AccountDataSession(namespace: 'invitations')..activate(2);
      final store = WorkspaceLocalStore(AccountLocalStorage(session));
      final notification = WorkspaceRemoteParsers.parseNotification({
        'id': 1,
        'trip_id': 7,
        'type': 'trip_invitation',
        'payload': {'invite_token': 'abcdefghij'},
      });
      expect(notification.inviteToken, 'abcdefghij');
      await store.writeGlobalNotificationsInbox(
        WorkspaceNotificationsInbox(
          unreadCount: 1,
          notifications: [notification],
          hasMore: false,
          nextCursor: null,
        ),
      );
      expect(
        (await store.readGlobalNotificationsInbox())!
            .notifications
            .single
            .inviteToken,
        'abcdefghij',
      );
      session.activate(3);
      expect(await store.readGlobalNotificationsInbox(), isNull);
    },
  );

  for (final choice in ['Accept', 'Decline', 'Dismiss']) {
    testWidgets('invitation decision: $choice, large text on narrow screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      bool? decision;
      bool finished = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  decision = await showDialog<bool>(
                    context: context,
                    builder: (_) => const TripInvitationDialog(
                      message: 'Join a private trip with this person?',
                    ),
                  );
                  finished = true;
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (choice == 'Dismiss') {
        await tester.tapAt(const Offset(5, 5));
      } else {
        await tester.tap(find.text(choice));
      }
      await tester.pumpAndSettle();
      expect(finished, isTrue);
      expect(decision, choice == 'Dismiss' ? null : choice == 'Accept');
      expect(tester.takeException(), isNull);
    });
  }
}
