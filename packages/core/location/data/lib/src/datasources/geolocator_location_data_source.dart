import 'dart:async';

import 'package:core_location_data/src/datasources/location_data_source.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:core_location_data/src/exceptions/location_permission_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

/// Owns OS access and native subscriptions. Technical failures reach the caller.
@LazySingleton(as: LocationDataSource)
final class GeolocatorLocationDataSource implements LocationDataSource {
  const GeolocatorLocationDataSource(this._platform);
  final GeolocatorPlatform _platform;

  Future<void> _requireAccess({bool requestPermission = true}) async {
    if (!await _platform.isLocationServiceEnabled()) {
      throw const LocationServiceDisabledException();
    }
    var permission = await _platform.checkPermission();
    if (permission == LocationPermission.denied && requestPermission) {
      permission = await _platform.requestPermission();
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      throw LocationPermissionException(permission);
    }
  }

  @override
  Future<LocationFixDto> locate() async {
    await _requireAccess();
    final position = await _platform
        .getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15),
          ),
        )
        .timeout(const Duration(seconds: 20));
    return LocationFixDto.fromPosition(position);
  }

  @override
  Stream<LocationFixDto> watch({bool requestPermission = true}) => Rx.defer(
    () =>
        Stream.fromFuture(
          _requireAccess(requestPermission: requestPermission),
        ).switchMap(
          (_) => Rx.race<LocationFixDto>([
            Rx.defer(
              () => _platform.getPositionStream(
                locationSettings:
                    !kIsWeb && defaultTargetPlatform == TargetPlatform.android
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
            ).map(LocationFixDto.fromPosition),
            // Only the first fix has a deadline. The winner cancels the timer.
            Rx.timer(null, const Duration(seconds: 20)).map<LocationFixDto>(
              (_) =>
                  throw TimeoutException('The first location fix timed out.'),
            ),
          ]),
        ),
  );

  @override
  Future<bool> openAppSettings() => _platform.openAppSettings();
  @override
  Future<bool> openLocationSettings() => _platform.openLocationSettings();
}
