import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/location/location_access.dart';
import '../domain/live_location.dart';

class LiveLocationPermissionError implements Exception {
  LiveLocationPermissionError([this.problem = LocationAccessProblem.denied]);
  final LocationAccessProblem problem;
}

abstract interface class LiveLocationDevice {
  Future<LiveFix> requestFix();
  Stream<LiveFix> watch(String notificationTitle, String notificationText);
}

class NativeLiveLocationDevice implements LiveLocationDevice {
  LiveFix _fix(Position p) =>
      LiveFix(p.latitude, p.longitude, p.accuracy, p.timestamp);
  @override
  Future<LiveFix> requestFix() async {
    try {
      await ensureLocationPermission();
      return _fix(
        await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 20),
          ),
        ),
      );
    } catch (error) {
      final problem = locationAccessProblemFor(error);
      if (problem != null) throw LiveLocationPermissionError(problem);
      rethrow;
    }
  }

  @override
  Stream<LiveFix> watch(String title, String text) {
    final LocationSettings settings;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        activityType: ActivityType.otherNavigation,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: title,
          notificationText: text,
          enableWakeLock: true,
        ),
      );
    } else {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }
    return Geolocator.getPositionStream(locationSettings: settings).map(_fix);
  }
}
