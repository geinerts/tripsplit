import '../repositories/trips_repository.dart';

class RemoveTripMemberUseCase {
  const RemoveTripMemberUseCase(this._repository);

  final TripsRepository _repository;

  Future<void> call({required int tripId, required int userId}) {
    return _repository.removeTripMember(tripId: tripId, userId: userId);
  }
}
