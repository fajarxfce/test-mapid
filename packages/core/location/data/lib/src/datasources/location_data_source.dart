import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:core_location_domain/core_location_domain.dart';

abstract interface class LocationDataSource {
  Future<Result<LocationFixDto>> locate();
  Future<Result<void>> openSettings(LocationSettingsTarget target);
}
