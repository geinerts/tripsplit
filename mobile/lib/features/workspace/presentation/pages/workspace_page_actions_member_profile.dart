part of 'workspace_page.dart';

extension _WorkspacePageMemberProfileActions on _WorkspacePageState {
  Future<void> _openTripMemberProfilePage(WorkspaceUser user) async {
    final snapshot = _snapshot;
    var paidExpensesCount = 0;
    var involvedExpensesCount = 0;
    var paidTotal = 0.0;
    final currencyCode = widget.trip.currencyCode;
    final isOwner = (widget.trip.createdBy ?? 0) == user.id;
    final sharedTripsFuture = widget.workspaceController
        .loadSharedTripsWithUser(userId: user.id, limit: 20);

    if (snapshot != null) {
      for (final expense in snapshot.expenses) {
        if (expense.paidById == user.id) {
          paidExpensesCount += 1;
          paidTotal += expense.amount;
        }
        final isParticipant = expense.participants.any((p) => p.id == user.id);
        if (expense.paidById == user.id || isParticipant) {
          involvedExpensesCount += 1;
        }
      }
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (pageContext) {
          final title = _plainLocalizedText(
            en: 'Member profile',
            lv: 'Dalībnieka profils',
          );
          final name = user.preferredName.trim().isEmpty
              ? pageContext.l10n.userWithId(user.id)
              : user.preferredName.trim();
          final nickname = user.nickname.trim();
          final hasDifferentNickname =
              nickname.isNotEmpty &&
              nickname.toLowerCase() != name.toLowerCase();
          final roleText = isOwner
              ? _plainLocalizedText(en: 'Trip owner', lv: 'Trip īpašnieks')
              : _plainLocalizedText(en: 'Member', lv: 'Dalībnieks');
          final readyText = user.isReadyToSettle
              ? _plainLocalizedText(
                  en: 'Ready for settlement',
                  lv: 'Gatavs norēķiniem',
                )
              : _plainLocalizedText(
                  en: 'Not ready for settlement',
                  lv: 'Nav gatavs norēķiniem',
                );
          final holderName = (user.bankAccountHolder ?? '').trim().isNotEmpty
              ? (user.bankAccountHolder ?? '').trim()
              : name;
          return UserProfilePage(
            title: title,
            name: name,
            nickname: hasDifferentNickname ? nickname : null,
            avatarUrl: user.avatarThumbUrl ?? user.avatarUrl,
            badges: [roleText, readyText],
            bankTitle: _plainLocalizedText(
              en: 'Bank details',
              lv: 'Bankas dati',
            ),
            bankDescription: _plainLocalizedText(
              en: 'IBAN and payout details will be added here in a next update.',
              lv: 'IBAN un izmaksu dati šeit tiks pievienoti nākamajā atjauninājumā.',
            ),
            showBankDetails: false,
            sections: [
              UserProfilePaymentDetailsSection(
                sectionTitle: _plainLocalizedText(
                  en: 'Payment details',
                  lv: 'Maksājumu dati',
                ),
                emptyText: _plainLocalizedText(
                  en: 'This member has not added payout details yet.',
                  lv: 'Šis dalībnieks vēl nav pievienojis izmaksu datus.',
                ),
                bankTransferTitle: _plainLocalizedText(
                  en: 'Bank transfer',
                  lv: 'Bankas pārskaitījums',
                ),
                bankHolderLabel: _plainLocalizedText(
                  en: 'Holder',
                  lv: 'Turētājs',
                ),
                bankHolderName: holderName,
                bankIban: user.bankIban,
                bankBic: user.bankBic,
                revolutTitle: 'Revolut',
                revolutHandle: user.revolutHandle,
                paypalTitle: 'PayPal.me',
                paypalMeLink: user.paypalMeLink,
                openLinkFailedText: _plainLocalizedText(
                  en: 'Could not open payment link.',
                  lv: 'Neizdevās atvērt maksājuma saiti.',
                ),
                onErrorMessage: (message) => _showSnack(message, isError: true),
              ),
              _buildSharedTripsSection(
                context: pageContext,
                future: sharedTripsFuture,
                fallbackTrip: _fallbackSharedTripForCurrentTrip(),
              ),
              _buildTripActivitySection(
                context: pageContext,
                paidExpensesCount: paidExpensesCount,
                paidTotal: paidTotal,
                involvedExpensesCount: involvedExpensesCount,
                currencyCode: currencyCode,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTripActivitySection({
    required BuildContext context,
    required int paidExpensesCount,
    required double paidTotal,
    required int involvedExpensesCount,
    required String currencyCode,
  }) {
    return UserProfileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _plainLocalizedText(en: 'Trip activity', lv: 'Trip aktivitāte'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: UserProfileMetricTile(
                  label: _plainLocalizedText(
                    en: 'Paid expenses',
                    lv: 'Apmaksāti izdevumi',
                  ),
                  value: '$paidExpensesCount',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: UserProfileMetricTile(
                  label: _plainLocalizedText(
                    en: 'Paid total',
                    lv: 'Apmaksāts kopā',
                  ),
                  value: _formatMoney(
                    context,
                    paidTotal,
                    currencyCode: currencyCode,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: UserProfileMetricTile(
                  label: _plainLocalizedText(
                    en: 'Involved in',
                    lv: 'Iesaistīts',
                  ),
                  value: '$involvedExpensesCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  WorkspaceSharedTrip _fallbackSharedTripForCurrentTrip() {
    return WorkspaceSharedTrip(
      id: widget.trip.id,
      name: widget.trip.name.trim().isEmpty
          ? _plainLocalizedText(en: 'Current trip', lv: 'Pašreizējais trips')
          : widget.trip.name.trim(),
      status: widget.trip.status.trim().toLowerCase(),
      imageUrl: widget.trip.imageUrl,
      imageThumbUrl: widget.trip.imageThumbUrl,
      membersCount: widget.trip.membersCount,
      createdAt: widget.trip.createdAt,
      endedAt: widget.trip.endedAt,
      archivedAt: widget.trip.archivedAt,
    );
  }

  Widget _buildSharedTripsSection({
    required BuildContext context,
    required Future<List<WorkspaceSharedTrip>> future,
    required WorkspaceSharedTrip fallbackTrip,
  }) {
    final title = _plainLocalizedText(en: 'Common trips', lv: 'Kopīgie tripi');
    final loadingText = _plainLocalizedText(
      en: 'Loading common trips...',
      lv: 'Ielādē kopīgos tripus...',
    );
    final emptyText = _plainLocalizedText(
      en: 'No common trips found yet.',
      lv: 'Kopīgi tripi vēl nav atrasti.',
    );
    final errorText = _plainLocalizedText(
      en: 'Could not load all common trips. Showing current one.',
      lv: 'Neizdevās ielādēt visus kopīgos tripus. Rādu pašreizējo.',
    );

    return UserProfileSectionCard(
      child: FutureBuilder<List<WorkspaceSharedTrip>>(
        future: future,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;
          final loaded = snapshot.data ?? const <WorkspaceSharedTrip>[];
          final items = loaded.isNotEmpty
              ? loaded
              : <WorkspaceSharedTrip>[fallbackTrip];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title (${items.length})',
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
                        loadingText,
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
                      errorText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppDesign.mutedColor(context),
                      ),
                    ),
                  ),
                if (items.isEmpty)
                  Text(
                    emptyText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppDesign.mutedColor(context),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        _buildSharedTripTile(context, items[i]),
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

  Widget _buildSharedTripTile(BuildContext context, WorkspaceSharedTrip trip) {
    final imageUrl = (trip.imageThumbUrl ?? trip.imageUrl ?? '').trim();
    final hasImage = imageUrl.isNotEmpty;
    final statusLabel = trip.isArchived
        ? context.l10n.archivedStatus
        : (trip.isSettling
              ? context.l10n.settlingStatus
              : context.l10n.activeStatus);
    final statusColor = trip.isArchived
        ? AppDesign.mutedColor(context)
        : (trip.isSettling ? _splytoAccent : _splytoPrimary);
    final subtitle = _sharedTripSubtitle(context, trip);

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
                        _sharedTripImageFallback(context),
                  )
                : _sharedTripImageFallback(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.name.trim().isEmpty
                      ? context.l10n.tripWithId(trip.id)
                      : trip.name.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
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
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sharedTripImageFallback(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D7A5E), Color(0xFF215A45)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.landscape_rounded, color: Colors.white, size: 20),
    );
  }

  String _sharedTripSubtitle(BuildContext context, WorkspaceSharedTrip trip) {
    final membersLabel = _plainLocalizedText(en: 'members', lv: 'dalībnieki');
    final dateLabel = _sharedTripDateLabel(trip);
    if (dateLabel.isEmpty) {
      return '${trip.membersCount} $membersLabel';
    }
    return '$dateLabel • ${trip.membersCount} $membersLabel';
  }

  String _sharedTripDateLabel(WorkspaceSharedTrip trip) {
    final raw = (trip.endedAt ?? trip.createdAt ?? '').trim();
    if (raw.isEmpty) {
      return '';
    }
    final parsed = DateTime.tryParse(raw)?.toLocal();
    if (parsed == null) {
      return '';
    }
    final dd = parsed.day.toString().padLeft(2, '0');
    final mm = parsed.month.toString().padLeft(2, '0');
    return '$dd.$mm';
  }
}
