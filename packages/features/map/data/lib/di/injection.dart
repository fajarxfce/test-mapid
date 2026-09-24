import 'package:dio/dio.dart';
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
  @injectable
  LoadMapLayer loadMapLayer(MapRepository repository) =>
      LoadMapLayer(repository);
}
