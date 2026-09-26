import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:map_presentation/src/map/bindings/map_canvas_binding.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/rendering/maplibre_renderer.dart';
import 'package:map_presentation/src/navigation/map_router.gr.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class MapRouter {
  MapRouter(this._container);
  final GetIt _container;
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MapRoute.page.copyWith(
        builder: (data) => RepositoryProvider<MapLibreRenderer>(
          create: (_) => _container<MapLibreRenderer>(),
          dispose: (renderer) => unawaited(renderer.close()),
          child: BlocProvider<MapBloc>(
            create: (context) => _container<MapBloc>()
              ..add(const MapLayerRequested())
              ..add(const MapLocationRequested()),
            child: RepositoryProvider<MapCanvasBinding>(
              lazy: false,
              create: (context) => MapCanvasBinding(
                renderer: context.read<MapLibreRenderer>(),
                initialScene: context.read<MapBloc>().state.scene,
                scenes: context.read<MapBloc>().stream.map(
                  (state) => state.scene,
                ),
                effects: context.read<MapBloc>().effects,
                onEvent: context.read<MapBloc>().add,
              ),
              dispose: (binding) => unawaited(binding.close()),
              child: MapRoute.page.builder(data),
            ),
          ),
        ),
      ),
      path: '/',
      initial: true,
    ),
  ];
}
