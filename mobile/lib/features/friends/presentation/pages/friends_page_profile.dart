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
            sections: [_buildFriendPaymentDetailsSection(pageContext, user)],
            bankTitle: _txt(en: 'Bank details', lv: 'Bankas dati'),
            bankDescription: _txt(
              en: 'IBAN and payout details will be added here in a next update.',
              lv: 'IBAN un izmaksu dati šeit tiks pievienoti nākamajā atjauninājumā.',
            ),
            showBankDetails: false,
          );
        },
      ),
    );
  }

  Widget _buildFriendPaymentDetailsSection(
    BuildContext context,
    FriendUser user,
  ) {
    final iban = (user.bankIban ?? '').trim();
    final bic = (user.bankBic ?? '').trim();
    final revolut = (user.revolutHandle ?? '').trim();
    final paypalRaw = (user.paypalMeLink ?? '').trim();
    final paypalUri = _paypalUriOrNull(paypalRaw);
    final paypalDisplay = _paypalDisplayLabel(paypalRaw, paypalUri);
    final bankHolderRaw = (user.bankAccountHolder ?? '').trim();
    final bankHolder = bankHolderRaw.isNotEmpty
        ? bankHolderRaw
        : user.preferredName;
    final hasBank = iban.isNotEmpty || bic.isNotEmpty;
    final hasRevolut = revolut.isNotEmpty;
    final hasPaypal = paypalRaw.isNotEmpty;
    final hasAny = hasBank || hasRevolut || hasPaypal;

    return UserProfileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _txt(en: 'Payment details', lv: 'Maksājumu dati'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!hasAny)
            Text(
              _txt(
                en: 'This friend has not added payout details yet.',
                lv: 'Šis draugs vēl nav pievienojis izmaksu datus.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppDesign.mutedColor(context),
              ),
            )
          else ...[
            if (hasBank)
              _FriendPaymentMethodTile(
                leading: Icon(
                  Icons.account_balance_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: _txt(en: 'Bank transfer', lv: 'Bankas pārskaitījums'),
                subtitleLines: [
                  '${_txt(en: 'Holder', lv: 'Turētājs')}: $bankHolder',
                  if (iban.isNotEmpty) 'IBAN: $iban',
                  if (bic.isNotEmpty) 'SWIFT: $bic',
                ],
              ),
            if (hasBank && (hasRevolut || hasPaypal)) const SizedBox(height: 8),
            if (hasRevolut)
              _FriendPaymentMethodTile(
                leading: const _FriendPaymentBrandLogo(
                  assetPath: 'assets/branding/revolut_logo.svg',
                  semanticsLabel: 'Revolut',
                ),
                title: 'Revolut',
                subtitleLines: [revolut],
              ),
            if (hasRevolut && hasPaypal) const SizedBox(height: 8),
            if (hasPaypal)
              _FriendPaymentMethodTile(
                leading: const _FriendPaymentBrandLogo(
                  assetPath: 'assets/branding/paypal_me_logo.svg',
                  semanticsLabel: 'PayPal.me',
                ),
                title: 'PayPal.me',
                subtitleLines: [paypalDisplay],
                trailing: paypalUri == null
                    ? null
                    : Icon(
                        Icons.open_in_new_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                onTap: paypalUri == null
                    ? null
                    : () => unawaited(_openExternalPaymentLink(paypalUri)),
              ),
          ],
        ],
      ),
    );
  }

  Uri? _paypalUriOrNull(String rawValue) {
    final raw = rawValue.trim();
    if (raw.isEmpty) {
      return null;
    }
    final candidate = raw.contains('://') ? raw : 'https://$raw';
    final uri = Uri.tryParse(candidate);
    if (uri == null) {
      return null;
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return null;
    }
    if ((uri.host).trim().isEmpty) {
      return null;
    }
    return uri;
  }

  String _paypalDisplayLabel(String rawValue, Uri? uri) {
    if (uri == null) {
      return rawValue;
    }
    final host = uri.host.toLowerCase();
    if (host == 'paypal.me' || host == 'www.paypal.me') {
      final segments = uri.pathSegments
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (segments.isEmpty) {
        return 'paypal.me';
      }
      return 'paypal.me/${segments.first}';
    }
    return uri.toString();
  }

  Future<void> _openExternalPaymentLink(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      _showSnack(
        _txt(
          en: 'Could not open payment link.',
          lv: 'Neizdevās atvērt maksājuma saiti.',
        ),
        isError: true,
      );
    }
  }
}

class _FriendPaymentMethodTile extends StatelessWidget {
  const _FriendPaymentMethodTile({
    required this.leading,
    required this.title,
    required this.subtitleLines,
    this.trailing,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final List<String> subtitleLines;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
        border: Border.all(color: AppDesign.cardStroke(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: SizedBox(
              width: 26,
              height: 26,
              child: Center(child: leading),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                for (final line in subtitleLines)
                  Text(
                    line,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppDesign.mutedColor(context),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _FriendPaymentBrandLogo extends StatelessWidget {
  const _FriendPaymentBrandLogo({
    required this.assetPath,
    required this.semanticsLabel,
  });

  final String assetPath;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SvgPicture.asset(
        assetPath,
        width: 24,
        height: 24,
        fit: BoxFit.cover,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}
