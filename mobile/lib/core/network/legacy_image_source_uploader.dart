import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_session_store.dart';
import '../auth/device_token_store.dart';
import '../media/image_crop.dart';

/// Adds an uncropped image and its crop to an image upload.
void addImageCropSource(
  http.MultipartRequest request,
  ImageCropSourceUpload source,
) {
  request.fields['crop'] = jsonEncode(source.crop.toJson());
  request.files.add(
    http.MultipartFile.fromBytes(
      'source_image',
      source.bytes,
      filename: 'source.jpg',
    ),
  );
}

/// Sends a visit photo's original. Failure only limits later crop edits, so callers
/// treat it as best effort.
class LegacyTravelPhotoSourceUploader {
  LegacyTravelPhotoSourceUploader({
    required String baseUrl,
    required DeviceTokenStore tokenStore,
    required AuthSessionStore authSessionStore,
    http.Client? httpClient,
  }) : _baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
       _tokenStore = tokenStore,
       _authSessionStore = authSessionStore,
       _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final DeviceTokenStore _tokenStore;
  final AuthSessionStore _authSessionStore;
  final http.Client _httpClient;

  Future<bool> upload({
    required int placeId,
    required ImageCropSourceUpload source,
  }) async {
    final uri = Uri.parse(
      _baseUrl,
    ).resolve('api/api.php?action=upload_travel_photo_source');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['X-Device-Token'] = await _tokenStore.getOrCreateToken()
      ..fields['id'] = '$placeId';
    addImageCropSource(request, source);
    final accessToken = await _authSessionStore.readValidAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
    final response = await _httpClient.send(request);
    await response.stream.drain<void>();
    return response.statusCode == 200;
  }
}
