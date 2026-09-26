import 'dart:async';

import 'package:core_common/core_common.dart';
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
  PermissionDeniedException() => const Failure(
    FailureKind.permissionDenied,
    'Location permission was denied by the device.',
  ),
  _ => const Failure(
    FailureKind.unexpected,
    'The device location is unavailable.',
  ),
};
