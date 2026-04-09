import '../entities/trip_invite_preview.dart';
import '../repositories/trips_repository.dart';

class PreviewTripInviteUseCase {
  const PreviewTripInviteUseCase(this._repository);

  final TripsRepository _repository;

  Future<TripInvitePreview> call({required String inviteToken}) {
    return _repository.previewTripInvite(inviteToken: inviteToken);
  }
}
