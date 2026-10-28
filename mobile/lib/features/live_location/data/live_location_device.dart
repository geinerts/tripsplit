import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../domain/live_location.dart';

class LiveLocationPermissionError implements Exception {}

abstract interface class LiveLocationDevice {
  Future<LiveFix> requestFix();
  Stream<LiveFix> watch(String notificationTitle, String notificationText);
}

class NativeLiveLocationDevice implements LiveLocationDevice {
  LiveFix _fix(Position p) =>
      LiveFix(p.latitude, p.longitude, p.accuracy, p.timestamp);
  @override
  Future<LiveFix> requestFix() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LiveLocationPermissionError();
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      throw LiveLocationPermissionError();
    }
    return _fix(
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      ),
    );
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
