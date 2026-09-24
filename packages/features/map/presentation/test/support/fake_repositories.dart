import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';

import 'map_fixtures.dart';

class FakeMapRepository implements MapRepository {
  Future<Result<MapLayer>> Function() response = () async =>
      Success(sampleLayer);
  int calls = 0;
  @override
  Future<Result<MapLayer>> loadLayer() {
    calls++;
    return response();
  }
}

class FakeLocationRepository implements LocationRepository {
  Future<Result<LocationFix>> Function() response = () async =>
      const Success(sampleLocation);
  Result<void> settingsResult = const Success(null);
  LocationSettingsTarget? opened;
  int calls = 0;
  @override
  Future<Result<LocationFix>> locate() {
    calls++;
    return response();
  }

  @override
  Future<Result<void>> openSettings(LocationSettingsTarget target) async {
    opened = target;
    return settingsResult;
  }
}
