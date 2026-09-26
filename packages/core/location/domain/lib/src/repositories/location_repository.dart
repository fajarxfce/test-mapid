import 'package:core_common/core_common.dart';
import 'package:core_location_domain/src/entities/location_fix.dart';
import 'package:core_location_domain/src/entities/location_settings_target.dart';

abstract interface class LocationRepository {
  Future<Result<LocationFix>> locate({required bool requestPermission});

  /// Checks access and combines GPS with bearing for one acquisition session.
  /// Failure or cancellation releases sensors. The caller controls prompting.
  Stream<Result<LocationFix>> watch({required bool requestPermission});
  Future<Result<void>> openSettings(LocationSettingsTarget target);
}
