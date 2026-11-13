import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/l10n.dart';

/// Why the device location could not be used.
enum LocationAccessProblem {
  /// The user declined the system prompt this time. Asking again is allowed.
  denied,

  /// "Don't ask again" (or a managed device): the system prompt cannot appear,
  /// only the app's settings page can change it.
  deniedForever,

  /// Device location is switched off.
  servicesDisabled,
}

class LocationAccessException implements Exception {
  const LocationAccessException(this.problem);
  final LocationAccessProblem problem;
}

/// The one permission flow used by every feature that reads the device
/// location (travel map, live map).
///
/// 1. Asks for permission with the system prompt when it is still undecided.
/// 2. Never starts a feature that is blocked: throws [LocationAccessException].
/// 3. Does not check whether device location is on. On Android the position
///    request itself shows Google's "Turn on device location" dialog. Callers
///    pass errors from the position request to [locationAccessProblemFor].
///    iOS cannot show such a dialog, so it is checked here.
Future<void> ensureLocationPermission() async {
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    throw const LocationAccessException(LocationAccessProblem.deniedForever);
  }
  if (permission != LocationPermission.whileInUse &&
      permission != LocationPermission.always) {
    throw const LocationAccessException(LocationAccessProblem.denied);
  }
  if (defaultTargetPlatform != TargetPlatform.android &&
      !await Geolocator.isLocationServiceEnabled()) {
    throw const LocationAccessException(LocationAccessProblem.servicesDisabled);
  }
}

/// Maps an error raised while reading a position, or null for other errors.
LocationAccessProblem? locationAccessProblemFor(Object error) {
  if (error is LocationAccessException) return error.problem;
  if (error is LocationServiceDisabledException) {
    return LocationAccessProblem.servicesDisabled;
  }
  if (error is PermissionDeniedException) return LocationAccessProblem.denied;
  return null;
}

/// Opens the settings page that can fix [problem].
Future<void> openLocationSettings(LocationAccessProblem problem) async {
  if (problem == LocationAccessProblem.servicesDisabled) {
    await Geolocator.openLocationSettings();
  } else {
    await Geolocator.openAppSettings();
  }
}

/// A "Settings" button for a snack bar, or null when the system prompt can
/// simply be shown again ([LocationAccessProblem.denied]).
SnackBarAction? locationSettingsAction(
  BuildContext context,
  LocationAccessProblem? problem,
) {
  if (problem == null || problem == LocationAccessProblem.denied) return null;
  return SnackBarAction(
    label: context.l10n.settings,
    onPressed: () => openLocationSettings(problem),
  );
}
