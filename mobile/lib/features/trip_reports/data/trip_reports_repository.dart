import 'dart:convert';
import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/http_method.dart';
import '../domain/year_summary.dart';

enum TripExportFormat { pdf, csv }

class TripExportFile {
  const TripExportFile({
    required this.name,
    required this.mimeType,
    required this.bytes,
  });

  final String name;
  final String mimeType;
  final Uint8List bytes;
}

abstract interface class TripReportsRepository {
  Future<TripExportFile> exportTrip({
    required int tripId,
    required TripExportFormat format,
    required String locale,
  });

  Future<YearSummary> loadYearSummary({int? year});
}

/// Premium access is decided by the server on each call.
class ApiTripReportsRepository implements TripReportsRepository {
  ApiTripReportsRepository(this.api);

  final ApiClient api;

  @override
  Future<TripExportFile> exportTrip({
    required int tripId,
    required TripExportFormat format,
    required String locale,
  }) async {
    final response = await api.request(
      path: ApiEndpoints.legacyAction('trip_export'),
      method: HttpMethod.get,
      query: <String, dynamic>{'format': format.name, 'locale': locale},
      headers: <String, String>{'X-Trip-Id': '$tripId'},
    );
    return TripExportFile(
      name: '${response['filename'] ?? 'splyto-trip.${format.name}'}',
      mimeType: '${response['mime_type'] ?? ''}',
      bytes: base64Decode('${response['content_base64'] ?? ''}'),
    );
  }

  @override
  Future<YearSummary> loadYearSummary({int? year}) async {
    final response = await api.request(
      path: ApiEndpoints.legacyAction('travel_year_summary'),
      method: HttpMethod.get,
      query: year == null ? null : <String, dynamic>{'year': '$year'},
    );
    final summary = response['summary'];
    if (summary is! Map<String, dynamic>) {
      throw const FormatException('Year summary is missing.');
    }
    return YearSummary.fromMap(summary);
  }
}
