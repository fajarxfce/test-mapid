import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_render_status.dart';

/// SDK-free rendering commands and status for the presentation Bloc.
abstract interface class MapRenderer {
  Stream<MapRenderStatus> get statuses;
  void render(MapScene scene);

  /// Explicitly recenters, including after the user manually pans the same scene.
  void focus(MapScene scene);
  void zoomBy(double amount);
  void reloadStyle();
  Future<Result<String?>> placeAt(Point<double> point);
}
