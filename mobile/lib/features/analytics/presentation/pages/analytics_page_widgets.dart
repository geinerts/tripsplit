part of 'analytics_page.dart';

extension _AnalyticsPageWidgets on _AnalyticsPageState {
  Widget _buildAnalyticsScaffold(BuildContext context) {
    final t = context.l10n;
    final report = _report;
    final hasData = _loaded && _trips.isNotEmpty;
    return AppBackground(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.responsive.pageMaxWidth,
          ),
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              key: const ValueKey('analytics-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                _AnalyticsTabs(
                  labels: [t.analyticsAllTrips, t.analyticsByTrip],
                  selected: _byTrip ? 1 : 0,
                  onSelected: (i) => _updateState(() {
                    if (i == 1 && !_byTrip) {
                      _hasChosenTrip = false;
                      _selectedTripId = _defaultTrip?.id;
                    }
                    _byTrip = i == 1;
                  }),
                ),
                if (_loading && _loaded) const LinearProgressIndicator(),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_error!),
                        if (_loaded)
                          Text(
                            t.analyticsLastLoaded,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        TextButton.icon(
                          onPressed: _loading ? null : _load,
                          icon: const Icon(Icons.refresh),
                          label: Text(t.retryAction),
                        ),
                      ],
                    ),
                  ),
                if (_loading && !_loaded) ...[
                  const SizedBox(height: 24),
                  const AppSkeletonBlock(height: 56),
                  const SizedBox(height: 24),
                  const AppSkeletonBlock(height: 100),
                  const SizedBox(height: 24),
                  const AppSkeletonBlock(height: 200),
                ] else if (_loaded && _trips.isEmpty)
                  _empty(t.analyticsEmptyTitle, t.analyticsEmptyBody)
                else if (hasData) ...[
                  if (_byTrip && _selectedTrip != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        onTap: _chooseTrip,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              _tripCover(_selectedTrip!),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedTrip!.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_tripDates(_selectedTrip!)} · $_displayCurrency',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: AppDesign.mutedColor(
                                              context,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.expand_more),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _AnalyticsScopeSwitch(
                      labels: [t.workspaceTripTotal, t.yourShare],
                      selected: _personal ? 1 : 0,
                      onSelected: (i) => _updateState(() => _personal = i == 1),
                    ),
                  ] else
                    Padding(
                      padding: EdgeInsets.zero,
                      child: LayoutBuilder(
                        builder: (context, box) {
                          final month = TextButton.icon(
                            onPressed: _chooseMonth,
                            icon: const Icon(Icons.calendar_today_outlined),
                            label: Text(
                              _month == null
                                  ? t.homeAllTime
                                  : _monthLabel(_month!),
                            ),
                          );
                          final currency = DropdownButton<String>(
                            value: _currency,
                            isDense: false,
                            underline: const SizedBox.shrink(),
                            onChanged: (v) => _updateState(() {
                              _currency = v;
                              _month = null;
                            }),
                            items:
                                (_trips
                                        .map((t) => t.currencyCode)
                                        .toSet()
                                        .toList()
                                      ..sort())
                                    .map(
                                      (code) => DropdownMenuItem(
                                        value: code,
                                        child: Text(code),
                                      ),
                                    )
                                    .toList(),
                          );
                          return MediaQuery.textScalerOf(context).scale(16) > 23
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [month, currency],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: month,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    currency,
                                  ],
                                );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (!_byTrip || report.expenseCount == 0) ...[
                    Text(
                      _byTrip
                          ? (_personal ? t.yourShare : t.workspaceTripTotal)
                          : t.analyticsYourSpending,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _money(report.totalCents),
                      key: const ValueKey('analytics-total'),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 32,
                        height: 1.15,
                      ),
                    ),
                    if (_byTrip)
                      Text(
                        t.analyticsExpenseCount(report.expenseCount),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppDesign.mutedColor(context),
                        ),
                      ),
                  ],
                  const SizedBox(height: 12),
                  if (!_byTrip || (_personal && report.expenseCount == 0))
                    _summaryMetrics(report),
                  if (report.expenseCount == 0)
                    _empty(t.analyticsEmptyTitle, t.analyticsPeriodEmptyBody)
                  else ...[
                    _sectionTitle(
                      _byTrip && _personal
                          ? t.analyticsYourCategories
                          : t.analyticsByCategory,
                    ),
                    _categories(report),
                    if (_byTrip) ...[
                      if (!_personal) ...[
                        _sectionTitle(t.analyticsPaidByMember),
                        ..._memberRows(report),
                      ],
                      _sectionTitle(t.analyticsDailySpending),
                      _daily(report),
                      _sectionTitle(
                        _personal
                            ? t.analyticsLargestShares
                            : t.analyticsLargestExpenses,
                      ),
                      ..._largestRows(report),
                    ] else ...[
                      _sectionTitle(t.analyticsSpendingByTrip),
                      ..._tripRows(report),
                    ],
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryMetrics(AnalyticsReport report) {
    final t = context.l10n;
    if (!_byTrip) {
      final tripCount = _month == null
          ? _trips.where((t) => t.currencyCode == _displayCurrency).length
          : report.shareByTrip.length;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Icon(
              Icons.luggage_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${t.analyticsTrips} $tripCount',
                  key: const ValueKey('analytics-trip-count'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  t.analyticsActiveArchived,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppDesign.mutedColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    final items = <(String, String)>[
      (t.analyticsYouPaid, _money(report.paidCents)),
      if (_personal)
        (
          (_selectedTrip!.myBalanceCents < 0
              ? t.analyticsYouOwe
              : t.analyticsYouGetBack),
          _money(_selectedTrip!.myBalanceCents.abs()),
        )
      else
        (t.analyticsParticipants, '${_selectedTrip!.membersCount}'),
    ];
    Widget metric(int i) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          items[i].$1,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppDesign.mutedColor(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          items[i].$2,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 20,
            color: _byTrip && _personal && i == 1
                ? (_selectedTrip!.myBalanceCents < 0
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary)
                : null,
          ),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, box) =>
          box.maxWidth < 300 || MediaQuery.textScalerOf(context).scale(16) > 23
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [metric(0), const SizedBox(height: 16), metric(1)],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: metric(0)),
                Container(
                  width: 1,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  color: AppDesign.cardStroke(context),
                ),
                Expanded(child: metric(1)),
              ],
            ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    ),
  );
  List<Widget> _memberRows(AnalyticsReport report) {
    final members = report.members;
    return [
      for (final member in members)
        Padding(
          key: ValueKey('analytics-member-${member.id}'),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                  child: Text(
                    member.nickname.trim().isEmpty
                        ? '?'
                        : member.nickname.trim().characters.first.toUpperCase(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final amount = Text(
                      _money(member.paidCents),
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                    final stacked =
                        constraints.maxWidth < 240 ||
                        MediaQuery.textScalerOf(context).scale(16) > 21;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (stacked) ...[
                          Text(member.nickname),
                          amount,
                        ] else
                          Row(
                            children: [
                              Expanded(child: Text(member.nickname)),
                              const SizedBox(width: 12),
                              amount,
                            ],
                          ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: report.totalCents == 0
                              ? 0
                              : member.paidCents / report.totalCents,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                          color: member.id == members.first.id
                              ? const Color(0xff00866e)
                              : const Color(0xff24b7d8),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _daily(AnalyticsReport report) {
    final rows = report.days.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxValue = rows.fold<int>(1, (a, b) => math.max(a, b.value));
    final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
    return SizedBox(
      height: 110 + 46 * scale,
      child: LayoutBuilder(
        builder: (context, box) => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final date = DateTime.tryParse(rows[i].key);
            final label = date == null
                ? rows[i].key
                : AppFormatters.shortDayMonth(context, date);
            return SizedBox(
              width: math.max(
                100 * scale,
                box.maxWidth / math.max(1, rows.length),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _money(rows[i].value),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 44,
                      height: 80 * rows[i].value / maxValue,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _largestRows(AnalyticsReport report) {
    return [
      for (final entry in report.largest)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                ExpenseCategoryCatalog.iconFor(entry.category),
                color: _categoryColor(entry.category),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  entry.note.trim().isEmpty
                      ? _categoryName(entry.category)
                      : entry.note,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _money(entry.amountCents),
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
    ];
  }

  List<Widget> _tripRows(AnalyticsReport report) {
    final totals = report.shareByTrip;
    final trips =
        _trips
            .where(
              (t) =>
                  t.currencyCode == _displayCurrency &&
                  (_month == null || totals.containsKey(t.id)),
            )
            .toList()
          ..sort((a, b) => (totals[b.id] ?? 0).compareTo(totals[a.id] ?? 0));
    return [
      for (final trip in trips)
        Column(
          children: [
            InkWell(
              onTap: widget.onOpenTrip == null
                  ? null
                  : () => widget.onOpenTrip!(trip),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked =
                        constraints.maxWidth < 300 ||
                        MediaQuery.textScalerOf(context).scale(16) > 21;
                    final amount = Text(
                      _money(totals[trip.id] ?? 0),
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                    return Row(
                      children: [
                        _tripCover(trip, width: 56, height: 56),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (stacked)
                                Text(
                                  trip.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                )
                              else
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        trip.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: constraints.maxWidth * .3,
                                      ),
                                      child: amount,
                                    ),
                                  ],
                                ),
                              Text(
                                _tripDates(trip),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (stacked) amount,
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: report.totalCents == 0
                                    ? 0
                                    : (totals[trip.id] ?? 0) /
                                          report.totalCents,
                                minHeight: 5,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                        if (widget.onOpenTrip != null)
                          const Icon(Icons.chevron_right),
                      ],
                    );
                  },
                ),
              ),
            ),
            const Divider(height: 1),
          ],
        ),
    ];
  }

  Widget _tripCover(Trip trip, {double width = 56, double height = 48}) {
    Widget fallback() => SplytoIllustration(
      'assets/branding/splyto_trip_cover_small.svg',
      fit: BoxFit.cover,
    );
    final url = trip.imageThumbUrl ?? trip.imageUrl;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: AppDesign.cardRadius,
        child: SizedBox(
          width: width,
          height: height,
          child: url == null || url.isEmpty
              ? fallback()
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => fallback(),
                ),
        ),
      ),
    );
  }

  Widget _empty(String title, String body) => Padding(
    key: const ValueKey('analytics-empty'),
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        SplytoIllustration(
          'assets/branding/splyto_empty_analytics.svg',
          width: 180,
          height: 160,
          excludeFromSemantics: true,
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          body,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppDesign.mutedColor(context)),
        ),
      ],
    ),
  );
}
