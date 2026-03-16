import 'balance_item.dart';
import 'random_order.dart';
import 'settlement_item.dart';
import 'trip_expense.dart';
import 'workspace_notification.dart';
import 'workspace_user.dart';

class WorkspaceSnapshot {
  const WorkspaceSnapshot({
    required this.tripStatus,
    required this.tripEndedAt,
    required this.tripArchivedAt,
    required this.users,
    required this.balances,
    required this.settlements,
    required this.settlementTotal,
    required this.settlementConfirmed,
    required this.settlementRemaining,
    required this.allSettled,
    required this.unreadNotifications,
    required this.notifications,
    required this.expenses,
    required this.orders,
  });

  final String tripStatus;
  final String? tripEndedAt;
  final String? tripArchivedAt;
  final List<WorkspaceUser> users;
  final List<BalanceItem> balances;
  final List<SettlementItem> settlements;
  final int settlementTotal;
  final int settlementConfirmed;
  final int settlementRemaining;
  final bool allSettled;
  final int unreadNotifications;
  final List<WorkspaceNotification> notifications;
  final List<TripExpense> expenses;
  final List<RandomOrder> orders;

  bool get isActive => tripStatus == 'active';
  bool get isSettling => tripStatus == 'settling';
  bool get isArchived => tripStatus == 'archived';

  WorkspaceSnapshot copyWith({
    String? tripStatus,
    String? tripEndedAt,
    bool clearTripEndedAt = false,
    String? tripArchivedAt,
    bool clearTripArchivedAt = false,
    List<WorkspaceUser>? users,
    List<BalanceItem>? balances,
    List<SettlementItem>? settlements,
    int? settlementTotal,
    int? settlementConfirmed,
    int? settlementRemaining,
    bool? allSettled,
    int? unreadNotifications,
    List<WorkspaceNotification>? notifications,
    List<TripExpense>? expenses,
    List<RandomOrder>? orders,
  }) {
    return WorkspaceSnapshot(
      tripStatus: tripStatus ?? this.tripStatus,
      tripEndedAt: clearTripEndedAt ? null : (tripEndedAt ?? this.tripEndedAt),
      tripArchivedAt: clearTripArchivedAt
          ? null
          : (tripArchivedAt ?? this.tripArchivedAt),
      users: users ?? this.users,
      balances: balances ?? this.balances,
      settlements: settlements ?? this.settlements,
      settlementTotal: settlementTotal ?? this.settlementTotal,
      settlementConfirmed: settlementConfirmed ?? this.settlementConfirmed,
      settlementRemaining: settlementRemaining ?? this.settlementRemaining,
      allSettled: allSettled ?? this.allSettled,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      notifications: notifications ?? this.notifications,
      expenses: expenses ?? this.expenses,
      orders: orders ?? this.orders,
    );
  }
}
