import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/expenses/expense_category_catalog.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/maps/world_countries.dart';
import '../../../core/ui/app_formatters.dart';
import '../../../core/ui/ribbon_background.dart';
import '../data/trip_reports_repository.dart';
import '../domain/year_summary.dart';

part 'year_summary_card.dart';
part 'year_summary_story.dart';

/// Whether the app offers the year summary. Off until the owner decides to
/// launch it; the server's season and Premium rules still apply once it is on.
const bool yearSummaryOfferedInApp = bool.fromEnvironment(
  'YEAR_SUMMARY_IN_APP',
);

/// The year summary on one screen in the Quick Start style: a card that can be
/// shared as an image, and below it details that stay private.
class YearSummaryPage extends StatefulWidget {
  const YearSummaryPage({super.key, required this.repository, this.clock});

  final TripReportsRepository repository;

  /// Today's date; tests set it to see the New Year look.
  final DateTime Function()? clock;

  @override
  State<YearSummaryPage> createState() => _YearSummaryPageState();
}

class _YearSummaryPageState extends State<YearSummaryPage> {
  final GlobalKey _cardKey = GlobalKey();
  List<WorldCountry>? _world;
  final GlobalKey _shareButtonKey = GlobalKey();
  YearSummary? _summary;
  bool _failed = false;
  bool _outOfSeason = false;
  bool _sharing = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_fetch());
    unawaited(_loadWorld());
  }

  Future<void> _loadWorld() async {
    try {
      final world = await WorldCountry.load();
      if (mounted) setState(() => _world = world);
    } catch (_) {
      // Without outlines the story simply has no map.
    }
  }

  void _retry() {
    setState(() {
      _failed = false;
      _outOfSeason = false;
      _summary = null;
    });
    unawaited(_fetch());
  }

  Future<void> _fetch() async {
    final request = ++_request;
    try {
      final summary = await widget.repository.loadYearSummary();
      if (!mounted || request != _request) return;
      setState(() => _summary = summary);
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(() {
        _outOfSeason =
            error is ApiException && error.code == 'year_summary_unavailable';
        _failed = true;
      });
    }
  }

  Future<void> _share() async {
    final summary = _summary;
    final boundary =
        _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (summary == null || boundary == null || _sharing) return;
    final failure = context.l10n.yearSummaryShareFailed;
    final messenger = ScaffoldMessenger.of(context);
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    setState(() => _sharing = true);
    try {
      // The card is drawn at 360 × 450 and shared at 1080 × 1350.
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null) throw StateError('No image data.');
      final name = 'splyto-${summary.year}.png';
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              data.buffer.asUint8List(),
              mimeType: 'image/png',
              name: name,
            ),
          ],
          fileNameOverrides: [name],
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(failure)));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Theme(
        data: AppTheme.light(),
        child: Scaffold(
          backgroundColor: quickStartCream,
          body: Stack(
            children: [
              Positioned.fill(child: const QuickStartBackground(page: 0)),
              SafeArea(
                child: Column(
                  children: [
                    _topBar(context),
                    Expanded(
                      child: _failed
                          ? _message(context)
                          : summary == null
                          ? const Center(
                              child: CircularProgressIndicator(
                                key: ValueKey('year-summary-loading'),
                              ),
                            )
                          : summary.tripCount == 0
                          ? _empty(context, summary)
                          : _summaryView(context, summary),
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

  bool get _holiday =>
      yearSummaryHolidaySeason((widget.clock ?? DateTime.now)());

  Widget _topBar(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 4, 16, 0),
    child: Row(
      children: [
        if (_holiday)
          SvgPicture.asset(
            'assets/branding/logo_full_holiday.svg',
            height: 34,
            semanticsLabel: 'Splyto',
          )
        else
          Image.asset(
            'assets/branding/logo_full.png',
            height: 30,
            fit: BoxFit.contain,
            semanticLabel: 'Splyto',
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              key: const ValueKey('year-summary-close'),
              style: TextButton.styleFrom(
                foregroundColor: quickStartInk,
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(
                MaterialLocalizations.of(context).closeButtonLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _message(BuildContext context) {
    final t = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _outOfSeason
                  ? t.yearSummarySeasonNotice
                  : t.yearSummaryLoadFailed,
              textAlign: TextAlign.center,
              style: _yearSummaryBodyStyle,
            ),
            if (!_outOfSeason) ...[
              const SizedBox(height: 16),
              _primaryButton(
                key: const ValueKey('year-summary-retry'),
                label: t.yearSummaryRetry,
                onPressed: _retry,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context, YearSummary summary) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        context.l10n.yearSummaryEmpty('${summary.year}'),
        key: const ValueKey('year-summary-empty'),
        textAlign: TextAlign.center,
        style: _yearSummaryTitleStyle.copyWith(fontSize: 24),
      ),
    ),
  );

  Widget _summaryView(BuildContext context, YearSummary summary) {
    final t = context.l10n;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: const ValueKey('year-summary-scroll'),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        t.yearSummaryScreenTitle,
                        textAlign: TextAlign.center,
                        style: _yearSummaryTitleStyle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.yearSummaryShareBody,
                      textAlign: TextAlign.center,
                      style: _yearSummaryBodyStyle,
                    ),
                    const SizedBox(height: 18),
                    // The exact picture that is shared, scaled to fit.
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: AspectRatio(
                          aspectRatio: yearSummaryStorySize.aspectRatio,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: quickStartInk.withValues(alpha: .18),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: FittedBox(
                              child: RepaintBoundary(
                                key: _cardKey,
                                child: _YearStory(
                                  summary: summary,
                                  world: _world,
                                  holiday: _holiday,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _PrivateDetails(summary: summary),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _primaryButton(
                  key: const ValueKey('year-summary-share'),
                  buttonKey: _shareButtonKey,
                  label: t.yearSummaryShareAction,
                  onPressed: _sharing ? null : () => unawaited(_share()),
                ),
                TextButton(
                  key: const ValueKey('year-summary-done'),
                  style: TextButton.styleFrom(
                    foregroundColor: quickStartInk,
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(t.yearSummaryDone),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _primaryButton({
    required Key key,
    Key? buttonKey,
    required String label,
    required VoidCallback? onPressed,
  }) => KeyedSubtree(
    key: buttonKey,
    child: FilledButton(
      key: key,
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: quickStartInk,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: onPressed,
      child: Text(label, textAlign: TextAlign.center),
    ),
  );
}
