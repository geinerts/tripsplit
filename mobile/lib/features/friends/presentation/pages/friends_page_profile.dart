part of 'friends_page.dart';

extension _FriendsPageProfile on _FriendsPageState {
  Future<void> _openFriendProfile(FriendUser user) async {
    final name = _friendPrimaryName(user);
    final sharedTripsFuture = widget.workspaceController
        .loadSharedTripsWithUser(userId: user.id, limit: 20);

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (pageContext) {
          final holderName = (user.bankAccountHolder ?? '').trim().isNotEmpty
              ? (user.bankAccountHolder ?? '').trim()
              : name;
          return UserProfilePage(
            title: _txt(en: 'Friend profile', lv: 'Drauga profils'),
            name: name,
            nickname: user.nickname,
            avatarUrl: user.avatarThumbUrl ?? user.avatarUrl,
            sections: [
              _buildCommonTripsSection(
                context: pageContext,
                future: sharedTripsFuture,
              ),
              UserProfilePaymentDetailsSection(
                sectionTitle: _txt(en: 'Payment details', lv: 'Maksājumu dati'),
                emptyText: _txt(
                  en: 'This friend has not added payout details yet.',
                  lv: 'Šis draugs vēl nav pievienojis izmaksu datus.',
                ),
                bankTransferTitle: _txt(
                  en: 'Bank transfer',
                  lv: 'Bankas pārskaitījums',
                ),
                bankHolderLabel: _txt(en: 'Holder', lv: 'Turētājs'),
                bankHolderName: holderName,
                bankIban: user.bankIban,
                bankBic: user.bankBic,
                revolutTitle: 'Revolut',
                revolutHandle: user.revolutHandle,
                revolutMeLink: user.revolutMeLink,
                paypalTitle: 'PayPal.me',
                paypalMeLink: user.paypalMeLink,
                openLinkFailedText: _txt(
                  en: 'Could not open payment link.',
                  lv: 'Neizdevās atvērt maksājuma saiti.',
                ),
                onErrorMessage: (message) => _showSnack(message, isError: true),
              ),
            ],
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

  Widget _buildCommonTripsSection({
    required BuildContext context,
    required Future<List<WorkspaceSharedTrip>> future,
  }) {
    return UserProfileSectionCard(
      child: FutureBuilder<List<WorkspaceSharedTrip>>(
        future: future,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;
          final items = snapshot.data ?? const <WorkspaceSharedTrip>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_txt(en: 'Common trips', lv: 'Kopīgie tripi')} (${items.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (isLoading)
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _txt(
                          en: 'Loading common trips...',
                          lv: 'Ielādē kopīgos tripus...',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppDesign.mutedColor(context),
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _txt(
                        en: 'Could not load common trips right now.',
                        lv: 'Šobrīd neizdevās ielādēt kopīgos tripus.',
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppDesign.mutedColor(context),
                      ),
                    ),
                  ),
                if (items.isEmpty)
                  Text(
                    _txt(
                      en: 'No common trips found yet.',
                      lv: 'Kopīgi tripi vēl nav atrasti.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppDesign.mutedColor(context),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        _buildCommonTripTile(context, items[i]),
                        if (i < items.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommonTripTile(BuildContext context, WorkspaceSharedTrip trip) {
    final imageUrl = (trip.imageThumbUrl ?? trip.imageUrl ?? '').trim();
    final hasImage = imageUrl.isNotEmpty;
    final statusText = trip.isArchived
        ? _txt(en: 'Finished', lv: 'Pabeigts')
        : (trip.isSettling
              ? _txt(en: 'Settling', lv: 'Norēķini')
              : _txt(en: 'Active', lv: 'Aktīvs'));
    final statusColor = trip.isArchived
        ? AppDesign.mutedColor(context)
        : (trip.isSettling
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.primary);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasImage
                ? Image.network(
                    imageUrl,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) =>
                        _commonTripImageFallback(context),
                  )
                : _commonTripImageFallback(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.name.trim().isEmpty
                      ? _txt(en: 'Trip #${trip.id}', lv: 'Trips #${trip.id}')
                      : trip.name.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  _commonTripSubtitle(context, trip),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppDesign.mutedColor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: statusColor.withValues(alpha: 0.12),
              border: Border.all(color: statusColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              statusText,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commonTripImageFallback(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.landscape_rounded,
        size: 22,
        color: AppDesign.mutedColor(context),
      ),
    );
  }

  String _commonTripSubtitle(BuildContext context, WorkspaceSharedTrip trip) {
    final dateLabel = _commonTripDateLabel(context, trip);
    final membersText = _txt(
      en: '${trip.membersCount} members',
      lv: '${trip.membersCount} dalībnieki',
    );
    return '$dateLabel • $membersText';
  }

  String _commonTripDateLabel(BuildContext context, WorkspaceSharedTrip trip) {
    final raw = trip.archivedAt ?? trip.endedAt ?? trip.createdAt;
    if (raw == null || raw.trim().isEmpty) {
      return _txt(en: 'No date', lv: 'Nav datuma');
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    return MaterialLocalizations.of(context).formatMediumDate(parsed.toLocal());
  }
}
