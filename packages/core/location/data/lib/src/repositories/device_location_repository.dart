import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/datasources/compass_data_source.dart';
import 'package:core_location_data/src/datasources/location_data_source.dart';
import 'package:core_location_data/src/lifecycle/watch_app_foreground.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@LazySingleton(as: LocationRepository)
final class DeviceLocationRepository implements LocationRepository {
  const DeviceLocationRepository(this._local, this._compass);
  final LocationDataSource _local;
  final CompassDataSource _compass;
  @override
  Future<Result<LocationFix>> locate() async => switch (await _local.locate()) {
    Success(:final value) => Success(value.toEntity()),
    FailureResult(:final failure) => FailureResult(failure),
  };
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
      final fixes = _local.watch(requestPermission: requestPermission);
      requestPermission = false;
      // Release sensors on failure, retaining visibility observation for resume.
      return Rx.combineLatest2(
        fixes,
        _compass.watch(),
        (result, heading) => switch (result) {
          Success(:final value) => Success<LocationFix>(
            value.toEntity(compassHeading: heading),
          ),
          FailureResult(:final failure) => FailureResult<LocationFix>(failure),
        },
      ).takeWhileInclusive((result) => result is Success<LocationFix>);
    });
  });
  @override
  Future<Result<void>> openSettings(LocationSettingsTarget target) =>
      _local.openSettings(target);
}
