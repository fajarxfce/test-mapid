import 'package:core_common/core_common.dart';
import 'package:core_location_domain/src/entities/location_settings_target.dart';

abstract interface class LocationAccessRepository {
  /// Emits one access result without prompting. Cancellation stops subsequent
  /// checks, including when a previous platform operation is still pending.
  Stream<Result<void>> checkAccess();

  Future<Result<void>> requestPermission();
  Future<Result<void>> openSettings(LocationSettingsTarget target);
}
