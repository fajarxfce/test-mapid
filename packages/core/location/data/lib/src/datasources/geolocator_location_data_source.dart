import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/datasources/location_data_source.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:core_location_data/src/mappers/map_location_exception.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

/// Owns OS permission prompts and translates platform failures at the I/O boundary.
@LazySingleton(as: LocationDataSource)
final class GeolocatorLocationDataSource implements LocationDataSource {
  const GeolocatorLocationDataSource(this._platform);
  final GeolocatorPlatform _platform;

  Future<Result<void>> _requestAccess({bool requestPermission = true}) async {
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
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await _platform.requestPermission();
      }
      return switch (permission) {
        LocationPermission.always ||
        LocationPermission.whileInUse => const Success(null),
        LocationPermission.deniedForever => const FailureResult(
          Failure(
            FailureKind.permissionPermanentlyDenied,
            'Location permission is permanently denied.',
          ),
        ),
        _ => const FailureResult(
          Failure(
            FailureKind.permissionDenied,
            'Location permission was denied.',
          ),
        ),
      };
    } on Exception catch (error) {
      return FailureResult(mapLocationException(error));
    }
  }

  @override
  Future<Result<LocationFixDto>> locate() async {
    if (await _requestAccess() case FailureResult(:final failure)) {
      return FailureResult(failure);
    }
    try {
      final position = await _platform
          .getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 15),
            ),
          )
          .timeout(const Duration(seconds: 20));
      return Success(LocationFixDto.fromPosition(position));
    } on Exception catch (error) {
      return FailureResult(mapLocationException(error));
    }
  }

  @override
  Stream<Result<LocationFixDto>> watch({
    bool requestPermission = true,
  }) => Rx.defer(
    () =>
        Stream.fromFuture(
          _requestAccess(requestPermission: requestPermission),
        ).switchMap(
          (access) => switch (access) {
            FailureResult(:final failure) => Stream.value(
              FailureResult<LocationFixDto>(failure),
            ),
            Success() => Rx.race<Result<LocationFixDto>>(
              [
                Rx.defer(
                      () => _platform.getPositionStream(
                        locationSettings:
                            !kIsWeb &&
                                defaultTargetPlatform == TargetPlatform.android
                            ? AndroidSettings(
                                accuracy: LocationAccuracy.high,
                                distanceFilter: 0,
                                intervalDuration: const Duration(seconds: 1),
                              )
                            : const LocationSettings(
                                accuracy: LocationAccuracy.high,
                                distanceFilter: 0,
                              ),
                      ),
                    )
                    .map<Result<LocationFixDto>>(
                      (position) =>
                          Success(LocationFixDto.fromPosition(position)),
                    )
                    .onErrorReturnWith(
                      (error, _) => FailureResult(mapLocationException(error)),
                    ),
                // The first fix cancels this deadline. Standing still never times out.
                Rx.timer(
                  const FailureResult<LocationFixDto>(
                    Failure(
                      FailureKind.timeout,
                      'The first location fix timed out.',
                    ),
                  ),
                  const Duration(seconds: 20),
                ),
              ],
            ).takeWhileInclusive((result) => result is Success<LocationFixDto>),
          },
        ),
  );

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
