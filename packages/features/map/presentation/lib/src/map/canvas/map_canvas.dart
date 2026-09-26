import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/canvas/map_pan_observer.dart';
import 'package:map_presentation/src/map/canvas/maplibre/maplibre_adapter.dart';
import 'package:map_presentation/src/map/models/map_canvas_status.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapCanvas extends StatelessWidget {
  const MapCanvas({super.key});
  @override
  Widget build(BuildContext context) => BlocSelector<MapBloc, MapState, bool>(
    selector: (state) => state.canvasStatus != MapCanvasStatus.creationTimeout,
    builder: (context, mountNativeMap) => mountNativeMap
        ? RawGestureDetector(
            excludeFromSemantics: true,
            gestures: {
              MapPanGestureObserver: MapPanGestureFactory(
                onPan: () => context.read<MapBloc>().add(const MapPanned()),
              ),
            },
            child: MapLibreMap(
              styleString: MapLibreAdapter.styleUrl,
              annotationOrder: const [
                AnnotationType.circle,
                AnnotationType.symbol,
              ],
              annotationConsumeTapEvents: const [
                AnnotationType.circle,
                AnnotationType.symbol,
              ],
              initialCameraPosition: const CameraPosition(
                target: LatLng(-7.80, 110.37),
                zoom: 11,
              ),
              attributionButtonPosition: AttributionButtonPosition.bottomLeft,
              compassViewPosition: CompassViewPosition.bottomRight,
              compassViewMargins: const Point(16, 16),
              onMapCreated: (controller) =>
                  context.read<MapLibreAdapter>().attach(controller),
              onStyleLoadedCallback: () =>
                  context.read<MapLibreAdapter>().styleLoaded(),
              onMapClick: (point, coordinates) =>
                  context.read<MapLibreAdapter>().backgroundTapped(),
            ),
          )
        : const SizedBox.expand(),
  );
}
