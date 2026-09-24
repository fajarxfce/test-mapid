import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_bloc.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_event.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_renderer.dart';
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
          child: MultiBlocProvider(
            providers: [
              BlocProvider<MapBloc>(
                create: (_) => _container<MapBloc>()
                  ..add(const MapLayerRequested())
                  ..add(const MapLocationRequested()),
              ),
              BlocProvider<MapCanvasBloc>(
                create: (context) =>
                    _container<MapCanvasBloc>(
                        param1: context.read<MapLibreRenderer>(),
                      )
                      ..add(const MapCanvasStarted())
                      ..add(
                        MapCanvasContentChanged(
                          context.read<MapBloc>().state.content,
                        ),
                      ),
              ),
            ],
            child: MapRoute.page.builder(data),
          ),
        ),
      ),
      path: '/',
      initial: true,
    ),
  ];
}
