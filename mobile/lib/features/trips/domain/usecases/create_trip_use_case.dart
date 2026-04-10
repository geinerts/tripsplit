import '../entities/trip.dart';
import '../repositories/trips_repository.dart';

class CreateTripUseCase {
  const CreateTripUseCase(this._repository);

  final TripsRepository _repository;

  Future<Trip> call({
    required String name,
    required String currencyCode,
    required List<int> memberIds,
    String? dateFrom,
    String? dateTo,
  }) {
    return _repository.createTrip(
      name: name,
      currencyCode: currencyCode,
      memberIds: memberIds,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
