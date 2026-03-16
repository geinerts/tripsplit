import 'random_order_member.dart';

class RandomOrder {
  const RandomOrder({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    required this.createdByNickname,
    required this.members,
  });

  final int id;
  final String createdAt;
  final int createdBy;
  final String createdByNickname;
  final List<RandomOrderMember> members;
}
