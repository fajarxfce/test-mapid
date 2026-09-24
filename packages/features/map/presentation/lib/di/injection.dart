import 'package:core_location_domain/core_location_domain.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:map_domain/map_domain.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    GetIt,
    LoadMapLayer,
    GetCurrentLocation,
    OpenLocationSettings,
  ],
  throwOnMissingDependencies: true,
)
void configureMapPresentationPackage() {}
