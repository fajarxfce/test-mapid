import 'dart:async';

import 'package:core_location_data/src/datasources/location_data_source.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

/// Reads GPS fixes and configures native acquisition. Never requests permission.
@LazySingleton(as: LocationDataSource)
final class GeolocatorLocationDataSource implements LocationDataSource {
  const GeolocatorLocationDataSource(this._platform);
  final GeolocatorPlatform _platform;

  @override
  Future<LocationFixDto> locate() async {
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
  Stream<LocationFixDto> watch() => Rx.defer(
    () => Rx.race<LocationFixDto>([
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
        (_) => throw TimeoutException('The first location fix timed out.'),
      ),
    ]),
  );
}
