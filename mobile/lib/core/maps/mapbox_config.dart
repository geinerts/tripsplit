import 'package:flutter/foundation.dart';

/// Public runtime token, supplied at build time; never commit account tokens.
const mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

bool get mapboxAvailable =>
    mapboxAccessToken.startsWith('pk.') &&
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);
