import 'package:core_common/core_common.dart';
import 'package:injectable/injectable.dart';
import 'package:map_data/src/datasources/local/location_data_source.dart';
import 'package:map_domain/map_domain.dart';

@LazySingleton(as: UserLocationRepository)
final class DeviceUserLocationRepository implements UserLocationRepository {
  const DeviceUserLocationRepository(this._local);
  final LocationDataSource _local;
  @override
  Future<Result<UserLocation>> locate() async => switch (await _local
      .locate()) {
    Success(:final value) => Success(
      UserLocation(
        point: GeoPoint(latitude: value.latitude, longitude: value.longitude),
        accuracyMeters: value.accuracy,
      ),
    ),
    FailureResult(:final failure) => FailureResult(failure),
  };
  @override
  Future<bool> openSettings(LocationSettingsTarget target) => switch (target) {
    LocationSettingsTarget.application => _local.openAppSettings(),
    LocationSettingsTarget.device => _local.openLocationSettings(),
  };
}
