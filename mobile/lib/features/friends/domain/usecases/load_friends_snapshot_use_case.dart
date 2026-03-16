import '../entities/friends_snapshot.dart';
import '../repositories/friends_repository.dart';

class LoadFriendsSnapshotUseCase {
  const LoadFriendsSnapshotUseCase(this._repository);

  final FriendsRepository _repository;

  Future<FriendsSnapshot> call() {
    return _repository.loadFriends();
  }
}
