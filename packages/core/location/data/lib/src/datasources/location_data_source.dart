import 'package:core_location_data/src/dto/location_fix_dto.dart';

abstract interface class LocationDataSource {
  Future<LocationFixDto> locate();

  /// Emits raw fixes or technical errors. Passive resume never opens a dialog.
  Stream<LocationFixDto> watch({bool requestPermission = true});
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}
