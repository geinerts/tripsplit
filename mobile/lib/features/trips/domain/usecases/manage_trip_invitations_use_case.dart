import '../entities/pending_trip_invitation.dart';
import '../repositories/trips_repository.dart';

class ManageTripInvitationsUseCase {
  const ManageTripInvitationsUseCase(this._repository);
  final TripsRepository _repository;

  Future<List<PendingTripInvitation>> list({required int tripId}) =>
      _repository.listPendingInvitations(tripId: tripId);

  Future<void> revoke({required int tripId, required int invitationId}) =>
      _repository.revokeInvitation(tripId: tripId, invitationId: invitationId);
}
