import 'package:core_common/core_common.dart';
import 'package:core_location_domain/src/entities/location_fix.dart';

abstract interface class LocationRepository {
  Future<Result<LocationFix>> locate();

  /// Combines GPS with bearing for one acquisition session. Access must already
  /// be granted. Failure or cancellation releases sensors.
  Stream<Result<LocationFix>> watch();
}
