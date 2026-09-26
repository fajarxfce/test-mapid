import 'dart:math';

import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Converts feature-level camera requests to native MapLibre updates.
class MapLibreCamera {
  const MapLibreCamera(this._controller);
  final MapLibreMapController _controller;

  Future<MapCameraOutcome> focus(MapScene scene, {bool reframe = false}) async {
    switch (scene.focus) {
      case MapCameraFocus.places:
        if (scene.layer case final layer?) return _fitPlaces(layer);
      case MapCameraFocus.userLocation:
        if (scene.location case final location?) {
          return _centerOn(location, reframe: reframe);
        }
      case MapCameraFocus.free:
        break;
    }
    return MapCameraOutcome.applied;
  }

  Future<MapCameraOutcome> _fitPlaces(MapLayer layer) async {
    if (layer.places.isEmpty) return MapCameraOutcome.applied;
    if (layer.places.length == 1) {
      final point = layer.places.single.point;
      return _animate(
        CameraUpdate.newLatLngZoom(LatLng(point.latitude, point.longitude), 14),
      );
    }
    final latitudes = layer.places.map((place) => place.point.latitude);
    final longitudes = layer.places.map((place) => place.point.longitude);
    return _animate(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(latitudes.reduce(min), longitudes.reduce(min)),
          northeast: LatLng(latitudes.reduce(max), longitudes.reduce(max)),
        ),
        left: 48,
        right: 72,
        top: 64,
        bottom: 140,
      ),
    );
  }

  Future<MapCameraOutcome> _centerOn(
    LocationFix location, {
    required bool reframe,
  }) async {
    final target = LatLng(location.point.latitude, location.point.longitude);
    if (reframe) {
      return _animate(CameraUpdate.newLatLngZoom(target, 15));
    }
    // Android animateCamera uses flyTo, dipping zoom across tile boundaries on
    // every GPS fix and making labels blink (maplibre-native#2477). Following
    // changes only the center, with no flight or zoom excursion.
    final completed = await _controller.easeCamera(
      CameraUpdate.newLatLng(target),
      duration: const Duration(milliseconds: 800),
      interpolation: CameraAnimationInterpolation.linear,
    );
    return completed ? MapCameraOutcome.applied : MapCameraOutcome.cancelled;
  }

  Future<MapCameraOutcome> zoomBy(double amount) =>
      _animate(CameraUpdate.zoomBy(amount));

  Future<MapCameraOutcome> _animate(CameraUpdate update) async {
    final completed = await _controller.animateCamera(update);
    // iOS acknowledges an accepted animateCamera request with null.
    return completed == false
        ? MapCameraOutcome.cancelled
        : MapCameraOutcome.applied;
  }
}

enum MapCameraOutcome { applied, cancelled }
