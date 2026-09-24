// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:injectable/injectable.dart' as _i526;
import 'package:settings_domain/settings_domain.dart' as _i406;
import 'package:settings_presentation/src/appearance/bloc/appearance_bloc.dart'
    as _i614;
import 'package:settings_presentation/src/navigation/settings_router.dart'
    as _i415;

class SettingsPresentationPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.lazySingleton<_i415.SettingsRouter>(() => _i415.SettingsRouter());
    gh.lazySingleton<_i614.AppearanceBloc>(
      () => _i614.AppearanceBloc(gh<_i406.LoadTheme>(), gh<_i406.SaveTheme>()),
      dispose: (i) => i.close(),
    );
  }
}
