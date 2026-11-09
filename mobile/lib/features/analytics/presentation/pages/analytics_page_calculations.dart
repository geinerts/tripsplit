part of 'analytics_page.dart';

extension _AnalyticsPageCalculations on _AnalyticsPageState {
  Trip? get _defaultTrip {
    final active = _trips.where((trip) => trip.isActive).toList();
    final candidates = active.isNotEmpty ? active : _trips.toList();
    DateTime date(Trip trip) {
      final dates = trip.isActive
          ? [trip.dateFrom, trip.dateTo, trip.createdAt]
          : [trip.dateTo, trip.dateFrom, trip.endedAt, trip.createdAt];
      for (final raw in dates) {
        final parsed = raw == null ? null : DateTime.tryParse(raw);
        if (parsed != null) return parsed;
      }
      return DateTime(1970);
    }

    candidates.sort((a, b) {
      final order = date(b).compareTo(date(a));
      return order != 0 ? order : b.id.compareTo(a.id);
    });
    return candidates.firstOrNull;
  }

  Trip? get _selectedTrip =>
      _trips.where((t) => t.id == _selectedTripId).firstOrNull;
  String get _displayCurrency =>
      (_byTrip ? _selectedTrip?.currencyCode : _currency) ?? 'EUR';
  AnalyticsReport get _report => AnalyticsReport(
    source: _summaries,
    currency: _displayCurrency,
    tripId: _byTrip ? _selectedTripId : null,
    month: _byTrip ? null : _month,
    personal: !_byTrip || _personal,
  );
  List<String> get _months =>
      (_summaries
          .where((s) => s.currencyCode == _currency)
          .expand((s) => s.buckets)
          .map((b) => b.month)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a)));
  String _monthLabel(String month) => MaterialLocalizations.of(
    context,
  ).formatMonthYear(DateTime.parse('$month-01'));
  String _money(int cents) => AppFormatters.displayCurrencyFromCents(
    context,
    cents,
    currencyCode: _displayCurrency,
  );
  String _tripDates(Trip trip) => AppFormatters.tripDateRange(
    context,
    startRaw: trip.dateFrom,
    endRaw: trip.dateTo,
    unknownLabel: '',
  );
  Color _categoryColor(String key) => ExpenseCategoryCatalog.colorFor(key);
  String _categoryName(String key) =>
      ExpenseCategoryCatalog.labelFor(key, Localizations.localeOf(context));
}
