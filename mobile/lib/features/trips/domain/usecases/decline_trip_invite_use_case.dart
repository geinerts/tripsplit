import '../repositories/trips_repository.dart';

class DeclineTripInviteUseCase {
  const DeclineTripInviteUseCase(this._repository);
  final TripsRepository _repository;

  Future<void> call({required String inviteToken}) =>
      _repository.declineTripInvite(inviteToken: inviteToken);
}
