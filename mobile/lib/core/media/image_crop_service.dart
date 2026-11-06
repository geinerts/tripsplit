import 'dart:convert';

import 'package:flutter/material.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/http_method.dart';
import 'image_crop.dart';
import 'image_crop_editor_page.dart';

enum ImageCropKind { trip, avatar, travel }

/// Opens and saves the crop of an image already on the server.
class ImageCropService {
  const ImageCropService(this._api);

  final ApiClient _api;

  Future<ImageCropSourceData> load(
    ImageCropKind kind, {
    int? tripId,
    int? placeId,
  }) async {
    final response = await _api.request(
      path: ApiEndpoints.legacyAction('image_crop_source'),
      method: HttpMethod.get,
      query: {'kind': kind.name, 'id': ?placeId},
      headers: tripId == null ? null : {'X-Trip-Id': '$tripId'},
    );
    return ImageCropSourceData(
      bytes: base64Decode(response['image_base64'] as String),
      width: (response['width'] as num).toInt(),
      height: (response['height'] as num).toInt(),
      crop: ImageCropRect.fromJson(
        (response['crop'] as Map).cast<String, dynamic>(),
      ),
      hasOriginal: response['has_original'] == true,
      revision: response['revision'] as String,
    );
  }

  Future<Map<String, dynamic>> save(
    ImageCropKind kind,
    ImageCropRect crop,
    String revision, {
    int? tripId,
    int? placeId,
  }) => _api.request(
    path: ApiEndpoints.legacyAction('update_image_crop'),
    method: HttpMethod.post,
    body: {
      'kind': kind.name,
      'crop': crop.toJson(),
      'revision': revision,
      'id': ?placeId,
    },
    headers: tripId == null ? null : {'X-Trip-Id': '$tripId'},
  );

  /// Shows the editor for a saved image. Returns the server's response, or null when
  /// the person cancels.
  Future<Map<String, dynamic>?> edit(
    BuildContext context, {
    required ImageCropKind kind,
    required String title,
    required double aspectRatio,
    bool circular = false,
    int? tripId,
    int? placeId,
  }) => Navigator.of(context).push<Map<String, dynamic>>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ImageCropEditorPage<Map<String, dynamic>>(
        title: title,
        aspectRatio: aspectRatio,
        circular: circular,
        load: () => load(kind, tripId: tripId, placeId: placeId),
        complete: (crop, source) =>
            save(kind, crop, source.revision, tripId: tripId, placeId: placeId),
      ),
    ),
  );
}
