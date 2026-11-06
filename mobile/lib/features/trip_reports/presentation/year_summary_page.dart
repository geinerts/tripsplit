import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_design.dart';
import '../../../core/expenses/expense_category_catalog.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_formatters.dart';
import '../../../core/ui/app_scaffold.dart';
import '../../../core/ui/responsive.dart';
import '../data/trip_reports_repository.dart';
import '../domain/year_summary.dart';

/// The Premium year summary, with a card that can be shared as an image.
class YearSummaryPage extends StatefulWidget {
  const YearSummaryPage({super.key, required this.repository});

  final TripReportsRepository repository;

  @override
  State<YearSummaryPage> createState() => _YearSummaryPageState();
}

class _YearSummaryPageState extends State<YearSummaryPage> {
  final GlobalKey _cardKey = GlobalKey();
  YearSummary? _summary;
  int? _year;
  bool _failed = false;
  bool _sharing = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_fetch());
  }

  Future<void> _load({int? year}) {
    setState(() {
      _failed = false;
      _year = year ?? _year;
      _summary = null;
    });
    return _fetch();
  }

  Future<void> _fetch() async {
    final request = ++_request;
    try {
      final summary = await widget.repository.loadYearSummary(year: _year);
      if (!mounted || request != _request) return;
      setState(() => _summary = summary);
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() => _failed = true);
    }
  }

  Future<void> _share() async {
    final summary = _summary;
    final boundary =
        _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (summary == null || boundary == null || _sharing) return;
    final failure = context.l10n.yearSummaryShareFailed;
    final messenger = ScaffoldMessenger.of(context);
    final box = context.findRenderObject() as RenderBox?;
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
    final t = context.l10n;
    final summary = _summary;
    return AppPageScaffold(
      appBar: AppBar(
        title: Text(t.yearSummaryTitle),
        actions: [
          if (summary != null && summary.tripCount > 0)
            IconButton(
              key: const ValueKey('year-summary-share'),
              onPressed: _sharing ? null : () => unawaited(_share()),
              icon: const Icon(Icons.ios_share_rounded),
              tooltip: t.yearSummaryShare,
            ),
        ],
      ),
      body: SafeArea(child: _buildBody(context, summary)),
    );
  }

  Widget _buildBody(BuildContext context, YearSummary? summary) {
    final t = context.l10n;
    if (_failed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.yearSummaryLoadFailed, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => unawaited(_load()),
                child: Text(t.yearSummaryRetry),
              ),
            ],
          ),
        ),
      );
    }
    if (summary == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final years = <int>{...summary.availableYears, summary.year}.toList()
      ..sort((a, b) => b.compareTo(a));
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.responsive.pageMaxWidth),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsive.pageHorizontalPadding,
            vertical: 12,
          ),
          children: [
            if (years.length > 1) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final year in years)
                    ChoiceChip(
                      key: ValueKey('year-summary-year-$year'),
                      label: Text('$year'),
                      selected: year == summary.year,
                      onSelected: year == summary.year
                          ? null
                          : (_) => unawaited(_load(year: year)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (summary.tripCount == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Text(
                  t.yearSummaryEmpty('${summary.year}'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppDesign.mutedColor(context)),
                ),
              )
            else
              RepaintBoundary(
                key: _cardKey,
                child: _YearSummaryCard(summary: summary),
              ),
            if (summary.tripCount > 0 && !summary.conversionComplete) ...[
              const SizedBox(height: 12),
              Text(
                t.yearSummaryPartial,
                style: TextStyle(
                  fontSize: 13,
                  color: AppDesign.mutedColor(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A fixed dark card, so a shared image looks the same in light and dark mode.
class _YearSummaryCard extends StatelessWidget {
  const _YearSummaryCard({required this.summary});

  final YearSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    String money(double value) => AppFormatters.currency(
      context,
      value,
      currencyCode: summary.currencyCode,
    );
    final category = summary.topCategoryKey;
    final companion = summary.topCompanionNickname;
    final biggest = summary.biggestTripName;
    final biggestShare = summary.biggestTripShare;
    final hasSpending = summary.totalShare > 0 || summary.conversionComplete;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppDesign.logoBackgroundStart, AppDesign.logoBackgroundEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.yearSummaryTitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${summary.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 28,
              runSpacing: 16,
              children: [
                _Stat(label: t.yearSummaryTrips, value: '${summary.tripCount}'),
                _Stat(label: t.yearSummaryDays, value: '${summary.daysAway}'),
                _Stat(
                  label: t.yearSummaryCountries,
                  value: '${summary.countries.length}',
                ),
                _Stat(
                  label: t.yearSummaryCities,
                  value: '${summary.cities.length}',
                ),
              ],
            ),
            if (summary.countries.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                summary.countries.join(' · '),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            if (hasSpending)
              _Highlight(
                label: t.yearSummarySpending,
                value: money(summary.totalShare),
              ),
            if (biggest != null && biggestShare != null)
              _Highlight(
                label: t.yearSummaryBiggestTrip,
                value: '$biggest · ${money(biggestShare)}',
              ),
            if (category != null)
              _Highlight(
                label: t.yearSummaryTopCategory,
                value: ExpenseCategoryCatalog.labelFor(
                  category,
                  Localizations.localeOf(context),
                ),
              ),
            if (companion != null)
              _Highlight(
                label: t.yearSummaryTopCompanion,
                value: companion,
                detail: t.yearSummaryTripsTogether(
                  '${summary.topCompanionTrips}',
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Splyto',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
    ],
  );
}

class _Highlight extends StatelessWidget {
  const _Highlight({required this.label, required this.value, this.detail});

  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final detailText = detail;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (detailText != null)
            Text(
              detailText,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
        ],
      ),
    );
  }
}
