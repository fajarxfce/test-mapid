// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:core_lifecycle_data/core_lifecycle_data.dart' as _i67;
import 'package:core_location_data/core_location_data.dart' as _i276;
import 'package:core_network/core_network.dart' as _i309;
import 'package:dio/dio.dart' as _i361;
import 'package:fluent_starter/config/app_config.dart' as _i209;
import 'package:fluent_starter/di/injection.dart' as _i487;
import 'package:fluent_starter/routing/app_router.dart' as _i902;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:map_data/map_data.dart' as _i301;
import 'package:map_presentation/map_presentation.dart' as _i275;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    await _i309.CoreNetworkPackageModule().init(gh);
    await _i67.CoreLifecycleDataPackageModule().init(gh);
    await _i276.CoreLocationDataPackageModule().init(gh);
    await _i301.MapDataPackageModule().init(gh);
    await _i275.MapPresentationPackageModule().init(gh);
    final appModule = _$AppModule();
    gh.lazySingleton<_i361.BaseOptions>(
      () => appModule.mapidOptions(),
      instanceName: 'mapidApi',
    );
    gh.lazySingleton<_i309.SafeLoggingInterceptor>(
      () => appModule.mapidLogging(),
      instanceName: 'mapidApi',
    );
    gh.lazySingleton<_i902.AppRouter>(
      () => _i902.AppRouter(gh<_i275.MapRouter>()),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i301.MapidLayerConfig>(
      () => appModule.mapidLayer(gh<_i209.AppConfig>()),
    );
    return this;
  }
}

class _$AppModule extends _i487.AppModule {}
