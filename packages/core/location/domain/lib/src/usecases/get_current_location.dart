import 'package:core_common/core_common.dart';
import 'package:core_location_domain/src/entities/location_fix.dart';
import 'package:core_location_domain/src/repositories/location_access_repository.dart';
import 'package:core_location_domain/src/repositories/location_repository.dart';

final class GetCurrentLocation {
  const GetCurrentLocation(this._repository, this._access);
  final LocationRepository _repository;
  final LocationAccessRepository _access;

  Future<Result<LocationFix>> call() async {
    final access = await _access.checkAccess().first;
    final permission = switch (access) {
      FailureResult(failure: Failure(kind: FailureKind.permissionDenied)) =>
        await _access.requestPermission(),
      _ => access,
    };
    return permission.flatMap((_) => _repository.locate());
  }
}
