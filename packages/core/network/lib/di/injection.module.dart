// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:core_network/di/injection.dart' as _i278;
import 'package:core_network/src/authentication/http_authentication.dart'
    as _i155;
import 'package:core_network/src/interceptors/auth_interceptor.dart' as _i267;
import 'package:core_network/src/interceptors/safe_logging_interceptor.dart'
    as _i231;
import 'package:dio/dio.dart' as _i361;
import 'package:injectable/injectable.dart' as _i526;

class CoreNetworkPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i267.AuthInterceptor>(
      () => networkModule.mainApiAuthentication(
        gh<_i155.HttpAuthentication>(instanceName: 'mainApi'),
        gh<_i361.BaseOptions>(instanceName: 'mainApi'),
      ),
      instanceName: 'mainApi',
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.mainApiDio(
        gh<_i361.BaseOptions>(instanceName: 'mainApi'),
        gh<_i361.HttpClientAdapter>(instanceName: 'mainApi'),
        gh<_i267.AuthInterceptor>(instanceName: 'mainApi'),
        gh<_i231.SafeLoggingInterceptor>(instanceName: 'mainApi'),
      ),
      instanceName: 'mainApi',
      dispose: _i278.disposeDio,
    );
  }
}

class _$NetworkModule extends _i278.NetworkModule {}
