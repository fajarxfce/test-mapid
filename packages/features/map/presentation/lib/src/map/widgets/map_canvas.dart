import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_bloc.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_event.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_style.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapCanvas extends StatelessWidget {
  const MapCanvas({super.key});
  @override
  Widget build(BuildContext context) => Listener(
    onPointerMove: (_) =>
        context.read<MapCanvasBloc>().add(const MapCanvasPanned()),
    child: MapLibreMap(
      styleString: MapStyle.liberty,
      annotationOrder: const [],
      annotationConsumeTapEvents: const [],
      initialCameraPosition: const CameraPosition(
        target: LatLng(-7.80, 110.37),
        zoom: 11,
      ),
      attributionButtonPosition: AttributionButtonPosition.bottomLeft,
      compassViewPosition: CompassViewPosition.bottomRight,
      compassViewMargins: const Point(16, 16),
      onMapCreated: (controller) =>
          context.read<MapCanvasBloc>().add(MapCanvasAttached(controller)),
      onStyleLoadedCallback: () =>
          context.read<MapCanvasBloc>().add(const MapCanvasStyleLoaded()),
      onMapClick: (point, coordinates) =>
          context.read<MapCanvasBloc>().add(MapCanvasTapped(point)),
    ),
  );
}
