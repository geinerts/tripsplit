part of 'trips_page.dart';

extension _TripsPageEditDialog on _TripsPageState {
  Future<_EditTripResult?> _showEditTripDialog(Trip trip) async {
    final result = await Navigator.of(context).push<TripFormDraft>(
      AppFormPageRoute(
        builder: (_) => TripFormPage(
          trip: trip,
          pickImage: _pickTripImageForUploadFromSource,
        ),
      ),
    );
    if (result == null) return null;
    return _EditTripResult(
      name: result.name,
      imageFileName: result.image?.fileName,
      imageBytes: result.image?.bytes,
      removeImage: result.removeImage,
    );
  }
}
