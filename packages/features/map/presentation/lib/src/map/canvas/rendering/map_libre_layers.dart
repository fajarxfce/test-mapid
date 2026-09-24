import 'dart:math';
import 'dart:ui';

import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_geojson_encoder.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_style.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Owns style sources, layer paint, and native feature queries.
class MapLibreLayers {
  const MapLibreLayers(this._controller);
  final MapLibreMapController _controller;

  Future<void> showPlaces(MapLayer layer) => _replaceCircleData(
    sourceId: MapStyle.placesSource,
    layerId: MapStyle.placesLayer,
    data: placesGeoJson(layer),
    paint: const CircleLayerProperties(
      circleRadius: 9,
      circleColor: '#E77536',
      circleStrokeColor: '#FFFFFF',
      circleStrokeWidth: 2.5,
    ),
  );

  Future<void> showLocation(LocationFix location) => _replaceCircleData(
    sourceId: MapStyle.locationSource,
    layerId: MapStyle.locationLayer,
    data: locationGeoJson(location),
    paint: const CircleLayerProperties(
      circleRadius: 9,
      circleColor: '#1468D4',
      circleStrokeColor: '#FFFFFF',
      circleStrokeWidth: 3,
    ),
  );

  Future<void> _replaceCircleData({
    required String sourceId,
    required String layerId,
    required Map<String, dynamic> data,
    required CircleLayerProperties paint,
  }) async {
    final sources = await _controller.getSourceIds();
    if (_controller.isDisposed) return;
    if (sources.contains(sourceId)) {
      await _controller.setGeoJsonSource(sourceId, data);
    } else {
      await _controller.addGeoJsonSource(sourceId, data);
    }
    if (_controller.isDisposed) return;
    // Source and layer creation can fail independently. Reconcile both on retry.
    final layers = await _controller.getLayerIds();
    if (_controller.isDisposed) return;
    if (!layers.contains(layerId)) {
      await _controller.addCircleLayer(
        sourceId,
        layerId,
        paint,
        enableInteraction: false,
      );
    }
  }

  Future<String?> placeAt(Point<double> point) async {
    final features = await _controller.queryRenderedFeaturesInRect(
      Rect.fromCenter(center: Offset(point.x, point.y), width: 28, height: 28),
      [MapStyle.placesLayer],
      null,
    );
    for (final feature in features) {
      if (feature case {'properties': {'place_id': final String id}}) return id;
    }
    return null;
  }
}
