import 'dart:async';
import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_render_status.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_renderer.dart';
import 'package:maplibre_gl/maplibre_gl.dart' show MapLibreMapController;

class FakeMapRenderer implements MapRenderer {
  final attachments = <StreamController<MapRenderStatus>>[];
  final scenes = <MapScene>[];
  final focuses = <MapScene>[];
  final zooms = <double>[];
  int styleLoads = 0;
  int styleReloads = 0;
  bool closed = false;
  Future<Result<String?>> Function(Point<double>) pick = (_) async =>
      const Success('place-1');

  @override
  Stream<MapRenderStatus> attach(MapLibreMapController controller) {
    final statuses = StreamController<MapRenderStatus>();
    attachments.add(statuses);
    return statuses.stream;
  }

  @override
  void render(MapScene scene) => scenes.add(scene);
  @override
  void focus(MapScene scene) => focuses.add(scene);
  @override
  void styleLoaded() => styleLoads++;
  @override
  void reloadStyle() => styleReloads++;
  @override
  void zoomBy(double amount) => zooms.add(amount);
  @override
  Future<Result<String?>> placeAt(Point<double> point) => pick(point);
  @override
  Future<void> close() async {
    closed = true;
    for (final stream in attachments) {
      await stream.close();
    }
  }
}
