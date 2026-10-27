import '../entities/trip.dart';
import '../repositories/trips_repository.dart';

class UpdateTripUseCase {
  const UpdateTripUseCase(this._repository);

  final TripsRepository _repository;

  Future<Trip> call({
    required int tripId,
    required String name,
    String? imagePath,
    bool removeImage = false,
    int? budgetCents,
    List<Map<String, dynamic>>? destinations,
    bool clearBudget = false,
  }) {
    return _repository.updateTrip(
      tripId: tripId,
      name: name,
      imagePath: imagePath,
      removeImage: removeImage,
      budgetCents: budgetCents,
      destinations: destinations,
      clearBudget: clearBudget,
    );
  }
}
