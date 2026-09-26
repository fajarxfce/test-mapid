// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:core_lifecycle_domain/core_lifecycle_domain.dart' as _i705;
import 'package:core_location_data/di/injection.dart' as _i953;
import 'package:core_location_data/src/datasources/compass_data_source.dart'
    as _i468;
import 'package:core_location_data/src/datasources/flutter_compass_data_source.dart'
    as _i310;
import 'package:core_location_data/src/datasources/geolocator_location_access_data_source.dart'
    as _i452;
import 'package:core_location_data/src/datasources/geolocator_location_data_source.dart'
    as _i998;
import 'package:core_location_data/src/datasources/location_access_data_source.dart'
    as _i520;
import 'package:core_location_data/src/datasources/location_data_source.dart'
    as _i633;
import 'package:core_location_data/src/repositories/device_location_repository.dart'
    as _i391;
import 'package:core_location_domain/core_location_domain.dart' as _i1025;
import 'package:geolocator/geolocator.dart' as _i699;
import 'package:injectable/injectable.dart' as _i526;

class CoreLocationDataPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final coreLocationDataModule = _$CoreLocationDataModule();
    gh.lazySingleton<_i699.GeolocatorPlatform>(
      () => coreLocationDataModule.geolocator(),
    );
    gh.lazySingleton<_i468.CompassDataSource>(
      () => const _i310.FlutterCompassDataSource(),
    );
    gh.lazySingleton<_i520.LocationAccessDataSource>(
      () => _i452.GeolocatorLocationAccessDataSource(
        gh<_i699.GeolocatorPlatform>(),
      ),
    );
    gh.lazySingleton<_i633.LocationDataSource>(
      () => _i998.GeolocatorLocationDataSource(gh<_i699.GeolocatorPlatform>()),
    );
    gh.lazySingleton<_i1025.LocationRepository>(
      () => _i391.DeviceLocationRepository(
        gh<_i633.LocationDataSource>(),
        gh<_i520.LocationAccessDataSource>(),
        gh<_i468.CompassDataSource>(),
      ),
    );
    gh.factory<_i1025.WatchLocation>(
      () => coreLocationDataModule.watchLocation(
        gh<_i1025.LocationRepository>(),
        gh<_i705.AppLifecycleRepository>(),
      ),
    );
    gh.factory<_i1025.GetCurrentLocation>(
      () => coreLocationDataModule.getCurrentLocation(
        gh<_i1025.LocationRepository>(),
      ),
    );
    gh.factory<_i1025.OpenLocationSettings>(
      () => coreLocationDataModule.openLocationSettings(
        gh<_i1025.LocationRepository>(),
      ),
    );
  }
}

class _$CoreLocationDataModule extends _i953.CoreLocationDataModule {}
