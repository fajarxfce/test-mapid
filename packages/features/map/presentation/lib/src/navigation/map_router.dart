import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/canvas/map_canvas_binding.dart';
import 'package:map_presentation/src/map/canvas/maplibre/maplibre_adapter.dart';
import 'package:map_presentation/src/navigation/map_router.gr.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class MapRouter {
  MapRouter(this._container);
  final GetIt _container;
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MapRoute.page.copyWith(
        builder: (data) => RepositoryProvider<MapLibreAdapter>(
          create: (_) => _container<MapLibreAdapter>(),
          dispose: (renderer) => unawaited(renderer.close()),
          child: BlocProvider<MapBloc>(
            create: (context) => _container<MapBloc>()
              ..add(const MapLayerRequested())
              ..add(const MapLocationRequested()),
            child: RepositoryProvider<MapCanvasBinding>(
              lazy: false,
              create: (context) => MapCanvasBinding(
                canvas: context.read<MapLibreAdapter>(),
                initialLayer: context.read<MapBloc>().state.layer,
                initialLocation: context.read<MapBloc>().state.location,
                layers: context.read<MapBloc>().stream.map(
                  (state) => state.layer,
                ),
                locations: context.read<MapBloc>().stream.map(
                  (state) => state.location,
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
