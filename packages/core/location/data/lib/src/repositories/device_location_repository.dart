import 'dart:developer' as developer;

import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/datasources/compass_data_source.dart';
import 'package:core_location_data/src/datasources/location_data_source.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:core_location_data/src/mappers/map_location_exception.dart';
import 'package:core_location_data/src/mappers/map_location_fix.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@LazySingleton(as: LocationRepository)
final class DeviceLocationRepository implements LocationRepository {
  const DeviceLocationRepository(this._positions, this._compass);
  final LocationDataSource _positions;
  final CompassDataSource _compass;
  @override
  Future<Result<LocationFix>> locate() async {
    try {
      return Success(mapLocationFix(await _positions.locate()));
    } on Exception catch (error) {
      return FailureResult(mapLocationException(error));
    }
  }

  @override
  Stream<Result<LocationFix>> watch() =>
      Rx.combineLatest2<LocationFixDto, double?, Result<LocationFix>>(
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
          )
          .onErrorReturnWith(
            (error, _) => FailureResult(mapLocationException(error)),
          )
          // An acquisition failure ends this session and releases both sensors.
          .takeWhileInclusive((result) => result is Success<LocationFix>);
}
