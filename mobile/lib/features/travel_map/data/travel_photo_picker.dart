import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickTravelPhoto() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1600,
    maxHeight: 1600,
    imageQuality: 90,
    requestFullMetadata: false,
  );
  if (file == null) return null;
  final source = await file.readAsBytes();
  for (final edge in [1024, 768, 512]) {
    final bytes = await FlutterImageCompress.compressWithList(
      source,
      minWidth: edge,
      minHeight: edge,
      quality: 80,
      format: CompressFormat.jpeg,
      autoCorrectionAngle: true,
      keepExif: false,
    );
    if (bytes.isNotEmpty && bytes.length <= 512 * 1024) return bytes;
  }
  throw const FormatException('Photo could not be prepared.');
}
