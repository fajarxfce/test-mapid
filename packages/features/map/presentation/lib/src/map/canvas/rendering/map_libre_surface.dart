import 'dart:math';

import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_camera.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_layers.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_style.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_surface.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// One surface is bound to one controller for its entire lifetime.
class MapLibreSurface implements MapSurface {
  MapLibreSurface(this._controller)
    : _layers = MapLibreLayers(_controller),
      _camera = MapLibreCamera(_controller);
  final MapLibreMapController _controller;
  final MapLibreLayers _layers;
  final MapLibreCamera _camera;

  @override
  bool get isDisposed => _controller.isDisposed;
  @override
  Future<void> showPlaces(MapLayer layer) => _layers.showPlaces(layer);
  @override
  Future<void> showLocation(LocationFix location) =>
      _layers.showLocation(location);
  @override
  Future<String?> placeAt(Point<double> point) => _layers.placeAt(point);
  @override
  Future<void> fitPlaces(MapLayer layer) => _camera.fitPlaces(layer);
  @override
  Future<void> centerOn(LocationFix location) => _camera.centerOn(location);
  @override
  Future<void> zoomBy(double amount) => _camera.zoomBy(amount);
  @override
  Future<void> reloadStyle() => _controller.setStyle(MapStyle.liberty);
}
