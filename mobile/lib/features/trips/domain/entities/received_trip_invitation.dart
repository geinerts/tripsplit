class ReceivedTripInvitation {
  const ReceivedTripInvitation({
    required this.id,
    required this.tripId,
    required this.tripName,
    required this.inviterName,
    required this.inviteToken,
  });
  final int id, tripId;
  final String tripName, inviterName, inviteToken;
}
