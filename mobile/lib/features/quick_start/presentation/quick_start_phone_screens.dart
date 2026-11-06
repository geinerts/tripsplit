import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/expenses/expense_category_catalog.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_formatters.dart';

const _screenWidth = 270.0;
const _screenHeight = 560.0;
const _frameWidth = _screenWidth + 20;
const _canvas = Color(0xFF12171D);
const _surface = Color(0xFF1C232B);
const _stroke = Color(0xFF2C3640);
const _text = Colors.white;
const _muted = Color(0xFF9AA8B3);
const _accent = Color(0xFF57B487);
const _teal = Color(0xFF00BED4);
const _pink = Color(0xFFE5398F);
const _red = Color(0xFFF2A0A8);
const _marta = Color(0xFF00836B);
const _rita = _pink;
const _ivo = Color(0xFF0A8FA3);

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
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFF05070A),
      borderRadius: BorderRadius.circular(46),
      border: Border.all(color: const Color(0xFF3A444F), width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 40,
          offset: Offset(0, 16),
        ),
      ],
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
                    child: switch (index) {
                      0 => const _TripScreen(),
                      1 => const _ExpensesScreen(),
                      2 => _BalancesScreen(active: (page - 2).abs() < .01),
                      3 => const _AnalyticsScreen(),
                      4 => const _TravelMapScreen(),
                      _ => const _LiveMapScreen(),
                    },
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
        352.0,
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
        _ConversionCard(
          original: AppFormatters.displayCurrencyFromCents(
            context,
            5000,
            currencyCode: 'USD',
          ),
          converted: _money(context, 4620),
        ),
      ),
      2 => (
        268.0,
        null,
        -22.0,
        _Pill(
          icon: Icons.payments_rounded,
          label: _money(context, 1666),
          color: _marta,
        ),
      ),
      3 => (222.0, null, -24.0, _DailyCard(title: t.analyticsDailySpending)),
      4 => (128.0, -22.0, null, const _PlaceCard()),
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
    super.key,
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

class _Avatar extends StatelessWidget {
  const _Avatar(this.letter, this.color, {this.size = 32});

  final String letter;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Text(
      letter,
      style: TextStyle(
        color: Colors.white,
        fontSize: size * .42,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

BoxDecoration _floatDecoration(Color color) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(16),
  boxShadow: const [
    BoxShadow(color: Color(0x73000000), blurRadius: 22, offset: Offset(0, 10)),
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
        Flexible(child: _Label(label, size: 14, weight: FontWeight.w700)),
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
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(DateTime(2026, 10, 5));
    return Container(
      width: 186,
      padding: const EdgeInsets.all(12),
      decoration: _floatDecoration(const Color(0xFF26313B)),
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
      decoration: _floatDecoration(const Color(0xFF26313B)),
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

class _PlaceCard extends StatelessWidget {
  const _PlaceCard();

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(DateTime(2026, 10, 5));
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: _floatDecoration(Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label(
            'Lisbon',
            size: 16,
            weight: FontWeight.w700,
            color: Color(0xFF0B1220),
          ),
          const _Label('Portugal', size: 12, color: Color(0xFF697182)),
          const SizedBox(height: 4),
          _Label(date, size: 12, color: const Color(0xFF0B1220)),
        ],
      ),
    );
  }
}

class _TripHeader extends StatelessWidget {
  const _TripHeader({required this.activeTab});

  final int activeTab;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final tabs = [
      t.workspaceExpense,
      t.navBalances,
      t.workspaceSettle,
      t.workspaceActivityTab,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 44, 14, 8),
          child: Row(
            children: [
              Icon(Icons.chevron_left_rounded, size: 22, color: _text),
              SizedBox(width: 4),
              Expanded(
                child: _Label(
                  'Lisbon getaway',
                  size: 17,
                  weight: FontWeight.w700,
                ),
              ),
              Icon(Icons.notifications_none_rounded, size: 18, color: _text),
            ],
          ),
        ),
        Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i == activeTab ? _accent : _stroke,
                        width: i == activeTab ? 2 : 1,
                      ),
                    ),
                  ),
                  child: _Label(
                    tabs[i],
                    size: 11,
                    weight: FontWeight.w600,
                    color: i == activeTab ? _text : _muted,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TripScreen extends StatelessWidget {
  const _TripScreen();

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 150,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_teal, _marta, _pink],
            ),
          ),
          child: const Icon(
            Icons.luggage_rounded,
            size: 58,
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Lisbon getaway', size: 20, weight: FontWeight.w700),
              const SizedBox(height: 6),
              const _TripTypeSwitch(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _Label(
                    t.activeStatus,
                    size: 12,
                    weight: FontWeight.w600,
                    color: _accent,
                  ),
                  const Spacer(),
                  const _Avatar('M', _marta, size: 26),
                  const SizedBox(width: 4),
                  const _Avatar('R', _rita, size: 26),
                  const SizedBox(width: 4),
                  const _Avatar('I', _ivo, size: 26),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _Stat(t.workspaceTripTotal, _money(context, 124000)),
                  ),
                  Expanded(child: _Stat(t.yourShare, _money(context, 41333))),
                ],
              ),
              const SizedBox(height: 8),
              _Label(
                '${t.analyticsYouGetBack} ${_money(context, 1666)}',
                weight: FontWeight.w600,
                color: _accent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TripTypeSwitch extends StatelessWidget {
  const _TripTypeSwitch();

  @override
  Widget build(BuildContext context) {
    Widget option(IconData icon, bool selected) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? _accent : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        size: 16,
        color: selected ? const Color(0xFF0B1220) : _muted,
      ),
    );
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          option(Icons.person_rounded, false),
          option(Icons.groups_rounded, true),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Label(label, size: 12, color: _muted),
      const SizedBox(height: 2),
      _Label(value, size: 18, weight: FontWeight.w700),
    ],
  );
}

class _ExpensesScreen extends StatelessWidget {
  const _ExpensesScreen();

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    Widget row(String key, String payer, int cents) {
      final color = ExpenseCategoryCatalog.colorFor(key);
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _stroke)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                ExpenseCategoryCatalog.iconFor(key),
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(
                    ExpenseCategoryCatalog.labelFor(key, locale),
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                  _Label(payer, size: 11, color: _muted),
                ],
              ),
            ),
            const SizedBox(width: 6),
            _Label(_money(context, cents), size: 14, weight: FontWeight.w600),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TripHeader(activeTab: 0),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              row('accommodation', 'Marta', 32000),
              row('tickets', 'Rita', 9600),
              row('food', 'Ivo', 4800),
              row('transport', 'Marta', 2400),
              row('groceries', 'Rita', 3150),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shows debts first, then clears them, to explain what settling up means.
class _BalancesScreen extends StatefulWidget {
  const _BalancesScreen({required this.active});

  final bool active;

  @override
  State<_BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<_BalancesScreen> {
  Timer? _timer;
  bool _settled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_BalancesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _timer?.cancel();
      _settled = true;
      return;
    }
    if (!widget.active || _settled || _timer != null) return;
    _timer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _settled = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 350);
    Widget row(String letter, Color color, String name, int cents) {
      final cleared = _settled || cents == 0;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _stroke)),
        ),
        child: Row(
          children: [
            _Avatar(letter, color),
            const SizedBox(width: 10),
            Expanded(child: _Label(name, size: 15, weight: FontWeight.w600)),
            AnimatedSwitcher(
              duration: duration,
              child: cleared
                  ? Row(
                      key: const ValueKey('cleared'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: _accent,
                        ),
                        const SizedBox(width: 4),
                        _Label(t.settledLabel, color: _muted),
                      ],
                    )
                  : _Label(
                      '${cents > 0 ? '+' : '−'}'
                      '${_money(context, cents.abs())}',
                      key: const ValueKey('amount'),
                      size: 15,
                      weight: FontWeight.w700,
                      color: cents > 0 ? _accent : _red,
                    ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TripHeader(activeTab: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              row('M', _marta, 'Marta', 1666),
              row('R', _rita, 'Rita', -1666),
              row('I', _ivo, 'Ivo', 0),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsScreen extends StatelessWidget {
  const _AnalyticsScreen();

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final locale = Localizations.localeOf(context);
    Widget bar(String key, double value, int cents) {
      final color = ExpenseCategoryCatalog.colorFor(key);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: _Label(
                ExpenseCategoryCatalog.labelFor(key, locale),
                size: 12,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 9,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            _Label(_money(context, cents), size: 12, weight: FontWeight.w600),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 46, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Label(t.analyticsYourSpending, color: _muted),
          _Label(_money(context, 124000), size: 30, weight: FontWeight.w700),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _Stat(t.analyticsTrips, '3')),
              Expanded(
                child: _Stat(t.analyticsAveragePerTrip, _money(context, 41333)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Label(t.tripBudgetTitle, size: 12, color: _muted),
              ),
              _Label(
                _money(context, 200000),
                size: 12,
                weight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            height: 9,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              widthFactor: .62,
              child: Container(
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Label(t.analyticsByCategory, size: 15, weight: FontWeight.w700),
          const SizedBox(height: 10),
          bar('accommodation', .8, 62000),
          bar('food', .55, 31000),
          bar('transport', .35, 19000),
          bar('tickets', .2, 12000),
        ],
      ),
    );
  }
}

/// Own artwork, not Mapbox content: Mapbox terms forbid distributing screenshots.
class _MapScreen extends StatelessWidget {
  const _MapScreen({
    required this.asset,
    required this.title,
    required this.height,
    this.subtitle,
    this.footer,
    this.overlays = const [],
  });

  final String asset;
  final String title;
  final double height;
  final String? subtitle;
  final Widget? footer;
  final List<Widget> overlays;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 44, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label(title, size: 18, weight: FontWeight.w700),
            if (subtitle != null)
              Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 13,
                    color: _muted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: _Label(subtitle!, size: 12, color: _muted)),
                ],
              ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SvgPicture.asset(
                  asset,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
                ...overlays,
              ],
            ),
          ),
        ),
      ),
      if (footer != null) ...[const SizedBox(height: 8), footer!],
    ],
  );
}

class _TravelMapScreen extends StatelessWidget {
  const _TravelMapScreen();

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return _MapScreen(
      asset: 'assets/branding/quick_start_travel_map.svg',
      title: t.travelMapTitle,
      subtitle: t.travelMapSubtitle,
      height: 230,
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _Label(
            t.travelMapHere,
            size: 13,
            weight: FontWeight.w700,
            color: const Color(0xFF0B1220),
          ),
        ),
      ),
    );
  }
}

class _LiveMember extends StatelessWidget {
  const _LiveMember(this.letter, this.color);

  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 56,
    height: 56,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: .28),
    ),
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: _Avatar(letter, color, size: 32),
    ),
  );
}

class _LiveMapScreen extends StatelessWidget {
  const _LiveMapScreen();

  @override
  Widget build(BuildContext context) => _MapScreen(
    asset: 'assets/branding/quick_start_live_map.svg',
    title: context.l10n.liveMapTitle,
    height: 286,
    overlays: const [
      Positioned(left: 24, top: 104, child: _LiveMember('M', _marta)),
      Positioned(left: 148, top: 28, child: _LiveMember('R', _rita)),
      Positioned(left: 112, top: 180, child: _LiveMember('I', _ivo)),
    ],
  );
}
