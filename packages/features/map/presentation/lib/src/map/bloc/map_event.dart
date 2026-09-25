import 'dart:math';

import 'package:map_presentation/src/map/models/map_scene.dart';

sealed class MapEvent {
  const MapEvent();
}

final class MapLayerRequested extends MapEvent {
  const MapLayerRequested();
}

final class MapLocationRequested extends MapEvent {
  const MapLocationRequested();
}

final class MapLocationActionRequested extends MapEvent {
  const MapLocationActionRequested();
}

final class MapPanned extends MapEvent {
  const MapPanned();
}

final class MapStarted extends MapEvent {
  const MapStarted();
}

final class MapStyleReloadRequested extends MapEvent {
  const MapStyleReloadRequested();
}

final class MapTapped extends MapEvent {
  const MapTapped(this.point);
  final Point<double> point;
}

final class MapSelectionCleared extends MapEvent {
  const MapSelectionCleared();
}

final class MapFocusRequested extends MapEvent {
  const MapFocusRequested(this.focus);
  final MapCameraFocus focus;
}

final class MapZoomRequested extends MapEvent {
  const MapZoomRequested(this.amount);
  final double amount;
}
