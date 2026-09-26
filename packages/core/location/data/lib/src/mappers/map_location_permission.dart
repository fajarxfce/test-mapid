import 'package:core_common/core_common.dart';
import 'package:geolocator/geolocator.dart';

Result<void> mapLocationPermission(LocationPermission permission) =>
    switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse => const Success(null),
      LocationPermission.denied => const FailureResult(
        Failure(
          FailureKind.permissionDenied,
          'Location permission was denied by the device.',
        ),
      ),
      LocationPermission.deniedForever => const FailureResult(
        Failure(
          FailureKind.permissionPermanentlyDenied,
          'Location permission is permanently denied.',
        ),
      ),
      LocationPermission.unableToDetermine => const FailureResult(
        Failure(
          FailureKind.unexpected,
          'Location permission could not be determined.',
        ),
      ),
    };
