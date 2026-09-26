import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/calls/safe_location_call.dart';
import 'package:core_location_data/src/datasources/location_access_data_source.dart';
import 'package:core_location_data/src/mappers/map_location_permission.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@LazySingleton(as: LocationAccessRepository)
final class DeviceLocationAccessRepository implements LocationAccessRepository {
  const DeviceLocationAccessRepository(this._source);
  final LocationAccessDataSource _source;

  @override
  Stream<Result<void>> checkAccess() => safeLocationStream(
    () => Stream.fromFuture(_source.isServiceEnabled()).switchMap(
      (enabled) => enabled
          ? Stream.fromFuture(_source.checkPermission())
                .map(mapLocationPermission)
          : Stream.value(
              const FailureResult<void>(
                Failure(
                  FailureKind.serviceDisabled,
                  'Location services are disabled.',
                ),
              ),
            ),
    ),
  );

  @override
  Future<Result<void>> requestPermission() => safeLocationCall(
    () async => mapLocationPermission(await _source.requestPermission()),
  );

  @override
  Future<Result<void>> openSettings(LocationSettingsTarget target) =>
      safeLocationCall(() async {
        final opened = await switch (target) {
          LocationSettingsTarget.application => _source.openAppSettings(),
          LocationSettingsTarget.device => _source.openLocationSettings(),
        };
        return opened
            ? const Success(null)
            : const FailureResult(
                Failure(
                  FailureKind.unexpected,
                  'Location settings could not be opened.',
                ),
              );
      });
}
