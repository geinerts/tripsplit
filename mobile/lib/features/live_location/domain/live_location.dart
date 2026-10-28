import 'package:latlong2/latlong.dart';

class LiveFix {
  const LiveFix(this.latitude, this.longitude, this.accuracy, this.observedAt);
  final double latitude, longitude, accuracy;
  final DateTime observedAt;
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy_m': accuracy,
    'observed_at': observedAt.toUtc().millisecondsSinceEpoch ~/ 1000,
  };
}

class LiveMember {
  LiveMember.fromJson(Map<String, dynamic> json)
    : userId = (json['user_id'] as num).toInt(),
      name = json['name'] as String,
      point = LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      accuracy = (json['accuracy_m'] as num).toDouble(),
      observedAt = fromSeconds(json['observed_at']),
      expiresAt = fromSeconds(json['expires_at']);
  final int userId;
  final String name;
  final LatLng point;
  final double accuracy;
  final DateTime observedAt, expiresAt;
  bool visibleAt(DateTime now) =>
      expiresAt.isAfter(now) && now.difference(observedAt).inSeconds < 120;
}

DateTime fromSeconds(dynamic seconds) => DateTime.fromMillisecondsSinceEpoch(
  (seconds as num).toInt() * 1000,
  isUtc: true,
);

class LiveMapSnapshot {
  LiveMapSnapshot.fromJson(Map<String, dynamic> json)
    : members = (json['members'] as List)
          .map((v) => LiveMember.fromJson(Map<String, dynamic>.from(v)))
          .toList(),
      serverTime = fromSeconds(json['server_time']),
      ownExpiresAt = json['own_expires_at'] == null
          ? null
          : fromSeconds(json['own_expires_at']);
  final List<LiveMember> members;
  final DateTime serverTime;
  final DateTime? ownExpiresAt;
}

class LiveShareSession {
  const LiveShareSession(this.token, this.expiresAt);
  final String token;
  final DateTime expiresAt;
}
