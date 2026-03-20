import '../entities/trip_invite_link.dart';
import '../repositories/trips_repository.dart';

class CreateTripInviteLinkUseCase {
  const CreateTripInviteLinkUseCase(this._repository);

  final TripsRepository _repository;

  Future<TripInviteLink> call({required int tripId}) {
    return _repository.createTripInviteLink(tripId: tripId);
  }
}
