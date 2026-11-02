import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/l10n.dart';
import '../domain/travel_place.dart';

class TravelMapOverlay extends StatelessWidget {
  const TravelMapOverlay({
    super.key,
    required this.positions,
    required this.places,
    required this.selected,
    required this.onSelect,
    required this.onDelete,
    this.showPins = false,
    required this.onFit,
    this.busy = false,
    this.photoBuilder,
    this.onEdit,
    this.onOpenTrip,
  });
  final Map<String, Offset> positions;
  final bool showPins;
  final List<TravelPlace> places;
  final TravelPlace? selected;
  final ValueChanged<TravelPlace?> onSelect;
  final ValueChanged<TravelPlace> onDelete;
  final VoidCallback onFit;
  final bool busy;
  final Widget Function(TravelPlace)? photoBuilder;
  final ValueChanged<TravelPlace>? onEdit, onOpenTrip;
  @override
  Widget build(BuildContext context) {
    final t = context.l10n, colors = Theme.of(context).colorScheme;
    final unique = <String, TravelPlace>{};
    for (final p in places) {
      unique.putIfAbsent(p.placeKey, () => p);
    }
    final countries = places.map((p) => p.countryCode).toSet();
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showPins)
          for (final place in unique.values)
            if (positions[place.placeKey] case final Offset pixel)
              Positioned(
                left: pixel.dx - 24,
                top: pixel.dy - 24,
                width: 48,
                height: 48,
                child: Semantics(
                  label: '${place.city}, ${place.country}',
                  button: true,
                  child: IconButton(
                    key: ValueKey('travel-pin-${place.id}'),
                    tooltip: place.city,
                    onPressed: () => onSelect(
                      selected?.placeKey == place.placeKey ? null : place,
                    ),
                    style: IconButton.styleFrom(padding: EdgeInsets.zero),
                    icon: Container(
                      key: ValueKey('travel-pin-symbol-${place.id}'),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary,
                        border: Border.all(color: colors.surface, width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
        Builder(
          builder: (context) => LayoutBuilder(
            builder: (context, size) {
              final place = selected;
              if (place == null) return const SizedBox.shrink();
              final pixel = positions[place.placeKey];
              if (pixel == null) return const SizedBox.shrink();
              if (pixel.dx < 0 ||
                  pixel.dx > size.maxWidth ||
                  pixel.dy < 0 ||
                  pixel.dy > size.maxHeight) {
                return const SizedBox.shrink();
              }
              final width = math.min(270.0, size.maxWidth - 24);
              final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
              final estimate =
                  (230.0 + (place.hasPhoto ? 90 : 0)) * scale.clamp(1.0, 1.6);
              final above = pixel.dy > estimate + 80;
              final top = (pixel.dy + 28).clamp(
                60.0,
                math.max(60.0, size.maxHeight - estimate - 40),
              );
              final bottom = size.maxHeight - pixel.dy + 20;
              final availableHeight = above
                  ? size.maxHeight - bottom - 60
                  : size.maxHeight - top - 40;
              final visits = places
                  .where((p) => p.placeKey == place.placeKey)
                  .toList();
              final index = visits.indexWhere((p) => p.id == place.id);
              return Stack(
                children: [
                  Positioned(
                    left: (pixel.dx - width / 2).clamp(
                      12.0,
                      math.max(12.0, size.maxWidth - width - 12),
                    ),
                    top: above ? null : top.toDouble(),
                    bottom: above ? bottom : null,
                    width: width,
                    child: Material(
                      key: const ValueKey('travel-place-popup'),
                      color: colors.surface,
                      elevation: 8,
                      shadowColor: Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: math.max(100, availableHeight),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          place.city,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: t.travelMapClose,
                                      onPressed: () => onSelect(null),
                                      icon: const Icon(Icons.close, size: 18),
                                    ),
                                  ],
                                ),
                                if (place.hasPhoto && photoBuilder != null) ...[
                                  photoBuilder!(place),
                                  const SizedBox(height: 8),
                                ],
                                if (place.title.isNotEmpty ||
                                    (place.tripName ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      place.title.isNotEmpty
                                          ? place.title
                                          : place.tripName!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                  ),
                                Text(
                                  place.subtitle,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat.yMMMd(
                                    Localizations.localeOf(context).toString(),
                                  ).format(DateTime.parse(place.visitedOn)),
                                ),
                                if (visits.length > 1)
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: t.travelPreviousVisit,
                                        onPressed: index > 0
                                            ? () => onSelect(visits[index - 1])
                                            : null,
                                        icon: const Icon(Icons.chevron_left),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${index + 1} / ${visits.length}',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: t.travelNextVisit,
                                        onPressed: index < visits.length - 1
                                            ? () => onSelect(visits[index + 1])
                                            : null,
                                        icon: const Icon(Icons.chevron_right),
                                      ),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    if (place.tripId != null &&
                                        onOpenTrip != null)
                                      Expanded(
                                        child: TextButton.icon(
                                          onPressed: busy
                                              ? null
                                              : () => onOpenTrip!(place),
                                          icon: const Icon(
                                            Icons.open_in_new,
                                            size: 16,
                                          ),
                                          label: Text(t.travelOpenTrip),
                                        ),
                                      )
                                    else
                                      const Spacer(),
                                    if (onEdit != null)
                                      IconButton(
                                        key: const ValueKey(
                                          'travel-edit-visit',
                                        ),
                                        tooltip: t.travelEditVisit,
                                        onPressed: busy
                                            ? null
                                            : () => onEdit!(place),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 19,
                                        ),
                                      ),
                                    IconButton(
                                      tooltip: t.travelMapDelete,
                                      onPressed: busy
                                          ? null
                                          : () => onDelete(place),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 19,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 64,
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Text(
                t.travelMapCounts(countries.length, unique.length),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filledTonal(
            tooltip: t.travelMapFit,
            onPressed: onFit,
            icon: const Icon(Icons.center_focus_strong),
          ),
        ),
      ],
    );
  }
}
