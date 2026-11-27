part of 'year_summary_page.dart';

/// Whether the story wears its New Year look: December and January.
bool yearSummaryHolidaySeason(DateTime now) =>
    now.month == DateTime.december || now.month == DateTime.january;

/// The story's design size. It is shared at three times this, 1080 × 1920,
/// the size of an Instagram or WhatsApp story.
const yearSummaryStorySize = Size(360, 640);

const _storyMint = Color(0xFFA6F0CC);
const _storyTeal = Color(0xFF2FB8B0);
const _storyMuted = Color(0xFF7E90AE);
const _storyCountryNames = 8;

/// The shared picture: the year, a map with the countries visited lit up (or
/// a globe when no country is known), the counts and the logo. Fixed colours
/// and text size, so every phone shares the same picture.
class _YearStory extends StatelessWidget {
  const _YearStory({
    required this.summary,
    required this.world,
    required this.holiday,
  });

  final YearSummary summary;

  /// Country outlines; null while they load.
  final List<WorldCountry>? world;
  final bool holiday;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String upper(String text) => text.toUpperCase();
    final lit = summary.countryCodes.toSet();
    final stats = [
      (summary.tripCount, t.yearSummaryTripsLabel(summary.tripCount)),
      if (summary.daysAway > 0)
        (summary.daysAway, t.yearSummaryDaysLabel(summary.daysAway)),
      if (summary.countries.isNotEmpty)
        (
          summary.countries.length,
          t.yearSummaryCountriesLabel(summary.countries.length),
        ),
      if (summary.cities.isNotEmpty)
        (
          summary.cities.length,
          t.yearSummaryCitiesLabel(summary.cities.length),
        ),
    ];
    final names = [
      ...summary.countries.take(_storyCountryNames),
      if (summary.countries.length > _storyCountryNames)
        '+${summary.countries.length - _storyCountryNames}',
    ].join(' · ');
    final countries = world;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: SizedBox.fromSize(
        size: yearSummaryStorySize,
        child: DecoratedBox(
          key: const ValueKey('year-summary-story'),
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -.2),
              radius: 1.2,
              colors: [Color(0xFF123A52), Color(0xFF081C33), Color(0xFF050F1F)],
              stops: [0, .55, 1],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _StarsPainter()),
              ),
              Positioned(
                top: 34,
                left: 20,
                right: 20,
                child: Text(
                  upper(t.yearSummaryTitle),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    letterSpacing: 3.2,
                    fontWeight: FontWeight.w700,
                    color: _storyMint,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, _storyMint],
                    ).createShader(bounds),
                    child: Padding(
                      // Keeps the slanted last digit inside the gradient.
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${summary.year}',
                        key: const ValueKey('year-summary-story-year'),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 84,
                          height: 1,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 150,
                left: 0,
                right: 0,
                height: 280,
                child: countries == null
                    ? const SizedBox.shrink()
                    : CustomPaint(
                        key: ValueKey(
                          lit.isEmpty
                              ? 'year-summary-story-globe'
                              : 'year-summary-story-map',
                        ),
                        painter: lit.isEmpty
                            ? _GlobePainter(countries)
                            : _CountryMapPainter(countries, lit),
                      ),
              ),
              Positioned(
                top: 444,
                left: 16,
                right: 16,
                child: Row(
                  key: const ValueKey('year-summary-story-stats'),
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final (value, label) in stats)
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            children: [
                              Text(
                                NumberFormat.decimalPattern(
                                  locale,
                                ).format(value),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 40,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                upper(label),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 8.5,
                                  letterSpacing: 1.3,
                                  fontWeight: FontWeight.w600,
                                  color: _storyMint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (names.isNotEmpty)
                Positioned(
                  top: 516,
                  left: 28,
                  right: 28,
                  child: Text(
                    names,
                    key: const ValueKey('year-summary-story-countries'),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      height: 1.5,
                      color: Color(0xFFC7D8FF),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 30,
                child: Column(
                  children: [
                    if (holiday)
                      SvgPicture.asset(
                        'assets/branding/logo_full_dark_holiday.svg',
                        key: const ValueKey('year-summary-story-logo'),
                        height: 30,
                        semanticsLabel: 'Splyto',
                      )
                    else
                      Image.asset(
                        'assets/branding/logo_full_dark.png',
                        key: const ValueKey('year-summary-story-logo'),
                        height: 26,
                        semanticLabel: 'Splyto',
                      ),
                    const SizedBox(height: 6),
                    Text(
                      holiday
                          ? '${t.yearSummaryHappyNewYear} · SPLYTO.EU'
                          : 'SPLYTO.EU',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        letterSpacing: 1.7,
                        color: _storyMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Faint stars in fixed places, so every shared picture looks the same.
class _StarsPainter extends CustomPainter {
  const _StarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final paint = Paint();
    for (var i = 0; i < 40; i++) {
      paint.color = Colors.white.withValues(
        alpha: .12 + random.nextDouble() * .38,
      );
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        .5 + random.nextDouble() * .9,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter oldDelegate) => false;
}

Offset _mercator(Offset lonLat) {
  final lat = lonLat.dy.clamp(-58.0, 80.0) * math.pi / 180;
  return Offset(
    lonLat.dx,
    -math.log(math.tan(math.pi / 4 + lat / 2)) * 180 / math.pi,
  );
}

/// A flat map zoomed to the countries visited, which glow; the rest of the
/// world is dim and fades out towards the edges.
class _CountryMapPainter extends CustomPainter {
  const _CountryMapPainter(this.countries, this.lit);

  final List<WorldCountry> countries;
  final Set<String> lit;

  @override
  void paint(Canvas canvas, Size size) {
    // Fit the largest outline of each visited country, so a far island or
    // territory does not zoom the map out.
    var bounds = Rect.zero;
    var first = true;
    for (final country in countries) {
      if (!lit.contains(country.code) || country.polygons.isEmpty) continue;
      final main = country.polygons.reduce(
        (a, b) => a.length >= b.length ? a : b,
      );
      for (final point in main) {
        final p = _mercator(point);
        bounds = first
            ? Rect.fromLTWH(p.dx, p.dy, 0, 0)
            : bounds.expandToInclude(Rect.fromLTWH(p.dx, p.dy, 0, 0));
        first = false;
      }
    }
    if (first) return;
    // A small country should not fill the whole frame.
    final span = Size(math.max(bounds.width, 14), math.max(bounds.height, 10));
    final scale =
        math.max(span.width / size.width, span.height / size.height) * 1.3;
    final centre = bounds.center;
    Offset project(Offset lonLat) {
      final p = _mercator(lonLat);
      return Offset(
        (p.dx - centre.dx) / scale + size.width / 2,
        (p.dy - centre.dy) / scale + size.height / 2,
      );
    }

    Path outline(WorldCountry country) {
      final path = Path();
      for (final polygon in country.polygons) {
        path.addPolygon([for (final point in polygon) project(point)], true);
      }
      return path;
    }

    final frame = Offset.zero & size;
    canvas.save();
    canvas.clipRect(frame);
    canvas.saveLayer(frame, Paint());
    final land = Paint()..color = const Color(0xFF16324D);
    final border = Paint()
      ..color = const Color(0xFF0A1E36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .45;
    for (final country in countries) {
      if (lit.contains(country.code)) continue;
      final path = outline(country);
      canvas.drawPath(path, land);
      canvas.drawPath(path, border);
    }
    // Fade the dim world out towards the edges.
    canvas.drawRect(
      frame,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = const RadialGradient(
          radius: .62,
          colors: [Colors.white, Colors.white, Color(0x00FFFFFF)],
          stops: [0, .55, 1],
        ).createShader(frame),
    );
    canvas.restore();
    final glow = Paint()
      ..color = _storyTeal.withValues(alpha: .75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final fill = Paint()..color = _storyTeal;
    final edge = Paint()
      ..color = _storyMint
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7;
    for (final country in countries) {
      if (!lit.contains(country.code)) continue;
      final path = outline(country);
      canvas.drawPath(path, glow);
      canvas.drawPath(path, fill);
      canvas.drawPath(path, edge);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CountryMapPainter oldDelegate) =>
      oldDelegate.countries != countries || !setEquals(oldDelegate.lit, lit);
}

/// A dim globe with a plane circling it: decoration for a year without any
/// country, so the picture does not pretend to know places.
class _GlobePainter extends CustomPainter {
  const _GlobePainter(this.countries);

  final List<WorldCountry> countries;

  static const _lon0 = 15 * math.pi / 180;
  static const _lat0 = 28 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height * .4;
    final centre = Offset(size.width / 2, size.height * .5);
    (Offset, bool) project(Offset lonLat) {
      final lon = lonLat.dx * math.pi / 180;
      final lat = lonLat.dy * math.pi / 180;
      final cosC =
          math.sin(_lat0) * math.sin(lat) +
          math.cos(_lat0) * math.cos(lat) * math.cos(lon - _lon0);
      return (
        centre +
            Offset(
              radius * math.cos(lat) * math.sin(lon - _lon0),
              -radius *
                  (math.cos(_lat0) * math.sin(lat) -
                      math.sin(_lat0) * math.cos(lat) * math.cos(lon - _lon0)),
            ),
        cosC > -.05,
      );
    }

    final globe = Rect.fromCircle(center: centre, radius: radius);
    canvas.drawCircle(
      centre,
      radius + 20,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _storyTeal.withValues(alpha: .22),
            _storyTeal.withValues(alpha: 0),
          ],
          stops: const [.74, 1],
        ).createShader(Rect.fromCircle(center: centre, radius: radius + 20)),
    );
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.2, -.3),
          radius: .9,
          colors: [Color(0xFF173F5C), Color(0xFF0A2036)],
        ).createShader(globe),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(globe));
    final grid = Paint()
      ..color = const Color(0xFF2A5372).withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .4;
    for (var lat = -60; lat <= 60; lat += 30) {
      _line(canvas, [
        for (var lon = -180; lon <= 180; lon += 3)
          project(Offset(lon.toDouble(), lat.toDouble())),
      ], grid);
    }
    for (var lon = -180; lon < 180; lon += 30) {
      _line(canvas, [
        for (var lat = -88; lat <= 88; lat += 3)
          project(Offset(lon.toDouble(), lat.toDouble())),
      ], grid);
    }
    final land = Paint()..color = const Color(0xFF1F4A66);
    final border = Paint()
      ..color = const Color(0xFF2C6584)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .4;
    for (final country in countries) {
      for (final polygon in country.polygons) {
        final points = [for (final p in polygon) project(p)];
        final visible = points.where((p) => p.$2).length;
        if (visible < points.length * .6) continue;
        final path = Path()
          ..addPolygon([
            for (final p in points)
              if (p.$2) p.$1,
          ], true);
        canvas.drawPath(path, land);
        canvas.drawPath(path, border);
      }
    }
    canvas.restore();
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = _storyMint.withValues(alpha: .35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7,
    );
    // The orbit, drawn as dots.
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(-18 * math.pi / 180);
    final orbit = Rect.fromCenter(
      center: Offset.zero,
      width: (radius + 40) * 2,
      height: 80,
    );
    final dots = Paint()..strokeCap = StrokeCap.round;
    for (var a = 0.0; a < math.pi * 2; a += .075) {
      final t = a / (math.pi * 2);
      dots.color = Color.lerp(
        const Color(0xFFE8388F),
        const Color(0xFF00E0D0),
        t,
      )!;
      // The back half passes behind the globe.
      if (math.sin(a) < 0 &&
          (Offset(
                orbit.width / 2 * math.cos(a),
                orbit.height / 2 * math.sin(a),
              )).distance <
              radius) {
        continue;
      }
      canvas.drawCircle(
        Offset(orbit.width / 2 * math.cos(a), orbit.height / 2 * math.sin(a)),
        .9,
        dots,
      );
    }
    final plane = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.flight.codePoint),
        style: TextStyle(
          fontFamily: Icons.flight.fontFamily,
          package: Icons.flight.fontPackage,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.translate(orbit.width / 2 - 2, -6);
    canvas.rotate(math.pi * .05);
    plane.paint(canvas, Offset(-plane.width / 2, -plane.height / 2));
    plane.dispose();
    canvas.restore();
  }

  void _line(Canvas canvas, List<(Offset, bool)> points, Paint paint) {
    final path = Path();
    var drawing = false;
    for (final (point, visible) in points) {
      if (!visible) {
        drawing = false;
        continue;
      }
      if (drawing) {
        path.lineTo(point.dx, point.dy);
      } else {
        path.moveTo(point.dx, point.dy);
        drawing = true;
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GlobePainter oldDelegate) =>
      oldDelegate.countries != countries;
}

