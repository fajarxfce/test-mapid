import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/gestures/map_pan_gesture.dart';
import 'package:map_presentation/src/map/rendering/maplibre_renderer.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapCanvas extends StatelessWidget {
  const MapCanvas({super.key});
  @override
  Widget build(BuildContext context) => RawGestureDetector(
    excludeFromSemantics: true,
    gestures: {
      MapPanGestureObserver: MapPanGestureFactory(
        onPan: () => context.read<MapBloc>().add(const MapPanned()),
      ),
    },
    child: MapLibreMap(
      styleString: MapLibreRenderer.styleUrl,
      annotationOrder: const [],
      initialCameraPosition: const CameraPosition(
        target: LatLng(-7.80, 110.37),
        zoom: 11,
      ),
      attributionButtonPosition: AttributionButtonPosition.bottomLeft,
      compassViewPosition: CompassViewPosition.bottomRight,
      compassViewMargins: const Point(16, 16),
      onMapCreated: (controller) =>
          context.read<MapLibreRenderer>().attach(controller),
      onStyleLoadedCallback: () =>
          context.read<MapLibreRenderer>().styleLoaded(),
      onMapClick: (point, coordinates) =>
          context.read<MapBloc>().add(MapTapped(point)),
    ),
  );
}
