part of 'year_summary_page.dart';

const _yearSummaryTeal = Color(0xFF2FB8B0);
const _yearSummaryGreen = Color(0xFF1F9D6B);
const _yearSummaryMint = Color(0xFFA6F0CC);
const _yearSummaryCardGreen = Color(0xFF1E5A43);
const _yearSummaryMuted = Color(0xFF4A5874);
const _yearSummaryMaxChips = 6;

const _yearSummaryTitleStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 30,
  height: 1.12,
  fontWeight: FontWeight.w800,
  letterSpacing: -.8,
  color: quickStartInk,
);
const _yearSummaryBodyStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  height: 1.4,
  color: Color(0xFF263654),
);

/// Title, line and card of one slide; scrolls when text is large.
class _Slide extends StatelessWidget {
  const _Slide({
    required this.title,
    required this.body,
    required this.child,
    this.footer,
  });

  final String title;
  final String body;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: math.max(0, constraints.maxHeight - 32),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: _yearSummaryTitleStyle,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: _yearSummaryBodyStyle,
                ),
                const SizedBox(height: 28),
                child,
                ?footer,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// The light, slightly see-through card in the middle of slides 1 and 2.
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white),
      boxShadow: [
        BoxShadow(
          color: quickStartInk.withValues(alpha: .08),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Padding(padding: const EdgeInsets.all(22), child: child),
  );
}

class _YearSlide extends StatelessWidget {
  const _YearSlide({required this.summary});

  final YearSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final stats = [
      ('${summary.daysAway}', t.yearSummaryDays),
      ('${summary.countries.length}', t.yearSummaryCountries),
      ('${summary.cities.length}', t.yearSummaryCities),
    ];
    return _Slide(
      title: t.yearSummaryIntroTitle('${summary.year}'),
      body: t.yearSummaryIntroBody,
      child: _GlassCard(
        child: Column(
          key: const ValueKey('year-summary-year-card'),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Transform.rotate(
                  angle: -.08,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _yearSummaryMint.withValues(alpha: .7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      child: Text(
                        '${summary.year}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _yearSummaryCardGreen,
                        ),
                      ),
                    ),
                  ),
                ),
                const Icon(
                  Icons.luggage_outlined,
                  size: 44,
                  color: _yearSummaryGreen,
                ),
              ],
            ),
            Text(
              '${summary.tripCount}',
              key: const ValueKey('year-summary-trip-count'),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 88,
                height: 1.05,
                fontWeight: FontWeight.w900,
                color: _yearSummaryGreen,
              ),
            ),
            Text(
              t.yearSummaryTripsToRemember(summary.tripCount),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: quickStartInk,
              ),
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: quickStartInk.withValues(alpha: .12)),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    if (i > 0)
                      VerticalDivider(
                        width: 1,
                        color: quickStartInk.withValues(alpha: .12),
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            stats[i].$1,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: quickStartInk,
                            ),
                          ),
                          Text(
                            stats[i].$2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: _yearSummaryMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlacesSlide extends StatelessWidget {
  const _PlacesSlide({required this.summary});

  final YearSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    String money(double value) => AppFormatters.currency(
      context,
      value,
      currencyCode: summary.currencyCode,
      wholeUnits: true,
    );
    final countries = summary.countries;
    final shown = countries.take(_yearSummaryMaxChips).toList();
    final hidden = countries.length - shown.length;
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
          value: summary.conversionComplete
              ? money(summary.totalShare)
              : '≈ ${money(summary.totalShare)}',
        ),
      if (biggest != null && biggest.isNotEmpty && biggestShare != null)
        _Row(
          key: const ValueKey('year-summary-biggest'),
          label: t.yearSummaryBiggestTrip,
          value: '$biggest · ${money(biggestShare)}',
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
          value: companion,
          detail: t.yearSummaryTripsTogether('${summary.topCompanionTrips}'),
        ),
    ];
    return _Slide(
      title: t.yearSummaryPlacesTitle,
      body: t.yearSummaryPlacesBody,
      footer: summary.conversionComplete
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                t.yearSummaryPartial,
                key: const ValueKey('year-summary-partial'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: _yearSummaryMuted,
                ),
              ),
            ),
      child: _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (shown.isNotEmpty) ...[
              Wrap(
                key: const ValueKey('year-summary-countries'),
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final country in shown) _Chip(label: country),
                  if (hidden > 0) _Chip(label: '+$hidden'),
                ],
              ),
              if (rows.isNotEmpty) ...[
                const SizedBox(height: 18),
                Divider(height: 1, color: quickStartInk.withValues(alpha: .12)),
                const SizedBox(height: 6),
              ],
            ],
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: _yearSummaryMint.withValues(alpha: .45),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _yearSummaryCardGreen,
        ),
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.label,
    required this.value,
    this.detail,
  });

  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final detailText = detail;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: quickStartInk,
                  ),
                ),
                if (detailText != null)
                  Text(
                    detailText,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: _yearSummaryMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareSlide extends StatelessWidget {
  const _ShareSlide({
    required this.summary,
    required this.cardKey,
    required this.includeSpending,
    required this.onIncludeSpendingChanged,
  });

  final YearSummary summary;
  final GlobalKey cardKey;
  final bool includeSpending;
  final ValueChanged<bool> onIncludeSpendingChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final hasSpending = summary.totalShare > 0;
    return _Slide(
      title: t.yearSummaryShareTitle,
      body: t.yearSummaryShareBody,
      footer: hasSpending
          ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SwitchListTile.adaptive(
                key: const ValueKey('year-summary-include-spending'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(
                  t.yearSummaryIncludeSpending,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: quickStartInk,
                  ),
                ),
                value: includeSpending,
                onChanged: onIncludeSpendingChanged,
              ),
            )
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: RepaintBoundary(
          key: cardKey,
          child: _ShareCard(
            summary: summary,
            includeSpending: includeSpending && hasSpending,
          ),
        ),
      ),
    );
  }
}

/// The shared image. Fixed colours, so it looks the same in light and dark mode.
class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.summary, required this.includeSpending});

  final YearSummary summary;
  final bool includeSpending;

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
    final shownCountries = countries.take(5).join(' · ');
    final moreCountries = countries.length > 5
        ? ' · +${countries.length - 5}'
        : '';
    final spending = AppFormatters.currency(
      context,
      summary.totalShare,
      currencyCode: summary.currencyCode,
      wholeUnits: true,
    );
    return DecoratedBox(
      key: const ValueKey('year-summary-share-card'),
      decoration: BoxDecoration(
        color: _yearSummaryCardGreen,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          children: [
            Text(
              '${summary.year}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 64,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                color: _yearSummaryMint,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${t.yearSummaryTripCount(summary.tripCount)} · '
              '${t.yearSummaryDayCount(summary.daysAway)}',
              textAlign: TextAlign.center,
              style: line,
            ),
            Text(
              '${t.yearSummaryCountryCount(summary.countries.length)} · '
              '${t.yearSummaryCityCount(summary.cities.length)}',
              textAlign: TextAlign.center,
              style: line,
            ),
            if (shownCountries.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '$shownCountries$moreCountries',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: .8),
                ),
              ),
            ],
            if (includeSpending) ...[
              const SizedBox(height: 10),
              Text(
                '${t.yearSummarySpending}: '
                '${summary.conversionComplete ? '' : '≈ '}$spending',
                key: const ValueKey('year-summary-share-spending'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _yearSummaryMint,
                ),
              ),
            ],
            const SizedBox(height: 14),
            const SizedBox(
              height: 64,
              width: double.infinity,
              child: CustomPaint(painter: _FlightPathPainter()),
            ),
            const SizedBox(height: 8),
            const Text(
              'Splyto',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    final mint = Paint()..color = _yearSummaryMint;
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
    canvas.drawPath(pin, mint);
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
