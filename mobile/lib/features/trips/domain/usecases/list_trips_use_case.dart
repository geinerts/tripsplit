import '../entities/trip.dart';
import '../repositories/trips_repository.dart';

class ListTripsUseCase {
  const ListTripsUseCase(this._repository);

  final TripsRepository _repository;

  Future<List<Trip>> call() {
    return _repository.listTrips();
  }
}
