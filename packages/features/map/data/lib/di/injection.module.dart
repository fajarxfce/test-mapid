// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:dio/dio.dart' as _i361;
import 'package:geolocator/geolocator.dart' as _i699;
import 'package:injectable/injectable.dart' as _i526;
import 'package:map_data/di/injection.dart' as _i862;
import 'package:map_data/src/config/mapid_layer_config.dart' as _i273;
import 'package:map_data/src/datasources/local/geolocator_location_data_source.dart'
    as _i151;
import 'package:map_data/src/datasources/local/location_data_source.dart'
    as _i1013;
import 'package:map_data/src/datasources/remote/api_map_remote_data_source.dart'
    as _i106;
import 'package:map_data/src/datasources/remote/map_remote_data_source.dart'
    as _i715;
import 'package:map_data/src/repositories/device_user_location_repository.dart'
    as _i822;
import 'package:map_data/src/repositories/remote_map_repository.dart' as _i180;
import 'package:map_data/src/services/mapid_api.dart' as _i220;
import 'package:map_domain/map_domain.dart' as _i774;

class MapDataPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final mapDataModule = _$MapDataModule();
    gh.lazySingleton<_i699.GeolocatorPlatform>(
      () => mapDataModule.geolocator(),
    );
    gh.lazySingleton<_i1013.LocationDataSource>(
      () => _i151.GeolocatorLocationDataSource(gh<_i699.GeolocatorPlatform>()),
    );
    gh.lazySingleton<_i220.MapidApi>(
      () => _i220.MapidApi(gh<_i361.Dio>(instanceName: 'mapidApi')),
    );
    gh.lazySingleton<_i715.MapRemoteDataSource>(
      () => _i106.ApiMapRemoteDataSource(
        gh<_i220.MapidApi>(),
        gh<_i273.MapidLayerConfig>(),
      ),
    );
    gh.lazySingleton<_i774.UserLocationRepository>(
      () => _i822.DeviceUserLocationRepository(gh<_i1013.LocationDataSource>()),
    );
    gh.lazySingleton<_i774.MapRepository>(
      () => _i180.RemoteMapRepository(gh<_i715.MapRemoteDataSource>()),
    );
    gh.factory<_i774.LocateUser>(
      () => mapDataModule.locateUser(gh<_i774.UserLocationRepository>()),
    );
    gh.factory<_i774.OpenLocationSettings>(
      () => mapDataModule.openLocationSettings(
        gh<_i774.UserLocationRepository>(),
      ),
    );
    gh.factory<_i774.LoadMapLayer>(
      () => mapDataModule.loadMapLayer(gh<_i774.MapRepository>()),
    );
  }
}

class _$MapDataModule extends _i862.MapDataModule {}
