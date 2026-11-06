part of 'trips_page.dart';

extension _TripsPageDialogHelpers on _TripsPageState {
  Future<TripImageDraft?> _pickTripImageForUploadFromSource(
    ImageSource source,
  ) async {
    try {
      final pick = await pickAndCropImage(
        context: context,
        source: source,
        title: context.l10n.imageCropperAdjustTripImage,
        aspectRatio: AppImageCropper.tripAspectRatio,
        maxEdge: 2048,
      );
      if (pick == null) return null;
      return (bytes: pick.bytes, fileName: 'trip.jpg', source: pick.source);
    } catch (_) {
      return null;
    }
  }
}
