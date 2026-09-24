import 'package:core_common/core_common.dart';
import 'package:core_location_domain/src/entities/location_fix.dart';
import 'package:core_location_domain/src/entities/location_settings_target.dart';

abstract interface class LocationRepository {
  Future<Result<LocationFix>> locate();

  /// Pauses sensors in the background and on failure. Rechecks access on resume
  /// without prompting again. Cancel the subscription to stop observing.
  Stream<Result<LocationFix>> watch();
  Future<Result<void>> openSettings(LocationSettingsTarget target);
}
