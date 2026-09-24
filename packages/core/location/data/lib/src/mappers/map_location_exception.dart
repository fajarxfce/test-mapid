import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/exceptions/location_permission_exception.dart';
import 'package:geolocator/geolocator.dart';

/// Platform errors are translated once, before crossing the data boundary.
Failure mapLocationException(Object error) => switch (error) {
  TimeoutException() => const Failure(
    FailureKind.timeout,
    'The location request timed out.',
  ),
  LocationServiceDisabledException() => const Failure(
    FailureKind.serviceDisabled,
    'Location services are disabled.',
  ),
  LocationPermissionException(permission: LocationPermission.deniedForever) =>
    const Failure(
      FailureKind.permissionPermanentlyDenied,
      'Location permission is permanently denied.',
    ),
  LocationPermissionException() || PermissionDeniedException() => const Failure(
    FailureKind.permissionDenied,
    'Location permission was denied by the device.',
  ),
  _ => const Failure(
    FailureKind.unexpected,
    'The device location is unavailable.',
  ),
};
