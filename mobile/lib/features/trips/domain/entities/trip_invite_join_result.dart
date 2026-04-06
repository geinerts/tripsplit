import 'trip.dart';

class TripInviteJoinResult {
  const TripInviteJoinResult({required this.trip, required this.alreadyMember});

  final Trip trip;
  final bool alreadyMember;
}
