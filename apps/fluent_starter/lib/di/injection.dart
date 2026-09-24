import 'package:core_location_data/core_location_data.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/injection.config.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:map_data/map_data.dart';
import 'package:map_presentation/map_presentation.dart';

@InjectableInit(
  ignoreUnregisteredTypes: [AppConfig, GetIt],
  externalPackageModulesBefore: [
    ExternalModule(CoreNetworkPackageModule),
    ExternalModule(CoreLocationDataPackageModule),
    ExternalModule(MapDataPackageModule),
    ExternalModule(MapPresentationPackageModule),
  ],
  throwOnMissingDependencies: true,
)
Future<GetIt> initializeDependencies(GetIt container) => container.init();

Future<GetIt> configureDependencies(AppConfig config) async {
  final container = GetIt.asNewInstance();
  container.registerSingleton(config);
  container.registerSingleton<GetIt>(container);
  return initializeDependencies(container);
}

@module
abstract class AppModule {
  @lazySingleton
  MapidLayerConfig mapidLayer(AppConfig config) => MapidLayerConfig(
    apiKey: config.apiKey,
    layerId: config.layerId,
    projectId: config.projectId,
  );
  @Named(mapidApi)
  @lazySingleton
  BaseOptions mapidOptions() => BaseOptions(
    baseUrl: 'https://geoserver.mapid.io',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 15),
    contentType: Headers.jsonContentType,
  );
  @Named(mapidApi)
  @lazySingleton
  SafeLoggingInterceptor mapidLogging() =>
      SafeLoggingInterceptor(kDebugMode ? debugPrint : null);
}
