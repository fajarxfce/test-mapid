// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:core_location_domain/core_location_domain.dart' as _i1025;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:map_domain/map_domain.dart' as _i774;
import 'package:map_presentation/src/map/bloc/map_bloc.dart' as _i1021;
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_bloc.dart'
    as _i242;
import 'package:map_presentation/src/map/canvas/rendering/map_libre_surface_factory.dart'
    as _i93;
import 'package:map_presentation/src/navigation/map_router.dart' as _i318;

class MapPresentationPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i93.MapLibreSurfaceFactory>(
      () => _i93.MapLibreSurfaceFactory(),
    );
    gh.factory<_i1021.MapBloc>(
      () => _i1021.MapBloc(
        gh<_i774.LoadMapLayer>(),
        gh<_i1025.GetCurrentLocation>(),
        gh<_i1025.OpenLocationSettings>(),
      ),
    );
    gh.lazySingleton<_i318.MapRouter>(() => _i318.MapRouter(gh<_i174.GetIt>()));
    gh.factory<_i242.MapCanvasBloc>(
      () => _i242.MapCanvasBloc(gh<_i93.MapLibreSurfaceFactory>()),
    );
  }
}
