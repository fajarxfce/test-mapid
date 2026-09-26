import 'dart:async';

import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/map_canvas_port.dart';
import 'package:map_presentation/src/map/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/models/map_canvas_status.dart';
import 'package:rxdart/rxdart.dart';

class FakeMapCanvas implements MapCanvasPort {
  final statusUpdates = BehaviorSubject.seeded(MapCanvasStatus.waitingForMap);
  final selectedIds = StreamController<String?>.broadcast();
  final layers = <MapLayer?>[];
  final locations = <LocationFix?>[];
  final focuses = <MapCameraFocus>[];
  final zooms = <double>[];
  int retries = 0;
  bool closed = false;
  @override
  Stream<MapCanvasStatus> get statuses => statusUpdates.stream;
  @override
  Stream<String?> get selections => selectedIds.stream;
  @override
  void showPlaces(MapLayer? layer) => layers.add(layer);
  @override
  void updateLocation(LocationFix? fix) => locations.add(fix);
  @override
  void focus(MapCameraFocus mode) => focuses.add(mode);
  @override
  void zoomBy(double amount) => zooms.add(amount);
  @override
  void retry() => retries++;
  @override
  Future<void> close() async {
    closed = true;
    await Future.wait([statusUpdates.close(), selectedIds.close()]);
  }
}
