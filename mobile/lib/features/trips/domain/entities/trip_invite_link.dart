class TripInviteLink {
  const TripInviteLink({
    required this.tripId,
    required this.inviteUrl,
    required this.inviteToken,
    required this.expiresAt,
    required this.expiresInSeconds,
  });

  final int tripId;
  final String inviteUrl;
  final String inviteToken;
  final String? expiresAt;
  final int expiresInSeconds;
}
