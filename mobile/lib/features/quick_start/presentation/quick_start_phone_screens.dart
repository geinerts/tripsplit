import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_formatters.dart';

const _screenWidth = 270.0;

/// Matches the iPhone screenshots (921 × 2000), so they fill the screen uncropped.
const _screenHeight = 586.0;
const _frameWidth = _screenWidth + 20;
const _canvas = Colors.white;
const _text = Color(0xFF0B1220);
const _muted = Color(0xFF5F6B76);
const _teal = Color(0xFF0098AD);
const _pink = Color(0xFFE5398F);
const _marta = Color(0xFF00836B);

/// A still phone frame whose screen slides with the swipe, plus small cards that
/// float over its edge. Decorative sample data: the slide text carries the meaning
/// for screen readers.
class QuickStartPhone extends StatelessWidget {
  const QuickStartPhone({
    super.key,
    required this.page,
    required this.slideCount,
  });

  final double page;
  final int slideCount;

  @override
  Widget build(BuildContext context) {
    final clamped = page.clamp(0.0, slideCount - 1.0);
    final visible = <int>{clamped.floor(), clamped.ceil()};
    return MediaQuery.withNoTextScaling(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / _frameWidth;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: constraints.maxWidth,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                  child: _Frame(page: page, visible: visible),
                ),
              ),
              for (final index in visible)
                _FloatingCard(
                  index: index,
                  page: page,
                  scale: scale,
                  phoneWidth: constraints.maxWidth,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.page, required this.visible});

  final double page;
  final Set<int> visible;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('quick-start-phone'),
    width: _frameWidth,
    height: _screenHeight + 20,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      // Natural titanium, as in the App Store preview.
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0, .22, .5, .78, 1],
        colors: [
          Color(0xFFE4DFD5),
          Color(0xFFA8A296),
          Color(0xFFD2CCC0),
          Color(0xFF99948A),
          Color(0xFFDAD5CA),
        ],
      ),
      borderRadius: BorderRadius.circular(46),
      boxShadow: const [
        BoxShadow(
          color: Color(0x400B1B3A),
          blurRadius: 36,
          offset: Offset(0, 16),
        ),
      ],
    ),
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF05070A),
        borderRadius: BorderRadius.circular(42),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: ColoredBox(
          color: _canvas,
          child: Stack(
            children: [
              for (final index in visible)
                Transform.translate(
                  offset: Offset((index - page) * _screenWidth, 0),
                  child: RepaintBoundary(
                    child: SizedBox(
                      width: _screenWidth,
                      height: _screenHeight,
                      child: _Screenshot(_screenshots[index]),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 76,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF05070A),
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Cleaned app screenshots, in slide order. Both map images use SPLYTO's own
/// drawn maps, never Mapbox tiles.
const _screenshots = [
  'assets/quick_start/create_trip.webp',
  'assets/quick_start/add_expense.webp',
  'assets/quick_start/settle_up.webp',
  'assets/quick_start/analytics.webp',
  'assets/quick_start/travel_map.webp',
  'assets/quick_start/live_map.webp',
];

class _Screenshot extends StatelessWidget {
  const _Screenshot(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    width: _screenWidth,
    height: _screenHeight,
    fit: BoxFit.cover,
    alignment: Alignment.topCenter,
    filterQuality: FilterQuality.medium,
    excludeFromSemantics: true,
    gaplessPlayback: true,
  );
}

/// Each card moves further than the screen behind it, which gives the swipe depth.
class _FloatingCard extends StatelessWidget {
  const _FloatingCard({
    required this.index,
    required this.page,
    required this.scale,
    required this.phoneWidth,
  });

  final int index;
  final double page;
  final double scale;
  final double phoneWidth;

  @override
  Widget build(BuildContext context) {
    final delta = index - page;
    final opacity = (1 - delta.abs() * 1.6).clamp(0.0, 1.0);
    if (opacity == 0) return const SizedBox.shrink();
    final t = context.l10n;
    final (
      double top,
      double? left,
      double? right,
      Widget card,
    ) = switch (index) {
      0 => (
        128.0,
        null,
        -22.0,
        _Pill(
          icon: Icons.qr_code_2_rounded,
          label: t.tripInviteAction,
          color: _teal,
        ),
      ),
      1 => (
        176.0,
        -22.0,
        null,
        // The screenshot's USD 132.25 at the 0.924 day rate.
        _ConversionCard(
          original: AppFormatters.displayCurrencyFromCents(
            context,
            13225,
            currencyCode: 'USD',
          ),
          converted: _money(context, 12220),
        ),
      ),
      2 => (
        268.0,
        null,
        -22.0,
        _Pill(
          icon: Icons.payments_rounded,
          label: _money(context, 4223),
          color: _marta,
        ),
      ),
      3 => (346.0, null, -24.0, _DailyCard(title: t.analyticsDailySpending)),
      // Over the empty sea, between the place count and the Iberian pins.
      4 => (160.0, -22.0, null, const _PlaceCard()),
      _ => (
        118.0,
        null,
        -22.0,
        _Pill(icon: Icons.timer_rounded, label: '1 h', color: _pink),
      ),
    };
    return Positioned(
      top: top * scale,
      left: left == null ? null : left * scale + delta * phoneWidth * 1.25,
      right: right == null ? null : right * scale - delta * phoneWidth * 1.25,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          alignment: left == null ? Alignment.topRight : Alignment.topLeft,
          child: card,
        ),
      ),
    );
  }
}

String _money(BuildContext context, int cents) =>
    AppFormatters.displayCurrencyFromCents(context, cents, currencyCode: 'EUR');

class _Label extends StatelessWidget {
  const _Label(
    this.text, {
    this.size = 13,
    this.weight = FontWeight.w400,
    this.color = _text,
  });

  final String text;
  final double size;
  final FontWeight weight;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(fontSize: size, fontWeight: weight, color: color),
  );
}

BoxDecoration _floatDecoration(Color color) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(16),
  boxShadow: const [
    BoxShadow(color: Color(0x330B1B3A), blurRadius: 22, offset: Offset(0, 10)),
  ],
);

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 190),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: _floatDecoration(color),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 8),
        Flexible(
          child: _Label(
            label,
            size: 14,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

class _ConversionCard extends StatelessWidget {
  const _ConversionCard({required this.original, required this.converted});

  final String original;
  final String converted;

  @override
  Widget build(BuildContext context) {
    // The expense screenshot's purchase date.
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(DateTime(2026, 11, 9));
    return Container(
      width: 186,
      padding: const EdgeInsets.all(12),
      decoration: _floatDecoration(Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_rounded, size: 14, color: _teal),
              const SizedBox(width: 5),
              Expanded(child: _Label(date, size: 12, color: _muted)),
            ],
          ),
          const SizedBox(height: 6),
          _Label(original, size: 14, weight: FontWeight.w600, color: _muted),
          Row(
            children: [
              const Icon(
                Icons.currency_exchange_rounded,
                size: 16,
                color: _teal,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _Label(converted, size: 20, weight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    const bars = [.45, .8, .35, 1.0, .6, .72, .5];
    return Container(
      width: 176,
      padding: const EdgeInsets.all(12),
      decoration: _floatDecoration(Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(title, size: 12, weight: FontWeight.w600),
          const SizedBox(height: 10),
          SizedBox(
            height: 58,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < bars.length; i++)
                  Container(
                    width: 15,
                    height: 58 * bars[i],
                    decoration: BoxDecoration(
                      color: i == 3 ? _pink : _teal,
                      borderRadius: BorderRadius.circular(4),
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

/// A visited place as the travel map shows it when a pin is tapped.
class _PlaceCard extends StatelessWidget {
  const _PlaceCard();

  static const _green = Color(0xFF00836B);
  static const _grey = Color(0xFF697182);

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(DateTime(2026, 11, 6));
    return Container(
      width: 188,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: _floatDecoration(Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: _Label('Vlorë', size: 15, weight: FontWeight.w700),
              ),
              Icon(Icons.close, size: 15, color: _grey),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              'assets/quick_start/place_albania.webp',
              width: 164,
              height: 92,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(height: 7),
          const _Label('Albania', size: 13, weight: FontWeight.w700),
          const _Label('Vlora, Albania', size: 11, color: _grey),
          const SizedBox(height: 2),
          _Label(date, size: 12),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.open_in_new, size: 14, color: _green),
              const SizedBox(width: 5),
              Expanded(
                child: _Label(
                  context.l10n.travelOpenTrip,
                  size: 11.5,
                  weight: FontWeight.w700,
                  color: _green,
                ),
              ),
              const Icon(Icons.edit_outlined, size: 15, color: _grey),
              const SizedBox(width: 8),
              const Icon(Icons.delete_outline, size: 15, color: _grey),
            ],
          ),
        ],
      ),
    );
  }
}
