import '../repositories/trips_repository.dart';

class LeaveTripUseCase {
  const LeaveTripUseCase(this._repository);

  final TripsRepository _repository;

  Future<void> call({required int tripId}) {
    return _repository.leaveTrip(tripId: tripId);
  }
}
