class RandomDrawResult {
  const RandomDrawResult({
    required this.pickedUserId,
    required this.pickedUserNickname,
    required this.membersIds,
    required this.remainingIds,
    required this.remainingCount,
    required this.cycleNo,
    required this.drawNo,
    required this.cycleCompleted,
  });

  final int pickedUserId;
  final String pickedUserNickname;
  final List<int> membersIds;
  final List<int> remainingIds;
  final int remainingCount;
  final int cycleNo;
  final int drawNo;
  final bool cycleCompleted;
}
