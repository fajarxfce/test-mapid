import 'package:core_common/core_common.dart';
import 'package:core_location_domain/src/entities/location_fix.dart';
import 'package:core_location_domain/src/repositories/location_repository.dart';

final class GetCurrentLocation {
  const GetCurrentLocation(this._repository);
  final LocationRepository _repository;
  Future<Result<LocationFix>> call() =>
      _repository.locate(requestPermission: true);
}
