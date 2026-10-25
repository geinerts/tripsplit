import '../entities/trip.dart';
import '../repositories/trips_repository.dart';

class ListTripsUseCase {
  const ListTripsUseCase(this._repository);

  final TripsRepository _repository;

  Future<List<Trip>> call({bool allowOfflineCache = true}) {
    return _repository.listTrips(allowOfflineCache: allowOfflineCache);
  }
}
