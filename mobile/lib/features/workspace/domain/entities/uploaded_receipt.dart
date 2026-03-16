class UploadedReceiptData {
  const UploadedReceiptData({
    required this.path,
    this.url,
    this.thumbUrl,
  });

  final String path;
  final String? url;
  final String? thumbUrl;
}
