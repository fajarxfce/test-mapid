import 'package:core_common/core_common.dart';
import 'package:core_location_domain/src/entities/location_fix.dart';
import 'package:core_location_domain/src/entities/location_settings_target.dart';

abstract interface class LocationRepository {
  Future<Result<LocationFix>> locate();

  /// Emits cancelled while backgrounded, resumes on foreground, ends on failure.
  Stream<Result<LocationFix>> watch();
  Future<Result<void>> openSettings(LocationSettingsTarget target);
}
