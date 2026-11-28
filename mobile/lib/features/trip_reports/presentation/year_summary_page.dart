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

/// Opens the year summary over the current screen: the card pops up on a
/// dimmed, blurred background, with details below it that stay private.
Future<void> showYearSummary(
  BuildContext context,
  TripReportsRepository repository, {
  @visibleForTesting DateTime Function()? clock,
}) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 280),
    pageBuilder: (_, _, _) =>
        YearSummaryPage(repository: repository, clock: clock),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: .9, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// The year summary as a pop-up: the card that is shared, and below it
/// details that stay private.
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
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: AppTheme.light(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Tapping the dimmed app around the card closes it.
              Positioned.fill(
                child: GestureDetector(
                  key: const ValueKey('year-summary-backdrop'),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: ColoredBox(
                      color: quickStartInk.withValues(alpha: .82),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
                        child: IconButton(
                          key: const ValueKey('year-summary-close'),
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: .16,
                            ),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _failed
                          ? _message(context)
                          : summary == null
                          ? const Center(
                              child: CircularProgressIndicator(
                                key: ValueKey('year-summary-loading'),
                                color: Colors.white,
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
              style: _yearSummaryBodyStyle.copyWith(color: Colors.white),
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
        style: _yearSummaryTitleStyle.copyWith(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    ),
  );

  Widget _summaryView(BuildContext context, YearSummary summary) {
    final t = context.l10n;
    return Column(
      children: [
        Expanded(
          // Taps beside the card close it, as on the dimmed area above.
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: SingleChildScrollView(
              key: const ValueKey('year-summary-scroll'),
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  // The card and details themselves keep their taps.
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // The exact picture that is shared, scaled to fit.
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 340),
                            child: AspectRatio(
                              aspectRatio: yearSummaryStorySize.aspectRatio,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x59000000),
                                      blurRadius: 48,
                                      spreadRadius: -10,
                                      offset: Offset(0, 22),
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
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: SizedBox(
              width: double.infinity,
              child: _primaryButton(
                key: const ValueKey('year-summary-share'),
                buttonKey: _shareButtonKey,
                label: t.yearSummaryShareAction,
                icon: Icons.ios_share_rounded,
                onPressed: _sharing ? null : () => unawaited(_share()),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// White on the dimmed background, so it stands out from the dark card.
  Widget _primaryButton({
    required Key key,
    Key? buttonKey,
    required String label,
    IconData? icon,
    required VoidCallback? onPressed,
  }) => KeyedSubtree(
    key: buttonKey,
    child: FilledButton.icon(
      key: key,
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        foregroundColor: quickStartInk,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: onPressed,
      icon: icon == null ? null : Icon(icon, size: 20),
      label: Text(label, textAlign: TextAlign.center),
    ),
  );
}
