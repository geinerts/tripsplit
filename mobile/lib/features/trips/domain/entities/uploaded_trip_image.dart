class UploadedTripImageData {
  const UploadedTripImageData({
    required this.path,
    this.url,
    this.thumbUrl,
  });

  final String path;
  final String? url;
  final String? thumbUrl;
}
