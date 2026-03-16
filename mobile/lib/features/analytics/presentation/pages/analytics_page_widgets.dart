part of 'analytics_page.dart';

extension _AnalyticsPageWidgets on _AnalyticsPageState {
  Widget _buildAnalyticsScaffold(BuildContext context) {
    final responsive = context.responsive;
    if (_isLoadingTrips && _trips.isEmpty) {
      return const AppBackground(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AppBackground(
      child: RefreshIndicator(
        onRefresh: () => _loadTrips(forceReload: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: responsive.pageMaxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    responsive.pageHorizontalPadding,
                    12,
                    responsive.pageHorizontalPadding,
                    18,
                  ),
                  children: [
                    if (_tripsError != null)
                      _InlineErrorCard(
                        message: _tripsError!,
                        onRetry: () => _loadTrips(forceReload: true),
                      ),
                    if (_tripsError != null) const SizedBox(height: 10),
                    _buildTripSelector(context),
                    const SizedBox(height: 10),
                    if (_isLoadingSnapshot && _selectedSnapshot == null)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      )
                    else if (_snapshotError != null &&
                        _selectedSnapshot == null)
                      _InlineErrorCard(
                        message: _snapshotError!,
                        onRetry: () =>
                            _loadSelectedTripSnapshot(forceReload: true),
                      )
                    else if (_selectedSnapshot != null)
                      ..._buildCharts(context, _selectedSnapshot!),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTripSelector(BuildContext context) {
    final t = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _txt(en: 'Analytics', lv: 'Analītika'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_selectedTrip != null && widget.onOpenTrip != null)
                  TextButton.icon(
                    onPressed: () => widget.onOpenTrip!(_selectedTrip!),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(t.openLabel),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_trips.isEmpty)
              Text(t.noTripsYet)
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final trip in _trips) ...[
                      ChoiceChip(
                        label: Text(_tripName(context, trip)),
                        selected: _selectedTripId == trip.id,
                        onSelected: (_) => _onTripSelected(trip.id),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCharts(BuildContext context, WorkspaceSnapshot snapshot) {
    final days = _lastFiveDays(snapshot);
    final members = _membersForSnapshot(snapshot);
    final memberColors = _memberColors(members, context);
    final dailyByMember = _memberSpentByDay(snapshot, days, members);
    final memberTotals = _memberTotals(snapshot);
    final categoryTotals = _categoryTotals(snapshot, context);

    return [
      _buildMemberPerDayChart(
        context,
        days: days,
        members: members,
        memberColors: memberColors,
        dailyByMember: dailyByMember,
      ),
      const SizedBox(height: 10),
      _buildMyPerDayChart(context, days: days, dailyByMember: dailyByMember),
      const SizedBox(height: 10),
      _buildMemberTotalsChart(
        context,
        members: members,
        memberColors: memberColors,
        memberTotals: memberTotals,
      ),
      const SizedBox(height: 10),
      _buildCategoryTotalsChart(context, rows: categoryTotals),
    ];
  }

  Widget _buildMemberPerDayChart(
    BuildContext context, {
    required List<DateTime> days,
    required List<_MemberMeta> members,
    required Map<int, Color> memberColors,
    required Map<String, Map<int, double>> dailyByMember,
  }) {
    final t = context.l10n;
    double maxDayTotal = 1;
    for (final day in days) {
      final values = dailyByMember[_dayKey(day)];
      if (values == null) {
        continue;
      }
      final dayTotal = values.values.fold<double>(
        0,
        (sum, value) => sum + value,
      );
      maxDayTotal = math.max(maxDayTotal, dayTotal);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _txt(
                en: 'Amount spent each member each day (last 5 days)',
                lv: 'Katra dalībnieka izdevumi pa dienām (pēdējās 5 dienas)',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (members.isEmpty)
              Text(t.noMembersFound)
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final member in members)
                    _LegendItem(
                      color: memberColors[member.id] ?? Colors.grey,
                      label: member.name,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final day in days) ...[
                      (() {
                        final values =
                            dailyByMember[_dayKey(day)] ??
                            const <int, double>{};
                        final dayTotal = values.values.fold<double>(
                          0,
                          (sum, value) => sum + value,
                        );
                        final segments = <_MemberDaySegment>[
                          for (final member in members)
                            if ((values[member.id] ?? 0) > 0)
                              _MemberDaySegment(
                                memberId: member.id,
                                memberName: member.name,
                                amount: values[member.id] ?? 0,
                                color: memberColors[member.id] ?? Colors.grey,
                              ),
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _DayStackedBar(
                            dayLabel: _dayShortLabel(day),
                            dayTotal: dayTotal,
                            maxDayTotal: maxDayTotal,
                            segments: segments,
                            onSegmentTap: (segment) {
                              _showMemberDayInfo(
                                day: day,
                                memberName: segment.memberName,
                                amount: segment.amount,
                              );
                            },
                          ),
                        );
                      })(),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMyPerDayChart(
    BuildContext context, {
    required List<DateTime> days,
    required Map<String, Map<int, double>> dailyByMember,
  }) {
    final t = context.l10n;
    final myId = _currentUserId;
    final points = <_DayPoint>[];

    for (final day in days) {
      final amount = (dailyByMember[_dayKey(day)]?[myId] ?? 0).toDouble();
      points.add(_DayPoint(label: _dayShortLabel(day), value: amount));
    }

    final maxValue = points.fold<double>(1, (m, p) => math.max(m, p.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _txt(
                en: 'Total amount spent each day (only me)',
                lv: 'Kopā iztērēts pa dienām (tikai es)',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in points)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _SingleBar(
                          label: point.label,
                          valueLabel: _formatMoney(point.value),
                          value: point.value,
                          maxValue: maxValue,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (points.every((p) => p.value <= 0)) ...[
              const SizedBox(height: 8),
              Text(t.noExpensesYet),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTotalsChart(
    BuildContext context, {
    required List<_MemberMeta> members,
    required Map<int, Color> memberColors,
    required Map<int, double> memberTotals,
  }) {
    final rows = <_MemberTotalRow>[];
    for (final member in members) {
      final total = memberTotals[member.id] ?? 0;
      rows.add(
        _MemberTotalRow(
          id: member.id,
          name: member.name,
          total: total,
          color: memberColors[member.id] ?? Colors.grey,
        ),
      );
    }
    rows.sort((a, b) => b.total.compareTo(a.total));

    final maxValue = rows.fold<double>(1, (m, row) => math.max(m, row.total));

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _txt(
                en: 'Total amount spent each member (selected trip)',
                lv: 'Kopā iztērēts katram dalībniekam (izvēlētais ceļojums)',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (rows.isEmpty)
              Text(context.l10n.noMembersFound)
            else
              ...rows.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _HorizontalMemberBar(
                    label: row.name,
                    valueLabel: _formatMoney(row.total),
                    value: row.total,
                    maxValue: maxValue,
                    color: row.color,
                    highlight: row.id == _currentUserId,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTotalsChart(
    BuildContext context, {
    required List<_CategoryTotalRow> rows,
  }) {
    final maxValue = rows.fold<double>(1, (m, row) => math.max(m, row.total));

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _txt(
                en: 'Total amount spent by category',
                lv: 'Kopējā iztērētā summa pa kategorijām',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (rows.isEmpty)
              Text(context.l10n.noExpensesYet)
            else
              ...rows.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _HorizontalCategoryBar(
                    icon: row.icon,
                    label: row.label,
                    valueLabel: _formatMoney(row.total),
                    value: row.total,
                    maxValue: maxValue,
                    color: row.color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMemberDayInfo({
    required DateTime day,
    required String memberName,
    required double amount,
  }) {
    final text = _txt(
      en: '$memberName spent ${_formatMoney(amount)} on ${_dayShortLabel(day)}',
      lv: '$memberName iztērēja ${_formatMoney(amount)} datumā ${_dayShortLabel(day)}',
    );
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
