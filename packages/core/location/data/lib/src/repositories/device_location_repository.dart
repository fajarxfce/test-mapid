import 'dart:developer' as developer;

import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/datasources/compass_data_source.dart';
import 'package:core_location_data/src/datasources/location_data_source.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:core_location_data/src/lifecycle/watch_app_foreground.dart';
import 'package:core_location_data/src/mappers/map_location_exception.dart';
import 'package:core_location_data/src/mappers/map_location_fix.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@LazySingleton(as: LocationRepository)
final class DeviceLocationRepository implements LocationRepository {
  const DeviceLocationRepository(this._local, this._compass);
  final LocationDataSource _local;
  final CompassDataSource _compass;
  @override
  Future<Result<LocationFix>> locate() async {
    try {
      return Success(mapLocationFix(await _local.locate()));
    } on Exception catch (error) {
      return FailureResult(mapLocationException(error));
    }
  }

  @override
  Stream<Result<LocationFix>> watch() => Rx.defer(() {
    // Only a new caller request may prompt. Returning from Settings is passive.
    var requestPermission = true;
    return watchAppForeground().switchMap((foreground) {
      if (!foreground) {
        return Stream.value(
          const FailureResult<LocationFix>(
            Failure(
              FailureKind.cancelled,
              'Foreground location tracking is paused.',
            ),
          ),
        );
      }
      final mayPrompt = requestPermission;
      final fixes = Rx.defer(() => _local.watch(requestPermission: mayPrompt));
      requestPermission = false;
      // Release sensors on failure, retaining visibility observation for resume.
      return Rx.combineLatest2<LocationFixDto, double?, Result<LocationFix>>(
            fixes,
            // Compass is optional: retain GPS and course when its sensor fails.
            Rx.defer(_compass.watch)
                .doOnError((error, stackTrace) {
                  developer.log(
                    'Compass unavailable; retaining GPS tracking.',
                    name: 'location.repository',
                    error: error,
                    stackTrace: stackTrace,
                  );
                })
                .onErrorReturn(null),
            (fix, heading) => Success<LocationFix>(
              mapLocationFix(fix, compassHeading: heading),
            ),
          )
          .onErrorReturnWith(
            (error, _) => FailureResult(mapLocationException(error)),
          )
          .takeWhileInclusive((result) => result is Success<LocationFix>);
    });
  });
  @override
  Future<Result<void>> openSettings(LocationSettingsTarget target) async {
    try {
      final opened = await switch (target) {
        LocationSettingsTarget.application => _local.openAppSettings(),
        LocationSettingsTarget.device => _local.openLocationSettings(),
      };
      return opened
          ? const Success(null)
          : const FailureResult(
              Failure(
                FailureKind.unexpected,
                'Location settings could not be opened.',
              ),
            );
    } on Exception catch (error) {
      return FailureResult(mapLocationException(error));
    }
  }
}
