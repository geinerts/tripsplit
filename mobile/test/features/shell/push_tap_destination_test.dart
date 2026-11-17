import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/push/push_tap.dart';
import 'package:tripsplit/features/shell/presentation/push_tap_destination.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_focus.dart';

PushTapDestination _of(Map<String, Object?> data) =>
    PushTapDestination.of(PushTap.fromMap(data));

void main() {
  test('tap data is read from both push shapes as strings', () {
    final tap = PushTap.fromMap({
      'type': ' Expense_Added ',
      'trip_id': 7,
      'expense_id': '950',
      'title': 'New expense added',
      'ignored': null,
    });
    expect(tap.type, 'expense_added');
    expect(tap.tripId, 7);
    expect(tap.intValue('expense_id'), 950);
    expect(tap.stringValue('missing'), isNull);
    expect(tap.values.containsKey('ignored'), isFalse);
  });

  test('each notification type opens its own place', () {
    expect(
      _of({'type': 'trip_invitation', 'trip_id': '7', 'invite_token': 'abc'}),
      isA<PushOpenInvitation>().having((d) => d.inviteToken, 'token', 'abc'),
    );
    for (final type in [
      'friend_invite',
      'friend_invite_received',
      'friend_invite_accepted',
    ]) {
      expect(_of({'type': type, 'trip_id': '0'}), isA<PushOpenFriends>());
    }
    expect(
      _of({'type': 'quick_split_added', 'quick_split_id': '31'}),
      isA<PushOpenQuickSplits>(),
    );

    PushOpenTrip trip(Map<String, Object?> data) =>
        _of({'trip_id': '7', ...data}) as PushOpenTrip;
    for (final type in [
      'expense_added',
      'expense_comment_added',
      'expense_comment_mention',
    ]) {
      final opened = trip({'type': type, 'expense_id': '950'});
      expect(opened.tripId, 7);
      expect(opened.focus, const WorkspaceFocus.expense(950));
    }
    expect(trip({'type': 'expense_added'}).focus, isNull);
    expect(
      trip({'type': 'live_location_started'}).focus,
      const WorkspaceFocus.liveMap(),
    );
    for (final type in [
      'payment_requested',
      'payment_confirmed',
      'settlement_sent',
      'settlement_reminder',
      'trip_ready_to_settle',
      'member_ready_to_settle',
      'trip_finished',
    ]) {
      expect(trip({'type': type}).focus, const WorkspaceFocus.settle());
    }
    for (final type in [
      'trip_added',
      'trip_member_added',
      'trip_starts_tomorrow',
      'trip_invitation',
    ]) {
      final opened = trip({'type': type});
      expect(opened.focus, isNull, reason: type);
    }
  });

  test('a push without a trip or known type opens nothing', () {
    expect(
      _of({'type': 'expense_added', 'trip_id': '0'}),
      isA<PushOpenNothing>(),
    );
    expect(_of({'type': 'info'}), isA<PushOpenNothing>());
  });
}
