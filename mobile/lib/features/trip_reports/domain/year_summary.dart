/// One account's travel year, as calculated by the server.
class YearSummary {
  const YearSummary({
    required this.year,
    required this.availableYears,
    required this.tripCount,
    required this.daysAway,
    required this.countries,
    required this.cities,
    required this.currencyCode,
    required this.totalShare,
    required this.conversionComplete,
    this.biggestTripName,
    this.biggestTripShare,
    this.topCategoryKey,
    this.topCompanionNickname,
    this.topCompanionTrips = 0,
  });

  final int year;
  final List<int> availableYears;
  final int tripCount;
  final int daysAway;
  final List<String> countries;
  final List<String> cities;
  final String currencyCode;
  final double totalShare;
  final bool conversionComplete;
  final String? biggestTripName;
  final double? biggestTripShare;
  final String? topCategoryKey;
  final String? topCompanionNickname;
  final int topCompanionTrips;

  factory YearSummary.fromMap(Map<String, dynamic> map) {
    int asInt(dynamic value) => value is num ? value.toInt() : 0;
    double asDouble(dynamic value) => value is num ? value.toDouble() : 0;
    List<dynamic> asList(dynamic value) => value is List ? value : const [];
    final biggest = map['biggest_trip'];
    final category = map['top_category'];
    final companion = map['top_companion'];
    return YearSummary(
      year: asInt(map['year']),
      availableYears: asList(
        map['available_years'],
      ).whereType<num>().map((value) => value.toInt()).toList(growable: false),
      tripCount: asInt(map['trip_count']),
      daysAway: asInt(map['days_away']),
      countries: asList(map['countries'])
          .whereType<Map>()
          .map((country) => '${country['name'] ?? ''}')
          .where((name) => name.isNotEmpty)
          .toList(growable: false),
      cities: asList(map['cities']).whereType<String>().toList(growable: false),
      currencyCode: '${map['currency_code'] ?? 'EUR'}',
      totalShare: asDouble(map['total_share']),
      conversionComplete: map['conversion_complete'] != false,
      biggestTripName: biggest is Map ? '${biggest['name'] ?? ''}' : null,
      biggestTripShare: biggest is Map ? asDouble(biggest['share']) : null,
      topCategoryKey: category is Map ? '${category['key'] ?? ''}' : null,
      topCompanionNickname: companion is Map
          ? '${companion['nickname'] ?? ''}'
          : null,
      topCompanionTrips: companion is Map ? asInt(companion['trip_count']) : 0,
    );
  }
}
