import 'package:geolocator/geolocator.dart';

/// A denied OS permission result, retaining whether another prompt is possible.
final class LocationPermissionException implements Exception {
  const LocationPermissionException(this.permission);
  final LocationPermission permission;
}
