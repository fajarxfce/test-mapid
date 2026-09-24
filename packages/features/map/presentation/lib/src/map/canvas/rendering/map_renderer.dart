import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_render_status.dart';
import 'package:maplibre_gl/maplibre_gl.dart' show MapLibreMapController;

/// A route-scoped renderer. Only attachment exposes the native SDK handle.
abstract interface class MapRenderer {
  /// Replaces the native target and observes its lifetime until detached.
  Stream<MapRenderStatus> attach(MapLibreMapController controller);
  void styleLoaded();
  void render(MapScene scene);

  /// Explicitly recenters, including after the user manually pans the same scene.
  void focus(MapScene scene);
  void zoomBy(double amount);
  void reloadStyle();
  Future<Result<String?>> placeAt(Point<double> point);
  Future<void> close();
}
