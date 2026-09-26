import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:map_presentation/src/map/models/map_render_status.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';

export 'package:map_presentation/src/map/models/map_render_status.dart';

/// Native rendering port consumed by the route-owned canvas binding.
abstract interface class MapRenderer {
  Stream<MapRenderStatus> get statuses;
  void render(MapScene scene);

  /// Explicitly recenters, including after the user manually pans the same scene.
  void focus(MapScene scene);
  void zoomBy(double amount);
  void reloadStyle();
  Future<Result<String?>> placeAt(Point<double> point);
}
