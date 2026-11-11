import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../media/trip_image_cache.dart';

class TripImageCacheScope extends InheritedWidget {
  const TripImageCacheScope({
    super.key,
    required this.cache,
    required super.child,
  });
  final TripImageCache? cache;

  static TripImageCache? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TripImageCacheScope>()?.cache;

  @override
  bool updateShouldNotify(TripImageCacheScope oldWidget) =>
      cache != oldWidget.cache;
}

class TripCoverImage extends StatefulWidget {
  const TripCoverImage({
    super.key,
    required this.tripId,
    required this.url,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.imageKey,
  });
  final int tripId;
  final String url;
  final Widget fallback;
  final BoxFit fit;
  final int? cacheWidth;
  final Key? imageKey;

  @override
  State<TripCoverImage> createState() => _TripCoverImageState();
}

class _TripCoverImageState extends State<TripCoverImage> {
  TripImageCache? _cache;
  Uint8List? _bytes;
  int _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cache = TripImageCacheScope.of(context);
    if (cache != _cache) {
      _cache = cache;
      _load();
    }
  }

  @override
  void didUpdateWidget(TripCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tripId != widget.tripId || oldWidget.url != widget.url) {
      _load();
    }
  }

  Future<void> _load() async {
    final generation = ++_generation;
    _bytes = null;
    final cache = _cache;
    if (cache == null || widget.url.isEmpty) return;
    final tripId = widget.tripId;
    final url = widget.url;
    bool current() => mounted && generation == _generation;
    try {
      final cached = await cache.read(tripId);
      if (!current()) return;
      if (cached != null) setState(() => _bytes = cached);
      final loaded = await cache.load(tripId, url);
      if (current() && loaded != null) setState(() => _bytes = loaded);
    } catch (_) {
      // Storage and network failures retain the existing illustration/photo.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty) return widget.fallback;
    final bytes = _bytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        key: widget.imageKey,
        fit: widget.fit,
        cacheWidth: widget.cacheWidth,
        errorBuilder: (_, _, _) => widget.fallback,
      );
    }
    if (_cache != null) return widget.fallback;
    return Image.network(
      widget.url,
      key: widget.imageKey,
      fit: widget.fit,
      cacheWidth: widget.cacheWidth,
      errorBuilder: (_, _, _) => widget.fallback,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : widget.fallback,
    );
  }
}
