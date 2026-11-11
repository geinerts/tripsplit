import 'package:tripsplit/features/live_location/presentation/live_location_controller.dart';
import 'package:tripsplit/features/live_location/domain/live_location.dart';
import 'package:tripsplit/features/workspace/data/datasources/workspace_remote_parsers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tripsplit/features/workspace/domain/entities/payment_details.dart';
import 'package:tripsplit/features/workspace/domain/entities/receipt_upload_payload.dart';
import 'package:tripsplit/features/workspace/domain/entities/uploaded_receipt.dart';
import 'package:tripsplit/core/ui/user_profile_payment_section.dart';
import 'package:tripsplit/features/trips/domain/entities/trip.dart';
import 'package:tripsplit/features/trips/domain/entities/uploaded_trip_image.dart';
import 'package:tripsplit/features/trips/presentation/widgets/trip_form_page.dart';
import 'package:tripsplit/core/ui/app_components.dart';
import 'package:tripsplit/features/trips/domain/entities/trip_invite_link.dart';
import 'package:tripsplit/features/trips/domain/entities/pending_trip_invitation.dart';
import 'package:tripsplit/features/friends/domain/entities/friends_snapshot.dart';
import 'package:tripsplit/features/friends/domain/entities/friend_user.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/ui/app_person_toggle.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/ui/app_skeleton.dart';
import 'package:tripsplit/core/ui/app_bottom_nav_bar.dart';
import 'package:tripsplit/core/ui/user_profile_page.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_shared_trip.dart';
import 'package:tripsplit/features/auth/domain/entities/auth_user.dart';
import 'package:tripsplit/features/subscriptions/domain/entities/premium_access.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/friends/presentation/controllers/friends_controller.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';
import 'package:tripsplit/features/trips/presentation/controllers/trips_controller.dart';
import 'package:tripsplit/features/workspace/domain/entities/balance_item.dart';
import 'package:tripsplit/features/workspace/domain/entities/settlement_item.dart';
import 'package:tripsplit/features/workspace/domain/entities/payment_item.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_activity_event.dart';
import 'package:tripsplit/features/workspace/domain/entities/expense_comment.dart';
import 'package:tripsplit/features/workspace/domain/entities/expense_comment_reaction.dart';
import 'package:tripsplit/features/workspace/domain/entities/expense_item.dart';
import 'package:tripsplit/features/workspace/domain/entities/expense_split_value.dart';
import 'package:tripsplit/features/workspace/domain/entities/mutation_result.dart';
import 'package:tripsplit/features/workspace/domain/entities/expense_reaction.dart';
import 'package:tripsplit/features/workspace/domain/entities/queued_mutation.dart';
import 'package:tripsplit/features/workspace/domain/entities/trip_expense.dart';
import 'package:tripsplit/features/workspace/domain/entities/trip_expenses_page.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_snapshot.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_user.dart';
import 'package:tripsplit/features/workspace/presentation/controllers/workspace_controller.dart';
import 'package:tripsplit/features/workspace/presentation/pages/workspace_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';
import 'package:tripsplit/core/media/image_crop.dart';
import 'package:tripsplit/core/media/image_crop_service.dart';

class _LiveLocation extends ChangeNotifier implements LiveLocationController {
  bool isSharing = false;
  void startSharing() {
    isSharing = true;
    notifyListeners();
  }

  @override
  LiveShareSession? sharing(int trip) =>
      isSharing ? LiveShareSession('test-only', DateTime(2030)) : null;
  @override
  bool stopping(int trip) => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Auth implements AuthController {
  _Auth({this.revtag, this.premiumAccess});
  final String? revtag;
  final PremiumAccess? premiumAccess;
  @override
  AuthUser? get currentUser => AuthUser(
    id: 7,
    nickname: 'Matiss',
    needsCredentials: false,
    revolutHandle: revtag,
    premiumAccess: premiumAccess,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Trips implements TripsController {
  @override
  ImageCropService? imageCropService;

  Uint8List? uploadedBytes;
  String? savedPath;
  bool failUpdate = false;
  bool failShare = false;
  int shareCalls = 0;
  @override
  Future<UploadedTripImageData> uploadTripImage({
    required int tripId,
    required String fileName,
    required Uint8List bytes,
    ImageCropSourceUpload? cropSource,
  }) async {
    uploadedBytes = bytes;
    return const UploadedTripImageData(path: 'uploads/trips/cropped.webp');
  }

  @override
  Future<Trip> updateTrip({
    required int tripId,
    required String name,
    String? imagePath,
    bool removeImage = false,
    int? budgetCents,
    List<Map<String, dynamic>>? destinations,
    bool clearBudget = false,
  }) async {
    if (failUpdate) throw const ApiException('Could not save trip');
    savedPath = removeImage ? null : imagePath;
    return TripModel.fromLegacyMap({
      'id': tripId,
      'name': name,
      'status': 'active',
      'currency_code': 'EUR',
      'created_by': 7,
      'current_user_role': 'owner',
      'image_url': savedPath == null
          ? null
          : 'https://example.test/cropped.webp',
    });
  }

  @override
  Future<TripInviteLink> createTripInviteLink({required int tripId}) async {
    shareCalls++;
    if (failShare) throw const ApiException('Offline', isNetworkError: true);
    return const TripInviteLink(
      tripId: 1,
      inviteUrl: 'https://splyto.app/?invite=lisbon-abcdefghij',
      inviteToken: 'abcdefghij',
      expiresAt: '2026-11-01 12:00:00',
      expiresInSeconds: 86400,
    );
  }

  @override
  Future<List<PendingTripInvitation>> listPendingInvitations({
    required int tripId,
  }) async => [
    const PendingTripInvitation(id: 21, userId: 9, name: 'Daniel Reed'),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Friends implements FriendsController {
  @override
  FriendsSnapshot? peekSnapshotCache({bool allowStale = false}) =>
      const FriendsSnapshot(
        friends: [
          FriendUser(id: 8, nickname: 'Anna'),
          FriendUser(id: 10, nickname: 'Laura'),
        ],
        pendingReceived: [],
        pendingSent: [],
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TripExpense expense(
  int id, {
  String? name,
  int payer = 7,
  String currency = 'EUR',
  String category = 'food',
  String splitMode = 'equal',
  String? receiptUrl,
  String date = '2026-10-21',
}) => TripExpense(
  id: id,
  amount: 24,
  originalAmount: currency == 'EUR' ? 24 : 30,
  tripCurrencyCode: 'EUR',
  expenseCurrencyCode: currency,
  fxRateToTrip: .8,
  category: category,
  note: name ?? 'Breakfast $id',
  expenseDate: date,
  splitMode: splitMode,
  paidById: payer,
  paidByNickname: payer == 7 ? 'Matiss' : 'Anna',
  receiptUrl: receiptUrl,
  participants: [],
);
WorkspaceSnapshot snapshot({
  List<TripExpense>? expenses,
  String status = 'active',
  bool solo = false,
  bool preview = false,
}) => WorkspaceSnapshot(
  tripStatus: status,
  tripEndedAt: null,
  tripArchivedAt: null,
  users: [
    const WorkspaceUser(id: 7, nickname: 'Matiss', role: 'owner'),
    if (!solo) const WorkspaceUser(id: 8, nickname: 'Anna'),
    if (!solo) ..._testGuests,
  ],
  balances: preview
      ? [
          BalanceItem(
            id: 7,
            nickname: 'Matiss',
            paid: expenses?.isEmpty == true ? 0 : (solo ? 48 : 24),
            owed: expenses?.isEmpty == true ? 0 : 48,
            net: expenses?.isEmpty == true || solo ? 0 : -24,
          ),
          if (!solo)
            BalanceItem(
              id: 8,
              nickname: 'Anna',
              paid: expenses?.isEmpty == true ? 0 : 72,
              owed: expenses?.isEmpty == true ? 0 : 48,
              net: expenses?.isEmpty == true ? 0 : 24,
            ),
        ]
      : [
          const BalanceItem(
            id: 7,
            nickname: 'Matiss',
            paid: 600,
            owed: 400,
            net: 200,
          ),
          if (!solo)
            const BalanceItem(
              id: 8,
              nickname: 'Anna',
              paid: 400,
              owed: 600,
              net: -200,
            ),
        ],
  settlements: [],
  payments: [],
  settlementTotal: 0,
  settlementConfirmed: 0,
  settlementRemaining: 0,
  allSettled: true,
  unreadNotifications: 0,
  notifications: [],
  expenses: expenses ?? [expense(1), expense(2, name: 'Dinner', payer: 8)],
  orders: [],
);

var _testGuests = const <WorkspaceUser>[];

class _Workspace implements WorkspaceController {
  final addedGuests = <String>[];
  @override
  Future<void> addTripGuest({required int tripId, required String name}) async {
    addedGuests.add(name);
  }

  int? savedPaidBy;
  bool memberDetailsShared = false;
  ApiException? memberDetailsError;
  int memberDetailsCalls = 0;
  @override
  Future<PaymentDetails> loadMemberPaymentDetails({
    required int tripId,
    required int userId,
  }) async {
    memberDetailsCalls++;
    if (memberDetailsError != null) throw memberDetailsError!;
    if (!memberDetailsShared) {
      throw const ApiException('Not shared', statusCode: 404);
    }
    return const PaymentDetails(revolutHandle: '@annarevtag');
  }

  final endedTrips = <int>[];
  final readinessCalls = <bool>[];
  @override
  Future<void> setReadyToSettle({
    required int tripId,
    required bool isReady,
  }) async {
    readinessCalls.add(isReady);
    data = data.copyWith(
      users: [
        for (final u in data.users)
          WorkspaceUser(
            id: u.id,
            nickname: u.nickname,
            isReadyToSettle: u.id == 7 ? isReady : u.isReadyToSettle,
          ),
      ],
    );
  }

  Object? endError;
  List<QueuedMutation> queued = [];
  @override
  Future<void> endTrip({required int tripId}) async {
    endedTrips.add(tripId);
    if (endError != null) throw endError!;
    data = data.copyWith(tripStatus: 'archived');
  }

  WorkspaceSnapshot data = snapshot();
  WorkspaceSnapshot? cache;
  Object? error;
  Completer<WorkspaceSnapshot>? pending;
  Completer<TripExpensesPage>? pendingPage;
  int cacheReads = 0;
  int pageCalls = 0;
  bool more = false;
  Object? activityError;
  Completer<WorkspaceActivityPage>? activityGate;
  List<WorkspaceActivityEvent> activity = [activityEvent(1)];
  bool moreActivity = false;
  final activityOffsets = <int>[];
  @override
  Future<WorkspaceActivityPage> loadTripActivity({
    required int tripId,
    int limit = 50,
    int? offset,
  }) async {
    activityOffsets.add(offset ?? 0);
    if (activityGate != null) return activityGate!.future;
    if (activityError != null) throw activityError!;
    return WorkspaceActivityPage(
      items: offset == 0 ? activity : [activityEvent(1), activityEvent(2)],
      hasMore: moreActivity && offset == 0,
      nextOffset: 1,
    );
  }

  bool pageFailure = false;
  bool commentsFailure = false;
  List<ExpenseComment> comments = [];
  final commentReactionCalls = <(int, int, int, String)>[];
  final commentEditCalls = <(int, int, int, String)>[];
  final commentReplyCalls = <(int, int, int?, String)>[];
  final commentMentionCalls = <List<int>>[];
  final commentDeleteCalls = <(int, int, int)>[];
  final paymentCalls = <(int, int, double, String)>[];
  final sentCalls = <(int, int)>[];
  @override
  Future<void> markSettlementSent({
    required int tripId,
    required int settlementId,
  }) async {
    sentCalls.add((tripId, settlementId));
    data = data.copyWith(settlements: [settlement('sent', permitted: false)]);
  }

  @override
  Future<void> createTripPayment({
    required int tripId,
    required int toUserId,
    required double amount,
    String note = '',
  }) async {
    paymentCalls.add((tripId, toUserId, amount, note));
  }

  @override
  Future<void> toggleExpenseCommentReaction({
    required int commentId,
    required int expenseId,
    required int tripId,
    required String emoji,
  }) async {
    commentReactionCalls.add((tripId, expenseId, commentId, emoji));
  }

  @override
  Future<ExpenseComment> updateExpenseComment({
    required int commentId,
    required int expenseId,
    required int tripId,
    required String body,
    List<int> mentionedUserIds = const <int>[],
  }) async {
    commentEditCalls.add((tripId, expenseId, commentId, body));
    commentMentionCalls.add(mentionedUserIds);
    final updated = ExpenseComment(
      id: commentId,
      userId: 7,
      userNickname: 'Matiss',
      body: body,
      createdAt: '2026-10-22',
    );
    comments = [updated];
    return updated;
  }

  @override
  Future<ExpenseComment> addExpenseComment({
    required int expenseId,
    required int tripId,
    required String body,
    int? parentCommentId,
    List<int> mentionedUserIds = const <int>[],
  }) async {
    commentReplyCalls.add((tripId, expenseId, parentCommentId, body));
    commentMentionCalls.add(mentionedUserIds);
    final added = ExpenseComment(
      id: 12,
      userId: 7,
      userNickname: 'Matiss',
      body: body,
      createdAt: '2026-10-22',
      parentCommentId: parentCommentId,
    );
    comments = [...comments, added];
    return added;
  }

  @override
  Future<void> deleteExpenseComment({
    required int commentId,
    required int expenseId,
    required int tripId,
  }) async {
    commentDeleteCalls.add((tripId, expenseId, commentId));
    comments = comments.where((c) => c.id != commentId).toList();
  }

  final receiptCalls = <(int, int)>[];
  @override
  Future<Uri?> loadReceiptUri({
    required int tripId,
    required int expenseId,
  }) async {
    receiptCalls.add((tripId, expenseId));
    return null;
  }

  int deletes = 0;
  final reactionCalls = <(int, int, String)>[];
  @override
  Future<MutationResult> deleteExpense({
    required int tripId,
    required int expenseId,
  }) async {
    deletes++;
    return const MutationResult(queued: false);
  }

  @override
  Future<void> toggleExpenseReaction({
    required int tripId,
    required int expenseId,
    required String emoji,
  }) async {
    reactionCalls.add((tripId, expenseId, emoji));
  }

  final receiptUploads = <ReceiptUploadPayload>[];
  @override
  Future<UploadedReceiptData> uploadReceipt({
    required ReceiptUploadPayload payload,
  }) async {
    receiptUploads.add(payload);
    return const UploadedReceiptData(path: 'receipts/test.jpg');
  }

  int saves = 0;
  int edits = 0;
  bool? editedReceiptRemoved;
  bool saveFailure = false;
  Completer<void>? saveGate;
  List<int>? savedParticipants;
  List<ExpenseSplitValue>? savedSplits;
  List<ExpenseItem>? savedItems;
  double? savedExtra;
  double? savedAmount;
  String? savedMode;
  String? savedCategory;
  String? savedCurrency;
  String? savedReceiptPath;
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
    List<ExpenseItem> items = const [],
    double extraAmount = 0,
    int? paidBy,
    String? receiptPath,
  }) async {
    saves++;
    savedParticipants = participants;
    savedSplits = splitValues;
    savedItems = items;
    savedExtra = extraAmount;
    savedPaidBy = paidBy;
    savedAmount = amount;
    savedCategory = category;
    savedMode = splitMode;
    savedCurrency = currencyCode;
    savedReceiptPath = receiptPath;
    if (saveGate != null) await saveGate!.future;
    if (saveFailure) throw const ApiException('Save failed');
    return const MutationResult(queued: true);
  }

  @override
  Future<MutationResult> updateExpense({
    required int tripId,
    required int expenseId,
    required double amount,
    required String currencyCode,
    required String category,
    required String note,
    required String date,
    required List<int> participants,
    required String splitMode,
    required List<ExpenseSplitValue> splitValues,
    List<ExpenseItem> items = const [],
    double extraAmount = 0,
    int? paidBy,
    String? receiptPath,
    bool removeReceipt = false,
  }) async {
    edits++;
    editedReceiptRemoved = removeReceipt;
    return const MutationResult(queued: true);
  }

  @override
  Future<List<ExpenseCommentReaction>> listExpenseCommentReactions({
    required int expenseId,
    required int tripId,
  }) async {
    if (commentsFailure) throw const ApiException('Comments failed');
    return [];
  }

  @override
  Future<WorkspaceSnapshot> refreshSnapshotFromServer({
    required int tripId,
  }) async {
    if (pending != null) return pending!.future;
    if (error != null) throw error!;
    return data;
  }

  @override
  Future<WorkspaceSnapshot?> readCachedSnapshot({required int tripId}) async {
    cacheReads++;
    return cache;
  }

  @override
  Future<int> loadCurrentUserId() async => 7;
  @override
  Future<List<WorkspaceSharedTrip>> loadSharedTripsWithUser({
    required int userId,
    int limit = 20,
  }) async => [];

  @override
  Future<List<QueuedMutation>> listQueuedMutations({int? tripId}) async =>
      queued;
  @override
  Future<TripExpensesPage> loadExpensesPage({
    required int tripId,
    int limit = 50,
    String? cursor,
    int? offset,
  }) async {
    pageCalls++;
    if (pendingPage != null) return pendingPage!.future;
    if (pageFailure) throw const ApiException('Page failed');
    return TripExpensesPage(
      items: cursor == null
          ? data.expenses
          : [expense(2), expense(3, name: 'Train')],
      hasMore: more && cursor == null,
      nextCursor: more && cursor == null ? 'page2' : null,
      nextOffset: null,
    );
  }

  @override
  Future<List<ExpenseReaction>> listExpenseReactions({
    required int expenseId,
    required int tripId,
  }) async => [];
  @override
  Future<List<ExpenseComment>> listExpenseComments({
    required int expenseId,
    required int tripId,
  }) async => comments;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> showInFilterMenu(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    120,
    scrollable: find
        .descendant(
          of: find.byKey(const ValueKey('expense-filters-menu')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> _mount(
  WidgetTester tester,
  _Workspace controller, {
  bool solo = false,
  bool openAddExpenseOnStart = false,
  LiveLocationController? liveLocation,
  bool manager = false,
  String? role,
  String? coverUrl,
  _Trips? trips,
  AuthController? auth,
  ValueChanged<Trip>? onTripUpdated,
  bool dark = false,
  String locale = 'en',
  double scale = 1,
  double width = 390,
  double height = 844,
  WorkspacePageCommandController? commands,
  GlobalKey? boundary,
  Map<String, bool>? premiumFeatures,
  Future<void> Function()? onExportTripRequested,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  if (boundary != null) {
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 20);
    addTearDown(tester.view.resetPadding);
  }
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
      child: child!,
    ),
    home: Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) => Text(
            'Lisbon getaway',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        leading: boundary == null ? null : const Icon(Icons.chevron_left),
        actions: boundary == null
            ? null
            : const [
                Icon(Icons.more_horiz),
                SizedBox(width: 16),
                Icon(Icons.notifications_none),
                SizedBox(width: 20),
              ],
      ),
      bottomNavigationBar: boundary == null
          ? null
          : AppBottomNavBar(
              selectedItem: null,
              onSelected: (_) {},
              avatarLetter: 'M',
            ),
      body: WorkspacePage(
        openAddExpenseOnStart: openAddExpenseOnStart,
        trip: TripModel.fromLegacyMap({
          'id': 1,
          'name': 'Lisbon getaway',
          'image_url': coverUrl,
          'trip_mode': solo ? 'solo' : 'group',
          'members_count': solo ? 1 : 2,
          if (manager) 'created_by': 7,
          'current_user_role': role ?? (manager ? 'owner' : 'member'),
          'currency_code': 'EUR',
          'date_from': '2026-10-05',
          'date_to': '2026-10-09',
          'premium_features': ?premiumFeatures,
        }),
        workspaceController: controller,
        liveLocationController: liveLocation,
        onExportTripRequested: onExportTripRequested,
        authController: auth ?? _Auth(),
        tripsController: trips ?? _Trips(),
        onTripUpdated: onTripUpdated,
        friendsController: _Friends(),
        commandController: commands,
        showAppBar: false,
        showBottomNav: false,
      ),
    ),
  );
  await tester.pumpWidget(
    boundary == null ? app : RepaintBoundary(key: boundary, child: app),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<Uint8List> _receiptPreviewFixture() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 240, 340),
    Paint()..color = Colors.white,
  );
  var y = 24.0;
  for (final line in [
    'CAFE LISBOA',
    '23 OCT 2026',
    '--------------------',
    'Lunch        35.00',
    'Coffee        7.50',
    '--------------------',
    'TOTAL    EUR 42.50',
    '',
    'Thank you!',
  ]) {
    final painter = TextPainter(
      text: TextSpan(
        text: line,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 210);
    painter.paint(canvas, Offset(15, y));
    painter.dispose();
    y += 30;
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(240, 340);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return data!.buffer.asUint8List();
}

Future<void> expandFirstSettlement(WidgetTester tester) async {
  final card = find
      .byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key as ValueKey<String>).value.startsWith('settlement-card-'),
      )
      .first;
  await tester.scrollUntilVisible(
    card,
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pumpAndSettle();
}

Future<void> disposePage(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

WorkspaceActivityEvent activityEvent(int id) => WorkspaceActivityEvent(
  id: id,
  tripId: 1,
  actorUserId: 7,
  actorName: 'Matiss',
  eventType: id == 1 ? 'expense.created' : 'expense.deleted',
  payload: {
    'amount_cents': 2400,
    'note': 'Breakfast',
    'category': 'food',
    'trip_currency_code': 'EUR',
  },
  createdAt: '2026-10-21 10:30:00',
);

SettlementItem settlement(String status, {bool permitted = true}) =>
    SettlementItem(
      id: status == 'suggested' ? null : 1,
      fromUserId: 7,
      toUserId: 8,
      from: 'Matiss',
      to: 'Anna',
      amount: 24,
      status: status,
      createdAt: '2026-10-21',
      markedSentAt: status == 'sent' || status == 'confirmed'
          ? '2026-10-21'
          : null,
      confirmedAt: status == 'confirmed' ? '2026-10-21' : null,
      canMarkSent: permitted && status == 'pending',
      canConfirmReceived: permitted && status == 'sent',
      canCancelSent: false,
      canReportNotReceived: false,
      isConfirmed: status == 'confirmed',
    );

PaymentItem payment(String status) => PaymentItem(
  id: 1,
  fromUserId: 7,
  toUserId: 8,
  from: 'Matiss',
  to: 'Anna',
  amount: 12,
  status: status,
  note: 'Part payment',
  requesterUserId: 8,
  requestedAt: null,
  createdAt: null,
  markedSentAt: null,
  confirmedAt: null,
  cancelledAt: null,
  cancelReason: null,
  canMarkRequestSent: status == 'requested',
  canCancelRequest: false,
  canDeclineRequest: status == 'requested',
  canConfirmReceived: status == 'sent',
  canCancelSent: false,
  canReportNotReceived: false,
  isConfirmed: status == 'confirmed',
);

Future<void> _selectTab(WidgetTester tester, String label) async {
  final tab = find.byTooltip(label);
  await tester.ensureVisible(tab);
  await tester.pumpAndSettle();
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

Future<void> selectExpenseFood(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const ValueKey('expense-category')));
  await tester.tap(find.byKey(const ValueKey('expense-category')));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('expense-category-picker')),
      matching: find.text('Food'),
    ),
  );
  await tester.pumpAndSettle();
}

/// Opens the split method list and picks the method with this label.
Future<void> pickSplitMode(WidgetTester tester, String label) async {
  await visibleTap(tester, find.byKey(const ValueKey('expense-split-method')));
  await tester.tap(find.widgetWithText(ListTile, label).last);
  await tester.pumpAndSettle();
}

Future<void> visibleTap(
  WidgetTester tester,
  Finder finder, {
  bool settle = true,
}) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  testWidgets(
    'icon tabs expose labels, update heading and load activity once',
    (tester) async {
      final controller = _Workspace();
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      final title = find.byKey(const ValueKey('workspace-section-title'));
      expect(tester.widget<Text>(title).data, 'Expenses');
      expect(controller.activityOffsets, isEmpty);
      for (final label in [
        'Balances',
        'Settle',
        'Activity',
        'Expenses',
        'Activity',
      ]) {
        await _selectTab(tester, label);
        expect(tester.widget<Text>(title).data, label);
        expect(tester.takeException(), isNull);
      }
      expect(controller.activityOffsets, [0]);
      await disposePage(tester);
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'live map overlays cover and retains sharing status at scale $scale',
      (tester) async {
        final live = _LiveLocation();
        await _mount(
          tester,
          _Workspace(),
          liveLocation: live,
          width: 320,
          scale: scale,
        );
        await tester.pumpAndSettle();
        final button = find.byKey(const ValueKey('trip-live-map'));
        expect(button, findsOneWidget);
        final cover = find
            .ancestor(of: button, matching: find.byType(AspectRatio))
            .first;
        final coverRect = tester.getRect(cover);
        final buttonRect = tester.getRect(button);
        expect(buttonRect.right, closeTo(coverRect.right - 12, .1));
        expect(buttonRect.bottom, closeTo(coverRect.bottom - 12, .1));
        final t = AppLocalizations.of(tester.element(button))!;
        live.startSharing();
        await tester.pumpAndSettle();
        expect(
          find.text('${t.liveMapTitle} · ${t.liveSharing}'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await disposePage(tester);
        live.dispose();
      },
    );
  }

  testWidgets('solo trips do not show live map or section tabs', (
    tester,
  ) async {
    final live = _LiveLocation();
    await _mount(tester, _Workspace(), solo: true, liveLocation: live);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('trip-live-map')), findsNothing);
    expect(find.byKey(const ValueKey('workspace-tab-0')), findsNothing);
    await disposePage(tester);
    live.dispose();
  });

  testWidgets(
    'readiness card toggles only self and updates finish eligibility',
    (tester) async {
      final controller = _Workspace()
        ..data = snapshot().copyWith(
          users: const [
            WorkspaceUser(id: 7, nickname: 'Matiss'),
            WorkspaceUser(id: 8, nickname: 'Ruslans', isReadyToSettle: true),
          ],
        );
      await _mount(tester, controller, manager: true);
      await tester.pumpAndSettle();
      await _selectTab(tester, 'Settle');
      final finish = find.byKey(const ValueKey('settle-finish-trip'));
      expect(tester.widget<FilledButton>(finish).onPressed, isNull);
      final toggle = find.byKey(const ValueKey('settle-ready-switch'));
      await visibleTap(tester, toggle);
      expect(controller.readinessCalls, [true]);
      expect(tester.widget<FilledButton>(finish).onPressed, isNotNull);
      expect(find.text('2 / 2'), findsOneWidget);
      await visibleTap(tester, toggle);
      expect(controller.readinessCalls, [true, false]);
      expect(tester.widget<FilledButton>(finish).onPressed, isNull);
      await disposePage(tester);
    },
  );

  testWidgets(
    'settle totals keep incoming and outgoing separate and exclude confirmed',
    (tester) async {
      final outgoing = settlement('pending');
      SettlementItem incoming(int id, double amount, bool confirmed) =>
          SettlementItem(
            id: id,
            fromUserId: 8,
            toUserId: 7,
            from: 'Ruslans',
            to: 'Matiss',
            amount: amount,
            status: confirmed ? 'confirmed' : 'sent',
            createdAt: null,
            markedSentAt: null,
            confirmedAt: null,
            canMarkSent: false,
            canConfirmReceived: !confirmed,
            canCancelSent: false,
            canReportNotReceived: !confirmed,
            isConfirmed: confirmed,
          );
      final controller = _Workspace()
        ..data = snapshot().copyWith(
          tripStatus: 'settling',
          settlements: [
            outgoing,
            incoming(2, 30, false),
            incoming(3, 15, true),
          ],
        );
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      await _selectTab(tester, 'Settle');
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('settle-summary-incoming')))
            .data,
        '€30.00',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('settle-summary-outgoing')))
            .data,
        '€24.00',
      );
      expect(find.text('I sent'), findsNothing);
      await expandFirstSettlement(tester);
      expect(find.text('Confirm received'), findsOneWidget);
      await disposePage(tester);
    },
  );

  testWidgets('settlement cards review images', (tester) async {
    if (!const bool.fromEnvironment('SETTLEMENT_CARDS_PREVIEWS')) return;
    for (final dark in [false, true]) {
      for (final phase in ['active', 'settling', 'expanded']) {
        final boundary = GlobalKey();
        final controller = _Workspace()
          ..data = snapshot().copyWith(
            tripStatus: phase == 'active' ? 'active' : 'settling',
            users: const [
              WorkspaceUser(id: 7, nickname: 'Matiss'),
              WorkspaceUser(id: 8, nickname: 'Ruslans', isReadyToSettle: true),
              WorkspaceUser(id: 9, nickname: 'Igors', isReadyToSettle: true),
            ],
            settlements: [
              for (final id in [8, 9])
                SettlementItem(
                  id: phase == 'active' ? null : id,
                  fromUserId: id,
                  toUserId: 7,
                  from: id == 8 ? 'Ruslans' : 'Igors',
                  to: 'Matiss',
                  amount: id == 8 ? 30 : 15,
                  status: phase == 'active'
                      ? 'suggested'
                      : id == 8
                      ? 'sent'
                      : 'pending',
                  createdAt: null,
                  markedSentAt: null,
                  confirmedAt: null,
                  canMarkSent: false,
                  canConfirmReceived: phase != 'active' && id == 8,
                  canCancelSent: false,
                  canReportNotReceived: false,
                  isConfirmed: false,
                ),
            ],
            balances: const [
              BalanceItem(
                id: 7,
                nickname: 'Matiss',
                paid: 90,
                owed: 45,
                net: 45,
              ),
              BalanceItem(
                id: 8,
                nickname: 'Ruslans',
                paid: 15,
                owed: 45,
                net: -30,
              ),
              BalanceItem(
                id: 9,
                nickname: 'Igors',
                paid: 30,
                owed: 45,
                net: -15,
              ),
            ],
            settlementTotal: 2,
            settlementRemaining: 2,
            settlementConfirmed: 0,
          );
        await _mount(
          tester,
          controller,
          dark: dark,
          manager: true,
          boundary: boundary,
        );
        await tester.pumpAndSettle();
        await _selectTab(tester, 'Settle');
        if (phase == 'expanded') await expandFirstSettlement(tester);
        await tester.ensureVisible(
          find.byKey(const ValueKey('settle-personal-summary')),
        );
        await tester.pumpAndSettle();
        final position = tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position;
        final summaryTop = tester
            .getTopLeft(find.byKey(const ValueKey('settle-personal-summary')))
            .dy;
        position.jumpTo(
          (position.pixels + summaryTop - 172).clamp(
            position.minScrollExtent,
            position.maxScrollExtent,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/settlement-cards/${dark ? 'dark' : 'light'}-$phase.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await disposePage(tester);
      }
    }
  });
  testWidgets(
    'trip menu shares through native sheet and recovers from failure',
    (tester) async {
      const channel = MethodChannel('dev.fluttercommunity.plus/share');
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call);
        return 'com.example.share';
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      final trips = _Trips();
      final commands = WorkspacePageCommandController();
      final boundary = GlobalKey();
      await _mount(
        tester,
        _Workspace(),
        manager: true,
        trips: trips,
        commands: commands,
        boundary: boundary,
      );
      await tester.pumpAndSettle();
      for (final fail in [false, true, false]) {
        trips.failShare = fail;
        calls.clear();
        commands.requestOpenTripActions();
        await tester.pumpAndSettle();
        final share = find.byKey(const ValueKey('workspace-trip-share'));
        expect(
          tester.getTopLeft(share).dy,
          greaterThan(tester.getTopLeft(find.text('Invite members')).dy),
        );
        expect(
          find.descendant(
            of: share,
            matching: find.byIcon(CupertinoIcons.arrowshape_turn_up_right),
          ),
          findsOneWidget,
        );
        if (const bool.fromEnvironment('HOME_ACTIONS_PREVIEWS') &&
            trips.shareCalls == 0) {
          await tester.runAsync(() async {
            final image =
                await (boundary.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              '../output/design/home-actions/trip-share-menu.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.tap(share);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('trip-actions-sheet')), findsNothing);
        if (fail) {
          expect(calls, isEmpty);
          expect(
            find.text('Could not share the trip. Please try again.'),
            findsOneWidget,
          );
        } else {
          expect(calls.single.method, 'share');
          expect(
            calls.single.arguments['text'],
            'Lisbon getaway\nhttps://splyto.app/?invite=lisbon-abcdefghij',
          );
          expect(calls.single.arguments['originWidth'], greaterThan(0));
          expect(calls.single.arguments['originHeight'], greaterThan(0));
        }
        expect(tester.takeException(), isNull);
      }
      expect(trips.shareCalls, 3);
      await disposePage(tester);
      commands.dispose();
    },
  );

  testWidgets('trip menu offers the export with trip or personal Premium', (
    tester,
  ) async {
    PremiumAccess premium(String plan, {Map<String, bool>? features}) =>
        PremiumAccess.fromMap({
          'schema_version': 1,
          'account_id': 7,
          'plan': plan,
          'source': plan == 'premium' ? 'admin_grant' : null,
          'expires_at': plan == 'premium' ? '2099-01-01T00:00:00Z' : null,
          'checked_at': '2026-11-08T12:00:00Z',
          'refresh_after_seconds': 300,
          'billing_enabled': false,
          'limits_enforced': false,
          'features': ?features,
        }, accountId: 7)!;
    final free = premium('free', features: {'trip_export': false});
    var exports = 0;
    Future<void> export() async => exports++;
    for (final (name, auth, tripFeatures, callback, shown) in [
      (
        'no export flow',
        _Auth(premiumAccess: free),
        {'trip_export': true},
        null,
        false,
      ),
      (
        'free account, no trip Premium',
        _Auth(premiumAccess: free),
        {'trip_export': false},
        export,
        false,
      ),
      (
        'free account, older server',
        _Auth(premiumAccess: free),
        null,
        export,
        false,
      ),
      (
        'trip Premium',
        _Auth(premiumAccess: free),
        {'trip_export': true},
        export,
        true,
      ),
      (
        'trip Premium, no account status',
        _Auth(),
        {'trip_export': true},
        export,
        true,
      ),
      (
        'personal Premium',
        _Auth(premiumAccess: premium('premium')),
        {'trip_export': false},
        export,
        true,
      ),
      (
        'personal Premium, older server',
        _Auth(premiumAccess: premium('premium')),
        null,
        export,
        true,
      ),
    ]) {
      final commands = WorkspacePageCommandController();
      await _mount(
        tester,
        _Workspace()..data = snapshot(status: 'active'),
        role: 'member',
        auth: auth,
        commands: commands,
        premiumFeatures: tripFeatures,
        onExportTripRequested: callback,
      );
      await tester.pumpAndSettle();
      commands.requestOpenTripActions();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('trip-export')),
        shown ? findsOneWidget : findsNothing,
        reason: name,
      );
      if (shown) {
        final before = exports;
        await tester.tap(find.byKey(const ValueKey('trip-export')));
        await tester.pumpAndSettle();
        expect(exports, before + 1, reason: name);
      }
      await disposePage(tester);
      commands.dispose();
    }
  });

  testWidgets('trip menu share requires active group management access', (
    tester,
  ) async {
    for (final role in ['owner', 'admin', 'member']) {
      for (final status in ['active', 'archived']) {
        final commands = WorkspacePageCommandController();
        await _mount(
          tester,
          _Workspace()..data = snapshot(status: status),
          role: role,
          commands: commands,
        );
        await tester.pumpAndSettle();
        commands.requestOpenTripActions();
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('workspace-trip-share')),
          status == 'active' && role != 'member'
              ? findsOneWidget
              : findsNothing,
        );
        await disposePage(tester);
        commands.dispose();
      }
    }
  });
  testWidgets('participant picker commits explicit members and rejects none', (
    tester,
  ) async {
    final commands = WorkspacePageCommandController();
    final controller = _Workspace();
    await _mount(tester, controller, commands: commands);
    await tester.pumpAndSettle();
    commands.requestOpenAddExpense();
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('expense-form-amount')),
      '10',
    );
    await selectExpenseFood(tester);
    // Everyone is in by default, right in the form.
    final anna = find.byKey(const ValueKey('expense-participant-7'));
    final ben = find.byKey(const ValueKey('expense-participant-8'));
    await tester.ensureVisible(anna);
    expect(tester.widget<AppPersonToggle>(anna).selected, isTrue);
    expect(tester.widget<AppPersonToggle>(ben).selected, isTrue);
    await tester.tap(anna);
    await tester.pumpAndSettle();
    expect(tester.widget<AppPersonToggle>(anna).selected, isFalse);
    // The last person can't be taken out.
    await tester.tap(ben);
    await tester.pumpAndSettle();
    expect(tester.widget<AppPersonToggle>(ben).selected, isTrue);
    await visibleTap(
      tester,
      find.byKey(const ValueKey('expense-custom-split')),
    );
    expect(find.byKey(const ValueKey('split-input-7')), findsNothing);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('split-input-8')))
          .controller!
          .text,
      '10.00',
    );
    await tester.tap(find.byKey(const ValueKey('expense-editor-done')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('split-input-8')), findsNothing);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();
    expect(controller.savedParticipants, [8]);
    expect(controller.savedSplits!.single.value, 10);
    expect(controller.savedSplits!.single.userId, 8);
    await disposePage(tester);
  });

  group('people without the app', () {
    const guest = WorkspaceUser(id: 99, nickname: 'Mamma', isGuest: true);
    setUp(() => _testGuests = const [guest]);
    tearDown(() => _testGuests = const []);

    Future<_Workspace> openForm(
      WidgetTester tester, {
      required bool owner,
    }) async {
      final commands = WorkspacePageCommandController();
      final controller = _Workspace();
      await _mount(tester, controller, commands: commands, manager: owner);
      await tester.pumpAndSettle();
      commands.requestOpenAddExpense();
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('expense-form-amount')),
        '10',
      );
      await selectExpenseFood(tester);
      return controller;
    }

    testWidgets('the trip owner can say a guest paid', (tester) async {
      final controller = await openForm(tester, owner: true);
      await visibleTap(tester, find.byKey(const ValueKey('expense-payer')));
      expect(find.byKey(const ValueKey('expense-payer-sheet')), findsOneWidget);
      // Only themselves and guests, never another account.
      expect(find.byKey(const ValueKey('expense-payer-8')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('expense-payer-99')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();
      expect(controller.savedPaidBy, 99);
      await disposePage(tester);
    });

    testWidgets('other members only enter their own expenses', (tester) async {
      final controller = await openForm(tester, owner: false);
      await visibleTap(tester, find.byKey(const ValueKey('expense-payer')));
      expect(find.byKey(const ValueKey('expense-payer-sheet')), findsNothing);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();
      expect(controller.savedPaidBy, isNull);
      await disposePage(tester);
    });

    test('a guest survives the server response and the local cache', () {
      final parsed = WorkspaceRemoteParsers.parseUser(const {
        'id': 99,
        'nickname': 'Mamma',
        'is_guest': true,
      });
      expect(parsed.isGuest, isTrue);
      expect(
        WorkspaceRemoteParsers.parseUser(const {
          'id': 8,
          'nickname': 'Anna',
        }).isGuest,
        isFalse,
      );
    });
  });

  testWidgets('adjustments show each result and save with a minus', (
    tester,
  ) async {
    final commands = WorkspacePageCommandController();
    final controller = _Workspace();
    await _mount(tester, controller, commands: commands);
    await tester.pumpAndSettle();
    commands.requestOpenAddExpense();
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('expense-form-amount')),
      '100',
    );
    await selectExpenseFood(tester);
    await visibleTap(
      tester,
      find.byKey(const ValueKey('expense-custom-split')),
    );
    await tester.tap(find.byKey(const ValueKey('expense-split-method')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('split-mode-itemized')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('split-mode-adjustment')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('split-input-7')), '10');
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('split-result-7'))).data,
      contains('55'),
    );
    await tester.enterText(find.byKey(const ValueKey('split-input-7')), '500');
    await tester.pumpAndSettle();
    final done = find.byKey(const ValueKey('expense-editor-done'));
    expect(tester.widget<ElevatedButton>(done).onPressed, isNull);
    await tester.enterText(find.byKey(const ValueKey('split-input-7')), '-5');
    await tester.pumpAndSettle();
    await tester.tap(done);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();
    expect(controller.savedMode, 'adjustment');
    expect(
      controller.savedSplits!.firstWhere((item) => item.userId == 7).value,
      -5,
    );
    await disposePage(tester);
  });

  testWidgets('items set the amount and decide who pays', (tester) async {
    final commands = WorkspacePageCommandController();
    final controller = _Workspace();
    await _mount(tester, controller, commands: commands);
    await tester.pumpAndSettle();
    commands.requestOpenAddExpense();
    await tester.pumpAndSettle();
    await selectExpenseFood(tester);
    await visibleTap(
      tester,
      find.byKey(const ValueKey('expense-custom-split')),
    );
    // No amount yet, so the items are what add up to it.
    final done = find.byKey(const ValueKey('expense-editor-done'));
    expect(find.byKey(const ValueKey('expense-item-name-0')), findsOneWidget);
    expect(tester.widget<ElevatedButton>(done).onPressed, isNull);
    await tester.enterText(
      find.byKey(const ValueKey('expense-item-name-0')),
      'Pizza',
    );
    await tester.enterText(
      find.byKey(const ValueKey('expense-item-amount-0')),
      '12',
    );
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(done).onPressed, isNotNull);
    await tester.ensureVisible(find.byKey(const ValueKey('expense-add-item')));
    await tester.tap(find.byKey(const ValueKey('expense-add-item')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('expense-item-name-1')),
      'Beer',
    );
    await tester.enterText(
      find.byKey(const ValueKey('expense-item-amount-1')),
      '5',
    );
    await tester.enterText(
      find.byKey(const ValueKey('expense-item-extra')),
      '3',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('expense-item-1-person-8')),
    );
    await tester.tap(find.byKey(const ValueKey('expense-item-1-person-8')));
    await tester.pumpAndSettle();
    expect(find.textContaining('20'), findsWidgets);
    await tester.tap(done);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('expense-form-amount')))
          .controller!
          .text,
      '20.00',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();
    expect(controller.savedMode, 'itemized');
    expect(controller.savedAmount, 20);
    expect(controller.savedExtra, 3);
    expect(controller.savedItems!.map((item) => item.name), ['Pizza', 'Beer']);
    expect(controller.savedItems!.last.participantIds, isNot(contains(8)));
    expect(controller.savedSplits, isEmpty);
    await disposePage(tester);
  });

  testWidgets(
    'split editor validates totals and cancel preserves committed amounts',
    (tester) async {
      final commands = WorkspacePageCommandController();
      final controller = _Workspace();
      await _mount(tester, controller, commands: commands);
      await tester.pumpAndSettle();
      commands.requestOpenAddExpense();
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('expense-form-amount')),
        '10',
      );
      await selectExpenseFood(tester);
      await visibleTap(
        tester,
        find.byKey(const ValueKey('expense-custom-split')),
      );
      String text(int id) => tester
          .widget<TextField>(find.byKey(ValueKey('split-input-$id')))
          .controller!
          .text;
      VoidCallback? done() => tester
          .widget<ElevatedButton>(
            find.byKey(const ValueKey('expense-editor-done')),
          )
          .onPressed;
      // Typing one value fills in the rest of the total for the others.
      await tester.enterText(find.byKey(const ValueKey('split-input-7')), '6');
      await tester.pumpAndSettle();
      expect(text(8), '4.00');
      expect(find.byKey(const ValueKey('split-pinned-7')), findsOneWidget);
      expect(find.byKey(const ValueKey('split-pinned-8')), findsNothing);
      expect(done(), isNotNull);
      // Once everyone is typed in, the totals are checked instead.
      await tester.enterText(find.byKey(const ValueKey('split-input-8')), '3');
      await tester.pumpAndSettle();
      expect(text(7), '6');
      expect(find.textContaining('left to split'), findsOneWidget);
      expect(done(), isNull);
      await tester.enterText(find.byKey(const ValueKey('split-input-8')), '5');
      await tester.pumpAndSettle();
      expect(find.textContaining('over the total'), findsOneWidget);
      // Split evenly forgets the typed values.
      await tester.tap(find.byKey(const ValueKey('split-evenly')));
      await tester.pumpAndSettle();
      expect([text(7), text(8)], ['5.00', '5.00']);
      expect(find.byKey(const ValueKey('split-pinned-7')), findsNothing);
      await tester.enterText(find.byKey(const ValueKey('split-input-7')), '6');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('expense-editor-done')));
      await tester.pumpAndSettle();
      await visibleTap(
        tester,
        find.byKey(const ValueKey('expense-split-summary')),
      );
      await tester.enterText(find.byKey(const ValueKey('split-input-7')), '1');
      await tester.pumpAndSettle();
      expect(text(8), '9.00');
      await tester.tap(find.byKey(const ValueKey('expense-editor-close')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();
      expect(controller.savedSplits!.map((s) => s.value), [6, 4]);
      await disposePage(tester);
    },
  );

  testWidgets(
    'split editor keeps mode drafts and rejects fractional shares with keyboard',
    (tester) async {
      final commands = WorkspacePageCommandController();
      await _mount(
        tester,
        _Workspace(),
        commands: commands,
        width: 320,
        height: 568,
      );
      await tester.pumpAndSettle();
      commands.requestOpenAddExpense();
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('expense-form-amount')),
        '10.01',
      );
      await visibleTap(
        tester,
        find.byKey(const ValueKey('expense-custom-split')),
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('split-input-7')))
            .controller!
            .text,
        '5.01',
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('split-input-8')))
            .controller!
            .text,
        '5.00',
      );
      await tester.enterText(
        find.byKey(const ValueKey('split-input-7')),
        '6.01',
      );
      await pickSplitMode(tester, 'Percentages');
      await tester.enterText(find.byKey(const ValueKey('split-input-7')), '40');
      await tester.pumpAndSettle();
      // The other person gets the rest of the percentages and its money.
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('split-input-8')))
            .controller!
            .text,
        '60.00',
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('split-result-8'))).data,
        contains('6.01'),
      );
      await pickSplitMode(tester, 'Exact amounts');
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('split-input-7')))
            .controller!
            .text,
        '6.01',
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('split-input-8')))
            .controller!
            .text,
        '4.00',
      );
      await pickSplitMode(tester, 'Shares');
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.ensureVisible(find.byKey(const ValueKey('split-input-7')));
      await tester.enterText(
        find.byKey(const ValueKey('split-input-7')),
        '1.5',
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ElevatedButton>(
              find.byKey(const ValueKey('expense-editor-done')),
            )
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
      expect(
        tester
            .getRect(find.byKey(const ValueKey('expense-editor-done')))
            .bottom,
        lessThanOrEqualTo(568 - 280),
      );
      await disposePage(tester);
    },
  );

  testWidgets('compact expense layout review images', (tester) async {
    if (!const bool.fromEnvironment('EXPENSE_LAYOUT_PREVIEWS')) return;
    for (final dark in [false, true]) {
      final key = GlobalKey();
      final commands = WorkspacePageCommandController();
      await _mount(
        tester,
        _Workspace()
          ..data = snapshot().copyWith(
            users: const [
              WorkspaceUser(id: 7, nickname: 'Matiss'),
              WorkspaceUser(id: 8, nickname: 'Ruslans'),
              WorkspaceUser(id: 9, nickname: 'Igors'),
            ],
          ),
        commands: commands,
        boundary: key,
        dark: dark,
      );
      await tester.pumpAndSettle();
      commands.requestOpenAddExpense();
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('expense-form-amount')),
        '180.00',
      );
      await selectExpenseFood(tester);
      final t = AppLocalizations.of(
        tester.element(find.byKey(const ValueKey('expense-form-amount'))),
      )!;
      await tester.enterText(
        find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == t.noteLabel,
        ),
        'Dinner with friends',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      for (final screen in ['split', 'form', 'participants']) {
        if (screen == 'split') {
          await visibleTap(
            tester,
            find.byKey(const ValueKey('expense-custom-split')),
          );
          for (final e in [(7, '80'), (8, '60'), (9, '40')]) {
            await tester.enterText(
              find.byKey(ValueKey('split-input-${e.$1}')),
              e.$2,
            );
          }
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
        } else if (screen == 'form') {
          await tester.tap(find.byKey(const ValueKey('expense-editor-done')));
          await tester.pumpAndSettle();
          Scrollable.of(
            tester.element(find.byKey(const ValueKey('expense-form-amount'))),
          ).position.jumpTo(0);
          await tester.pumpAndSettle();
        } else {
          await visibleTap(
            tester,
            find.byKey(const ValueKey('expense-participants')),
          );
        }
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/expense-layout/${dark ? 'dark' : 'light'}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await disposePage(tester);
      commands.dispose();
    }
  });

  testWidgets(
    'Duo trip overview reflows and retains expense tab while folding',
    (tester) async {
      final controller = _Workspace();
      await _mount(tester, controller, width: 951, height: 669);
      await tester.pumpAndSettle();
      final state = tester.state(find.byType(WorkspacePage));
      expect(
        find.byKey(const ValueKey('workspace-wide-overview')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      for (final size in [
        const Size(466, 678),
        const Size(669, 951),
        const Size(951, 669),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(WorkspacePage)), same(state));
        expect(find.byKey(const ValueKey('workspace-total')), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      await disposePage(tester);
    },
  );

  testWidgets('invitation review invite', (tester) async {
    if (!const bool.fromEnvironment('INVITATION_PREVIEWS')) return;
    for (final dark in [false, true]) {
      final key = GlobalKey();
      final commands = WorkspacePageCommandController();
      await _mount(
        tester,
        _Workspace(),
        manager: true,
        dark: dark,
        boundary: key,
        commands: commands,
      );
      await tester.pumpAndSettle();
      commands.requestOpenTripActions();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Invite members'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(
          '../output/design/invitations/${dark ? 'dark' : 'light'}-invite.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      commands.dispose();
    }
  });

  testWidgets('secondary flow review images', (tester) async {
    if (!const bool.fromEnvironment('SECONDARY_PREVIEWS')) return;
    final emojiFont = File('/System/Library/Fonts/Apple Color Emoji.ttc');
    if (emojiFont.existsSync()) {
      final bytes = emojiFont.readAsBytesSync();
      await (FontLoader(
        'Apple Color Emoji',
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
    for (final dark in [false, true]) {
      for (final screen in [
        'comment',
        'edit-comment',
        'flow',
        'payment',
        'request',
        'review',
      ]) {
        final key = GlobalKey();
        final controller = _Workspace()
          ..comments = [
            const ExpenseComment(
              id: 11,
              userId: 7,
              userNickname: 'Matiss',
              body: 'Thanks! I included the airport transfer.',
              createdAt: '2026-10-22 10:00:00',
            ),
          ]
          ..data = snapshot(preview: true).copyWith(
            settlements: [
              screen == 'request'
                  ? SettlementItem(
                      id: null,
                      fromUserId: 8,
                      toUserId: 7,
                      from: 'Anna',
                      to: 'Matiss',
                      amount: 24,
                      status: 'suggested',
                      createdAt: null,
                      markedSentAt: null,
                      confirmedAt: null,
                      canMarkSent: false,
                      canConfirmReceived: false,
                      canCancelSent: false,
                      canReportNotReceived: false,
                      isConfirmed: false,
                    )
                  : settlement(screen == 'flow' ? 'pending' : 'suggested'),
            ],
            payments: screen == 'review' ? [payment('requested')] : [],
            tripStatus: screen == 'flow' ? 'settling' : 'active',
          );
        await _mount(tester, controller, dark: dark, boundary: key);
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(WorkspacePage)),
        )!;
        if (screen == 'comment' || screen == 'edit-comment') {
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('expense-row-1')),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.tap(find.byKey(const ValueKey('expense-row-1')));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text(controller.comments.first.body),
            200,
            scrollable: find.byType(Scrollable).last,
          );
          await tester.longPress(find.text(controller.comments.first.body));
          await tester.pumpAndSettle();
          if (screen == 'edit-comment') {
            await tester.tap(find.text(t.editAction));
            await tester.pumpAndSettle();
          }
        } else {
          await _selectTab(tester, t.workspaceSettle);
          final label = screen == 'flow'
              ? t.workspaceOpenFlow
              : screen == 'review'
              ? t.paymentReviewRequestAction
              : screen == 'request'
              ? t.paymentRequestAction
              : t.paymentRecordAction;
          await tester.scrollUntilVisible(
            find.text(label),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await Scrollable.ensureVisible(
            tester.element(find.text(label)),
            alignment: .5,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        if (screen == 'payment' || screen == 'request') {
          expect(find.byType(TextField), findsNWidgets(2));
        }
        if (screen == 'review') {
          expect(find.text(t.paymentRequestReviewTitle), findsOneWidget);
        }
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/secondary-flows/${dark ? 'dark' : 'light'}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await disposePage(tester);
      }
    }
  });

  Future<void> openComment(WidgetTester tester, _Workspace controller) async {
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('expense-row-1')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.byKey(const ValueKey('expense-row-1'))),
      alignment: .5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('expense-row-1')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(controller.comments.first.body),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.text(controller.comments.first.body)),
      alignment: .5,
    );
    await tester.pumpAndSettle();
    await tester.longPress(find.text(controller.comments.first.body));
    await tester.pumpAndSettle();
  }

  ExpenseComment comment({bool own = true}) => ExpenseComment(
    id: 11,
    userId: own ? 7 : 8,
    userNickname: own ? 'Matiss' : 'Anna',
    body: 'Airport transfer is included in this expense.',
    createdAt: '2026-10-22',
  );
  testWidgets(
    'member revtag loads with sharing and disappears after revocation refresh',
    (tester) async {
      final controller = _Workspace()..memberDetailsShared = true;
      await _mount(tester, controller, auth: _Auth(revtag: '@myrevtag'));
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage)),
      )!;
      await tester.ensureVisible(find.byTooltip(t.workspaceMemberCount(2)));
      await tester.tap(find.byTooltip(t.workspaceMemberCount(2)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('member-row-8')));
      await tester.pumpAndSettle();
      expect(find.text('@annarevtag'), findsOneWidget);
      expect(find.text('@myrevtag'), findsNothing);
      controller.memberDetailsShared = false;
      final profile = tester.widget<UserProfilePage>(
        find.byType(UserProfilePage),
      );
      final refreshed = profile.onRefresh!();
      await tester.pumpAndSettle();
      await refreshed;
      expect(find.text('@annarevtag'), findsNothing);
      expect(find.text(t.profilePaymentNotAdded), findsOneWidget);
      expect(find.text(t.memberPaymentDetailsNotShared), findsNothing);
      expect(find.text(t.paymentDetailsRetry), findsNothing);
      expect(controller.memberDetailsCalls, 2);
      // A connectivity failure is still retryable and never shows stale details.
      controller.memberDetailsShared = true;
      controller.memberDetailsError = const ApiException(
        'Offline',
        isNetworkError: true,
      );
      final retryRefresh = profile.onRefresh!();
      await tester.pumpAndSettle();
      await retryRefresh;
      expect(find.text('@annarevtag'), findsNothing);
      expect(find.text(t.memberPaymentDetailsNotShared), findsOneWidget);
      expect(find.text(t.paymentDetailsRetry), findsOneWidget);
      controller.memberDetailsError = null;
      await tester.ensureVisible(find.text(t.paymentDetailsRetry));
      await tester.tap(find.text(t.paymentDetailsRetry));
      await tester.pumpAndSettle();
      expect(find.text('@annarevtag'), findsOneWidget);
      expect(find.text(t.paymentDetailsRetry), findsNothing);
      await disposePage(tester);
    },
  );

  for (final memberId in [7, 8]) {
    testWidgets('own revtag is visible only on own member profile $memberId', (
      tester,
    ) async {
      await _mount(tester, _Workspace(), auth: _Auth(revtag: '@myrevtag'));
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage)),
      )!;
      await tester.ensureVisible(find.byTooltip(t.workspaceMemberCount(2)));
      await tester.tap(find.byTooltip(t.workspaceMemberCount(2)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('member-row-$memberId')));
      await tester.pumpAndSettle();
      final profile = tester.widget<UserProfilePage>(
        find.byType(UserProfilePage),
      );
      if (memberId == 7) {
        final payments = profile.sections
            .whereType<UserProfilePaymentDetailsSection>()
            .single;
        expect(payments.revolutHandle, '@myrevtag');
      } else {
        expect(find.text(t.profilePaymentNotAdded), findsOneWidget);
        expect(find.text(t.memberPaymentDetailsNotShared), findsNothing);
        expect(find.text(t.paymentDetailsRetry), findsNothing);
        expect(find.text('@myrevtag'), findsNothing);
      }
      await disposePage(tester);
    });
  }
  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      testWidgets('secondary menus 320px 200% $locale dark=$dark', (
        tester,
      ) async {
        final controller = _Workspace()..comments = [comment()];
        await _mount(
          tester,
          controller,
          width: 320,
          scale: 2,
          locale: locale,
          dark: dark,
        );
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(WorkspacePage)),
        )!;
        await openComment(tester, controller);
        final menu = find.byType(AppActionSheet).last;
        await visibleTap(
          tester,
          find.descendant(of: menu, matching: find.text(t.expenseReplyAction)),
        );
        expect(find.text(t.expenseReplyAction), findsNothing);
        expect(tester.takeException(), isNull);
        await disposePage(tester);
        controller.data = snapshot().copyWith(payments: [payment('requested')]);
        await _mount(
          tester,
          controller,
          width: 320,
          scale: 2,
          locale: locale,
          dark: dark,
        );
        await tester.pumpAndSettle();
        await _selectTab(tester, t.workspaceSettle);
        await tester.scrollUntilVisible(
          find.text(t.paymentReviewRequestAction),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await visibleTap(tester, find.text(t.paymentReviewRequestAction));
        expect(find.text(t.paymentRequestReviewTitle), findsOneWidget);
        await tester.ensureVisible(find.text(t.paymentDeclineAction));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(
          find.descendant(
            of: find.byType(AppActionSheet).last,
            matching: find.byIcon(Icons.close),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(t.paymentRequestReviewTitle), findsNothing);
        await disposePage(tester);
      });
    }
  }
  testWidgets(
    'comment ownership reaction destination edit and deletion cancellation',
    (tester) async {
      final controller = _Workspace()..comments = [comment(own: false)];
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      await openComment(tester, controller);
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsNothing);
      await tester.tap(find.text('👍'));
      await tester.pumpAndSettle();
      expect(controller.commentReactionCalls, [(1, 1, 11, '👍')]);
      await disposePage(tester);
      controller.comments = [comment()];
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      await openComment(tester, controller);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('comment-edit-input')),
        'Updated airport transfer',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(controller.commentEditCalls, [
        (1, 1, 11, 'Updated airport transfer'),
      ]);
      await visibleTap(tester, find.text('Updated airport transfer'));
      await tester.longPress(find.text('Updated airport transfer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(controller.commentDeleteCalls, isEmpty);
      expect(find.text('Updated airport transfer'), findsOneWidget);
      await disposePage(tester);
    },
  );
  testWidgets('mention works in a reply and in an edit', (tester) async {
    final option = find.byKey(const ValueKey('comment-mention-option-8'));
    final controller = _Workspace()..comments = [comment(own: true)];
    await _mount(tester, controller);
    await tester.pumpAndSettle();
    final t = AppLocalizations.of(tester.element(find.byType(WorkspacePage)))!;
    await openComment(tester, controller);
    await tester.tap(find.text(t.expenseReplyAction));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('expense-comment-input')),
      '@An',
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('comment-mention-option-7')),
      findsNothing,
    );
    await visibleTap(tester, option);
    await tester.pumpAndSettle();
    await visibleTap(tester, find.byTooltip(t.expenseCommentSend));
    expect(controller.commentReplyCalls, [(1, 1, 11, '@Anna')]);
    expect(controller.commentMentionCalls, [
      [8],
    ]);

    await tester.longPress(find.text(controller.comments.first.body).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('comment-edit-input')),
      'Ask @An',
    );
    await tester.pumpAndSettle();
    await tester.tap(option);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(controller.commentEditCalls, [(1, 1, 11, 'Ask @Anna')]);
    expect(controller.commentMentionCalls.last, [8]);
    expect(tester.takeException(), isNull);
    await disposePage(tester);
  });
  testWidgets('comment reply preserves parent and expense identifiers', (
    tester,
  ) async {
    final controller = _Workspace()..comments = [comment(own: false)];
    await _mount(tester, controller);
    await tester.pumpAndSettle();
    final t = AppLocalizations.of(tester.element(find.byType(WorkspacePage)))!;
    await openComment(tester, controller);
    await tester.tap(find.text(t.expenseReplyAction));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('expense-comment-input')),
      'Thanks Anna',
    );
    await tester.pumpAndSettle();
    await visibleTap(tester, find.byTooltip(t.expenseCommentSend));
    expect(controller.commentReplyCalls, [(1, 1, 11, 'Thanks Anna')]);
    expect(find.text('Thanks Anna'), findsOneWidget);
    await disposePage(tester);
  });
  testWidgets(
    'settlement flow requires confirmation and refreshes after exact mutation',
    (tester) async {
      final controller = _Workspace()
        ..data = snapshot().copyWith(
          tripStatus: 'settling',
          settlements: [settlement('pending')],
        );
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage)),
      )!;
      await _selectTab(tester, t.workspaceSettle);
      await expandFirstSettlement(tester);
      await tester.scrollUntilVisible(
        find.text(t.workspaceOpenFlow),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await visibleTap(tester, find.text(t.workspaceOpenFlow));
      await visibleTap(
        tester,
        find.descendant(
          of: find.byType(AppActionSheet).last,
          matching: find.widgetWithText(FilledButton, t.iSentAction),
        ),
      );
      expect(controller.sentCalls, isEmpty);
      await tester.tap(find.text(t.cancelAction));
      await tester.pumpAndSettle();
      expect(controller.sentCalls, isEmpty);
      await visibleTap(
        tester,
        find.descendant(
          of: find.byType(AppActionSheet).last,
          matching: find.widgetWithText(FilledButton, t.iSentAction),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('app-confirmation-dialog')),
          matching: find.text(t.iSentAction),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.sentCalls, [(1, 1)]);
      expect(
        find.descendant(
          of: find.byType(AppActionSheet).last,
          matching: find.widgetWithText(FilledButton, t.iSentAction),
        ),
        findsNothing,
      );
      await disposePage(tester);
    },
  );
  testWidgets(
    'record payment form calls original mutation with exact payee amount and note',
    (tester) async {
      final controller = _Workspace()
        ..data = snapshot(
          preview: true,
        ).copyWith(settlements: [settlement('suggested')]);
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage)),
      )!;
      await _selectTab(tester, t.workspaceSettle);
      await expandFirstSettlement(tester);
      await tester.scrollUntilVisible(
        find.text(t.paymentRecordAction),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await visibleTap(tester, find.text(t.paymentRecordAction));
      await tester.enterText(
        find.byKey(const ValueKey('payment-amount')),
        '12,50',
      );
      await tester.enterText(
        find.byKey(const ValueKey('payment-note')),
        'Cash',
      );
      await tester.tap(
        find.widgetWithText(FilledButton, t.paymentMarkPaidAction),
      );
      await tester.pumpAndSettle();
      expect(controller.paymentCalls, [(1, 8, 12.5, 'Cash')]);
      await disposePage(tester);
    },
  );

  testWidgets('split detail review images', (tester) async {
    if (!const bool.fromEnvironment('DETAIL_PREVIEWS')) return;
    for (final dark in [false, true]) {
      for (final mode in ['picker', 'exact', 'percent', 'shares']) {
        final key = GlobalKey();
        final commands = WorkspacePageCommandController();
        await _mount(
          tester,
          _Workspace(),
          boundary: key,
          commands: commands,
          dark: dark,
        );
        await tester.pumpAndSettle();
        commands.requestOpenAddExpense();
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('expense-form-amount')),
          '60',
        );
        final t = AppLocalizations.of(
          tester.element(find.byType(WorkspacePage, skipOffstage: false)),
        )!;
        await tester.scrollUntilVisible(
          find.text(t.splitModeLabel),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        await visibleTap(
          tester,
          find.byKey(const ValueKey('expense-custom-split')),
        );
        if (mode != 'picker') {
          final labels = {
            'exact': t.exactAmountsLabel,
            'percent': t.percentagesLabel,
            'shares': t.sharesLabel,
          };
          await pickSplitMode(tester, labels[mode]!);
          await tester.pumpAndSettle();
          for (final name in ['Matiss', 'Anna']) {
            final field = find.byKey(
              ValueKey('split-input-${name == 'Matiss' ? 7 : 8}'),
            );
            await tester.ensureVisible(field);
            await tester.enterText(
              field,
              mode == 'exact'
                  ? '30'
                  : mode == 'percent'
                  ? '50'
                  : '1',
            );
          }
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          await Scrollable.ensureVisible(
            tester.element(find.byKey(const ValueKey('expense-split-status'))),
            alignment: 0,
          );
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/detail-states/${dark ? 'dark' : 'light'}-split-$mode.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await disposePage(tester);
        commands.dispose();
      }
    }
  });

  testWidgets(
    'receipt entry uses fresh loader with exact expense and trip IDs',
    (tester) async {
      final controller = _Workspace()
        ..data = snapshot(
          expenses: [expense(1, receiptUrl: 'https://splyto.eu/expired-link')],
        );
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('expense-row-1')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await visibleTap(tester, find.byKey(const ValueKey('expense-row-1')));
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('receipt-open')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await visibleTap(tester, find.byKey(const ValueKey('receipt-open')));
      expect(controller.receiptCalls, [(1, 1)]);
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage)),
      )!;
      expect(find.text(t.receiptLinkInvalid), findsOneWidget);
      expect(find.textContaining('expired-link'), findsNothing);
      await disposePage(tester);
    },
  );
  testWidgets('remaining selector review', (tester) async {
    if (!const bool.fromEnvironment('FRIEND_FLOW_PREVIEWS')) return;
    for (final dark in [false, true]) {
      for (final screen in ['category', 'currency']) {
        final key = GlobalKey();
        final commands = WorkspacePageCommandController();
        await _mount(
          tester,
          _Workspace(),
          commands: commands,
          boundary: key,
          dark: dark,
        );
        await tester.pumpAndSettle();
        commands.requestOpenAddExpense();
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(WorkspacePage, skipOffstage: false)),
        )!;
        if (screen == 'category') {
          await tester.scrollUntilVisible(
            find.text(t.workspaceCategory),
            150,
            scrollable: find.byType(Scrollable).first,
          );
          await visibleTap(
            tester,
            find.byKey(const ValueKey('expense-category')),
          );
        } else {
          await tester.tap(find.text('EUR').first);
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/friend-flows/${dark ? 'dark' : 'light'}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
        await disposePage(tester);
        commands.dispose();
      }
    }
  });
  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      testWidgets(
        'category and currency selectors 320px 200% $locale dark=$dark',
        (tester) async {
          final commands = WorkspacePageCommandController();
          await _mount(
            tester,
            _Workspace(),
            commands: commands,
            width: 320,
            scale: 2,
            locale: locale,
            dark: dark,
          );
          await tester.pumpAndSettle();
          commands.requestOpenAddExpense();
          await tester.pumpAndSettle();
          final t = AppLocalizations.of(
            tester.element(find.byType(WorkspacePage, skipOffstage: false)),
          )!;
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('expense-category')),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await visibleTap(
            tester,
            find.byKey(const ValueKey('expense-category')),
          );
          final picker = find.byKey(const ValueKey('expense-category-picker'));
          expect(picker, findsOneWidget);
          await visibleTap(
            tester,
            find.descendant(
              of: picker,
              matching: find.text(t.workspaceCustomCategory),
            ),
          );
          expect(picker, findsNothing);
          expect(tester.takeException(), isNull);
          await tester.scrollUntilVisible(
            find.text('EUR').first,
            -200,
            scrollable: find.byType(Scrollable).first,
          );
          await visibleTap(tester, find.text('EUR').first);
          final search = find.byKey(const ValueKey('expense-currency-search'));
          await tester.enterText(search, 'zzzz');
          await tester.pumpAndSettle();
          expect(find.text(t.profileEditNoCurrenciesFound), findsOneWidget);
          await tester.enterText(search, 'USD');
          await tester.pumpAndSettle();
          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          addTearDown(tester.view.resetViewInsets);
          await tester.pumpAndSettle();
          final choice = find.textContaining('USD ·');
          await tester.ensureVisible(choice);
          await tester.pumpAndSettle();
          expect(tester.getBottomRight(choice).dy, lessThan(544));
          await tester.tap(choice);
          await tester.pumpAndSettle();
          tester.view.resetViewInsets();
          await tester.pumpAndSettle();
          expect(find.text('USD'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await disposePage(tester);
          commands.dispose();
        },
      );
    }
  }
  setUp(() => SharedPreferences.setMockInitialValues({}));
  setUpAll(() async {
    await (FontLoader('packages/cupertino_icons/CupertinoIcons')..addFont(
          rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'),
        ))
        .load();
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  Future<void> openExpenseActions(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('expense-row-1')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const ValueKey('expense-row-1')));
    await tester.pumpAndSettle();
  }

  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      testWidgets('action sheets 320px 200% $locale dark=$dark', (
        tester,
      ) async {
        final commands = WorkspacePageCommandController();
        await _mount(
          tester,
          _Workspace()
            ..data = snapshot(
              expenses: [
                expense(
                  1,
                  name:
                      'A very long dinner description with all details visible',
                  currency: 'USD',
                ),
              ],
            ),
          manager: true,
          commands: commands,
          width: 320,
          scale: 2,
          locale: locale,
          dark: dark,
        );
        await tester.pumpAndSettle();
        commands.requestOpenTripActions();
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('trip-actions-sheet')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        await openExpenseActions(tester);
        expect(
          find.byKey(const ValueKey('expense-actions-sheet')),
          findsOneWidget,
        );
        final heading = tester
            .widget<Text>(
              find.textContaining(
                'A very long dinner description with all details visible ·',
              ),
            )
            .data!;
        expect(heading, contains('€'));
        expect(heading, contains(RegExp(r'24[.,]00')));
        expect(heading, isNot(contains('30')));
        expect(tester.takeException(), isNull);
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('expense-actions-sheet')),
          findsNothing,
        );
        await disposePage(tester);
        commands.dispose();
      });
    }
  }
  for (final locale in ['en', 'lv', 'es']) {
    testWidgets(
      'solo finish confirms, archives and keeps expenses in $locale',
      (tester) async {
        final controller = _Workspace()..data = snapshot(solo: true);
        final commands = WorkspacePageCommandController();
        await _mount(
          tester,
          controller,
          solo: true,
          manager: true,
          commands: commands,
          locale: locale,
          width: 320,
          scale: 2,
        );
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(WorkspacePage)),
        )!;
        expect(find.byTooltip(t.workspaceActivityTab), findsNothing);
        expect(controller.data.allMembersReadyToSettle, isFalse);
        Future<void> finishDialog() async {
          commands.requestOpenTripActions();
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text(t.finishTripAction));
          await tester.tap(find.text(t.finishTripAction));
          await tester.pumpAndSettle();
          expect(find.text(t.finishSoloTripConfirmationText), findsOneWidget);
          expect(find.text(t.finishTripStartSettlementsAction), findsNothing);
        }

        await finishDialog();
        await tester.ensureVisible(find.text(t.cancelAction));
        await tester.tap(find.text(t.cancelAction));
        await tester.pumpAndSettle();
        expect(controller.endedTrips, isEmpty);
        await finishDialog();
        final confirm = find.widgetWithText(FilledButton, t.finishTripAction);
        await tester.ensureVisible(confirm);
        await tester.tap(confirm);
        await tester.pumpAndSettle();
        expect(controller.endedTrips, [1]);
        expect(controller.data.isArchived, isTrue);
        expect(controller.data.expenses, hasLength(2));
        expect(find.text(t.soloTripArchived), findsOneWidget);
        commands.requestOpenTripActions();
        await tester.pumpAndSettle();
        expect(find.text(t.finishTripAction), findsNothing);
        expect(controller.activityOffsets, isEmpty);
        expect(tester.takeException(), isNull);
        await disposePage(tester);
        commands.dispose();
      },
    );
  }
  testWidgets('solo finish failure keeps the trip active and allows retry', (
    tester,
  ) async {
    final controller = _Workspace()
      ..data = snapshot(solo: true)
      ..endError = const ApiException('Could not finish');
    final commands = WorkspacePageCommandController();
    await _mount(
      tester,
      controller,
      solo: true,
      manager: true,
      commands: commands,
    );
    await tester.pumpAndSettle();
    commands.requestOpenTripActions();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish trip'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Finish trip'));
    await tester.pumpAndSettle();
    expect(controller.data.isActive, isTrue);
    expect(find.text('Could not finish'), findsOneWidget);
    commands.requestOpenTripActions();
    await tester.pumpAndSettle();
    expect(find.text('Finish trip'), findsOneWidget);
    await disposePage(tester);
    commands.dispose();
  });
  testWidgets('solo finish protects pending offline expense changes', (
    tester,
  ) async {
    final controller = _Workspace()
      ..data = snapshot(solo: true)
      ..queued = [
        const QueuedMutation(
          id: 'pending',
          tripId: 1,
          createdAtMillis: 1,
          type: QueuedMutationType.addExpense,
        ),
      ];
    final commands = WorkspacePageCommandController();
    await _mount(
      tester,
      controller,
      solo: true,
      manager: true,
      commands: commands,
    );
    await tester.pumpAndSettle();
    commands.requestOpenTripActions();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish trip'));
    await tester.pumpAndSettle();
    expect(
      find.text('Sync your pending changes before finishing this trip.'),
      findsOneWidget,
    );
    expect(controller.endedTrips, isEmpty);
    expect(find.byKey(const ValueKey('app-confirmation-dialog')), findsNothing);
    await disposePage(tester);
    commands.dispose();
  });
  for (final status in ['active', 'archived']) {
    testWidgets('trip actions respect $status and solo mode', (tester) async {
      final commands = WorkspacePageCommandController();
      await _mount(
        tester,
        _Workspace()..data = snapshot(status: status, solo: true),
        manager: true,
        solo: true,
        commands: commands,
      );
      await tester.pumpAndSettle();
      commands.requestOpenTripActions();
      await tester.pumpAndSettle();
      expect(find.text('Invite members'), findsNothing);
      expect(find.byKey(const ValueKey('workspace-trip-share')), findsNothing);
      expect(
        find.text('Finish trip'),
        status == 'active' ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('Edit trip'),
        status == 'active' ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('Delete trip'),
        status == 'active' ? findsOneWidget : findsNothing,
      );
      await disposePage(tester);
      commands.dispose();
    });
  }
  testWidgets(
    'saved crop appears immediately; failed save retains it; removal clears it',
    (tester) async {
      final commands = WorkspacePageCommandController();
      final trips = _Trips();
      final updates = <Trip>[];
      await _mount(
        tester,
        _Workspace(),
        manager: true,
        commands: commands,
        trips: trips,
        onTripUpdated: updates.add,
      );
      await tester.pumpAndSettle();
      Future<void> edit(TripFormDraft draft) async {
        commands.requestOpenTripActions();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit trip'));
        await tester.pumpAndSettle();
        if (updates.isNotEmpty) {
          expect(
            tester
                .widget<TripFormPage>(find.byType(TripFormPage))
                .trip!
                .imageUrl,
            updates.last.imageUrl,
          );
        }
        Navigator.of(tester.element(find.byType(TripFormPage))).pop(draft);
        await tester.pumpAndSettle();
      }

      final croppedBytes = Uint8List.fromList([1, 2, 3]);
      await edit(
        TripFormDraft(
          name: 'Lisbon getaway',
          currencyCode: 'EUR',
          tripMode: 'group',
          memberIds: [],
          image: (bytes: croppedBytes, fileName: 'cropped.jpg', source: null),
        ),
      );
      expect(trips.uploadedBytes, croppedBytes);
      expect(trips.savedPath, 'uploads/trips/cropped.webp');
      final photo = find.byKey(const ValueKey('workspace-cover-photo'));
      expect(
        (tester.widget<Image>(photo).image as NetworkImage).url,
        'https://example.test/cropped.webp',
      );
      expect(updates, hasLength(1));
      trips.failUpdate = true;
      const remove = TripFormDraft(
        name: 'Lisbon getaway',
        currencyCode: 'EUR',
        tripMode: 'group',
        memberIds: [],
        removeImage: true,
      );
      await edit(remove);
      expect(photo, findsOneWidget);
      expect(updates, hasLength(1));
      trips.failUpdate = false;
      await edit(remove);
      expect(photo, findsNothing);
      expect(updates, hasLength(2));
      expect(updates.last.imageUrl, isNull);
      expect(tester.takeException(), isNull);
      await disposePage(tester);
      commands.dispose();
    },
  );

  testWidgets('trip actions close, edit and cancel deletion', (tester) async {
    final commands = WorkspacePageCommandController();
    await _mount(tester, _Workspace(), manager: true, commands: commands);
    await tester.pumpAndSettle();
    commands.requestOpenTripActions();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit trip'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsWidgets);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    commands.requestOpenTripActions();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete trip'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('app-confirmation-dialog')),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Cancel').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-confirmation-dialog')), findsNothing);
    await disposePage(tester);
    commands.dispose();
  });
  testWidgets(
    'expense actions preserve confirmation and reaction destination',
    (tester) async {
      final controller = _Workspace();
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      await openExpenseActions(tester);
      await tester.tap(find.text('Delete expense'));
      await tester.pumpAndSettle();
      expect(controller.deletes, 0);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel').last);
      await tester.pumpAndSettle();
      expect(controller.deletes, 0);
      await openExpenseActions(tester);
      await tester.tap(find.text('👍'));
      await tester.pumpAndSettle();
      expect(controller.reactionCalls, [(1, 1, '👍')]);
      expect(find.byKey(const ValueKey('expense-actions-sheet')), findsNothing);
      await disposePage(tester);
    },
  );
  testWidgets('archived expense retains reactions but no edit or delete', (
    tester,
  ) async {
    await _mount(tester, _Workspace()..data = snapshot(status: 'archived'));
    await tester.pumpAndSettle();
    await openExpenseActions(tester);
    expect(find.text('Edit expense'), findsNothing);
    expect(find.text('Delete expense'), findsNothing);
    expect(find.text('👍'), findsOneWidget);
    await disposePage(tester);
  });

  testWidgets('budget review images', (tester) async {
    if (!const bool.fromEnvironment('BUDGET_PREVIEWS')) return;
    for (final dark in [false, true]) {
      final key = GlobalKey();
      final commands = WorkspacePageCommandController();
      final controller = _Workspace()
        ..data = snapshot().copyWith(budgetCents: 150000, budgetLoaded: true);
      await _mount(
        tester,
        controller,
        manager: true,
        dark: dark,
        boundary: key,
        commands: commands,
      );
      await tester.pumpAndSettle();
      for (final screen in ['overview', 'edit']) {
        if (screen == 'edit') {
          commands.requestOpenTripActions();
          await tester.pumpAndSettle();
          await tester.tap(find.text('Edit trip'));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/trip-budget/${dark ? 'dark' : 'light'}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await disposePage(tester);
      commands.dispose();
    }
  });

  testWidgets(
    'budget uses complete group spending rather than loaded expenses or own share',
    (tester) async {
      final controller = _Workspace()
        ..data = snapshot().copyWith(budgetCents: 150000, budgetLoaded: true);
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('trip-budget-spent')))
            .data,
        contains('1,000.00'),
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('trip-budget-remaining')))
            .data,
        contains('500.00'),
      );
      expect(find.text('Group budget'), findsOneWidget);
      await disposePage(tester);
    },
  );

  testWidgets(
    'summary uses complete balances, personal share and real trip status',
    (tester) async {
      await _mount(tester, _Workspace());
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('workspace-total'))).data,
        contains('1,000.00'),
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('workspace-share'))).data,
        contains('400.00'),
      );
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Settled'), findsNothing);
      expect(find.text('You get back €200.00'), findsOneWidget);
      await disposePage(tester);
    },
  );
  for (final dark in [false, true]) {
    for (final locale in ['en', 'lv', 'es']) {
      for (final solo in [false, true]) {
        testWidgets('320px 200% $locale dark=$dark solo=$solo', (tester) async {
          final controller = _Workspace()
            ..data = snapshot(
              solo: solo,
              expenses: [
                expense(
                  1,
                  name:
                      'Very long expense title with a café and a train journey',
                  currency: 'USD',
                ),
              ],
            );
          await _mount(
            tester,
            controller,
            solo: solo,
            dark: dark,
            locale: locale,
            scale: 2,
            width: 320,
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('workspace-share')),
            solo ? findsNothing : findsOneWidget,
          );
          final t = AppLocalizations.of(
            tester.element(find.byType(WorkspacePage)),
          )!;
          expect(
            find.byTooltip(t.navBalances),
            solo ? findsNothing : findsOneWidget,
          );
          expect(
            find.byTooltip(t.workspaceActivityTab),
            solo ? findsNothing : findsOneWidget,
          );
          if (solo) expect(controller.activityOffsets, isEmpty);
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('expense-row-1')),
            250,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(find.textContaining('USD'), findsWidgets);
          expect(tester.takeException(), isNull);
          await disposePage(tester);
        });
      }
    }
  }
  for (final status in ['active', 'settling', 'archived']) {
    testWidgets('empty $status keeps appropriate expense action', (
      tester,
    ) async {
      await _mount(
        tester,
        _Workspace()..data = snapshot(expenses: [], status: status),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('No expenses yet.'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text('Add expenses'),
        status == 'active' ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
      await disposePage(tester);
    });
  }
  testWidgets('search preserves query and clear returns the loaded rows', (
    tester,
  ) async {
    await _mount(tester, _Workspace());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'not-in-any-expense');
    await tester.pumpAndSettle();
    expect(find.text('No matching expenses'), findsOneWidget);
    expect(find.text('No expenses yet.'), findsNothing);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('expense-row-1')), findsOneWidget);
    await disposePage(tester);
  });
  testWidgets('expense starts without a category and Other can be saved', (
    tester,
  ) async {
    final controller = _Workspace();
    await _mount(tester, controller, openAddExpenseOnStart: true);
    await tester.pumpAndSettle();
    expect(find.text('Choose category'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('expense-form-amount')),
      '12',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('expense-category')));
    await tester.tap(find.byKey(const ValueKey('expense-category')));
    await tester.pumpAndSettle();
    final other = find.widgetWithText(ListTile, 'Other');
    await tester.ensureVisible(other);
    expect(tester.widget<ListTile>(other).selected, isFalse);
    await tester.tap(other);
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();
    expect(controller.saves, 1);
    expect(controller.savedCategory, 'other');
    expect(tester.takeException(), isNull);
    await disposePage(tester);
  });

  testWidgets(
    'expense filters combine category payer and search and can be reset',
    (tester) async {
      final controller = _Workspace()
        ..data = snapshot(
          expenses: [
            expense(1, category: 'other'),
            expense(2, category: 'other', payer: 8),
            expense(3, category: 'food', payer: 8),
          ],
        );
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('expense-filters')));
      await tester.tap(find.byKey(const ValueKey('expense-filters')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('expense-filters-menu')), findsOne);
      expect(find.byKey(const ValueKey('expense-filters-save')), findsNothing);
      expect(find.byKey(const ValueKey('expense-filters-clear')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('expense-filter-payer-row')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('expense-filter-payer-8')));
      await tester.pumpAndSettle();
      // Applied at once, the menu stays open on its first page.
      expect(find.byKey(const ValueKey('expense-filters-menu')), findsOne);
      expect(find.byKey(const ValueKey('expense-row-1')), findsNothing);
      expect(find.byKey(const ValueKey('expense-row-3')), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('expense-filter-category-row')),
      );
      await tester.pumpAndSettle();
      await showInFilterMenu(
        tester,
        find.byKey(const ValueKey('expense-filter-category-other')),
      );
      await tester.tap(
        find.byKey(const ValueKey('expense-filter-category-other')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('expense-row-2')), findsOneWidget);
      expect(find.byKey(const ValueKey('expense-row-3')), findsNothing);
      // Tapping outside closes the menu and keeps the filters.
      await tester.tapAt(const Offset(20, 800));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('expense-filters-menu')), findsNothing);
      expect(find.byKey(const ValueKey('expense-row-1')), findsNothing);
      expect(find.byKey(const ValueKey('expense-row-2')), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'no-match');
      await tester.pumpAndSettle();
      expect(find.text('No matching expenses'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('expense-row-2')), findsOneWidget);
      expect(find.byKey(const ValueKey('expense-row-1')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('expense-filters')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('expense-filters-clear')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('expense-filters-clear')), findsNothing);
      expect(find.byKey(const ValueKey('expense-row-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('expense-row-2')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await disposePage(tester);
    },
  );

  testWidgets('pagination is explicit, retryable and deduplicated', (
    tester,
  ) async {
    final controller = _Workspace()..more = true;
    await _mount(tester, controller);
    await tester.pumpAndSettle();
    expect(controller.pageCalls, 1);
    await tester.scrollUntilVisible(
      find.text('Load more expenses'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Load more expenses'));
    await tester.pumpAndSettle();
    controller.pageFailure = true;
    await tester.tap(find.text('Load more expenses'));
    await tester.pumpAndSettle();
    expect(find.text('Page failed'), findsOneWidget);
    controller.pageFailure = false;
    await tester.tap(find.text('Load more expenses'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('expense-row-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('expense-row-3')), findsOneWidget);
    expect(controller.pageCalls, 3);
    await disposePage(tester);
  });
  testWidgets(
    'saved offline trip opens the expense form and displays a queued addition',
    (tester) async {
      final controller = _Workspace()
        ..cache = snapshot()
        ..error = const ApiException('Offline', isNetworkError: true);
      final commands = WorkspacePageCommandController();
      await _mount(tester, controller, commands: commands);
      await tester.pumpAndSettle();
      commands.requestOpenAddExpense();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('expense-form-amount')), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('expense-form-amount')),
        '12.34',
      );
      await selectExpenseFood(tester);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();
      expect(controller.saves, 1);
      expect(controller.savedAmount, 12.34);
      expect(find.byKey(const ValueKey('expense-form-amount')), findsNothing);
      await tester.scrollUntilVisible(
        find.textContaining('12.34').first,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('12.34'), findsWidgets);
      expect(tester.takeException(), isNull);
      await disposePage(tester);
      commands.dispose();
    },
  );

  for (final delayPage in [false, true]) {
    testWidgets(
      'cached trip saves before stalled refresh; expenses page: $delayPage',
      (tester) async {
        final remote = Completer<WorkspaceSnapshot>();
        final page = Completer<TripExpensesPage>();
        final controller = _Workspace()
          ..cache = snapshot()
          ..pending = delayPage ? null : remote
          ..pendingPage = delayPage ? page : null;
        await _mount(tester, controller, openAddExpenseOnStart: true);
        // Do not wait for the background spinner to settle: the server is stalled.
        await tester.pump(const Duration(milliseconds: 400));
        expect(remote.isCompleted, isFalse);
        expect(
          find.byKey(const ValueKey('expense-form-amount')),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const ValueKey('expense-form-amount')),
          '12.34',
        );
        // Finish the outstanding read after the local save, proving it cannot
        // overwrite the newly queued expense with an older server snapshot.
        await selectExpenseFood(tester);
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Add'));
        await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));
        expect(controller.saves, 1);
        if (delayPage) {
          expect(controller.pageCalls, 1);
          page.complete(
            TripExpensesPage(
              items: snapshot().expenses,
              hasMore: false,
              nextCursor: null,
              nextOffset: null,
            ),
          );
        } else {
          remote.complete(snapshot());
        }
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.textContaining('12.34'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('12.34'), findsWidgets);
        expect(tester.takeException(), isNull);
        await disposePage(tester);
      },
    );
  }

  testWidgets(
    'cached offline data is retained; access denial clears it and prevents cache revival',
    (tester) async {
      final controller = _Workspace()
        ..cache = snapshot()
        ..error = const ApiException('Offline', isNetworkError: true);
      final commands = WorkspacePageCommandController();
      await _mount(tester, controller, commands: commands);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('workspace-total')), findsOneWidget);
      expect(
        find.text('Showing saved data. It may be out of date.'),
        findsOneWidget,
      );
      controller.error = const ApiException('Access denied', statusCode: 403);
      commands.requestRefresh();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('workspace-total')), findsNothing);
      controller.error = const ApiException('Offline', isNetworkError: true);
      commands.requestRefresh();
      await tester.pumpAndSettle();
      expect(controller.cacheReads, 1);
      expect(find.byKey(const ValueKey('workspace-total')), findsNothing);
      await disposePage(tester);
      commands.dispose();
    },
  );
  testWidgets(
    'initial skeleton and overlapping refreshes never show a stale result',
    (tester) async {
      final first = Completer<WorkspaceSnapshot>();
      final controller = _Workspace()..pending = first;
      final commands = WorkspacePageCommandController();
      await _mount(tester, controller, commands: commands);
      expect(find.byType(AppSkeletonBlock), findsWidgets);
      expect(find.text('No expenses yet.'), findsNothing);
      controller.pending = null;
      controller.data = snapshot(solo: true);
      commands.requestRefresh();
      await tester.pumpAndSettle();
      first.complete(snapshot());
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('workspace-total'))).data,
        contains('600.00'),
      );
      await disposePage(tester);
      commands.dispose();
    },
  );
  testWidgets('balance rows stay on one line with a signed amount', (
    tester,
  ) async {
    final controller = _Workspace()
      ..data = snapshot().copyWith(
        balances: const [
          BalanceItem(id: 7, nickname: 'Matiss', paid: 9, owed: 4, net: 5),
          BalanceItem(id: 8, nickname: 'Anna', paid: 0, owed: 5, net: -5),
          BalanceItem(id: 9, nickname: 'Igors', paid: 1, owed: 1, net: 0),
        ],
      );
    await _mount(tester, controller);
    await tester.pumpAndSettle();
    await _selectTab(tester, 'Balances');
    final row = find.byKey(const ValueKey('balance-row-7'));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('balance-row-9')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    String amount(int id) =>
        tester.widget<Text>(find.byKey(ValueKey('balance-amount-$id'))).data!;
    expect(amount(7), startsWith('+'));
    expect(amount(8), startsWith('−'));
    expect(amount(8), isNot(contains('-')));
    final t = AppLocalizations.of(tester.element(find.byType(WorkspacePage)))!;
    expect(amount(9), t.settledLabel);
    expect(find.text(t.workspaceGetsBackFromTheGroup), findsNothing);
    expect(find.text(t.workspaceOwesToTheGroup), findsNothing);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('balance-amount-8')))
          .semanticsLabel,
      contains(t.workspaceOwesToTheGroup),
    );
    expect(
      find.descendant(of: row, matching: find.byIcon(Icons.chevron_right)),
      findsNothing,
    );
    expect(
      tester.getTopRight(find.byKey(const ValueKey('balance-amount-7'))).dx,
      closeTo(tester.getTopRight(row).dx, .1),
    );
    final height = tester.getSize(row).height;
    expect(height, greaterThanOrEqualTo(48));
    expect(height, lessThanOrEqualTo(56));
    expect(tester.takeException(), isNull);
    await disposePage(tester);
  });

  testWidgets('expense dates and split modes only show when they add meaning', (
    tester,
  ) async {
    final controller = _Workspace()
      ..data = snapshot(
        expenses: [
          expense(1, name: 'Dinner', date: '2026-10-21'),
          expense(2, name: 'Taxi', date: '2026-10-21', splitMode: 'exact'),
          expense(3, name: 'Museum', date: '2026-10-20'),
        ],
      );
    await _mount(tester, controller);
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(WorkspacePage));
    final t = AppLocalizations.of(context)!;
    final row = find.byKey(const ValueKey('expense-row-1'));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('expense-row-3')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    String details(int id) => tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(ValueKey('expense-row-$id')),
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data ?? '')
        .join(' | ');
    expect(find.text(t.equalSplitLabel), findsNothing);
    expect(details(1), isNot(contains(t.equalSplitLabel)));
    expect(details(2), contains(t.exactAmountsLabel));
    expect(details(3), contains('Oct 20'));
    expect(details(1), isNot(contains('Oct 21')));
    expect(find.text('Oct 21'), findsOneWidget);
    expect(find.text('Oct 20'), findsNothing);
    expect(
      find.descendant(of: row, matching: find.byIcon(Icons.chevron_right)),
      findsNothing,
    );
    final height = tester.getSize(row).height;
    expect(height, greaterThanOrEqualTo(48));
    expect(height, lessThanOrEqualTo(64));
    expect(tester.takeException(), isNull);
    await disposePage(tester);
  });

  testWidgets('activity sentence uses a first name unless it is ambiguous', (
    tester,
  ) async {
    WorkspaceActivityEvent event(int id, int actor, String name, String type) =>
        WorkspaceActivityEvent(
          id: id,
          tripId: 1,
          actorUserId: actor,
          actorName: name,
          eventType: type,
          payload: const {},
          createdAt: '2026-10-21 10:30:00',
        );
    final controller = _Workspace()
      ..activity = [
        event(1, 7, 'Matiss Geinerts', 'payment.confirmed'),
        event(2, 9, 'Matīss Geinerts', 'payment.requested'),
        event(3, 8, 'Anna Ozola', 'trip.member_joined'),
        event(4, 8, 'Anna Ozola', 'trip.settled'),
      ];
    await _mount(tester, controller);
    await tester.pumpAndSettle();
    final t = AppLocalizations.of(tester.element(find.byType(WorkspacePage)))!;
    await _selectTab(tester, t.workspaceActivityTab);
    Future<String> sentence(int id) async {
      final row = find.byKey(ValueKey('activity-row-$id'));
      await tester.scrollUntilVisible(
        row,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      return tester
          .widget<RichText>(
            find.descendant(of: row, matching: find.byType(RichText)).at(1),
          )
          .text
          .toPlainText();
    }

    expect(
      await sentence(1),
      'Matiss Geinerts ${t.activityEventPaymentConfirmed}',
    );
    expect(
      await sentence(2),
      'Matīss Geinerts ${t.activityEventPaymentRequested}',
    );
    expect(await sentence(3), 'Anna ${t.activityEventTripMemberJoined}');
    expect(await sentence(4), t.activityEventTripSettled);
    expect(tester.takeException(), isNull);
    await disposePage(tester);
  });

  for (final dark in [false, true]) {
    testWidgets('compact lists fit 320px at 200% dark=$dark', (tester) async {
      final controller = _Workspace()
        ..data = snapshot(
          expenses: [
            expense(1, name: 'Dinner', date: '2026-10-21', splitMode: 'exact'),
            expense(2, name: 'Taxi', date: '2026-10-20', currency: 'USD'),
          ],
        )
        ..activity = [activityEvent(1), activityEvent(2)];
      await _mount(
        tester,
        controller,
        dark: dark,
        locale: 'lv',
        width: 320,
        scale: 2,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage)),
      )!;
      for (final tab in [t.navBalances, t.workspaceActivityTab]) {
        await _selectTab(tester, tab);
        expect(tester.takeException(), isNull);
      }
      await disposePage(tester);
    });
  }

  if (const bool.fromEnvironment('COMPACT_LIST_PREVIEWS')) {
    for (final dark in [false, true]) {
      testWidgets('capture compact lists dark=$dark', (tester) async {
        final key = GlobalKey();
        final controller = _Workspace()
          ..data =
              snapshot(
                expenses: [
                  expense(1, name: 'Dinner', date: '2026-10-21'),
                  expense(
                    2,
                    name: 'Taxi',
                    date: '2026-10-21',
                    splitMode: 'exact',
                  ),
                  expense(3, name: 'Museum', date: '2026-10-20', payer: 8),
                  expense(
                    4,
                    name: 'Train',
                    date: '2026-10-19',
                    currency: 'USD',
                  ),
                ],
              ).copyWith(
                balances: const [
                  BalanceItem(
                    id: 7,
                    nickname: 'Matiss',
                    paid: 9,
                    owed: 4,
                    net: 5,
                  ),
                  BalanceItem(
                    id: 8,
                    nickname: 'Anna',
                    paid: 0,
                    owed: 5,
                    net: -5,
                  ),
                  BalanceItem(
                    id: 9,
                    nickname: 'Igors',
                    paid: 1,
                    owed: 1,
                    net: 0,
                  ),
                ],
              )
          ..activity = [
            activityEvent(1),
            for (final item in [
              (2, 'payment.request_marked_sent'),
              (3, 'trip.member_joined'),
              (4, 'trip.settled'),
            ])
              WorkspaceActivityEvent(
                id: item.$1,
                tripId: 1,
                actorUserId: 8,
                actorName: 'Anna Ozola',
                eventType: item.$2,
                payload: const {'amount_cents': 1666},
                createdAt: '2026-10-21 10:30:00',
              ),
          ];
        await _mount(tester, controller, dark: dark, boundary: key);
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(WorkspacePage)),
        )!;
        Future<void> capture(String name, Finder scrollTo) async {
          await tester.scrollUntilVisible(
            scrollTo,
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final image =
                await (key.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              '../output/design/compact-lists/${dark ? 'dark' : 'light'}-$name.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        await capture('expenses', find.byKey(const ValueKey('expense-row-4')));
        await _selectTab(tester, 'Balances');
        await capture('balances', find.byKey(const ValueKey('balance-row-9')));
        await _selectTab(tester, t.workspaceActivityTab);
        await capture('activity', find.byKey(const ValueKey('activity-row-4')));
        await disposePage(tester);
      });
    }
  }

  testWidgets('workspace photo preserves the crop frame', (tester) async {
    await _mount(
      tester,
      _Workspace(),
      coverUrl: 'https://example.test/cropped.jpg',
    );
    await tester.pumpAndSettle();
    final photo = find.byKey(const ValueKey('workspace-cover-photo'));
    expect(tester.widget<Image>(photo).fit, BoxFit.contain);
    final size = tester.getSize(photo);
    expect(size.width / size.height, closeTo(16 / 9, .001));
    await disposePage(tester);
  });

  for (final mode in ['equal', 'exact', 'percent', 'shares']) {
    testWidgets('expense detail shows $mode icon and trailing share amounts', (
      tester,
    ) async {
      await _mount(
        tester,
        _Workspace()..data = snapshot(expenses: [expense(1, splitMode: mode)]),
      );
      await tester.pumpAndSettle();
      final row = find.byKey(const ValueKey('expense-row-1'));
      await tester.scrollUntilVisible(
        row,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(row);
      await tester.pumpAndSettle();
      final badge = find.byKey(const ValueKey('expense-split-mode'));
      final t = AppLocalizations.of(tester.element(badge))!;
      final (label, icon) = switch (mode) {
        'exact' => (t.exactAmountsLabel, Icons.payments_outlined),
        'percent' => (t.percentagesLabel, Icons.percent_rounded),
        'shares' => (t.sharesLabel, Icons.pie_chart_outline_rounded),
        _ => (t.equalSplitLabel, Icons.drag_handle_rounded),
      };
      expect(
        find.descendant(of: badge, matching: find.text(label)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: badge, matching: find.byIcon(icon)),
        findsOneWidget,
      );
      final amount = find.byKey(const ValueKey('expense-share-amount-7'));
      await tester.scrollUntilVisible(
        amount,
        100,
        scrollable: find.byType(Scrollable).last,
      );
      expect(tester.getTopRight(amount).dx, closeTo(390 - 20, .1));
      expect(tester.takeException(), isNull);
      await disposePage(tester);
    });
  }

  for (final payer in [7, 8]) {
    testWidgets('expense actions preserve payer permissions: $payer', (
      tester,
    ) async {
      await _mount(
        tester,
        _Workspace()..data = snapshot(expenses: [expense(1, payer: payer)]),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('expense-row-1')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.longPress(find.byKey(const ValueKey('expense-row-1')));
      await tester.pumpAndSettle();
      expect(
        find.text('Edit expense'),
        payer == 7 ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('Delete expense'),
        payer == 7 ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
      await disposePage(tester);
    });
  }

  for (final dark in [false, true]) {
    for (final locale in ['en', 'lv', 'es']) {
      for (final solo in [false, true]) {
        testWidgets(
          'expense detail and form 320px 200% $locale dark=$dark solo=$solo',
          (tester) async {
            final commands = WorkspacePageCommandController();
            final controller = _Workspace()
              ..data = snapshot(
                solo: solo,
                expenses: [
                  expense(
                    1,
                    name:
                        'A very long dinner description that must be readable in full',
                    currency: 'USD',
                  ),
                ],
              );
            await _mount(
              tester,
              controller,
              commands: commands,
              width: 320,
              scale: 2,
              locale: locale,
              dark: dark,
              solo: solo,
            );
            await tester.pumpAndSettle();
            final t = AppLocalizations.of(
              tester.element(find.byType(WorkspacePage)),
            )!;
            await tester.scrollUntilVisible(
              find.byKey(const ValueKey('expense-row-1')),
              250,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const ValueKey('expense-row-1')));
            await tester.pumpAndSettle();
            expect(
              find.byKey(const ValueKey('expense-detail-total')),
              findsOneWidget,
            );
            expect(find.textContaining('USD 30'), findsWidgets);
            if (!solo) {
              await tester.scrollUntilVisible(
                find.text(t.splitBreakdownTitle),
                200,
                scrollable: find.byType(Scrollable).last,
              );
              await tester.pumpAndSettle();
            }
            expect(
              find.text(t.splitBreakdownTitle),
              solo ? findsNothing : findsOneWidget,
            );
            await tester.scrollUntilVisible(
              find.text(t.expenseAddCommentHint),
              200,
              scrollable: find.byType(Scrollable).last,
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await tester.tap(
              find.byTooltip(
                MaterialLocalizations.of(
                  tester.element(find.byType(WorkspacePage)),
                ).closeButtonTooltip,
              ),
            );
            await tester.pumpAndSettle();
            commands.requestOpenAddExpense();
            await tester.pumpAndSettle();
            await tester.enterText(
              find.byKey(const ValueKey('expense-form-amount')),
              '1234.56',
            );
            await tester.scrollUntilVisible(
              find.text(t.addReceiptAction),
              200,
              scrollable: find.byType(Scrollable).last,
            );
            await tester.pumpAndSettle();
            expect(find.byType(CheckboxListTile), findsNothing);
            expect(tester.takeException(), isNull);
            await disposePage(tester);
          },
        );
      }
    }
  }
  for (final source in ['camera', 'gallery', 'files', 'remove']) {
    testWidgets(
      'receipt source $source reaches upload and leaves the form alone',
      (tester) async {
        final dir = Directory.systemTemp.createTempSync('splyto-receipt-test-');
        addTearDown(() => dir.deleteSync(recursive: true));
        final receiptBytes = await tester.runAsync(_receiptPreviewFixture);
        final file = File('${dir.path}/receipt.png')
          ..writeAsBytesSync(receiptBytes!);
        const photoChannel = MethodChannel('plugins.flutter.io/image_picker');
        const fileChannel = MethodChannel(
          'miguelruivo.flutter.plugins.filepicker',
          JSONMethodCodec(),
        );
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        const cropChannel = MethodChannel('plugins.hunghd.vn/image_cropper');
        var crops = 0;
        messenger.setMockMethodCallHandler(cropChannel, (call) async {
          crops++;
          final output = File.fromUri(dir.uri.resolve('cropped.jpg'));
          await output.writeAsBytes(receiptBytes);
          return output.path;
        });
        addTearDown(
          () => messenger.setMockMethodCallHandler(cropChannel, null),
        );
        Map<dynamic, dynamic>? photoArgs;
        messenger.setMockMethodCallHandler(photoChannel, (call) async {
          expect(call.method, 'pickImage');
          photoArgs = call.arguments as Map<dynamic, dynamic>;
          return file.path;
        });
        FilePickerIO.registerWith();
        messenger.setMockMethodCallHandler(
          fileChannel,
          (call) async => [
            {
              'name': 'receipt.png',
              'path': file.path,
              'size': receiptBytes.length,
              'bytes': null,
            },
          ],
        );
        addTearDown(() {
          messenger.setMockMethodCallHandler(photoChannel, null);
          messenger.setMockMethodCallHandler(fileChannel, null);
        });
        final commands = WorkspacePageCommandController();
        final controller = _Workspace();
        final previewKey = const bool.fromEnvironment('EXPENSE_PREVIEWS')
            ? GlobalKey()
            : null;
        await _mount(
          tester,
          controller,
          commands: commands,
          boundary: previewKey,
          dark: source == 'gallery',
        );
        await tester.pumpAndSettle();
        commands.requestOpenAddExpense();
        await tester.pumpAndSettle();
        await selectExpenseFood(tester);
        await visibleTap(
          tester,
          find.byKey(const ValueKey('receipt-add')),
          settle: false,
        );
        final t = AppLocalizations.of(
          tester.element(find.byType(WorkspacePage, skipOffstage: false)),
        )!;
        for (final label in [
          t.takePhotoAction,
          t.chooseFromLibraryAction,
          t.chooseReceiptFile,
        ]) {
          expect(find.text(label), findsOneWidget);
        }
        final label = source == 'camera'
            ? t.takePhotoAction
            : source == 'gallery'
            ? t.chooseFromLibraryAction
            : t.chooseReceiptFile;
        await tester.tap(find.text(label));
        await tester.pump(const Duration(milliseconds: 400));
        // Cropping and reading the file take real time, which fake pumps cannot
        // advance. A slow CI machine needs far longer than a developer laptop.
        for (
          var attempt = 0;
          attempt < 1000 && controller.receiptUploads.isEmpty;
          attempt++
        ) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)),
          );
          await tester.pump();
        }
        expect(controller.receiptUploads, hasLength(1));
        await tester.pumpAndSettle();
        expect(controller.receiptUploads.single.tripId, 1);
        expect(controller.receiptUploads.single.bytes, receiptBytes);
        expect(controller.receiptUploads.single.fileName, 'receipt.jpg');
        expect(crops, 1);
        expect(file.existsSync(), isTrue);
        if (source == 'camera' || source == 'gallery') {
          expect(photoArgs!['source'], source == 'camera' ? 0 : 1);
        }
        expect(
          tester
              .widget<TextField>(
                find.byKey(const ValueKey('expense-form-amount')),
              )
              .controller!
              .text,
          isEmpty,
        );
        expect(
          find.byKey(const ValueKey('receipt-attachment-card')),
          findsOneWidget,
        );
        expect(find.text(t.replaceReceiptAction), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const ValueKey('receipt-attachment-card')),
        );
        await tester.pumpAndSettle();
        final thumbnail = find.descendant(
          of: find.byKey(const ValueKey('receipt-attachment-card')),
          matching: find.byType(Image),
        );
        expect(thumbnail, findsOneWidget);
        await tester.runAsync(
          () => precacheImage(
            tester.widget<Image>(thumbnail).image,
            tester.element(thumbnail),
          ),
        );
        await tester.pumpAndSettle();
        if (previewKey != null) {
          await tester.runAsync(() async {
            final boundary =
                previewKey.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            final file = File('../output/design/expenses/receipt-$source.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }
        if (source == 'remove') {
          await visibleTap(
            tester,
            find.byKey(const ValueKey('receipt-remove')),
          );
          expect(
            find.byKey(const ValueKey('receipt-attachment-card')),
            findsNothing,
          );
          expect(find.text(t.addReceiptAction), findsOneWidget);
        }

        await tester.enterText(
          find.byKey(const ValueKey('expense-form-amount')),
          '42.50',
        );
        await visibleTap(
          tester,
          find.widgetWithText(ElevatedButton, t.addAction),
        );
        expect(controller.saves, 1);
        expect(
          controller.savedReceiptPath,
          source == 'remove' ? isNull : 'receipts/test.jpg',
        );
        expect(controller.receiptUploads, hasLength(1));
        expect(tester.takeException(), isNull);
        await disposePage(tester);
        commands.dispose();
      },
    );
  }
  for (final denied in [false, true]) {
    testWidgets(
      'receipt photo cancellation or denied access keeps draft: $denied',
      (tester) async {
        const channel = MethodChannel('plugins.flutter.io/image_picker');
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(channel, (_) async {
          if (denied) throw PlatformException(code: 'camera_access_denied');
          return null;
        });
        addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
        final commands = WorkspacePageCommandController();
        final controller = _Workspace();
        await _mount(tester, controller, commands: commands);
        await tester.pumpAndSettle();
        commands.requestOpenAddExpense();
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('expense-form-amount')),
          '9.99',
        );
        await visibleTap(
          tester,
          find.byKey(const ValueKey('receipt-add')),
          settle: false,
        );
        final t = AppLocalizations.of(
          tester.element(find.byType(WorkspacePage, skipOffstage: false)),
        )!;
        await tester.tap(find.text(t.takePhotoAction));
        await tester.pumpAndSettle();
        expect(controller.receiptUploads, isEmpty);
        expect(
          tester
              .widget<TextField>(
                find.byKey(const ValueKey('expense-form-amount')),
              )
              .controller!
              .text,
          '9.99',
        );
        expect(
          tester
              .widget<TextButton>(find.byKey(const ValueKey('receipt-add')))
              .onPressed,
          isNotNull,
        );
        if (denied) {
          expect(find.text(t.receiptPhotoAccessDenied), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await disposePage(tester);
        commands.dispose();
      },
    );
  }
  testWidgets(
    'failed save preserves draft; pending save blocks duplicate requests',
    (tester) async {
      final commands = WorkspacePageCommandController();
      final controller = _Workspace()..saveFailure = true;
      await _mount(tester, controller, commands: commands);
      await tester.pumpAndSettle();
      commands.requestOpenAddExpense();
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('expense-form-amount')),
        '42.50',
      );
      await selectExpenseFood(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();
      expect(find.text('Save failed'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('expense-form-amount')),
            )
            .controller!
            .text,
        '42.50',
      );
      expect(controller.saves, 1);
      controller.saveFailure = false;
      controller.saveGate = Completer<void>();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pump();
      expect(find.text('Saving...'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byKey(const ValueKey('expense-form-amount')), findsOneWidget);
      expect(controller.saves, 2);
      controller.saveGate!.complete();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('expense-form-amount')), findsNothing);
      expect(controller.savedCurrency, 'EUR');
      await disposePage(tester);
    },
  );
  testWidgets(
    'comments failure is retryable and never claims an empty discussion',
    (tester) async {
      final controller = _Workspace()..commentsFailure = true;
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('expense-row-1')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('expense-row-1')));
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage)),
      )!;
      await tester.scrollUntilVisible(
        find.text(t.retryAction),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.text(t.expenseNoComments), findsNothing);
      expect(find.text(t.expenseCommentsLoadFailed), findsOneWidget);
      controller.commentsFailure = false;
      await tester.tap(find.text(t.retryAction));
      await tester.pumpAndSettle();
      expect(find.text(t.expenseNoComments), findsOneWidget);
      await disposePage(tester);
    },
  );

  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      testWidgets('custom splits 320px 200% $locale dark=$dark', (
        tester,
      ) async {
        final commands = WorkspacePageCommandController();
        await _mount(
          tester,
          _Workspace()
            ..data = snapshot().copyWith(
              users: const [
                WorkspaceUser(
                  id: 7,
                  nickname: 'Matiss Geinerts with a long participant name',
                ),
                WorkspaceUser(
                  id: 8,
                  nickname: 'Anna Parker with a long participant name',
                ),
              ],
            ),
          commands: commands,
          width: 320,
          scale: 2,
          locale: locale,
          dark: dark,
        );
        await tester.pumpAndSettle();
        commands.requestOpenAddExpense();
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(WorkspacePage, skipOffstage: false)),
        )!;
        await tester.enterText(
          find.byKey(const ValueKey('expense-form-amount')),
          '100',
        );
        for (final label in [
          t.exactAmountsLabel,
          t.percentagesLabel,
          t.sharesLabel,
        ]) {
          await tester.scrollUntilVisible(
            find.text(t.splitModeLabel),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await visibleTap(
            tester,
            find.byKey(const ValueKey('expense-custom-split')),
          );
          final picker = find.byKey(const ValueKey('expense-editor-done'));
          expect(picker, findsOneWidget);
          await pickSplitMode(tester, label);
          for (final id in [7, 8]) {
            final field = find.byKey(ValueKey('split-input-$id'));
            await tester.ensureVisible(field);
            await tester.pumpAndSettle();
            await tester.enterText(field, '1');
            expect(tester.widget<TextField>(field).controller!.text, '1');
          }
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('expense-editor-close')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        await disposePage(tester);
        commands.dispose();
      });
    }
  }
  for (final mode in ['exact', 'percent', 'shares']) {
    testWidgets('group form submits validated $mode split', (tester) async {
      final commands = WorkspacePageCommandController();
      final controller = _Workspace();
      await _mount(tester, controller, commands: commands);
      await tester.pumpAndSettle();
      commands.requestOpenAddExpense();
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('expense-form-amount')),
        '10',
      );
      await selectExpenseFood(tester);
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage, skipOffstage: false)),
      )!;
      final labels = {
        'exact': t.exactAmountsLabel,
        'percent': t.percentagesLabel,
        'shares': t.sharesLabel,
      };
      await tester.scrollUntilVisible(
        find.text(t.splitModeLabel),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('expense-custom-split')));
      await tester.pumpAndSettle();
      await pickSplitMode(tester, labels[mode]!);
      await tester.pumpAndSettle();
      for (final name in ['Matiss', 'Anna']) {
        final field = find.byKey(
          ValueKey('split-input-${name == 'Matiss' ? 7 : 8}'),
        );
        await tester.ensureVisible(field);
        await tester.enterText(
          field,
          mode == 'exact' ? '5' : (mode == 'percent' ? '50' : '1'),
        );
      }
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('expense-editor-done')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(controller.savedMode, mode);
      expect(controller.savedSplits!.map((value) => value.userId), [7, 8]);
      expect(
        controller.savedSplits!.map((value) => value.value),
        mode == 'exact' ? [5, 5] : (mode == 'percent' ? [50, 50] : [1, 1]),
      );
      expect(tester.takeException(), isNull);
      await disposePage(tester);
    });
  }
  for (final restore in [false, true]) {
    testWidgets('saved receipt removal can be restored before save: $restore', (
      tester,
    ) async {
      final controller = _Workspace()
        ..data = snapshot(
          expenses: [expense(1, receiptUrl: 'https://splyto.eu/stale')],
        );
      await _mount(tester, controller, width: 320, scale: 2, dark: true);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('expense-row-1')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.longPress(find.byKey(const ValueKey('expense-row-1')));
      await tester.pumpAndSettle();
      await visibleTap(tester, find.text('Edit expense'));
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage, skipOffstage: false)),
      )!;
      await visibleTap(tester, find.byKey(const ValueKey('receipt-remove')));
      expect(
        find.byKey(const ValueKey('receipt-attachment-card')),
        findsNothing,
      );
      expect(controller.edits, 0);
      if (restore) {
        await visibleTap(tester, find.text(t.restoreReceiptAction));
        expect(
          find.byKey(const ValueKey('receipt-attachment-card')),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(controller.edits, 1);
      expect(controller.editedReceiptRemoved, !restore);
      expect(controller.receiptUploads, isEmpty);
      await disposePage(tester);
    });
  }

  testWidgets(
    'edit confirmation can cancel without losing the original-currency draft',
    (tester) async {
      final controller = _Workspace()
        ..data = snapshot(expenses: [expense(1, currency: 'USD')]);
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('expense-row-1')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.longPress(find.byKey(const ValueKey('expense-row-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit expense'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('expense-form-amount')),
            )
            .controller!
            .text,
        '30.00',
      );
      expect(find.text('USD'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.widgetWithText(TextButton, 'Cancel').last);
      await tester.pumpAndSettle();
      expect(controller.edits, 0);
      expect(find.byKey(const ValueKey('expense-form-amount')), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(controller.edits, 1);
      await disposePage(tester);
    },
  );

  testWidgets(
    'small screen keeps form usable above keyboard with validation error',
    (tester) async {
      final commands = WorkspacePageCommandController();
      await _mount(
        tester,
        _Workspace(),
        commands: commands,
        width: 320,
        height: 568,
        scale: 2,
        locale: 'lv',
      );
      await tester.pumpAndSettle();
      commands.requestOpenAddExpense();
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage, skipOffstage: false)),
      )!;
      await tester.tap(find.widgetWithText(ElevatedButton, t.addAction));
      await tester.pumpAndSettle();
      expect(find.text(t.amountMustBeGreaterThanZero), findsOneWidget);
      expect(tester.takeException(), isNull);
      await disposePage(tester);
    },
  );

  for (final dark in [false, true]) {
    for (final locale in ['en', 'lv', 'es']) {
      testWidgets(
        'balances, member details, settlement and activity at 320px 200% $locale dark=$dark',
        (tester) async {
          final controller = _Workspace()
            ..data = snapshot().copyWith(
              settlements: [settlement('suggested')],
              payments: [payment('requested')],
            );
          await _mount(
            tester,
            controller,
            width: 320,
            scale: 2,
            locale: locale,
            dark: dark,
            manager: true,
          );
          await tester.pumpAndSettle();
          final t = AppLocalizations.of(
            tester.element(find.byType(WorkspacePage)),
          )!;
          await _selectTab(tester, t.navBalances);
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('balance-row-7')),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('balance-row-7')));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text(t.balanceHistoryScope),
            200,
            scrollable: find.byType(Scrollable).last,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(
            find.byTooltip(
              MaterialLocalizations.of(
                tester.element(find.byType(WorkspacePage)),
              ).closeButtonTooltip,
            ),
          );
          await tester.pumpAndSettle();
          await _selectTab(tester, t.workspaceSettle);
          await tester.scrollUntilVisible(
            find.text(t.paymentReviewRequestAction),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await expandFirstSettlement(tester);
          await tester.scrollUntilVisible(
            find.text(t.workspaceOpenFlow),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text(t.workspaceOpenFlow));
          await tester.tap(find.text(t.workspaceOpenFlow));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text(t.workspaceActions),
            200,
            scrollable: find.byType(Scrollable).last,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          Navigator.of(tester.element(find.text(t.workspaceActions))).pop();
          await tester.pumpAndSettle();
          await _selectTab(tester, t.workspaceActivityTab);
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('activity-row-1')),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(find.textContaining('€'), findsWidgets);
          expect(tester.takeException(), isNull);
          await disposePage(tester);
        },
      );
    }
  }
  testWidgets('balances includes members beyond the former four-row cap', (
    tester,
  ) async {
    final controller = _Workspace()
      ..data = snapshot().copyWith(
        balances: [
          for (var id = 7; id < 13; id++)
            BalanceItem(
              id: id,
              nickname: 'Member $id',
              paid: 0,
              owed: 0,
              net: 0,
            ),
        ],
      );
    await _mount(tester, controller);
    await tester.pumpAndSettle();
    await _selectTab(tester, 'Balances');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('balance-row-12')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const ValueKey('balance-row-12')), findsOneWidget);
    await disposePage(tester);
  });
  for (final state in ['active', 'pending', 'sent', 'confirmed', 'archived']) {
    testWidgets('completion and transfer permissions remain distinct: $state', (
      tester,
    ) async {
      final transfer = state == 'active'
          ? 'suggested'
          : state == 'archived'
          ? 'pending'
          : state;
      final controller = _Workspace()
        ..data = snapshot().copyWith(
          tripStatus: state == 'active'
              ? 'active'
              : state == 'archived'
              ? 'archived'
              : 'settling',
          settlements: [settlement(transfer)],
          allSettled: state == 'confirmed',
          settlementTotal: 1,
          settlementConfirmed: state == 'confirmed' ? 1 : 0,
          settlementRemaining: state == 'confirmed' ? 0 : 1,
        );
      await _mount(tester, controller);
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage)),
      )!;
      await _selectTab(tester, t.workspaceSettle);
      await expandFirstSettlement(tester);
      await tester.scrollUntilVisible(
        find.text(t.workspaceOpenFlow),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(
        find.text(t.workspaceAllTripSettlementsAreFullyCompleted),
        state == 'confirmed' ? findsOneWidget : findsNothing,
      );
      await tester.ensureVisible(find.text(t.workspaceOpenFlow));
      await tester.tap(find.text(t.workspaceOpenFlow));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(t.workspaceActions),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppActionSheet).last,
          matching: find.widgetWithText(FilledButton, t.iSentAction),
        ),
        state == 'pending' ? findsOneWidget : findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(AppActionSheet).last,
          matching: find.widgetWithText(FilledButton, t.confirmReceivedAction),
        ),
        state == 'sent' ? findsOneWidget : findsNothing,
      );
      await disposePage(tester);
    });
  }
  testWidgets('readiness finish gate preserves pending payment restriction', (
    tester,
  ) async {
    final controller = _Workspace()
      ..data = snapshot().copyWith(
        users: [
          const WorkspaceUser(id: 7, nickname: 'Matiss', isReadyToSettle: true),
          const WorkspaceUser(id: 8, nickname: 'Anna', isReadyToSettle: true),
        ],
        payments: [payment('sent')],
      );
    final commands = WorkspacePageCommandController();
    await _mount(tester, controller, manager: true, commands: commands);
    await tester.pumpAndSettle();
    final t = AppLocalizations.of(tester.element(find.byType(WorkspacePage)))!;
    await _selectTab(tester, t.workspaceSettle);
    final button = find.widgetWithText(FilledButton, t.finishTripAction);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    controller.data = controller.data.copyWith(payments: []);
    commands.requestRefresh();
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    await disposePage(tester);
  });
  testWidgets(
    'activity failure retry pagination dedup and stale-response protection',
    (tester) async {
      final controller = _Workspace()
        ..activityError = const ApiException('Offline', isNetworkError: true);
      final commands = WorkspacePageCommandController();
      await _mount(tester, controller, commands: commands);
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage)),
      )!;
      await _selectTab(tester, t.workspaceActivityTab);
      expect(find.text(t.workspaceNoRecentActivityYet), findsNothing);
      expect(find.text(t.activityLoadFailed), findsOneWidget);
      controller.activityError = null;
      controller.moreActivity = true;
      await tester.ensureVisible(find.text(t.retryAction));
      await tester.tap(find.text(t.retryAction));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(t.tripsLoadMore),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(t.tripsLoadMore));
      await tester.tap(find.text(t.tripsLoadMore));
      await tester.pumpAndSettle();
      expect(controller.activityOffsets, [0, 0, 1]);
      expect(find.byKey(const ValueKey('activity-row-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('activity-row-2')), findsOneWidget);
      final old = Completer<WorkspaceActivityPage>();
      controller.activityGate = old;
      commands.requestRefresh();
      await tester.pump();
      controller.activityGate = null;
      controller.activity = [];
      commands.requestRefresh();
      await tester.pumpAndSettle();
      old.complete(
        WorkspaceActivityPage(items: [activityEvent(3)], hasMore: false),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('activity-row-3')), findsNothing);
      await disposePage(tester);
    },
  );

  testWidgets('activity rows name each event and show its own icon', (
    tester,
  ) async {
    WorkspaceActivityEvent event(
      int id,
      String type, [
      Map<String, dynamic> payload = const {},
    ]) => WorkspaceActivityEvent(
      id: id,
      tripId: 1,
      actorUserId: 7,
      actorName: 'Matiss',
      eventType: type,
      payload: payload,
      createdAt: '2026-10-21 10:30:00',
    );
    final controller = _Workspace()
      ..activity = [
        event(1, 'trip.settled'),
        event(2, 'expense.comment_added', {'note': 'Breakfast'}),
        event(3, 'trip.all_members_ready'),
        event(4, 'trip.updated', {
          'name_changed': true,
          'image_changed': false,
        }),
        event(5, 'trip.updated', {
          'name_changed': true,
          'budget_changed': true,
        }),
        event(6, 'settlement.reminder_sent'),
      ];
    await _mount(tester, controller);
    await tester.pumpAndSettle();
    final t = AppLocalizations.of(tester.element(find.byType(WorkspacePage)))!;
    await _selectTab(tester, t.workspaceActivityTab);

    Future<void> expectRow(int id, String text, IconData icon) async {
      final row = find.byKey(ValueKey('activity-row-$id'));
      await tester.scrollUntilVisible(
        row,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(row, findsOneWidget);
      expect(
        find.descendant(
          of: row,
          matching: find.textContaining(text, findRichText: true),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: row, matching: find.byIcon(icon)),
        findsOneWidget,
      );
    }

    await expectRow(1, t.activityEventTripSettled, Icons.task_alt_rounded);
    await expectRow(
      2,
      '${t.activityEventExpenseCommentAdded} Breakfast',
      Icons.chat_bubble_outline_rounded,
    );
    await expectRow(
      3,
      t.activityEventTripAllMembersReady,
      Icons.done_all_rounded,
    );
    await expectRow(4, t.activityEventTripRenamed, Icons.edit_rounded);
    await expectRow(5, t.activityEventTripUpdated, Icons.edit_rounded);
    expect(find.byKey(const ValueKey('activity-row-6')), findsNothing);
    await disposePage(tester);
  });

  testWidgets(
    'activity refresh error retains entries, denial clears protected content',
    (tester) async {
      final controller = _Workspace();
      final commands = WorkspacePageCommandController();
      await _mount(tester, controller, commands: commands);
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage)),
      )!;
      await _selectTab(tester, t.workspaceActivityTab);
      controller.activityError = const ApiException(
        'Unavailable',
        isNetworkError: true,
      );
      commands.requestRefresh();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('activity-row-1')), findsOneWidget);
      expect(find.text(t.activityLoadFailed), findsOneWidget);
      controller.activityError = const ApiException(
        'No access',
        statusCode: 403,
      );
      await tester.ensureVisible(find.text(t.retryAction));
      await tester.tap(find.text(t.retryAction));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('activity-row-1')), findsNothing);
      expect(find.byKey(const ValueKey('workspace-total')), findsNothing);
      expect(find.text('No access'), findsOneWidget);
      await disposePage(tester);
    },
  );
  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      testWidgets('member list and profile 320px 200% $locale dark=$dark', (
        tester,
      ) async {
        final controller = _Workspace()
          ..data = snapshot().copyWith(
            users: [
              const WorkspaceUser(
                id: 7,
                nickname: 'Matiss Geinerts',
                role: 'owner',
              ),
              const WorkspaceUser(
                id: 8,
                nickname: 'Anna Verylongsurname Bērziņa',
              ),
            ],
          );
        await _mount(
          tester,
          controller,
          width: 320,
          scale: 2,
          locale: locale,
          dark: dark,
          manager: true,
        );
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(WorkspacePage)),
        )!;
        await tester.ensureVisible(find.byTooltip(t.workspaceMemberCount(2)));
        await tester.tap(find.byTooltip(t.workspaceMemberCount(2)));
        await tester.pumpAndSettle();
        expect(find.byTooltip(t.memberRemoveAction), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('member-row-7')));
        await tester.pumpAndSettle();
        expect(find.byType(UserProfilePage), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text(t.memberActivityScope),
          200,
          scrollable: find
              .descendant(
                of: find.byType(ListView).last,
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        expect(
          tester.widget<UserProfilePage>(find.byType(UserProfilePage)).badges,
          contains('${t.workspaceTripOwner} · ${t.youLabel}'),
        );
        await tester.scrollUntilVisible(
          find.textContaining(t.workspaceCommonTrips),
          200,
          scrollable: find
              .descendant(
                of: find.byType(ListView).last,
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await disposePage(tester);
      });
    }
  }
  testWidgets('reference form puts currency beside amount at normal scale', (
    tester,
  ) async {
    final commands = WorkspacePageCommandController();
    await _mount(tester, _Workspace(), commands: commands);
    await tester.pumpAndSettle();
    commands.requestOpenAddExpense();
    await tester.pumpAndSettle();
    final amount = find.byKey(const ValueKey('expense-form-amount'));
    final currency = find.text('EUR');
    expect(
      (tester.getCenter(amount).dy - tester.getCenter(currency).dy).abs(),
      lessThan(32),
    );
    expect(
      tester.getTopLeft(currency).dx,
      greaterThan(tester.getCenter(amount).dx),
    );
    expect(
      tester
          .getSize(
            find
                .ancestor(of: currency, matching: find.byType(TextButton))
                .first,
          )
          .width,
      greaterThanOrEqualTo(44),
    );
    expect(tester.takeException(), isNull);
    await disposePage(tester);
  });
  testWidgets('member preview images', (tester) async {
    if (!const bool.fromEnvironment('FRIENDS_PREVIEWS')) return;
    for (final dark in [false, true]) {
      for (final screen in ['members', 'member-profile']) {
        final key = GlobalKey();
        await _mount(
          tester,
          _Workspace()..data = snapshot(preview: true),
          locale: 'en',
          dark: dark,
          manager: true,
          boundary: key,
        );
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(WorkspacePage)),
        )!;
        await tester.ensureVisible(find.byTooltip(t.workspaceMemberCount(2)));
        await tester.tap(find.byTooltip(t.workspaceMemberCount(2)));
        await tester.pumpAndSettle();
        if (screen == 'member-profile') {
          await tester.tap(find.byKey(const ValueKey('member-row-7')));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/friends/friends-${dark ? 'dark' : 'light'}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await disposePage(tester);
      }
    }
  });

  testWidgets('settlement review images', (tester) async {
    if (!const bool.fromEnvironment('SETTLEMENT_PREVIEWS')) return;
    for (final dark in [false, true]) {
      for (final screen in [
        'balances',
        'member',
        'ready',
        'flow',
        'complete',
        'activity',
      ]) {
        final key = GlobalKey();
        final controller = _Workspace()
          ..data = snapshot(preview: true).copyWith(
            balances: [
              BalanceItem(
                id: 7,
                nickname: 'Matiss',
                paid: 24,
                owed: 12,
                net: screen == 'complete' ? 0 : 12,
              ),
              BalanceItem(
                id: 8,
                nickname: 'Anna',
                paid: 0,
                owed: 12,
                net: screen == 'complete' ? 0 : -12,
              ),
            ],
            expenses: [expense(1)],
            users: const [
              WorkspaceUser(id: 7, nickname: 'Matiss', isReadyToSettle: true),
              WorkspaceUser(id: 8, nickname: 'Anna'),
            ],
            tripStatus: screen == 'flow' || screen == 'complete'
                ? 'settling'
                : 'active',
            settlements:
                screen == 'ready' ||
                    screen == 'balances' ||
                    screen == 'member' ||
                    screen == 'activity'
                ? []
                : [
                    SettlementItem(
                      id: 1,
                      fromUserId: 8,
                      toUserId: 7,
                      from: 'Anna',
                      to: 'Matiss',
                      amount: 12,
                      status: screen == 'complete' ? 'confirmed' : 'sent',
                      createdAt: '2026-10-21 10:30:00',
                      markedSentAt: '2026-10-21 11:00:00',
                      confirmedAt: screen == 'complete'
                          ? '2026-10-21 11:30:00'
                          : null,
                      canMarkSent: false,
                      canConfirmReceived: screen == 'flow',
                      canCancelSent: false,
                      canReportNotReceived: screen == 'flow',
                      isConfirmed: screen == 'complete',
                    ),
                  ],
            allSettled: screen == 'complete',
            settlementTotal: 1,
            settlementConfirmed: screen == 'complete' ? 1 : 0,
            settlementRemaining: screen == 'complete' ? 0 : 1,
          );
        controller.activity = [activityEvent(1), activityEvent(2)];
        await _mount(
          tester,
          controller,
          dark: dark,
          locale: 'en',
          manager: true,
          boundary: key,
        );
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(WorkspacePage)),
        )!;
        await _selectTab(
          tester,
          screen == 'balances' || screen == 'member'
              ? t.navBalances
              : screen == 'activity'
              ? t.workspaceActivityTab
              : t.workspaceSettle,
        );
        if (screen == 'member') {
          await tester.ensureVisible(
            find.byKey(const ValueKey('balance-row-7')),
          );
          await tester.tap(find.byKey(const ValueKey('balance-row-7')));
        } else if (screen == 'flow') {
          await expandFirstSettlement(tester);
          await tester.scrollUntilVisible(
            find.text(t.workspaceOpenFlow),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text(t.workspaceOpenFlow));
          await tester.tap(find.text(t.workspaceOpenFlow));
        } else if (screen == 'ready') {
          await tester.ensureVisible(find.text(t.workspaceReadyToSettle));
        } else if (screen == 'complete') {
          await tester.ensureVisible(
            find.text(t.workspaceAllTripSettlementsAreFullyCompleted),
          );
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/settlements/settlement-${dark ? 'dark' : 'light'}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await disposePage(tester);
      }
    }
  });

  testWidgets('action sheet review images', (tester) async {
    if (!const bool.fromEnvironment('ACTION_SHEET_PREVIEWS')) return;
    await tester.runAsync(() async {
      final emojiFont = File('/System/Library/Fonts/Apple Color Emoji.ttc');
      if (await emojiFont.exists()) {
        await (FontLoader(
          'Apple Color Emoji',
        )..addFont(emojiFont.readAsBytes().then(ByteData.sublistView))).load();
      }
    });
    for (final dark in [false, true]) {
      for (final screen in ['trip', 'expense']) {
        final key = GlobalKey();
        final commands = WorkspacePageCommandController();
        await _mount(
          tester,
          _Workspace()..data = snapshot(preview: true),
          manager: true,
          dark: dark,
          commands: commands,
          boundary: key,
        );
        await tester.pumpAndSettle();
        if (screen == 'trip') {
          commands.requestOpenTripActions();
        } else {
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('expense-row-1')),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.longPress(find.byKey(const ValueKey('expense-row-1')));
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/actions/${dark ? 'dark' : 'light'}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await disposePage(tester);
        commands.dispose();
      }
    }
  });

  testWidgets('expense review images', (tester) async {
    if (!const bool.fromEnvironment('EXPENSE_PREVIEWS')) return;
    for (final dark in [false, true]) {
      for (final screen in ['details', 'form']) {
        final key = GlobalKey();
        final commands = WorkspacePageCommandController();
        await _mount(
          tester,
          _Workspace(),
          dark: dark,
          locale: 'en',
          commands: commands,
          boundary: key,
        );
        await tester.pumpAndSettle();
        if (screen == 'form') {
          commands.requestOpenAddExpense();
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const ValueKey('expense-form-amount')),
            '60.00',
          );
          await selectExpenseFood(tester);
          await tester.pumpAndSettle();
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
        } else {
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('expense-row-1')),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('expense-row-1')));
          await tester.pumpAndSettle();
        }
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/expenses/expense-${dark ? 'dark' : 'light'}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await disposePage(tester);
      }
    }
  });

  testWidgets('visual review images', (tester) async {
    if (!const bool.fromEnvironment('WORKSPACE_PREVIEWS')) return;
    for (final dark in [false, true]) {
      for (final variant in ['group', 'solo', 'empty']) {
        final key = GlobalKey();
        final controller = _Workspace()
          ..data = snapshot(
            preview: true,
            solo: variant == 'solo',
            expenses: variant == 'empty'
                ? []
                : [
                    expense(1),
                    expense(
                      2,
                      name: 'Dinner',
                      payer: variant == 'solo' ? 7 : 8,
                    ),
                    if (variant != 'solo') expense(3, name: 'Train', payer: 8),
                    if (variant != 'solo') expense(4, name: 'Museum', payer: 8),
                  ],
          );
        await _mount(
          tester,
          controller,
          solo: variant == 'solo',
          dark: dark,
          locale: 'en',
          boundary: key,
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/workspace/workspace-${dark ? 'dark' : 'light'}-$variant.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await disposePage(tester);
      }
    }
  });
  testWidgets('a synced trip shows no sync icon or status text', (
    tester,
  ) async {
    await _mount(tester, _Workspace()..data = snapshot(solo: true), solo: true);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('workspace-sync-status')), findsNothing);
    await disposePage(tester);
  });
  testWidgets('with no expenses, waiting changes are still only an icon', (
    tester,
  ) async {
    await _mount(
      tester,
      _Workspace()
        ..data = snapshot(expenses: [], solo: true)
        ..queued = [
          const QueuedMutation(
            id: 'pending',
            tripId: 1,
            createdAtMillis: 1,
            type: QueuedMutationType.addExpense,
          ),
        ],
      solo: true,
    );
    await tester.pumpAndSettle();
    final status = find.byKey(const ValueKey('workspace-sync-status'));
    await tester.scrollUntilVisible(
      status,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(status, findsOneWidget);
    final t = AppLocalizations.of(tester.element(status))!;
    expect(find.text(t.syncChangesWaiting(1)), findsNothing);
    final search = find.widgetWithText(TextField, t.workspaceSearchExpenses);
    expect(
      (tester.getCenter(status).dy - tester.getCenter(search).dy).abs(),
      lessThan(2),
    );
    await disposePage(tester);
  });
  for (final dark in [false, true]) {
    testWidgets('waiting changes show only a cloud icon dark=$dark', (
      tester,
    ) async {
      final key = GlobalKey();
      await _mount(
        tester,
        _Workspace()
          ..data = snapshot(solo: true)
          ..queued = [
            const QueuedMutation(
              id: 'pending',
              tripId: 1,
              createdAtMillis: 1,
              type: QueuedMutationType.addExpense,
            ),
          ],
        solo: true,
        locale: 'lv',
        dark: dark,
        width: 320,
        scale: 2,
        boundary: const bool.fromEnvironment('SYNC_ICON_PREVIEWS') ? key : null,
      );
      await tester.pumpAndSettle();
      final status = find.byKey(const ValueKey('workspace-sync-status'));
      await tester.scrollUntilVisible(
        status,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(status, findsOneWidget);
      final t = AppLocalizations.of(tester.element(status))!;
      expect(find.byTooltip(t.syncChangesWaiting(1)), findsOneWidget);
      expect(find.text(t.syncChangesWaiting(1)), findsNothing);
      expect(
        find.descendant(
          of: status,
          matching: find.byIcon(Icons.cloud_upload_outlined),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('SYNC_ICON_PREVIEWS')) {
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/sync-icon/${dark ? 'dark' : 'light'}.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await disposePage(tester);
    });
  }
  for (final locale in AppLocalizations.supportedLocales.map(
    (l) => l.languageCode,
  )) {
    for (final dark in [false, true]) {
      testWidgets('expense filter menu 320px 200% $locale dark=$dark', (
        tester,
      ) async {
        await _mount(
          tester,
          _Workspace()
            ..data = snapshot(
              expenses: [
                expense(1, category: 'other'),
                expense(2, category: 'food', payer: 8),
              ],
            ),
          locale: locale,
          dark: dark,
          width: 320,
          scale: 2,
        );
        await tester.pumpAndSettle();
        final filters = find.byKey(const ValueKey('expense-filters'));
        await tester.scrollUntilVisible(
          filters,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(filters);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(
          find.byKey(const ValueKey('expense-filter-category-row')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await showInFilterMenu(
          tester,
          find.byKey(const ValueKey('expense-filter-category-other')),
        );
        await tester.tap(
          find.byKey(const ValueKey('expense-filter-category-other')),
        );
        await tester.pumpAndSettle();
        final clear = find.byKey(const ValueKey('expense-filters-clear'));
        await showInFilterMenu(tester, clear);
        expect(clear, findsOne);
        expect(tester.takeException(), isNull);
        await disposePage(tester);
      });
    }
  }
  testWidgets('expense filter menu review images', (tester) async {
    if (!const bool.fromEnvironment('FILTER_MENU_PREVIEWS')) return;
    // Real shadows for the images; tests draw them as solid outlines.
    debugDisableShadows = false;
    for (final dark in [false, true]) {
      for (final screen in ['root', 'payer', 'applied', 'large']) {
        final key = GlobalKey();
        await _mount(
          tester,
          _Workspace()
            ..data =
                snapshot(
                  expenses: [
                    expense(1, category: 'food'),
                    expense(2, category: 'transport', payer: 8),
                    expense(3, category: 'accommodation', payer: 9),
                  ],
                ).copyWith(
                  users: const [
                    WorkspaceUser(id: 7, nickname: 'Matiss Geinerts'),
                    WorkspaceUser(id: 8, nickname: 'Marta Kalnīte'),
                    WorkspaceUser(id: 9, nickname: 'Valerija Gornovska'),
                    WorkspaceUser(id: 10, nickname: 'Jana'),
                  ],
                ),
          locale: 'lv',
          dark: dark,
          boundary: key,
          width: screen == 'large' ? 320 : 390,
          scale: screen == 'large' ? 2 : 1,
        );
        await tester.pumpAndSettle();
        final filters = find.byKey(const ValueKey('expense-filters'));
        await tester.scrollUntilVisible(
          filters,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(filters);
        await tester.pumpAndSettle();
        if (screen != 'root') {
          await tester.tap(
            find.byKey(const ValueKey('expense-filter-payer-row')),
          );
          await tester.pumpAndSettle();
        }
        if (screen == 'applied' || screen == 'large') {
          await tester.tap(
            find.byKey(const ValueKey('expense-filter-payer-7')),
          );
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../output/design/expense-filter-menu/${dark ? 'dark' : 'light'}-$screen.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await disposePage(tester);
      }
    }
    debugDisableShadows = true;
  });
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('extra member count is a filled pill dark=$dark x$scale', (
        tester,
      ) async {
        final key = GlobalKey();
        final previews = const bool.fromEnvironment('MEMBER_PILL_PREVIEWS');
        await _mount(
          tester,
          _Workspace()
            ..data = snapshot().copyWith(
              users: const [
                WorkspaceUser(id: 7, nickname: 'Matiss'),
                WorkspaceUser(id: 8, nickname: 'Marta'),
                WorkspaceUser(id: 9, nickname: 'Valerija'),
                WorkspaceUser(id: 10, nickname: 'Jana'),
              ],
            ),
          dark: dark,
          scale: scale,
          width: scale == 1 ? 390 : 320,
          boundary: previews ? key : null,
        );
        await tester.pumpAndSettle();
        final pill = find.byKey(const ValueKey('workspace-members-more'));
        expect(pill, findsOneWidget);
        expect(
          find.descendant(of: pill, matching: find.text('+1')),
          findsOneWidget,
        );
        expect(tester.getSize(pill).height, 32);
        expect(tester.takeException(), isNull);
        if (previews) {
          await tester.runAsync(() async {
            final image =
                await (key.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              '../output/design/member-pill/${dark ? 'dark' : 'light'}-x${scale.round()}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await disposePage(tester);
      });
    }
  }
}
