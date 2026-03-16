import 'dart:typed_data';

class ReceiptUploadPayload {
  const ReceiptUploadPayload({
    required this.fileName,
    required this.bytes,
    this.tripId,
  });

  final String fileName;
  final Uint8List bytes;
  final int? tripId;
}
