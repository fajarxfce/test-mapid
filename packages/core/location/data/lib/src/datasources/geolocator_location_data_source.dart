import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/datasources/location_data_source.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

/// Owns OS permission prompts and translates platform failures at the I/O boundary.
@LazySingleton(as: LocationDataSource)
final class GeolocatorLocationDataSource implements LocationDataSource {
  const GeolocatorLocationDataSource(this._platform);
  final GeolocatorPlatform _platform;

  @override
  Future<Result<LocationFixDto>> locate() async {
    try {
      if (!await _platform.isLocationServiceEnabled()) {
        return const FailureResult(
          Failure(
            FailureKind.serviceDisabled,
            'Location services are disabled.',
          ),
        );
      }
      var permission = await _platform.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _platform.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const FailureResult(
          Failure(
            FailureKind.permissionPermanentlyDenied,
            'Location permission is permanently denied.',
          ),
        );
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return const FailureResult(
          Failure(
            FailureKind.permissionDenied,
            'Location permission was denied.',
          ),
        );
      }
      final position = await _platform
          .getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 15),
            ),
          )
          .timeout(const Duration(seconds: 20));
      return Success(
        LocationFixDto(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        ),
      );
    } on TimeoutException {
      return const FailureResult(
        Failure(FailureKind.timeout, 'The location request timed out.'),
      );
    } on LocationServiceDisabledException {
      return const FailureResult(
        Failure(FailureKind.serviceDisabled, 'Location services are disabled.'),
      );
    } on PermissionDeniedException {
      return const FailureResult(
        Failure(
          FailureKind.permissionDenied,
          'Location permission was denied by the device.',
        ),
      );
    } on PlatformException {
      return const FailureResult(
        Failure(FailureKind.unexpected, 'The device location is unavailable.'),
      );
    }
  }

  @override
  Future<Result<void>> openSettings(LocationSettingsTarget target) async {
    try {
      final opened = await switch (target) {
        LocationSettingsTarget.application => _platform.openAppSettings(),
        LocationSettingsTarget.device => _platform.openLocationSettings(),
      };
      return opened
          ? const Success(null)
          : const FailureResult(
              Failure(
                FailureKind.unexpected,
                'Location settings could not be opened.',
              ),
            );
    } on PlatformException {
      return const FailureResult(
        Failure(
          FailureKind.unexpected,
          'Location settings are unavailable on this device.',
        ),
      );
    }
  }
}
