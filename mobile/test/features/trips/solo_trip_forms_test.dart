import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/features/auth/domain/entities/auth_user.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/friends/domain/entities/friends_snapshot.dart';
import 'package:tripsplit/features/friends/domain/entities/friend_user.dart';
import 'package:tripsplit/features/friends/presentation/controllers/friends_controller.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';
import 'package:tripsplit/features/trips/domain/entities/trip.dart';
import 'package:tripsplit/features/trips/presentation/controllers/trips_controller.dart';
import 'package:tripsplit/features/trips/presentation/pages/trips_page.dart';
import 'package:tripsplit/features/workspace/domain/entities/expense_split_value.dart';
import 'package:tripsplit/features/workspace/domain/entities/mutation_result.dart';
import 'package:tripsplit/features/workspace/domain/entities/queued_mutation.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_snapshot.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_user.dart';
import 'package:tripsplit/features/workspace/presentation/controllers/workspace_controller.dart';
import 'package:tripsplit/features/workspace/presentation/pages/workspace_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class _Auth implements AuthController {
  @override
  AuthUser? get currentUser => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Friends implements FriendsController {
  @override
  FriendsSnapshot? peekSnapshotCache({bool allowStale = false}) =>
      const FriendsSnapshot(
        friends: [FriendUser(id: 8, nickname: 'Test friend')],
        pendingReceived: [],
        pendingSent: [],
      );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Trips implements TripsController {
  @override
  List<Trip>? peekTripsCache({bool allowStale = false}) => [];
  @override
  Future<List<Trip>> loadTrips({bool forceRefresh = false}) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _snapshot = WorkspaceSnapshot(
  tripStatus: 'active',
  tripEndedAt: null,
  tripArchivedAt: null,
  users: [WorkspaceUser(id: 7, nickname: 'Owner', role: 'owner')],
  balances: [],
  settlements: [],
  payments: [],
  settlementTotal: 0,
  settlementConfirmed: 0,
  settlementRemaining: 0,
  allSettled: false,
  unreadNotifications: 0,
  notifications: [],
  expenses: [],
  orders: [],
);

class _Workspace implements WorkspaceController {
  List<int>? savedParticipants;
  String? savedMode;
  @override
  Future<WorkspaceSnapshot> loadSnapshot({required int tripId}) async =>
      _snapshot;
  @override
  Future<WorkspaceSnapshot?> readCachedSnapshot({required int tripId}) async =>
      null;
  @override
  Future<int> loadCurrentUserId() async => 7;
  @override
  Future<List<QueuedMutation>> listQueuedMutations({int? tripId}) async => [];
  @override
  Future<MutationResult> addExpense({
    required int tripId,
    required double amount,
    required String currencyCode,
    required String category,
    required String note,
    required String date,
    required List<int> participants,
    required String splitMode,
    required List<ExpenseSplitValue> splitValues,
    String? receiptPath,
  }) async {
    savedParticipants = participants;
    savedMode = splitMode;
    expect(splitValues, isEmpty);
    return const MutationResult(queued: false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, {String locale = 'en'}) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: home),
);

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final locale in ['en', 'lv', 'es']) {
    testWidgets('creation mode switches and clears group picks ($locale)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _app(
          TripsPage(
            controller: _Trips(),
            authController: _Auth(),
            friendsController: _Friends(),
            openCreateTripOnStart: true,
            showInlineHeader: false,
            showBottomNav: false,
          ),
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();
      final picker = find.byType(SegmentedButton<String>);
      expect(tester.widget<SegmentedButton<String>>(picker).selected, {
        'group',
      });
      await tester.ensureVisible(
        find.widgetWithText(FilterChip, 'Test friend'),
      );
      await tester.tap(find.widgetWithText(FilterChip, 'Test friend'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(InputChip, 'Test friend'), findsOneWidget);
      await tester.ensureVisible(picker);
      final soloLabel = {
        'en': 'Just me',
        'lv': 'Tikai es',
        'es': 'Solo yo',
      }[locale]!;
      await tester.tap(find.text(soloLabel));
      await tester.pumpAndSettle();
      expect(tester.widget<SegmentedButton<String>>(picker).selected, {'solo'});
      expect(find.byType(FilterChip), findsNothing);
      expect(find.byType(InputChip), findsNothing);
      final groupLabel = {
        'en': 'With others',
        'lv': 'Ar citiem',
        'es': 'Con otros',
      }[locale]!;
      await tester.tap(find.text(groupLabel));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(InputChip, 'Test friend'), findsNothing);
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Test friend'))
            .selected,
        isFalse,
      );
      expect(tester.takeException(), isNull);
      await _dispose(tester);
    });
  }

  for (final mode in ['solo', 'group']) {
    for (final width in [360.0, 800.0]) {
      testWidgets(
        '$mode expense form at width $width keeps correct fields and submission',
        (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final workspace = _Workspace();
          final trip = TripModel.fromLegacyMap({
            'id': 1,
            'name': 'Test trip',
            'trip_mode': mode,
            'created_by': 7,
            'current_user_role': 'owner',
            'members_count': 1,
          });
          await tester.pumpWidget(
            _app(
              WorkspacePage(
                trip: trip,
                workspaceController: workspace,
                tripsController: _Trips(),
                friendsController: _Friends(),
                authController: _Auth(),
                openAddExpenseOnStart: true,
                showAppBar: false,
                showBottomNav: false,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.text('Participants (empty = all members)'),
            mode == 'solo' ? findsNothing : findsOneWidget,
          );
          expect(
            find.text('Split mode'),
            mode == 'solo' ? findsNothing : findsOneWidget,
          );
          expect(find.text('Note'), findsOneWidget);
          expect(find.text('Choose receipt file'), findsOneWidget);
          if (mode == 'solo') {
            await tester.enterText(find.byType(TextField).first, '12.34');
            await tester.ensureVisible(find.text('Other'));
            await tester.tap(find.text('Other'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Food').last);
            await tester.pumpAndSettle();
            await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
            await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 1));
            await tester.pumpAndSettle();
            expect(workspace.savedParticipants, [7]);
            expect(workspace.savedMode, 'equal');
          }
          expect(tester.takeException(), isNull);
          await _dispose(tester);
        },
      );
    }
  }
}
