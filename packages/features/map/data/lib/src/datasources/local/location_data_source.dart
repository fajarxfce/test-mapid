import 'package:core_common/core_common.dart';
import 'package:map_data/src/dto/user_location_dto.dart';

abstract interface class LocationDataSource {
  Future<Result<UserLocationDto>> locate();
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}
