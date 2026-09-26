import 'package:core_location_data/src/dto/location_fix_dto.dart';

abstract interface class LocationDataSource {
  Future<LocationFixDto> locate();

  /// Reads raw GPS fixes. Access must be arranged by the caller.
  Stream<LocationFixDto> watch();
}
