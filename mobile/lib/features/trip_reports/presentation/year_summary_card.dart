part of 'year_summary_page.dart';

const _yearSummaryMuted = Color(0xFF4A5874);

const _yearSummaryTitleStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 28,
  height: 1.12,
  fontWeight: FontWeight.w800,
  letterSpacing: -.6,
  color: quickStartInk,
);
const _yearSummaryBodyStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 15,
  height: 1.4,
  color: Color(0xFF263654),
);

String _yearSummaryMoney(
  BuildContext context,
  YearSummary summary,
  double value,
) => AppFormatters.currency(
  context,
  value,
  currencyCode: summary.currencyCode,
  wholeUnits: true,
);

/// Details for the user only; they never go into the shared image.
class _PrivateDetails extends StatelessWidget {
  const _PrivateDetails({required this.summary});

  final YearSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final biggest = summary.biggestTripName;
    final biggestShare = summary.biggestTripShare;
    final category = summary.topCategoryKey;
    final companion = summary.topCompanionNickname;
    final rows = <Widget>[
      if (summary.totalShare > 0 || summary.conversionComplete)
        _Row(
          key: const ValueKey('year-summary-spending'),
          label: t.yearSummarySpending,
          // Some trips are left out when a rate is missing: say it's partial.
          value:
              '${summary.conversionComplete ? '' : '≈ '}'
              '${_yearSummaryMoney(context, summary, summary.totalShare)}',
        ),
      if (biggest != null && biggest.isNotEmpty && biggestShare != null)
        _Row(
          key: const ValueKey('year-summary-biggest'),
          label: t.yearSummaryBiggestTrip,
          value:
              '$biggest · ${_yearSummaryMoney(context, summary, biggestShare)}',
        ),
      if (category != null && category.isNotEmpty)
        _Row(
          key: const ValueKey('year-summary-category'),
          label: t.yearSummaryTopCategory,
          value: ExpenseCategoryCatalog.labelFor(
            category,
            Localizations.localeOf(context),
          ),
        ),
      if (companion != null && companion.isNotEmpty)
        _Row(
          key: const ValueKey('year-summary-companion'),
          label: t.yearSummaryTopCompanion,
          value: '$companion · ${summary.topCompanionTrips}',
        ),
    ];
    if (rows.isEmpty) return const SizedBox(height: 12);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 15,
                      color: _yearSummaryMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        t.yearSummaryOnlyForYou,
                        key: const ValueKey('year-summary-private'),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: _yearSummaryMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: quickStartInk.withValues(alpha: .08),
                    ),
                  rows[i],
                ],
              ],
            ),
          ),
        ),
        if (!summary.conversionComplete)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              t.yearSummaryPartial,
              key: const ValueKey('year-summary-partial'),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: _yearSummaryMuted,
              ),
            ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: _yearSummaryMuted,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: quickStartInk,
            ),
          ),
        ),
      ],
    ),
  );
}
