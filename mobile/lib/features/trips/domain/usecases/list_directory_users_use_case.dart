import '../entities/trip_user.dart';
import '../repositories/trips_repository.dart';

class ListDirectoryUsersUseCase {
  const ListDirectoryUsersUseCase(this._repository);

  final TripsRepository _repository;

  Future<List<TripUser>> call({
    String query = '',
    int limit = 20,
    List<int> excludeIds = const <int>[],
  }) {
    return _repository.listDirectoryUsers(
      query: query,
      limit: limit,
      excludeIds: excludeIds,
    );
  }
}
