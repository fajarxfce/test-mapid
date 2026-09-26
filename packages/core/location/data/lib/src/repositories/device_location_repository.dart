import 'dart:developer' as developer;

import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/datasources/compass_data_source.dart';
import 'package:core_location_data/src/datasources/location_access_data_source.dart';
import 'package:core_location_data/src/datasources/location_data_source.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:core_location_data/src/exceptions/location_permission_exception.dart';
import 'package:core_location_data/src/mappers/map_location_exception.dart';
import 'package:core_location_data/src/mappers/map_location_fix.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@LazySingleton(as: LocationRepository)
final class DeviceLocationRepository implements LocationRepository {
  const DeviceLocationRepository(this._positions, this._access, this._compass);
  final LocationDataSource _positions;
  final LocationAccessDataSource _access;
  final CompassDataSource _compass;
  @override
  Future<Result<LocationFix>> locate({required bool requestPermission}) async {
    try {
      await _prepareAccess(requestPermission: requestPermission).first;
      return Success(mapLocationFix(await _positions.locate()));
    } on Exception catch (error) {
      return FailureResult(mapLocationException(error));
    }
  }

  @override
  Stream<Result<LocationFix>> watch({
    required bool requestPermission,
  }) => _prepareAccess(requestPermission: requestPermission)
      .switchMap(
        (_) => Rx.combineLatest2<LocationFixDto, double?, Result<LocationFix>>(
          Rx.defer(_positions.watch),
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
        ),
      )
      .onErrorReturnWith(
        (error, _) => FailureResult(mapLocationException(error)),
      )
      // An acquisition failure ends this session and releases both sensors.
      .takeWhileInclusive((result) => result is Success<LocationFix>);

  // Cancelled checks cannot proceed to a permission dialog or GPS acquisition.
  // Whether a dialog is allowed is supplied by the calling use case.
  Stream<void> _prepareAccess({required bool requestPermission}) =>
      Rx.defer(() => Stream.fromFuture(_access.isServiceEnabled()))
          .switchMap((enabled) {
            if (!enabled) throw const LocationServiceDisabledException();
            return Stream.fromFuture(_access.checkPermission());
          })
          .switchMap(
            (permission) =>
                permission == LocationPermission.denied && requestPermission
                ? Stream.fromFuture(_access.requestPermission())
                : Stream.value(permission),
          )
          .map((permission) {
            if (permission != LocationPermission.always &&
                permission != LocationPermission.whileInUse) {
              throw LocationPermissionException(permission);
            }
          });
  @override
  Future<Result<void>> openSettings(LocationSettingsTarget target) async {
    try {
      final opened = await switch (target) {
        LocationSettingsTarget.application => _access.openAppSettings(),
        LocationSettingsTarget.device => _access.openLocationSettings(),
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
