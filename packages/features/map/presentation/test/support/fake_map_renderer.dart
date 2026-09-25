import 'dart:async';
import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';
import 'package:map_presentation/src/map/rendering/map_renderer.dart';

class FakeMapRenderer implements MapRenderer {
  final updates = StreamController<MapRenderStatus>.broadcast();
  final scenes = <MapScene>[];
  final focuses = <MapScene>[];
  final zooms = <double>[];
  int styleReloads = 0;
  bool closed = false;
  Future<Result<String?>> Function(Point<double>) pick = (_) async =>
      const Success('place-1');

  @override
  Stream<MapRenderStatus> get statuses => updates.stream;

  @override
  void render(MapScene scene) => scenes.add(scene);
  @override
  void focus(MapScene scene) => focuses.add(scene);
  @override
  void reloadStyle() => styleReloads++;
  @override
  void zoomBy(double amount) => zooms.add(amount);
  @override
  Future<Result<String?>> placeAt(Point<double> point) => pick(point);
  Future<void> close() async {
    closed = true;
    await updates.close();
  }
}
