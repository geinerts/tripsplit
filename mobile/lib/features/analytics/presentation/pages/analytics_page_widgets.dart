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
      child: ColoredBox(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).scaffoldBackgroundColor
            : _analyticsBg,
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
                      const SizedBox(height: 12),
                      if (_isLoadingSnapshot && _selectedSnapshot == null)
                        _buildAnalyticsCard(
                          context,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 26),
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
      ),
    );
  }

  Widget _buildTripSelector(BuildContext context) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTrip = _selectedTrip;
    final hasTrips = _trips.isNotEmpty;

    return _buildAnalyticsCard(
      context,
      child: Column(
        children: [
          _AnalyticsPressScale(
            borderRadius: _showTripSelectorMenu
                ? const BorderRadius.vertical(top: Radius.circular(24))
                : BorderRadius.circular(24),
            enabled: hasTrips,
            onTap: hasTrips
                ? () {
                    _updateState(() {
                      _showTripSelectorMenu = !_showTripSelectorMenu;
                    });
                  }
                : () {},
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isDark
                          ? colors.primary.withValues(alpha: 0.24)
                          : _analyticsPrimary.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      Icons.airplanemode_active_rounded,
                      size: 20,
                      color: isDark ? colors.primary : _analyticsPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedTrip == null
                              ? t.noTripsYet
                              : _tripName(context, selectedTrip),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isDark ? null : _analyticsFg,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedTrip == null
                              ? context.l10n.analyticsSelectATripForAnalytics
                              : context.l10n.analyticsMembers(
                                  _tripStatusLabel(selectedTrip),
                                  selectedTrip.membersCount,
                                  _tripDateLabel(selectedTrip),
                                  _formatMoney(
                                    selectedTrip.totalAmountCents / 100,
                                  ),
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark
                                    ? colors.onSurfaceVariant
                                    : _analyticsMuted,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    _showTripSelectorMenu
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: isDark ? colors.onSurfaceVariant : _analyticsMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_showTripSelectorMenu && hasTrips) ...[
            Divider(
              height: 1,
              color: isDark
                  ? colors.outlineVariant.withValues(alpha: 0.25)
                  : _analyticsStroke,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    final selected = trip.id == _selectedTripId;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          _updateState(() {
                            _showTripSelectorMenu = false;
                          });
                          await _onTripSelected(trip.id);
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: selected
                                ? (isDark
                                      ? colors.primary.withValues(alpha: 0.22)
                                      : _analyticsPrimary.withValues(
                                          alpha: 0.12,
                                        ))
                                : (isDark ? colors.surface : _analyticsCard),
                            border: Border.all(
                              color: selected
                                  ? (isDark
                                        ? colors.primary.withValues(alpha: 0.55)
                                        : _analyticsPrimary.withValues(
                                            alpha: 0.45,
                                          ))
                                  : (isDark
                                        ? colors.outlineVariant.withValues(
                                            alpha: 0.28,
                                          )
                                        : _analyticsStroke),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? colors.surfaceContainerHighest
                                        : AppDesign.lightSurfaceMuted,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.map_outlined,
                                    color: isDark
                                        ? colors.onSurfaceVariant
                                        : _analyticsMuted,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _tripName(context, trip),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: isDark
                                                  ? null
                                                  : _analyticsFg,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        context.l10n.analyticsMembers(
                                          _tripStatusLabel(trip),
                                          trip.membersCount,
                                          _tripDateLabel(trip),
                                          _formatMoney(
                                            trip.totalAmountCents / 100,
                                          ),
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? colors.onSurfaceVariant
                                                  : _analyticsMuted,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: isDark
                                        ? colors.primary
                                        : _analyticsPrimary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemCount: _trips.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildCharts(BuildContext context, WorkspaceSnapshot snapshot) {
    final days = _allTripDays(snapshot);
    final members = _membersForSnapshot(snapshot);
    final memberColors = _memberColors(members, context);
    final dailyByMember = _memberSpentByDay(snapshot, days, members);
    final memberTotals = _memberTotals(snapshot);
    final categoryTotals = _categoryTotals(snapshot, context);

    // For quick insights (best day), fall back to last-5-days when no expenses.
    final insightDays = days.isNotEmpty ? days : _lastFiveDays(snapshot);

    final blocks = <Widget>[
      _buildCategoryTotalsChart(context, rows: categoryTotals),
      _buildMemberTotalsChart(
        context,
        members: members,
        memberColors: memberColors,
        memberTotals: memberTotals,
        expanded: _showMemberStats,
        onToggle: () {
          _updateState(() {
            _showMemberStats = !_showMemberStats;
          });
        },
      ),
      _buildFullDailyChart(
        context,
        days: days,
        members: members,
        memberColors: memberColors,
        dailyByMember: dailyByMember,
      ),
      _buildQuickInsightsCard(
        context,
        days: insightDays,
        members: members,
        memberTotals: memberTotals,
        categoryTotals: categoryTotals,
        dailyByMember: dailyByMember,
      ),
    ];

    final widgets = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      widgets.add(_AnalyticsFadeSlide(index: i, child: blocks[i]));
      if (i < blocks.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    return widgets;
  }

  Widget _buildFullDailyChart(
    BuildContext context, {
    required List<DateTime> days,
    required List<_MemberMeta> members,
    required Map<int, Color> memberColors,
    required Map<String, Map<int, double>> dailyByMember,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    if (days.isEmpty) {
      return _buildAnalyticsCard(
        context,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 18,
                    color: isDark ? colors.primary : _analyticsPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.analyticsDailySpending,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? null : _analyticsFg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.noExpensesYet,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    // Compute max day total for bar scaling.
    var maxDayTotal = 0.0;
    for (final day in days) {
      final byMember = dailyByMember[_dayKey(day)] ?? const <int, double>{};
      final total = byMember.values.fold<double>(0, (s, v) => s + v);
      if (total > maxDayTotal) maxDayTotal = total;
    }
    if (maxDayTotal <= 0) maxDayTotal = 1;

    // Adaptive bar width based on number of days.
    final n = days.length;
    final barWidth = n <= 7
        ? 52.0
        : n <= 14
        ? 44.0
        : n <= 31
        ? 36.0
        : 28.0;
    const barGap = 6.0;

    return _buildAnalyticsCard(
      context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: isDark ? colors.primary : _analyticsPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.analyticsDailySpending,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? null : _analyticsFg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < days.length; i++) ...[
                    if (i > 0) const SizedBox(width: barGap),
                    _buildDayBar(
                      context,
                      day: days[i],
                      members: members,
                      memberColors: memberColors,
                      dailyByMember: dailyByMember,
                      maxDayTotal: maxDayTotal,
                      barWidth: barWidth,
                    ),
                  ],
                ],
              ),
            ),
            if (members.length > 1) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  for (final member in members)
                    _LegendItem(
                      color: memberColors[member.id] ?? _analyticsPrimary,
                      label: member.name,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDayBar(
    BuildContext context, {
    required DateTime day,
    required List<_MemberMeta> members,
    required Map<int, Color> memberColors,
    required Map<String, Map<int, double>> dailyByMember,
    required double maxDayTotal,
    required double barWidth,
  }) {
    final byMember = dailyByMember[_dayKey(day)] ?? const <int, double>{};
    final dayTotal = byMember.values.fold<double>(0, (s, v) => s + v);

    final segments = <_MemberDaySegment>[
      for (final member in members)
        if ((byMember[member.id] ?? 0) > 0)
          _MemberDaySegment(
            memberId: member.id,
            memberName: member.name,
            amount: byMember[member.id]!,
            color: memberColors[member.id] ?? _analyticsPrimary,
          ),
    ];

    return _DayStackedBar(
      dayLabel: _dayShortLabel(day),
      dayTotal: dayTotal,
      maxDayTotal: maxDayTotal,
      segments: segments,
      barWidth: barWidth,
      onSegmentTap: (_) {},
    );
  }

  Widget _buildMemberTotalsChart(
    BuildContext context, {
    required List<_MemberMeta> members,
    required Map<int, Color> memberColors,
    required Map<int, double> memberTotals,
    required bool expanded,
    required VoidCallback onToggle,
  }) {
    final rows = <_MemberTotalRow>[];
    for (final member in members) {
      rows.add(
        _MemberTotalRow(
          id: member.id,
          name: member.name,
          total: memberTotals[member.id] ?? 0,
          color: memberColors[member.id] ?? _analyticsPrimary,
        ),
      );
    }
    rows.sort((a, b) => b.total.compareTo(a.total));

    final maxValue = rows.fold<double>(1, (m, row) => math.max(m, row.total));
    final showRows = expanded || rows.length <= 4
        ? rows
        : rows.take(4).toList(growable: false);

    return _buildAnalyticsCard(
      context,
      child: Column(
        children: [
          _AnalyticsPressScale(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.groups_rounded,
                    size: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary
                        : _analyticsPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.analyticsByMember,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (rows.isNotEmpty)
                    _MemberAvatarStack(
                      rows: rows.take(4).toList(growable: false),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            Divider(
              height: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.25)
                  : _analyticsStroke,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                children: [
                  if (rows.isEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(context.l10n.noMembersFound),
                    )
                  else ...[
                    ...showRows.map(
                      (row) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
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
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (final row in rows.take(4))
                          _MemberAmountChip(
                            initials: _memberInitials(row.name),
                            amount: _formatMoney(row.total),
                            color: row.color,
                          ),
                      ],
                    ),
                    if (rows.length > 4) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onToggle,
                          icon: const Icon(Icons.expand_less_rounded),
                          label: Text(context.l10n.analyticsShowLess),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryTotalsChart(
    BuildContext context, {
    required List<_CategoryTotalRow> rows,
  }) {
    final total = rows.fold<double>(0, (sum, row) => sum + row.total);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return _buildAnalyticsCard(
      context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 18,
                  color: isDark ? colors.primary : _analyticsPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.analyticsByCategory,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? null : _analyticsFg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (rows.isEmpty)
              Text(context.l10n.noExpensesYet)
            else
              Row(
                children: [
                  SizedBox(
                    width: 134,
                    height: 134,
                    child: _DonutChart(
                      rows: rows,
                      total: total <= 0 ? 1 : total,
                      backgroundColor: isDark
                          ? colors.surfaceContainerHighest
                          : AppDesign.lightSurfaceMutedAlt,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        for (final row in rows)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: row.color,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    row.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: isDark ? null : _analyticsFg,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  total <= 0
                                      ? '0%'
                                      : '${((row.total / total) * 100).toStringAsFixed(0)}%',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? colors.onSurfaceVariant
                                            : _analyticsMuted,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatMoney(row.total),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInsightsCard(
    BuildContext context, {
    required List<DateTime> days,
    required List<_MemberMeta> members,
    required Map<int, double> memberTotals,
    required List<_CategoryTotalRow> categoryTotals,
    required Map<String, Map<int, double>> dailyByMember,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final memberRows =
        members
            .map(
              (member) =>
                  (name: member.name, total: memberTotals[member.id] ?? 0),
            )
            .toList(growable: false)
          ..sort((a, b) => b.total.compareTo(a.total));

    DateTime? bestDay;
    double bestDayValue = -1;
    for (final day in days) {
      final values = dailyByMember[_dayKey(day)] ?? const <int, double>{};
      final total = values.values.fold<double>(0, (sum, value) => sum + value);
      if (total > bestDayValue) {
        bestDayValue = total;
        bestDay = day;
      }
    }

    final topMember = memberRows.isEmpty ? null : memberRows.first;
    final topCategory = categoryTotals.isEmpty ? null : categoryTotals.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? colors.tertiary.withValues(alpha: 0.35)
              : _analyticsAccent.withValues(alpha: 0.35),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colors.tertiaryContainer.withValues(alpha: 0.30),
                  colors.surface,
                ]
              : [_analyticsAccent.withValues(alpha: 0.18), _analyticsCard],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: isDark ? colors.tertiary : _analyticsAccent,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.analyticsQuickInsights,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? null : _analyticsFg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (topCategory != null)
            _InsightRow(
              dotColor: _analyticsPrimary,
              text: context.l10n.analyticsBiggestExpense(
                topCategory.label,
                _formatMoney(topCategory.total),
              ),
            ),
          if (topMember != null)
            _InsightRow(
              dotColor: _analyticsAccent,
              text: context.l10n.analyticsTopSpender(
                topMember.name,
                _formatMoney(topMember.total),
              ),
            ),
          if (bestDay != null && bestDayValue > 0)
            _InsightRow(
              dotColor: _analyticsSuccess,
              text: context.l10n.analyticsHighestGroupDay(
                _dayShortLabel(bestDay),
                _formatMoney(bestDayValue),
              ),
            ),
          if (topMember == null && topCategory == null)
            Text(
              context.l10n.noExpensesYet,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colors.surface : _analyticsCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.28)
              : _analyticsStroke,
        ),
        boxShadow: isDark ? null : AppDesign.panelShadow(context),
      ),
      child: child,
    );
  }

  String _tripStatusLabel(Trip trip) {
    if (trip.isActive) {
      return context.l10n.activeStatus;
    }
    if (trip.isSettling) {
      return context.l10n.settlingStatus;
    }
    return context.l10n.archivedStatus;
  }

  String _tripDateLabel(Trip trip) {
    return AppFormatters.tripDateRange(
      context,
      startRaw: trip.dateFrom ?? trip.createdAt,
      endRaw: trip.dateTo ?? trip.endedAt ?? trip.archivedAt,
      unknownLabel: context.l10n.analyticsNoDates,
    );
  }

  String _memberInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      final first = parts.first;
      return (first.length >= 2 ? first.substring(0, 2) : first).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.dotColor, required this.text});

  final Color dotColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
