part of 'year_summary_page.dart';

const _yearSummaryMint = Color(0xFFA6F0CC);
const _yearSummaryCardGreen = Color(0xFF1E5A43);
const _yearSummaryMuted = Color(0xFF4A5874);
const _yearSummaryMaxCountries = 5;

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

/// The shared image. Fixed colours, so it looks the same in light and dark
/// mode. Counts that are zero are left out rather than shown as "0".
class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.summary, this.holiday = false});

  final YearSummary summary;

  /// The New Year look: snow, the digits with snow caps, a greeting and the
  /// logo in a Santa hat.
  final bool holiday;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    const line = TextStyle(
      fontFamily: 'Inter',
      fontSize: 19,
      height: 1.3,
      fontWeight: FontWeight.w800,
      color: Colors.white,
    );
    final countries = summary.countries;
    final tripLine = [
      t.yearSummaryTripCount(summary.tripCount),
      if (summary.daysAway > 0) t.yearSummaryDayCount(summary.daysAway),
    ].join(' · ');
    final placeLine = [
      if (countries.isNotEmpty) t.yearSummaryCountryCount(countries.length),
      if (summary.cities.isNotEmpty)
        t.yearSummaryCityCount(summary.cities.length),
    ].join(' · ');
    final countryNames = [
      ...countries.take(_yearSummaryMaxCountries),
      if (countries.length > _yearSummaryMaxCountries)
        '+${countries.length - _yearSummaryMaxCountries}',
    ].join(' · ');
    final plainYear = ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD9FBEA), _yearSummaryMint, Color(0xFF5ED6B8)],
      ).createShader(bounds),
      // Padding keeps the slanted last digit inside the gradient.
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(
          '${summary.year}',
          key: const ValueKey('year-summary-card-year'),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 76,
            height: 1,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: -3,
            color: Colors.white,
          ),
        ),
      ),
    );
    final content = Padding(
      padding: EdgeInsets.fromLTRB(20, 22, 20, holiday ? 46 : 20),
      child: Column(
        children: [
          if (holiday) ...[
            _HolidayYear(year: summary.year),
            Text(
              t.yearSummaryHappyNewYear,
              key: const ValueKey('year-summary-card-greeting'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: _yearSummaryMint,
              ),
            ),
          ] else
            plainYear,
          const SizedBox(height: 12),
          Text(
            tripLine,
            key: const ValueKey('year-summary-card-trips'),
            textAlign: TextAlign.center,
            style: line,
          ),
          if (placeLine.isNotEmpty)
            Text(
              placeLine,
              key: const ValueKey('year-summary-card-places'),
              textAlign: TextAlign.center,
              style: line,
            ),
          if (countryNames.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              countryNames,
              key: const ValueKey('year-summary-card-countries'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.white.withValues(alpha: .8),
              ),
            ),
          ],
          const SizedBox(height: 14),
          const SizedBox(
            height: 56,
            width: double.infinity,
            child: CustomPaint(painter: _FlightPathPainter()),
          ),
          const SizedBox(height: 10),
          if (holiday)
            SvgPicture.asset(
              'assets/branding/logo_full_dark_holiday.svg',
              key: const ValueKey('year-summary-card-logo'),
              height: 46,
              semanticsLabel: 'Splyto',
            )
          else
            Image.asset(
              'assets/branding/logo_full_dark.png',
              key: const ValueKey('year-summary-card-logo'),
              height: 34,
              fit: BoxFit.contain,
              semanticLabel: 'Splyto',
            ),
        ],
      ),
    );
    return ClipRRect(
      key: const ValueKey('year-summary-share-card'),
      borderRadius: BorderRadius.circular(28),
      child: ColoredBox(
        color: _yearSummaryCardGreen,
        child: Stack(
          children: [
            if (holiday)
              const Positioned.fill(
                child: CustomPaint(painter: _SnowfallPainter()),
              ),
            content,
            if (holiday)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 44,
                child: CustomPaint(painter: _SnowDriftPainter()),
              ),
          ],
        ),
      ),
    );
  }
}

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

/// A pin, a looping dashed route and a plane.
class _FlightPathPainter extends CustomPainter {
  const _FlightPathPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final start = Offset(w * .12, h * .62);
    final end = Offset(w * .84, h * .22);
    final route = Path()
      ..moveTo(start.dx, start.dy + 8)
      ..cubicTo(w * .3, h * 1.05, w * .52, h * .9, w * .54, h * .45)
      ..cubicTo(w * .56, h * .05, w * .38, h * .1, w * .44, h * .5)
      ..cubicTo(w * .5, h * .9, w * .7, h * .55, end.dx - 14, end.dy + 6);
    final dash = Paint()
      ..color = Colors.white.withValues(alpha: .85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final metric in route.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, d + 4), dash);
      }
    }
    final pin = Path()
      ..moveTo(start.dx, start.dy + 8)
      ..quadraticBezierTo(
        start.dx - 9,
        start.dy - 2,
        start.dx - 9,
        start.dy - 8,
      )
      ..arcToPoint(
        Offset(start.dx + 9, start.dy - 8),
        radius: const Radius.circular(9),
      )
      ..quadraticBezierTo(start.dx + 9, start.dy - 2, start.dx, start.dy + 8)
      ..close();
    canvas.drawPath(pin, Paint()..color = _yearSummaryMint);
    canvas.drawCircle(
      Offset(start.dx, start.dy - 8),
      3.5,
      Paint()..color = _yearSummaryCardGreen,
    );
    final plane = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.flight.codePoint),
        style: TextStyle(
          fontFamily: Icons.flight.fontFamily,
          package: Icons.flight.fontPackage,
          fontSize: 30,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(end.dx, end.dy);
    canvas.rotate(math.pi / 4);
    plane.paint(canvas, Offset(-plane.width / 2, -plane.height / 2));
    canvas.restore();
    plane.dispose();
  }

  @override
  bool shouldRepaint(_FlightPathPainter oldDelegate) => false;
}
