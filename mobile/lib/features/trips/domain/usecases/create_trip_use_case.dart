import '../entities/trip.dart';
import '../repositories/trips_repository.dart';

class CreateTripUseCase {
  const CreateTripUseCase(this._repository);

  final TripsRepository _repository;

  Future<Trip> call({required String name, required List<int> memberIds}) {
    return _repository.createTrip(name: name, memberIds: memberIds);
  }
}
