import 'package:core_common/core_common.dart';
import 'package:core_location_domain/src/entities/location_settings_target.dart';
import 'package:core_location_domain/src/repositories/location_access_repository.dart';

final class OpenLocationSettings {
  const OpenLocationSettings(this._repository);
  final LocationAccessRepository _repository;
  Future<Result<void>> call(LocationSettingsTarget target) =>
      _repository.openSettings(target);
}
