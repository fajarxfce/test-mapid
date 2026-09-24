import 'dart:math';

import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Converts feature-level camera requests to native MapLibre updates.
class MapLibreCamera {
  const MapLibreCamera(this._controller);
  final MapLibreMapController _controller;

  Future<void> focus(MapScene scene, {bool reframe = false}) async {
    switch (scene.focus) {
      case MapCameraFocus.places:
        if (scene.content.layer case final layer?) await _fitPlaces(layer);
      case MapCameraFocus.userLocation:
        if (scene.content.location case final location?) {
          await _centerOn(location, reframe: reframe);
        }
      case MapCameraFocus.free:
        break;
    }
  }

  Future<void> _fitPlaces(MapLayer layer) async {
    if (layer.places.isEmpty) return;
    if (layer.places.length == 1) {
      final point = layer.places.single.point;
      await _controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(point.latitude, point.longitude), 14),
      );
      return;
    }
    final latitudes = layer.places.map((place) => place.point.latitude);
    final longitudes = layer.places.map((place) => place.point.longitude);
    await _controller.animateCamera(
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

  Future<void> _centerOn(LocationFix location, {required bool reframe}) async {
    await _controller.animateCamera(
      reframe
          ? CameraUpdate.newLatLngZoom(
              LatLng(location.point.latitude, location.point.longitude),
              15,
            )
          : CameraUpdate.newLatLng(
              LatLng(location.point.latitude, location.point.longitude),
            ),
    );
  }

  Future<void> zoomBy(double amount) async {
    await _controller.animateCamera(CameraUpdate.zoomBy(amount));
  }
}
