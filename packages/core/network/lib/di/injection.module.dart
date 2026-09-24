// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:core_network/di/injection.dart' as _i278;
import 'package:core_network/src/interceptors/safe_logging_interceptor.dart'
    as _i231;
import 'package:dio/dio.dart' as _i361;
import 'package:injectable/injectable.dart' as _i526;

class CoreNetworkPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.mapidDio(
        gh<_i361.BaseOptions>(instanceName: 'mapidApi'),
        gh<_i231.SafeLoggingInterceptor>(instanceName: 'mapidApi'),
      ),
      instanceName: 'mapidApi',
      dispose: _i278.disposeDio,
    );
  }
}

class _$NetworkModule extends _i278.NetworkModule {}
