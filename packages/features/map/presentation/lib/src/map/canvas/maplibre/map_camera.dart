import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/models/map_camera_focus.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Converts feature-level camera requests to native MapLibre updates.
final class MapCamera {
  MapLibreMapController? _controller;

  MapCameraFocus _focus = MapCameraFocus.places;
  bool _focusCommandPending = false;
  bool _needsFrame = true;
  MapLayer? _framedLayer;
  GeoPoint? _center;

  void attach(MapLibreMapController controller) {
    _controller = controller;
    resetStyle();
  }

  void close() => _controller = null;

  void requestFocus(MapCameraFocus focus, {bool waitForCommand = false}) {
    _focus = focus;
    _focusCommandPending = waitForCommand && focus != MapCameraFocus.free;
    _needsFrame = true;
  }

  Future<void> applyFocus(
    MapCameraFocus requested,
    MapLayer? layer,
    LocationFix? location,
  ) async {
    if (_focus != requested) return;
    _focusCommandPending = false;
    _needsFrame = true;
    await update(layer, location);
  }

  void resetStyle() {
    _focusCommandPending = false;
    _framedLayer = null;
    _center = null;
    _needsFrame = true;
  }

  Future<void> update(MapLayer? layer, LocationFix? location) async {
    final controller = _controller;
    if (_focusCommandPending || controller == null || controller.isDisposed) {
      return;
    }
    switch (_focus) {
      case MapCameraFocus.places:
        if (layer == null || (!_needsFrame && layer == _framedLayer)) return;
        _framedLayer = null;
        final outcome = await _fitPlaces(layer);
        if (identical(controller, _controller) &&
            outcome == MapCameraOutcome.applied &&
            _focus == MapCameraFocus.places) {
          _framedLayer = layer;
          _needsFrame = false;
        }
      case MapCameraFocus.userLocation:
        if (location == null || (!_needsFrame && location.point == _center)) {
          return;
        }
        _center = null;
        final outcome = await _centerOn(location, reframe: _needsFrame);
        if (identical(controller, _controller) &&
            outcome == MapCameraOutcome.applied &&
            _focus == MapCameraFocus.userLocation) {
          _center = location.point;
          _needsFrame = false;
        }
      case MapCameraFocus.free:
        return;
    }
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
    final completed = await _controller!.easeCamera(
      CameraUpdate.newLatLng(target),
      duration: const Duration(milliseconds: 800),
      interpolation: CameraAnimationInterpolation.linear,
    );
    return completed ? MapCameraOutcome.applied : MapCameraOutcome.cancelled;
  }

  Future<MapCameraOutcome> zoomBy(double amount) async {
    if (_controller == null || _controller!.isDisposed) {
      return MapCameraOutcome.cancelled;
    }
    return _animate(CameraUpdate.zoomBy(amount));
  }

  Future<MapCameraOutcome> _animate(CameraUpdate update) async {
    final completed = await _controller!.animateCamera(update);
    // iOS acknowledges an accepted animateCamera request with null.
    return completed == false
        ? MapCameraOutcome.cancelled
        : MapCameraOutcome.applied;
  }
}

enum MapCameraOutcome { applied, cancelled }
