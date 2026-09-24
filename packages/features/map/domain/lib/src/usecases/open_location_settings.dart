import 'package:map_domain/src/entities/location_settings_target.dart';
import 'package:map_domain/src/repositories/user_location_repository.dart';

final class OpenLocationSettings {
  const OpenLocationSettings(this._repository);
  final UserLocationRepository _repository;
  Future<bool> call(LocationSettingsTarget target) =>
      _repository.openSettings(target);
}
