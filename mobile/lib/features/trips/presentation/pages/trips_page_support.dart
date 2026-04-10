part of 'trips_page.dart';

class _CreateTripResult {
  const _CreateTripResult({
    required this.name,
    required this.currencyCode,
    required this.memberIds,
    required this.dateFrom,
    required this.dateTo,
    this.imageFileName,
    this.imageBytes,
  });

  final String name;
  final String currencyCode;
  final List<int> memberIds;
  final String dateFrom;
  final String dateTo;
  final String? imageFileName;
  final Uint8List? imageBytes;
}

class _EditTripResult {
  const _EditTripResult({
    required this.name,
    this.imageFileName,
    this.imageBytes,
    this.removeImage = false,
  });

  final String name;
  final String? imageFileName;
  final Uint8List? imageBytes;
  final bool removeImage;
}
