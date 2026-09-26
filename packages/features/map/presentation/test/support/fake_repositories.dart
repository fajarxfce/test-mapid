import 'package:core_common/core_common.dart';
import 'package:core_lifecycle_domain/core_lifecycle_domain.dart';
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
  int calls = 0;
  Stream<Result<LocationFix>> Function()? updates;
  @override
  Stream<Result<LocationFix>> watch() {
    calls++;
    return updates?.call() ?? Stream.fromFuture(response());
  }

  @override
  Future<Result<LocationFix>> locate() {
    calls++;
    return response();
  }
}

class FakeLocationAccessRepository implements LocationAccessRepository {
  Result<void> settingsResult = const Success(null);
  LocationSettingsTarget? opened;
  @override
  Stream<Result<void>> checkAccess() => Stream.value(const Success(null));
  @override
  Future<Result<void>> requestPermission() async => const Success(null);
  @override
  Future<Result<void>> openSettings(LocationSettingsTarget target) async {
    opened = target;
    return settingsResult;
  }
}

class FakeAppLifecycleRepository implements AppLifecycleRepository {
  const FakeAppLifecycleRepository();
  @override
  Stream<bool> watchForeground() => Stream.value(true);
}
