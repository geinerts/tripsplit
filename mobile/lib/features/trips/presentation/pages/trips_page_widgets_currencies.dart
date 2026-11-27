part of 'trips_page.dart';

/// The Home total split by trip currency, each with its share converted to
/// the profile currency by the server.
extension _TripsPageCurrencies on _TripsPageState {
  Future<void> _openShareByCurrencySheet(
    List<Trip> trips,
    List<String> currencies,
    Map<String, int> totals,
    String profileCurrency,
  ) {
    final converted = <String, int>{};
    final tripCounts = <String, int>{};
    for (final trip in trips) {
      final code = AppCurrencyCatalog.normalize(trip.currencyCode);
      tripCounts.update(code, (value) => value + 1, ifAbsent: () => 1);
      converted.update(
        code,
        (value) => value + (trip.myOwedPreferredCents ?? 0),
        ifAbsent: () => trip.myOwedPreferredCents ?? 0,
      );
    }
    final total = converted.values.fold<int>(0, (sum, cents) => sum + cents);
    return showAppBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final t = sheetContext.l10n;
        final theme = Theme.of(sheetContext);
        final muted = theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );
        String money(int cents, String code) =>
            AppFormatters.displayCurrencyFromCents(
              sheetContext,
              cents,
              currencyCode: code,
            );
        return SingleChildScrollView(
          key: const ValueKey('home-currencies-sheet'),
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.homeShareByCurrencyTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                t.homeShareByCurrencySubtitle(profileCurrency),
                style: muted,
              ),
              const SizedBox(height: 12),
              for (final code in currencies) ...[
                const Divider(height: 1),
                Padding(
                  key: ValueKey('home-currency-$code'),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          code,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              money(totals[code]!, code),
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              '${AppCurrencyCatalog.labelForCode(code, t)} · '
                              '${t.homeShareByCurrencyTrips(tripCounts[code] ?? 0)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '≈ ${money(converted[code] ?? 0, profileCurrency)}',
                        style: muted,
                      ),
                    ],
                  ),
                ),
              ],
              Divider(height: 1, color: theme.colorScheme.outline),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.homeShareByCurrencyTotal,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '≈ ${money(total, profileCurrency)}',
                      key: const ValueKey('home-currencies-total'),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
