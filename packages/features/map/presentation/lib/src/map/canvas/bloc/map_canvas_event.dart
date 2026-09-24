import 'dart:math';

import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/models/map_content.dart';

sealed class MapCanvasEvent {
  const MapCanvasEvent();
}

final class MapCanvasPanned extends MapCanvasEvent {
  const MapCanvasPanned();
}

final class MapCanvasStarted extends MapCanvasEvent {
  const MapCanvasStarted();
}

final class MapCanvasStyleReloadRequested extends MapCanvasEvent {
  const MapCanvasStyleReloadRequested();
}

final class MapCanvasContentChanged extends MapCanvasEvent {
  const MapCanvasContentChanged(this.content);
  final MapContent content;
}

final class MapCanvasTapped extends MapCanvasEvent {
  const MapCanvasTapped(this.point);
  final Point<double> point;
}

final class MapCanvasSelectionCleared extends MapCanvasEvent {
  const MapCanvasSelectionCleared();
}

final class MapCanvasFocusRequested extends MapCanvasEvent {
  const MapCanvasFocusRequested(this.focus);
  final MapCameraFocus focus;
}

final class MapCanvasZoomRequested extends MapCanvasEvent {
  const MapCanvasZoomRequested(this.amount);
  final double amount;
}
