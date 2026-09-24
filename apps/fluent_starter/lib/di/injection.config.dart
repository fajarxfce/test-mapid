// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auth_presentation/auth_presentation.dart' as _i612;
import 'package:core_common/core_common.dart' as _i699;
import 'package:core_network/core_network.dart' as _i309;
import 'package:dio/dio.dart' as _i361;
import 'package:fluent_starter/config/app_config.dart' as _i209;
import 'package:fluent_starter/di/injection.dart' as _i487;
import 'package:fluent_starter/routing/app_router.dart' as _i902;
import 'package:fluent_starter/routing/guards/session_guard.dart' as _i749;
import 'package:get_it/get_it.dart' as _i174;
import 'package:home_presentation/home_presentation.dart' as _i1032;
import 'package:identity_data/identity_data.dart' as _i188;
import 'package:identity_domain/identity_domain.dart' as _i516;
import 'package:injectable/injectable.dart' as _i526;
import 'package:settings_data/settings_data.dart' as _i201;
import 'package:settings_presentation/settings_presentation.dart' as _i1029;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    await _i309.CoreNetworkPackageModule().init(gh);
    await _i188.IdentityDataPackageModule().init(gh);
    await _i612.AuthPresentationPackageModule().init(gh);
    await _i1032.HomePresentationPackageModule().init(gh);
    await _i201.SettingsDataPackageModule().init(gh);
    await _i1029.SettingsPresentationPackageModule().init(gh);
    final appModule = _$AppModule();
    gh.lazySingleton<_i361.BaseOptions>(
      () => appModule.mainApiOptions(gh<_i209.AppConfig>()),
      instanceName: 'mainApi',
    );
    gh.lazySingleton<_i361.HttpClientAdapter>(
      () => appModule.mainApiAdapter(gh<_i209.AppConfig>()),
      instanceName: 'mainApi',
    );
    gh.lazySingleton<_i309.SafeLoggingInterceptor>(
      () => appModule.mainApiLogging(),
      instanceName: 'mainApi',
    );
    gh.lazySingleton<_i188.OAuthConfiguration>(
      () => appModule.oauthConfiguration(gh<_i209.AppConfig>()),
    );
    gh.lazySingleton<_i699.AppEnvironment>(
      () => appModule.environment(gh<_i209.AppConfig>()),
    );
    gh.lazySingleton<_i749.SessionGuard>(
      () => _i749.SessionGuard(gh<_i516.GetCurrentSession>()),
    );
    gh.lazySingleton<_i902.AppRouter>(
      () => _i902.AppRouter(
        gh<_i749.SessionGuard>(),
        gh<_i516.GetCurrentSession>(),
        gh<_i516.WatchSession>(),
        gh<_i612.AuthRouter>(),
        gh<_i1032.HomeRouter>(),
        gh<_i1029.SettingsRouter>(),
      ),
      dispose: (i) => i.close(),
    );
    return this;
  }
}

class _$AppModule extends _i487.AppModule {}
