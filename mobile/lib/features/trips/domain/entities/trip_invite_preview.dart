class TripInvitePreview {
  const TripInvitePreview({
    required this.inviteToken,
    required this.previewNonce,
    required this.tripId,
    required this.tripName,
    required this.inviterName,
    required this.expiresAt,
    required this.previewNonceExpiresAt,
    required this.alreadyMember,
  });

  final String inviteToken;
  final String previewNonce;
  final int tripId;
  final String tripName;
  final String inviterName;
  final String? expiresAt;
  final String? previewNonceExpiresAt;
  final bool alreadyMember;
}
