import 'dart:async';
import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:injectable/injectable.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_render_session.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_render_status.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_renderer.dart';
import 'package:maplibre_gl/maplibre_gl.dart' show MapLibreMapController;

/// Retains the desired scene across native creation and style replacement.
@Injectable(as: MapRenderer)
final class MapLibreRenderer implements MapRenderer {
  MapScene _scene = const MapScene();
  MapLibreRenderSession? _session;

  @override
  Stream<MapRenderStatus> attach(MapLibreMapController controller) {
    unawaited(_session?.close());
    _session = MapLibreRenderSession(controller);
    return _session!.statuses;
  }

  @override
  void styleLoaded() => _session?.styleLoaded(_scene);

  @override
  void render(MapScene scene) {
    _scene = scene;
    _session?.render(scene);
  }

  @override
  void focus(MapScene scene) {
    _scene = scene;
    _session?.render(scene, refocus: true);
  }

  @override
  void zoomBy(double amount) => _session?.zoomBy(amount);

  @override
  void reloadStyle() => _session?.reloadStyle();

  @override
  Future<Result<String?>> placeAt(Point<double> point) =>
      _session?.placeAt(point) ?? Future.value(const Success(null));

  @override
  Future<void> close() async {
    await _session?.close();
    _session = null;
  }
}
