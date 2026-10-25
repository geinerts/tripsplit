part of 'analytics_page.dart';

extension _AnalyticsPageCalculations on _AnalyticsPageState {
  Trip? get _selectedTrip =>
      _trips.where((t) => t.id == _selectedTripId).firstOrNull;
  String get _displayCurrency =>
      (_byTrip ? _selectedTrip?.currencyCode : _currency) ?? 'EUR';
  AnalyticsReport get _report => AnalyticsReport(
    source: _entries,
    currency: _displayCurrency,
    tripId: _byTrip ? _selectedTripId : null,
    month: _byTrip ? null : _month,
    personal: !_byTrip || _personal,
  );
  List<String> get _months =>
      (_entries
          .where((e) => e.trip.currencyCode == _currency)
          .map((e) => e.month)
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
  Color _categoryColor(String key) => switch (key) {
    'food' => const Color(0xFF00836B),
    'transport' => const Color(0xFF28BCE0),
    'accommodation' || 'stays' || 'lodging' => const Color(0xFFD92192),
    'activities' => const Color(0xFF8571C8),
    _ => const Color(0xFF63869B),
  };
  String _categoryName(String key) =>
      ExpenseCategoryCatalog.labelFor(key, Localizations.localeOf(context));
}
