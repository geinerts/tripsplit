import '../entities/friends_section_page.dart';
import '../repositories/friends_repository.dart';

class LoadFriendsSectionPageUseCase {
  const LoadFriendsSectionPageUseCase(this._repository);

  final FriendsRepository _repository;

  Future<FriendsSectionPage> call({
    required String section,
    int limit = 25,
    String? cursor,
    int? offset,
  }) {
    return _repository.loadSectionPage(
      section: section,
      limit: limit,
      cursor: cursor,
      offset: offset,
    );
  }
}

