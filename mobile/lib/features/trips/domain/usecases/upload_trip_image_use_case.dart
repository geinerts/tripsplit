import 'dart:typed_data';

import '../entities/uploaded_trip_image.dart';
import '../repositories/trips_repository.dart';
import '../../../../core/media/image_crop.dart';

class UploadTripImageUseCase {
  const UploadTripImageUseCase(this._repository);

  final TripsRepository _repository;

  Future<UploadedTripImageData> call({
    required int tripId,
    required String fileName,
    required Uint8List bytes,
    ImageCropSourceUpload? cropSource,
  }) {
    return _repository.uploadTripImage(
      tripId: tripId,
      fileName: fileName,
      bytes: bytes,
      cropSource: cropSource,
    );
  }
}
