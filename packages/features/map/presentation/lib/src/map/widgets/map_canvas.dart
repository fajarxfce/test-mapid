import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/rendering/map_style.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapCanvas extends StatelessWidget {
  const MapCanvas({super.key});
  @override
  Widget build(BuildContext context) => MapLibreMap(
    styleString: MapStyle.liberty,
    initialCameraPosition: const CameraPosition(
      target: LatLng(-7.80, 110.37),
      zoom: 11,
    ),
    attributionButtonPosition: AttributionButtonPosition.bottomLeft,
    compassViewPosition: CompassViewPosition.bottomRight,
    compassViewMargins: const Point(16, 16),
    onMapCreated: (controller) =>
        context.read<MapBloc>().add(MapAttached(controller)),
    onStyleLoadedCallback: () =>
        context.read<MapBloc>().add(const MapStyleLoaded()),
    onMapClick: (point, coordinates) =>
        context.read<MapBloc>().add(MapTapped(point)),
  );
}
