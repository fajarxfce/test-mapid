import 'package:core_common/core_common.dart';
import 'package:map_domain/src/entities/user_location.dart';
import 'package:map_domain/src/entities/location_settings_target.dart';

abstract interface class UserLocationRepository {
  Future<Result<UserLocation>> locate();
  Future<bool> openSettings(LocationSettingsTarget target);
}
