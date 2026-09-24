// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:auth_presentation/src/login/bloc/login_bloc.dart' as _i1001;
import 'package:auth_presentation/src/navigation/auth_router.dart' as _i0;
import 'package:core_common/core_common.dart' as _i699;
import 'package:get_it/get_it.dart' as _i174;
import 'package:identity_domain/identity_domain.dart' as _i516;
import 'package:injectable/injectable.dart' as _i526;

class AuthPresentationPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i1001.LoginBloc>(
      () => _i1001.LoginBloc(
        gh<_i516.Login>(),
        gh<_i516.LoginWithProvider>(),
        gh<_i516.GetIdentityProviders>(),
        gh<_i699.AppEnvironment>(),
      ),
    );
    gh.lazySingleton<_i0.AuthRouter>(() => _i0.AuthRouter(gh<_i174.GetIt>()));
  }
}
