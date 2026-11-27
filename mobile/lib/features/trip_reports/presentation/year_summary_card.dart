part of 'year_summary_page.dart';


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
    String capitalise(String text) =>
        text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
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
      if (summary.expenseCount > 0)
        _Row(
          key: const ValueKey('year-summary-expenses'),
          label: t.yearSummaryExpensesAdded,
          value: '${summary.expenseCount}',
        ),
      if (summary.countries.isNotEmpty)
        _Row(
          key: const ValueKey('year-summary-all-countries'),
          label: capitalise(
            t.yearSummaryCountriesLabel(summary.countries.length),
          ),
          value: summary.countries.join(', '),
        ),
      if (summary.cities.isNotEmpty)
        _Row(
          key: const ValueKey('year-summary-all-cities'),
          label: capitalise(t.yearSummaryCitiesLabel(summary.cities.length)),
          value: summary.cities.join(', '),
        ),
    ];
    if (rows.isEmpty) return const SizedBox(height: 12);
    const muted = Color(0xB3FFFFFF);
    // Straight on the dimmed background, as wide as the card above.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 22),
        Row(
          children: [
            const Icon(Icons.lock_outline, size: 14, color: muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                t.yearSummaryOnlyForYou,
                key: const ValueKey('year-summary-private'),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  letterSpacing: .2,
                  color: muted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        for (var i = 0; i < rows.length; i++) ...[
          Divider(height: 1, color: Colors.white.withValues(alpha: .14)),
          rows[i],
        ],
        Divider(height: 1, color: Colors.white.withValues(alpha: .14)),
        if (!summary.conversionComplete)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              t.yearSummaryPartial,
              key: const ValueKey('year-summary-partial'),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: muted,
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
              color: Color(0xB3FFFFFF),
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
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}
