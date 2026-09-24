import 'package:core_common/core_common.dart';
import 'package:map_domain/src/entities/user_location.dart';
import 'package:map_domain/src/repositories/user_location_repository.dart';

final class LocateUser {
  const LocateUser(this._repository);
  final UserLocationRepository _repository;
  Future<Result<UserLocation>> call() => _repository.locate();
}
