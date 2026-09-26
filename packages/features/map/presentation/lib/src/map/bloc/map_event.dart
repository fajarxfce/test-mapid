import 'dart:math';

import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/models/map_render_status.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';
import 'package:map_presentation/src/map/models/place_details.dart';

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

final class MapRenderStatusChanged extends MapEvent {
  const MapRenderStatusChanged(this.status);
  final MapRenderStatus status;
}

final class MapStyleReloadRequested extends MapEvent {
  const MapStyleReloadRequested();
}

final class MapTapped extends MapEvent {
  const MapTapped(this.point);
  final Point<double> point;
}

final class MapPlacePicked extends MapEvent {
  const MapPlacePicked(this.id, {required this.layer, required this.selection});
  final String? id;
  final MapLayer? layer;
  final PlaceDetails? selection;
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
