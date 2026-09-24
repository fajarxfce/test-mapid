// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:core_common/core_common.dart' as _i699;
import 'package:get_it/get_it.dart' as _i174;
import 'package:home_presentation/src/home/bloc/home_bloc.dart' as _i523;
import 'package:home_presentation/src/navigation/home_router.dart' as _i724;
import 'package:identity_domain/identity_domain.dart' as _i516;
import 'package:injectable/injectable.dart' as _i526;

class HomePresentationPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.lazySingleton<_i724.HomeRouter>(
      () => _i724.HomeRouter(gh<_i174.GetIt>()),
    );
    gh.factory<_i523.HomeBloc>(
      () => _i523.HomeBloc(
        gh<_i516.WatchSession>(),
        gh<_i516.GetCurrentSession>(),
        gh<_i516.RestoreSession>(),
        gh<_i516.Logout>(),
        gh<_i516.ExpireDemoSession>(),
        gh<_i699.AppEnvironment>(),
      ),
    );
  }
}
