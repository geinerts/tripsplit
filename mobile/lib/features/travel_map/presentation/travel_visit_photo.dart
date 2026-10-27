import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../data/travel_places_repository.dart';
import '../domain/travel_place.dart';

class TravelVisitPhoto extends StatefulWidget {
  const TravelVisitPhoto({
    super.key,
    required this.place,
    required this.repository,
    this.height = 90,
  });
  final TravelPlace place;
  final TravelPlacesRepository repository;
  final double height;
  @override
  State<TravelVisitPhoto> createState() => _TravelVisitPhotoState();
}

class _TravelVisitPhotoState extends State<TravelVisitPhoto> {
  late Future<Uint8List?> _photo = widget.repository.photo(widget.place);
  @override
  void didUpdateWidget(covariant TravelVisitPhoto old) {
    super.didUpdateWidget(old);
    if (old.place.id != widget.place.id ||
        old.place.photoVersion != widget.place.photoVersion) {
      _photo = widget.repository.photo(widget.place);
    }
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: SizedBox(
      height: widget.height,
      width: double.infinity,
      child: FutureBuilder<Uint8List?>(
        future: _photo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.broken_image_outlined),
            );
          }
          return ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).refreshIndicatorSemanticLabel,
                      onPressed: () => setState(
                        () => _photo = widget.repository.photo(widget.place),
                      ),
                      icon: const Icon(Icons.refresh),
                    ),
            ),
          );
        },
      ),
    ),
  );
}
