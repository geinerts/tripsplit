import '../repositories/trips_repository.dart';

class AddTripMembersUseCase {
  const AddTripMembersUseCase(this._repository);

  final TripsRepository _repository;

  Future<int> call({required int tripId, required List<int> memberIds}) {
    return _repository.addTripMembers(tripId: tripId, memberIds: memberIds);
  }
}
