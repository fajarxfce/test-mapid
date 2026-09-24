import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/datasources/location_data_source.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LocationRepository)
final class DeviceLocationRepository implements LocationRepository {
  const DeviceLocationRepository(this._local);
  final LocationDataSource _local;
  @override
  Future<Result<LocationFix>> locate() async => switch (await _local.locate()) {
    Success(:final value) => Success(
      LocationFix(
        point: GeoPoint(latitude: value.latitude, longitude: value.longitude),
        accuracyMeters: value.accuracy,
      ),
    ),
    FailureResult(:final failure) => FailureResult(failure),
  };
  @override
  Future<Result<void>> openSettings(LocationSettingsTarget target) =>
      _local.openSettings(target);
}
