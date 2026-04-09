class TripInvitePreview {
  const TripInvitePreview({
    required this.inviteToken,
    required this.tripId,
    required this.tripName,
    required this.inviterName,
    required this.expiresAt,
    required this.alreadyMember,
  });

  final String inviteToken;
  final int tripId;
  final String tripName;
  final String inviterName;
  final String? expiresAt;
  final bool alreadyMember;
}
