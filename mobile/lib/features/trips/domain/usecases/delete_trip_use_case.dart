import '../repositories/trips_repository.dart';

class DeleteTripUseCase {
  const DeleteTripUseCase(this._repository);

  final TripsRepository _repository;

  Future<void> call({required int tripId}) {
    return _repository.deleteTrip(tripId: tripId);
  }
}
