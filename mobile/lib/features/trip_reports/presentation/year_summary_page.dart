import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/expenses/expense_category_catalog.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_formatters.dart';
import '../../../core/ui/ribbon_background.dart';
import '../data/trip_reports_repository.dart';
import '../domain/year_summary.dart';

part 'year_summary_slides.dart';

/// Whether the app offers the year summary. Off until the owner decides to
/// launch it; the server's season and Premium rules still apply once it is on.
const bool yearSummaryOfferedInApp = bool.fromEnvironment(
  'YEAR_SUMMARY_IN_APP',
);

/// The year summary in three slides, in the Quick Start style: the year, its
/// places and spending, and a card that can be shared as an image.
class YearSummaryPage extends StatefulWidget {
  const YearSummaryPage({super.key, required this.repository});

  final TripReportsRepository repository;

  @override
  State<YearSummaryPage> createState() => _YearSummaryPageState();
}

class _YearSummaryPageState extends State<YearSummaryPage> {
  static const _slideCount = 3;

  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _shareButtonKey = GlobalKey();
  final _pageController = PageController();
  YearSummary? _summary;
  bool _failed = false;
  bool _outOfSeason = false;
  bool _sharing = false;
  bool _includeSpending = false;
  int _step = 0;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_fetch());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  double get _page {
    if (_pageController.hasClients && _pageController.position.haveDimensions) {
      return _pageController.page ?? _step.toDouble();
    }
    return _step.toDouble();
  }

  void _goTo(int page) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(page);
      return;
    }
    unawaited(
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      ),
    );
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
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, _) => QuickStartBackground(page: _page),
                ),
              ),
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
                          : _slides(context, summary),
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

  Widget _topBar(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 4, 16, 0),
    child: Row(
      children: [
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

  Widget _slides(BuildContext context, YearSummary summary) {
    final t = context.l10n;
    final last = _step == _slideCount - 1;
    return Column(
      children: [
        Expanded(
          child: PageView(
            key: const ValueKey('year-summary-pages'),
            controller: _pageController,
            onPageChanged: (page) => setState(() => _step = page),
            children: [
              _YearSlide(summary: summary),
              _PlacesSlide(summary: summary),
              _ShareSlide(
                summary: summary,
                cardKey: _cardKey,
                includeSpending: _includeSpending,
                onIncludeSpendingChanged: (value) =>
                    setState(() => _includeSpending = value),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                liveRegion: true,
                label: t.quickStartStep(_step + 1, _slideCount),
                child: ExcludeSemantics(
                  child: Row(
                    key: const ValueKey('year-summary-dots'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slideCount,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _step
                              ? _yearSummaryTeal
                              : quickStartInk.withValues(alpha: .22),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_step > 0 && !last) ...[
                    SizedBox(
                      width: 56,
                      height: 52,
                      child: OutlinedButton(
                        key: const ValueKey('year-summary-back'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: quickStartInk,
                          backgroundColor: Colors.white.withValues(alpha: .7),
                          side: BorderSide(
                            color: quickStartInk.withValues(alpha: .12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _goTo(_step - 1),
                        child: Icon(
                          Icons.arrow_back,
                          semanticLabel: MaterialLocalizations.of(
                            context,
                          ).backButtonTooltip,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: last
                        ? _primaryButton(
                            key: const ValueKey('year-summary-share'),
                            buttonKey: _shareButtonKey,
                            label: t.yearSummaryShareAction,
                            onPressed: _sharing
                                ? null
                                : () => unawaited(_share()),
                          )
                        : _primaryButton(
                            key: const ValueKey('year-summary-next'),
                            label: t.quickStartNext,
                            onPressed: () => _goTo(_step + 1),
                          ),
                  ),
                ],
              ),
              if (last)
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
