import '../../../core/push/push_tap.dart';
import '../../workspace/domain/entities/workspace_focus.dart';

/// What a tapped push opens.
sealed class PushTapDestination {
  const PushTapDestination();

  /// Notification types the server sends; see api/lib/helpers/push/.
  factory PushTapDestination.of(PushTap tap) {
    final type = tap.type;
    if (type == 'trip_invitation') {
      final token = tap.stringValue('invite_token');
      if (token != null) return PushOpenInvitation(token);
    }
    if (type.startsWith('friend_invite')) return const PushOpenFriends();
    if (type == 'quick_split_added') return const PushOpenQuickSplits();
    if (tap.tripId <= 0) return const PushOpenNothing();

    final expenseId = tap.intValue('expense_id');
    final focus = switch (type) {
      'expense_comment_mention' || 'expense_comment_added' || 'expense_added'
          when expenseId != null && expenseId > 0 =>
        WorkspaceFocus.expense(expenseId),
      'live_location_started' => const WorkspaceFocus.liveMap(),
      'trip_ready_to_settle' ||
      'member_ready_to_settle' ||
      'trip_finished' => const WorkspaceFocus.settle(),
      _ when type.startsWith('settlement_') || type.startsWith('payment_') =>
        const WorkspaceFocus.settle(),
      _ => null,
    };
    return PushOpenTrip(tap.tripId, focus: focus);
  }
}

class PushOpenNothing extends PushTapDestination {
  const PushOpenNothing();
}

class PushOpenFriends extends PushTapDestination {
  const PushOpenFriends();
}

class PushOpenQuickSplits extends PushTapDestination {
  const PushOpenQuickSplits();
}

class PushOpenInvitation extends PushTapDestination {
  const PushOpenInvitation(this.inviteToken);

  final String inviteToken;
}

class PushOpenTrip extends PushTapDestination {
  const PushOpenTrip(this.tripId, {this.focus});

  final int tripId;
  final WorkspaceFocus? focus;
}
