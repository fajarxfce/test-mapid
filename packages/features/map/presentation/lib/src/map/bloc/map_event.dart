import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

sealed class MapEvent {
  const MapEvent();
}

final class MapLayerRequested extends MapEvent {
  const MapLayerRequested();
}

final class MapLocationRequested extends MapEvent {
  const MapLocationRequested({this.focus = true});
  final bool focus;
}

final class MapLocationSettingsRequested extends MapEvent {
  const MapLocationSettingsRequested();
}

/// All native scene mutations share one sequential event queue.
sealed class MapSceneEvent extends MapEvent {
  const MapSceneEvent();
}

final class MapAttached extends MapSceneEvent {
  const MapAttached(this.controller);
  final MapLibreMapController controller;
}

final class MapStyleLoaded extends MapSceneEvent {
  const MapStyleLoaded();
}

final class MapStyleTimedOut extends MapSceneEvent {
  const MapStyleTimedOut();
}

final class MapStyleReloadRequested extends MapSceneEvent {
  const MapStyleReloadRequested();
}

final class MapLayerReceived extends MapSceneEvent {
  const MapLayerReceived(this.result);
  final Result<MapLayer> result;
}

final class MapLocationReceived extends MapSceneEvent {
  const MapLocationReceived(this.result, {required this.focus});
  final Result<LocationFix> result;
  final bool focus;
}

final class MapTapped extends MapSceneEvent {
  const MapTapped(this.point);
  final Point<double> point;
}

final class MapSelectionCleared extends MapSceneEvent {
  const MapSelectionCleared();
}

final class MapLayerFocusRequested extends MapSceneEvent {
  const MapLayerFocusRequested();
}

final class MapZoomRequested extends MapSceneEvent {
  const MapZoomRequested(this.amount);
  final double amount;
}
