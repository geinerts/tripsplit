part of 'friends_page.dart';

extension _FriendsPageProfile on _FriendsPageState {
  Future<void> _openFriendProfile(FriendUser user) async {
    final name = _friendPrimaryName(user);

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (pageContext) {
          return UserProfilePage(
            title: _txt(en: 'Friend profile', lv: 'Drauga profils'),
            name: name,
            nickname: user.nickname,
            avatarUrl: user.avatarThumbUrl ?? user.avatarUrl,
            bankTitle: _txt(en: 'Bank details', lv: 'Bankas dati'),
            bankDescription: _txt(
              en: 'IBAN and payout details will be added here in a next update.',
              lv: 'IBAN un izmaksu dati šeit tiks pievienoti nākamajā atjauninājumā.',
            ),
          );
        },
      ),
    );
  }
}
