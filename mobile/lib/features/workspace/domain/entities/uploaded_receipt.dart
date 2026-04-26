class UploadedReceiptData {
  const UploadedReceiptData({
    required this.path,
    this.url,
    this.thumbUrl,
    this.ocrAmount,
    this.ocrDate,
    this.ocrMerchant,
  });

  final String path;
  final String? url;
  final String? thumbUrl;
  final double? ocrAmount;
  final String? ocrDate;
  final String? ocrMerchant;
}
