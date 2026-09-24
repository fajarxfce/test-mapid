import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:map_data/src/config/mapid_layer_config.dart';
import 'package:map_domain/map_domain.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [Dio, MapidLayerConfig],
  throwOnMissingDependencies: true,
)
void configureMapDataPackage() {}

@module
abstract class MapDataModule {
  @lazySingleton
  GeolocatorPlatform geolocator() => GeolocatorPlatform.instance;
  @injectable
  LoadMapLayer loadMapLayer(MapRepository repository) =>
      LoadMapLayer(repository);
  @injectable
  LocateUser locateUser(UserLocationRepository repository) =>
      LocateUser(repository);
  @injectable
  OpenLocationSettings openLocationSettings(
    UserLocationRepository repository,
  ) => OpenLocationSettings(repository);
}
