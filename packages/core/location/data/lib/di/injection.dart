import 'package:core_lifecycle_domain/core_lifecycle_domain.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [AppLifecycleRepository],
  throwOnMissingDependencies: true,
)
void configureCoreLocationDataPackage() {}

@module
abstract class CoreLocationDataModule {
  @lazySingleton
  GeolocatorPlatform geolocator() => GeolocatorPlatform.instance;

  @injectable
  GetCurrentLocation getCurrentLocation(
    LocationRepository repository,
    LocationAccessRepository access,
  ) => GetCurrentLocation(repository, access);

  @injectable
  WatchLocation watchLocation(
    LocationRepository repository,
    LocationAccessRepository access,
    AppLifecycleRepository lifecycle,
  ) => WatchLocation(repository, access, lifecycle);

  @injectable
  OpenLocationSettings openLocationSettings(
    LocationAccessRepository repository,
  ) => OpenLocationSettings(repository);
}
