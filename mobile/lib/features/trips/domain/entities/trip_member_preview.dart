/// One of the first members of a trip, sent with the trips list so the home
/// screen can show avatars without loading the trip workspace.
class TripMemberPreview {
  const TripMemberPreview({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.avatarThumbUrl,
  });

  final int id;
  final String displayName;

  /// The avatar the member set on their profile, or null when they have none.
  final String? avatarUrl;
  final String? avatarThumbUrl;
}
