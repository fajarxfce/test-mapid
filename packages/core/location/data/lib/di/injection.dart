import 'package:core_location_domain/core_location_domain.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(throwOnMissingDependencies: true)
void configureCoreLocationDataPackage() {}

@module
abstract class CoreLocationDataModule {
  @lazySingleton
  GeolocatorPlatform geolocator() => GeolocatorPlatform.instance;

  @injectable
  GetCurrentLocation getCurrentLocation(LocationRepository repository) =>
      GetCurrentLocation(repository);

  @injectable
  WatchLocation watchLocation(LocationRepository repository) =>
      WatchLocation(repository);

  @injectable
  OpenLocationSettings openLocationSettings(LocationRepository repository) =>
      OpenLocationSettings(repository);
}
