import '../entities/trip_invite_join_result.dart';
import '../repositories/trips_repository.dart';

class JoinTripInviteUseCase {
  const JoinTripInviteUseCase(this._repository);

  final TripsRepository _repository;

  Future<TripInviteJoinResult> call({required String inviteToken}) {
    return _repository.joinTripInvite(inviteToken: inviteToken);
  }
}
