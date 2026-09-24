import 'package:core_common/core_common.dart';
import 'package:core_location_domain/src/entities/location_fix.dart';
import 'package:core_location_domain/src/repositories/location_repository.dart';

/// Foreground position and bearing updates; cancellation releases device sensors.
final class WatchLocation {
  const WatchLocation(this._repository);
  final LocationRepository _repository;
  Stream<Result<LocationFix>> call() => _repository.watch();
}
